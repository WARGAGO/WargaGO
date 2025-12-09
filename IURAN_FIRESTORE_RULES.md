# FIRESTORE SECURITY RULES - IURAN WARGA
## Implementation Guide
### Date: December 8, 2025

---

## 📋 OVERVIEW

Dokumen ini berisi Firestore Security Rules yang diperlukan untuk fitur iuran warga. Rules ini memastikan:
- **Warga** hanya bisa READ & UPDATE tagihan keluarganya sendiri
- **Warga** bisa bayar iuran (update status tagihan)
- **Admin** punya akses penuh ke semua data
- **Security** mencegah unauthorized access dan data manipulation

---

## 🔐 FIRESTORE RULES

### Helper Functions (Global)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================================================
    // HELPER FUNCTIONS
    // ========================================================================
    
    // Check if user is signed in
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Check if user is admin
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Get user's keluarga ID
    function getUserKeluargaId() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.keluargaId;
    }
    
    // Check if user owns this keluarga
    function ownsKeluarga(keluargaId) {
      return isSignedIn() && getUserKeluargaId() == keluargaId;
    }
```

---

### Collection: `tagihan`

```javascript
    // ========================================================================
    // COLLECTION: tagihan
    // ========================================================================
    match /tagihan/{tagihanId} {
      
      // -------------------- READ --------------------
      // Warga dapat READ tagihan keluarganya sendiri
      // Admin dapat READ semua tagihan
      allow read: if isSignedIn() && (
        resource.data.keluargaId == getUserKeluargaId() ||
        isAdmin()
      );
      
      // -------------------- CREATE --------------------
      // Hanya admin yang bisa CREATE tagihan
      allow create: if isAdmin();
      
      // -------------------- UPDATE --------------------
      // Warga dapat UPDATE untuk pembayaran (field terbatas)
      // Admin dapat UPDATE semua field
      allow update: if isSignedIn() && (
        // Admin bisa update semua
        isAdmin() ||
        
        // Warga bisa update HANYA untuk pembayaran
        (
          // Harus tagihan keluarganya sendiri
          resource.data.keluargaId == getUserKeluargaId() &&
          
          // Status harus berubah ke 'Lunas'
          request.resource.data.status == 'Lunas' &&
          resource.data.status != 'Lunas' &&
          
          // Hanya field pembayaran yang boleh berubah
          request.resource.data.diff(resource.data).affectedKeys()
            .hasOnly(['status', 'tanggalBayar', 'metodePembayaran', 
                     'buktiPembayaran', 'catatan', 'updatedAt']) &&
          
          // Field kritis tidak boleh berubah
          request.resource.data.keluargaId == resource.data.keluargaId &&
          request.resource.data.jenisIuranId == resource.data.jenisIuranId &&
          request.resource.data.nominal == resource.data.nominal &&
          request.resource.data.kodeTagihan == resource.data.kodeTagihan
        )
      );
      
      // -------------------- DELETE --------------------
      // Hanya admin yang bisa DELETE
      allow delete: if isAdmin();
    }
```

**Penjelasan Rules `tagihan`:**

1. **READ**: 
   - Warga bisa baca tagihan keluarganya (`resource.data.keluargaId == getUserKeluargaId()`)
   - Admin bisa baca semua

2. **CREATE**: 
   - Hanya admin (via admin panel)

3. **UPDATE**:
   - **Admin**: Bisa update semua field
   - **Warga**: Bisa update HANYA untuk pembayaran dengan kondisi:
     - Harus tagihan keluarganya
     - Status berubah dari `!= 'Lunas'` ke `'Lunas'`
     - Hanya field pembayaran yang berubah (status, tanggalBayar, metodePembayaran, buktiPembayaran, catatan)
     - Field kritis TIDAK boleh berubah (keluargaId, jenisIuranId, nominal, kodeTagihan)

4. **DELETE**:
   - Hanya admin (soft delete via `isActive = false`)

---

### Collection: `keuangan`

```javascript
    // ========================================================================
    // COLLECTION: keuangan
    // ========================================================================
    match /keuangan/{keuanganId} {
      
      // -------------------- READ --------------------
      // Hanya admin yang bisa READ
      // Warga TIDAK bisa akses langsung
      allow read: if isAdmin();
      
      // -------------------- CREATE --------------------
      // INSERT otomatis via service (atomic transaction)
      // Allow if:
      // 1. User is signed in (warga bayar iuran)
      // 2. Type is 'pemasukan' and sourceType is 'iuran'
      // 3. OR user is admin
      allow create: if isSignedIn() && (
        // Admin bisa create semua
        isAdmin() ||
        
        // Warga bisa create HANYA untuk pembayaran iuran
        (
          request.resource.data.type == 'pemasukan' &&
          request.resource.data.sourceType == 'iuran' &&
          request.resource.data.keluargaId == getUserKeluargaId() &&
          request.resource.data.createdBy == request.auth.uid
        )
      );
      
      // -------------------- UPDATE --------------------
      // Hanya admin yang bisa UPDATE
      allow update: if isAdmin();
      
      // -------------------- DELETE --------------------
      // Hanya admin yang bisa DELETE
      allow delete: if isAdmin();
    }
