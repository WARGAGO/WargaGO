# 🔒 FIRESTORE RULES UPDATE - BUKTI PEMBAYARAN IURAN

## ⚠️ PENTING: Update Firestore Security Rules

Error **permission-denied** terjadi karena Firestore Rules tidak mengizinkan warga untuk update tagihan. 

## 🔧 Solusi yang Diimplementasikan

### ✅ Approach: "Menunggu Verifikasi"

Sistem sekarang menggunakan flow 2-step:

1. **Warga submit bukti** → Status: "Menunggu Verifikasi"
2. **Admin verifikasi** → Status: "Lunas" + Create keuangan record

**Keuntungan:**
- ✅ Tidak perlu warga punya permission write ke keuangan
- ✅ Admin bisa review bukti pembayaran dulu
- ✅ Lebih aman (admin approval required)
- ✅ Audit trail lebih baik

---

## 📋 Update Firestore Rules

### 1. **Rules untuk Collection `tagihan`**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Tagihan Collection
    match /tagihan/{tagihanId} {
      
      // Read: Warga hanya bisa baca tagihan keluarganya
      allow read: if request.auth != null && 
                     (resource.data.keluargaId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.keluargaId ||
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      
      // Create: Hanya admin
      allow create: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      
      // Update: Warga bisa update HANYA untuk submit bukti pembayaran
      allow update: if request.auth != null && (
        // Admin bisa update semua
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
        // Warga bisa update HANYA field tertentu pada tagihan keluarganya
        (resource.data.keluargaId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.keluargaId &&
         // Field yang boleh diubah warga:
         request.resource.data.diff(resource.data).affectedKeys().hasOnly(['buktiPembayaran', 'metodePembayaran', 'tanggalBayar', 'updatedAt', 'status']) &&
         // Status hanya boleh diubah ke "Menunggu Verifikasi"
         (request.resource.data.status == 'Menunggu Verifikasi' || request.resource.data.status == resource.data.status))
      );
      
      // Delete: Hanya admin
      allow delete: if request.auth != null && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // ... rules lainnya
  }
}
```

### 2. **Rules untuk Collection `keuangan`**

```javascript
// Keuangan Collection
match /keuangan/{keuanganId} {
  // Read: Admin dan warga bisa baca data keluarganya
  allow read: if request.auth != null && (
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
    resource.data.keluargaId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.keluargaId
  );
  
  // Write: Hanya admin yang bisa create/update/delete keuangan
  allow write: if request.auth != null && 
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

---

## 🚀 Cara Update Rules

### Option 1: Firebase Console (Web)

1. Buka Firebase Console: https://console.firebase.google.com
2. Pilih project Anda
3. Klik **Firestore Database** di sidebar
4. Klik tab **Rules**
5. Copy-paste rules di atas
6. Klik **Publish**

### Option 2: Firebase CLI

```bash
# Edit file firestore.rules
nano firestore.rules

# Deploy rules
firebase deploy --only firestore:rules
```

---

## 📊 Flow Pembayaran yang Baru

```
┌─────────────────────────────────────────────────────────────┐
│ WARGA: Submit Bukti Pembayaran                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 1. Upload gambar ke Azure Blob Storage                      │
│    → Get permanent URL                                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Update Tagihan (Firestore)                               │
│    - status: "Menunggu Verifikasi"                          │
│    - buktiPembayaran: permanent URL                          │
│    - metodePembayaran: "Transfer Bank"                       │
│    - tanggalBayar: timestamp                                 │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ WARGA: Lihat status "Menunggu Verifikasi"                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ ADMIN: Review Bukti Pembayaran                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ ADMIN: Approve/Reject                                        │
│ IF APPROVE:                                                  │
│   - Update tagihan.status → "Lunas"                          │
│   - Create keuangan record (pemasukan)                       │
│ IF REJECT:                                                   │
│   - Update tagihan.status → "Ditolak"                        │
│   - Add catatan penolakan                                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ WARGA: Lihat status final ("Lunas" atau "Ditolak")          │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Testing Setelah Update Rules

### 1. Test sebagai Warga:
```
✅ Submit bukti pembayaran
✅ Status berubah ke "Menunggu Verifikasi"
✅ Bukti tersimpan dengan URL permanen
✅ Tidak bisa langsung ubah status ke "Lunas"
✅ Tidak bisa create keuangan record
```

### 2. Test sebagai Admin:
```
✅ Lihat semua tagihan "Menunggu Verifikasi"
✅ Review bukti pembayaran
✅ Approve → Status "Lunas" + Create keuangan
✅ Reject → Status "Ditolak" + Add catatan
```

---

## 🎯 Status Tagihan yang Valid

| Status | Description | Who can set |
|--------|-------------|-------------|
| **Belum Dibayar** | Tagihan baru dari admin | Admin |
| **Menunggu Verifikasi** | Warga sudah upload bukti | Warga |
| **Lunas** | Admin approve pembayaran | Admin |
| **Ditolak** | Admin reject bukti | Admin |
| **Terlambat** | Melewati jatuh tempo | System/Admin |

---

## 🔐 Security Considerations

### ✅ Yang Sudah Aman:

1. **Warga tidak bisa:**
   - Create tagihan sendiri
   - Ubah nominal tagihan
   - Langsung set status "Lunas"
   - Create keuangan record
   - Akses data keluarga lain

2. **Admin bisa:**
   - Full CRUD tagihan
   - Full CRUD keuangan
   - Approve/reject pembayaran
   - Lihat semua data

3. **URL Bukti:**
   - Permanent (tidak expired)
   - Public readable (untuk admin review)
   - Stored in Azure Blob Storage

---

## 📝 Update Dokumentasi

File yang sudah diupdate:
- ✅ `bukti_pembayaran_service.dart` - Status "Menunggu Verifikasi"
- ✅ `bayar_iuran_simple_page.dart` - Success message updated
- ✅ Dokumentasi Firestore Rules (file ini)

File yang perlu dibuat (untuk admin):
- [ ] `admin/iuran/verifikasi_pembayaran_page.dart` - Halaman approve/reject
- [ ] `admin/iuran/verifikasi_pembayaran_service.dart` - Service approve/reject

---

## 🚨 URGENT ACTIONS

### ✅ Sekarang (DONE):
1. ✅ Code sudah diupdate (status "Menunggu Verifikasi")
2. ✅ **FIRESTORE RULES DEPLOYED** ✅
3. ✅ Test flow warga submit bukti pembayaran
4. ✅ **FIXED: Admin stats counter untuk include "Menunggu Verifikasi"**

### Nanti:
4. 🔨 Buat halaman admin untuk verifikasi pembayaran
5. 🔨 Buat service admin approve/reject
6. 📱 Add notification untuk admin saat ada pembayaran baru

---

## 🐛 TROUBLESHOOTING

### Issue: Admin tidak melihat tagihan yang sudah dibayar

**Problem:**
Admin dashboard menampilkan "Total Tagihan: 0" padahal warga sudah submit bukti pembayaran.

**Root Cause:**
Query di `_loadTagihanStats()` tidak menghitung status "Menunggu Verifikasi".

**Solution:** ✅ FIXED
File `kelola_iuran_page.dart` sudah diupdate untuk include counter "Menunggu Verifikasi".

```dart
// BEFORE: Hanya hitung Belum Bayar dan Lunas
if (status == 'Belum Dibayar' || status == 'Terlambat') {
  belumBayar++;
} else if (status == 'Lunas') {
  lunas++;
}

// AFTER: Include Menunggu Verifikasi
if (status == 'Belum Dibayar' || status == 'Terlambat') {
  belumBayar++;
} else if (status == 'Menunggu Verifikasi') {
  menungguVerifikasi++; // ⭐ ADDED
} else if (status == 'Lunas') {
  lunas++;
}
```

**Files Updated:**
- ✅ `lib/features/admin/kelola_iuran/pages/kelola_iuran_page.dart`

---

**Updated:** December 9, 2025  
**Status:** ✅ Code Fixed, ⚠️ Firestore Rules Need Update  
**Priority:** 🔴 HIGH (Warga cannot submit payment without rules update)

