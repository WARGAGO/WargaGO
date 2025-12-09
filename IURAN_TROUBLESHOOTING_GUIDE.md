# 🔧 TROUBLESHOOTING: TAGIHAN TIDAK MUNCUL DI IURAN WARGA

## ❌ Problem: Tagihan yang dibuat admin tidak muncul di menu iuran warga

---

## 🔍 DIAGNOSTIK OTOMATIS

### Cara 1: Via Console Logs

1. **Run aplikasi** dalam debug mode
2. **Login** sebagai warga
3. **Buka** menu Iuran
4. **Check console** untuk output diagnostik

Console akan menampilkan:
```
======================================================================
🔍 IURAN WARGA DIAGNOSTICS - START
======================================================================

📌 STEP 1: Checking Authentication...
✅ User authenticated
   - UID: xxx
   - Email: xxx@gmail.com

📌 STEP 2: Checking User Document...
✅ User document exists
   - name: Pak Budi
   - email: budi@gmail.com
   - keluargaId: keluarga_001  ← PENTING!

📌 STEP 3: Checking Tagihan Collection...
   Total tagihan in collection: 5

   📄 Document: tagihan_001
      - keluargaId: keluarga_001
      - jenisIuranName: Iuran Sampah
      - nominal: 50000
      - status: Belum Dibayar
      - isActive: true

📌 STEP 4: Testing Query with User's keluargaId...
   Querying tagihan for keluargaId: keluarga_001
   Query result: 1 documents

✅ Found 1 tagihan for this user!
   📄 Iuran Sampah
      Status: Belum Dibayar
      Nominal: Rp 50000
      Periode: Desember 2025

======================================================================
🔍 IURAN WARGA DIAGNOSTICS - COMPLETE
======================================================================
```

### Cara 2: Via UI Dialog

1. **Jika muncul error** di halaman Iuran
2. **Klik tombol** "Lihat Detail Diagnostik"
3. **Dialog akan menampilkan**:
   - ✅/❌ User Login
   - ✅/❌ Has keluargaId
   - ✅/❌ Tagihan Found
   - Error details (jika ada)

---

## 🐛 KEMUNGKINAN MASALAH & SOLUSI

### Problem 1: ❌ User Tidak Punya keluargaId

**Gejala di Console**:
```
❌ PROBLEM: User has no keluargaId!
   Field: keluargaId
   Current value: null
```

**Cara Check**:
```
1. Buka Firebase Console
2. Firestore Database
3. Collection: users
4. Document: [user_id yang login]
5. Check field: keluargaId
```

**Solusi**:

#### Opsi A: Update via Firebase Console
```
1. Buka document user
2. Tambahkan field:
   keluargaId: "keluarga_001"  (sesuaikan dengan ID keluarga)
3. Save
4. Refresh app
```

#### Opsi B: Update via Firestore Rules (Auto)
Jika ingin auto-generate saat user register, update signup logic:

```dart
// Saat user register/create
await FirebaseFirestore.instance.collection('users').doc(userId).set({
  'name': name,
  'email': email,
  'keluargaId': keluargaId,  // ← TAMBAHKAN INI
  'role': 'warga',
  ...
});
```

---

### Problem 2: ❌ keluargaId Tidak Match

**Gejala di Console**:
```
❌ PROBLEM: No tagihan found for this keluargaId!
   - User's keluargaId: keluarga_001
   - Query: tagihan where keluargaId == "keluarga_001" AND isActive == true
```

**Cara Check**:
```
1. Lihat console output di STEP 2:
   User keluargaId: "keluarga_001"

2. Lihat console output di STEP 3:
   Tagihan documents:
   - keluargaId: "keluarga_002"  ← BEDA!

3. Check Firebase Console:
   - users/{userId}/keluargaId vs
   - tagihan/{tagihanId}/keluargaId
```

**Solusi**:

#### Opsi A: Update User keluargaId
```
Firebase Console → users → [user_id]
Update field keluargaId menjadi sama dengan tagihan
```

#### Opsi B: Update Tagihan keluargaId
```
Firebase Console → tagihan → [tagihan_id]
Update field keluargaId menjadi sama dengan user
```

**Contoh**:
```
User:
  keluargaId: "keluarga_001"

Tagihan:
  keluargaId: "keluarga_001"  ✅ MATCH!
```

---