```

**Penjelasan Rules `keuangan`:**

1. **READ**: 
   - Hanya admin (untuk privacy & security)

2. **CREATE**:
   - **Admin**: Bisa create semua jenis transaksi
   - **Warga**: Bisa create HANYA jika:
     - Type = 'pemasukan'
     - sourceType = 'iuran' (dari pembayaran iuran)
     - keluargaId sesuai dengan keluarga user
     - createdBy sesuai dengan user ID

3. **UPDATE & DELETE**:
   - Hanya admin

---

### Collection: `jenis_iuran`

```javascript
    // ========================================================================
    // COLLECTION: jenis_iuran
    // ========================================================================
    match /jenis_iuran/{jenisIuranId} {
      
      // Warga bisa READ (untuk melihat jenis iuran)
      allow read: if isSignedIn();
      
      // Hanya admin yang bisa CREATE, UPDATE, DELETE
      allow create, update, delete: if isAdmin();
    }
```

---

## 🚀 DEPLOYMENT

### 1. Backup Rules Saat Ini

```powershell
# Backup existing rules
firebase firestore:rules > firestore.rules.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')
```

### 2. Update File `firestore.rules`

Copy rules di atas ke file `firestore.rules` di root project.

### 3. Deploy Rules

```powershell
# Deploy rules
firebase deploy --only firestore:rules

# Verify deployment
firebase firestore:rules
```

---

## ✅ TESTING CHECKLIST

### Test sebagai Warga:

- [ ] ✅ Bisa READ tagihan keluarga sendiri
- [ ] ❌ TIDAK bisa READ tagihan keluarga lain
- [ ] ✅ Bisa UPDATE tagihan untuk pembayaran (status → Lunas)
- [ ] ❌ TIDAK bisa UPDATE field lain (nominal, jenisIuranId, dll)
- [ ] ❌ TIDAK bisa CREATE tagihan baru
- [ ] ❌ TIDAK bisa DELETE tagihan
- [ ] ✅ Bisa READ jenis_iuran
- [ ] ❌ TIDAK bisa READ keuangan langsung

### Test sebagai Admin:

- [ ] ✅ Bisa READ semua tagihan
- [ ] ✅ Bisa CREATE tagihan
- [ ] ✅ Bisa UPDATE semua field tagihan
- [ ] ✅ Bisa DELETE tagihan
- [ ] ✅ Bisa READ semua keuangan
- [ ] ✅ Bisa CREATE keuangan
- [ ] ✅ Bisa UPDATE keuangan
- [ ] ✅ Bisa DELETE keuangan

### Test Atomic Transaction (Pembayaran):

- [ ] ✅ Bayar iuran berhasil
- [ ] ✅ Tagihan.status = 'Lunas'
- [ ] ✅ Keuangan record created
- [ ] ✅ Jika salah satu gagal, semua rollback

---

## ⚠️ IMPORTANT NOTES

### 1. **Security Considerations**

```javascript
// ❌ JANGAN PAKAI INI (terlalu permissive):
allow update: if isSignedIn();

// ✅ PAKAI INI (specific & secure):
allow update: if isSignedIn() && (
  isAdmin() ||
  (ownsResource() && onlyAllowedFieldsChanged())
);
```

### 2. **Atomic Transaction Security**

Firestore batch/transaction akan **GAGAL** jika rules tidak allow salah satu operasi:

```dart
// Jika salah satu dari operasi ini tidak allowed by rules,
// SEMUA operasi akan ROLLBACK
final batch = firestore.batch();
batch.update(tagihanRef, {...});  // ← Harus allowed
batch.set(keuanganRef, {...});    // ← Harus allowed
await batch.commit();              // ← Gagal jika ada yang tidak allowed
```

### 3. **Helper Function `getUserKeluargaId()`**

Fungsi ini mengasumsikan structure:
```
users/{userId}/
  keluargaId: "keluarga123"
```

Pastikan field `keluargaId` ada di document user!

### 4. **Field Validation**

Rules di atas meng-enforce:
- Status hanya bisa berubah ke 'Lunas' (tidak bisa 'Lunas' → 'Belum Dibayar')
- Field kritis (nominal, jenisIuranId, keluargaId) tidak bisa diubah
- Hanya field pembayaran yang bisa diupdate oleh warga

---

## 🔄 ROLLBACK PLAN

Jika ada masalah setelah deploy:

```powershell
# Restore dari backup
firebase deploy --only firestore:rules --file firestore.rules.backup_YYYYMMDD_HHMMSS
```

---

## 📚 REFERENCES

- [Firestore Security Rules Docs](https://firebase.google.com/docs/firestore/security/get-started)
- [Rule Conditions](https://firebase.google.com/docs/firestore/security/rules-conditions)
- [Testing Rules](https://firebase.google.com/docs/firestore/security/test-rules-emulator)

---

**Pastikan test semua rules sebelum deploy ke production!**