### Problem 3: ❌ Tagihan isActive = false

**Gejala di Console**:
```
⚠️ WARNING: Found 2 inactive tagihan
   These will not appear in warga view

📌 STEP 4: Testing Query...
   Query result: 0 documents
```

**Cara Check**:
```
Firebase Console → tagihan → [tagihan_id]
Field: isActive = false
```

**Solusi**:
```
Update tagihan:
isActive: true  ← Ubah menjadi true
```

---

### Problem 4: ❌ Admin Belum Buat Tagihan

**Gejala di Console**:
```
❌ PROBLEM: No tagihan found in Firestore!
   Collection: tagihan
   Total documents: 0
```

**Solusi**:
```
1. Login sebagai admin
2. Menu Tagihan → Tambah Tagihan
3. Pilih:
   - Jenis Iuran
   - Keluarga (pastikan keluargaId benar!)
   - Nominal, Periode, dll
4. Save
5. Refresh app warga
```

---

### Problem 5: ❌ Collection Name Salah

**Gejala**:
- Console tidak ada error
- Tapi data tidak muncul

**Cara Check**:
```
Firebase Console → Firestore
Check nama collection:
✅ "tagihan" (lowercase, tanpa spasi)
❌ "Tagihan" (uppercase)
❌ "tagihan " (ada spasi)
```

**Solusi**:
```
Pastikan collection name EXACT: "tagihan"
```

---

## 📋 CHECKLIST LENGKAP

Sebelum report issue, pastikan sudah check:

### Data User:
- [ ] ✅ User sudah login
- [ ] ✅ User document exists di Firestore
- [ ] ✅ User document punya field `keluargaId`
- [ ] ✅ keluargaId bukan null/empty

### Data Tagihan:
- [ ] ✅ Collection `tagihan` ada di Firestore
- [ ] ✅ Ada minimal 1 document tagihan
- [ ] ✅ Tagihan punya field `keluargaId`
- [ ] ✅ Tagihan.keluargaId = User.keluargaId (EXACT MATCH!)
- [ ] ✅ Tagihan.isActive = true
- [ ] ✅ Tagihan.status ada ('Belum Dibayar', 'Lunas', 'Terlambat')

### App Configuration:
- [ ] ✅ IuranWargaProvider registered di main.dart
- [ ] ✅ Firebase initialized
- [ ] ✅ Firestore rules deployed (optional untuk testing)

---

## 🧪 CARA TEST MANUAL

### Test 1: Check Data di Firebase Console

```
1. Buka Firebase Console
2. Firestore Database

3. Collection: users
   Document: [user_yang_login]
   ✅ Catat keluargaId: "keluarga_001"

4. Collection: tagihan
   Documents: [list tagihan]
   ✅ Cari tagihan dengan keluargaId: "keluarga_001"
   ✅ Check isActive: true

5. Jika ada tagihan yang match:
   ✅ SEHARUSNYA muncul di app!
```

### Test 2: Create Test Data

```sql
-- Via Firebase Console, tambahkan:

Collection: users
Document ID: test_user_001
{
  "name": "Test User",
  "email": "test@test.com",
  "keluargaId": "test_keluarga_001",
  "role": "warga"
}

Collection: tagihan
Document ID: test_tagihan_001
{
  "keluargaId": "test_keluarga_001",
  "keluargaName": "Test Keluarga",
  "jenisIuranId": "test_iuran",
  "jenisIuranName": "Test Iuran",
  "nominal": 10000,
  "periode": "Test",
  "periodeTanggal": [Timestamp now],
  "status": "Belum Dibayar",
  "isActive": true,
  "createdAt": [Timestamp now]
}

-- Login dengan test@test.com
-- Buka menu Iuran
-- ✅ HARUS muncul 1 tagihan!
```

---

## 🔧 QUICK FIX COMMANDS

### Fix 1: Add keluargaId to User (Firebase Console)

```javascript
// Navigate to: users/[userId]
// Add field:
{
  keluargaId: "keluarga_001"  // Sesuaikan dengan ID keluarga
}
```

### Fix 2: Update Tagihan keluargaId (Firebase Console)

```javascript
// Navigate to: tagihan/[tagihanId]
// Update field:
{
  keluargaId: "keluarga_001"  // Sama dengan user.keluargaId
}
```

### Fix 3: Activate Tagihan

```javascript
// Navigate to: tagihan/[tagihanId]
// Update field:
{
  isActive: true
}
```

---

## 📞 CONTOH KASUS NYATA

### Kasus 1: User Baru Tidak Ada keluargaId

**Situasi**:
- Admin buat tagihan untuk "Keluarga Budi"
- User "Pak Budi" login
- Menu Iuran kosong

**Diagnosis**:
```
users/pak_budi_001/
  name: "Pak Budi"
  email: "budi@gmail.com"
  keluargaId: null  ❌ TIDAK ADA!
```

**Solusi**:
```
1. Firebase Console → users → pak_budi_001
2. Add field: keluargaId = "keluarga_budi_001"
3. Refresh app
4. ✅ Tagihan muncul!
```

---

### Kasus 2: Typo di keluargaId

**Situasi**:
- Admin buat tagihan dengan keluargaId: "keluarga_budi"
- User punya keluargaId: "keluarga-budi" (pakai dash)
- Menu Iuran kosong

**Diagnosis**:
```
Tagihan:
  keluargaId: "keluarga_budi"

User:
  keluargaId: "keluarga-budi"

❌ TIDAK MATCH! (beda karakter "-")
```

**Solusi**:
```
Option A: Update user.keluargaId jadi "keluarga_budi"
Option B: Update tagihan.keluargaId jadi "keluarga-budi"

Pilih salah satu yang konsisten!
```

---

### Kasus 3: Tagihan Inactive

**Situasi**:
- Admin buat tagihan
- Admin soft-delete tagihan (isActive = false)
- Menu Iuran kosong

**Diagnosis**:
```
tagihan/tagihan_001/
  keluargaId: "keluarga_001"  ✅
  status: "Belum Dibayar"     ✅
  isActive: false             ❌
```

**Solusi**:
```
Firebase Console → tagihan → tagihan_001
Update: isActive = true
```

---

## 🎯 GUARANTEED FIX

Jika semua checklist sudah ✅ tapi masih tidak muncul:

1. **Restart app** completely (kill & reopen)
2. **Clear app data** (Settings → Apps → App → Clear Data)
3. **Check Firestore rules** (might be blocking read)
4. **Check internet connection**
5. **Check Firebase Console** - is data really there?

---

## 📱 TESTING FLOW

```
┌────────────────────────────────────────────────────────┐
│ 1. Admin: Create Tagihan                              │
│    - Jenis: Iuran Sampah                              │
│    - Keluarga: Keluarga Budi                          │
│    - keluargaId: "keluarga_001"  ← CATAT INI!        │
└────────────────────────────────────────────────────────┘
                        ↓
┌────────────────────────────────────────────────────────┐
│ 2. Firebase Console: Check Data                        │
│    Collection: tagihan                                 │
│    ✅ Document created                                 │
│    ✅ keluargaId = "keluarga_001"                      │
│    ✅ isActive = true                                  │
└────────────────────────────────────────────────────────┘
                        ↓
┌────────────────────────────────────────────────────────┐
│ 3. Firebase Console: Check User                        │
│    Collection: users/[user_id]                         │
│    ✅ keluargaId = "keluarga_001"  ← HARUS SAMA!      │
└────────────────────────────────────────────────────────┘
                        ↓
┌────────────────────────────────────────────────────────┐
│ 4. App: Login & Open Iuran                            │
│    - Login as warga                                    │
│    - Navigate to Iuran menu                            │
│    - Check console logs                                │
│    - ✅ HARUS MUNCUL!                                  │
└────────────────────────────────────────────────────────┘
```

---

## 🆘 MASIH TIDAK MUNCUL?

Jika sudah check semua dan masih tidak muncul:

1. **Copy console output** (full diagnostics)
2. **Screenshot Firebase Console**:
   - users/[userId] document
   - tagihan/[tagihanId] document
3. **Screenshot app** (menu Iuran)
4. **Report dengan detail**:
   - User email
   - User keluargaId
   - Tagihan keluargaId
   - Console output
   - Screenshots

---

**File Created**: `IURAN_TROUBLESHOOTING_GUIDE.md`
**Debugger**: `lib/core/utils/iuran_debugger.dart`
**Updated**: `lib/features/warga/iuran/pages/iuran_warga_page.dart`

**Next**: Run app, check console logs, follow diagnostics!
