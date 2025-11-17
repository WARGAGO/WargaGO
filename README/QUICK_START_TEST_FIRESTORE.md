# 🔥 QUICK START GUIDE - TEST SAVE TO FIRESTORE

## ⚡ CEPAT! Langsung Test Sekarang

### 🎯 Test Tambah Data Warga (5 Menit)

#### Step 1: Run Aplikasi
```bash
flutter run
```

#### Step 2: Login
- Masukkan email & password admin
- Atau buat akun baru jika belum punya

#### Step 3: Navigasi ke Tambah Warga
```
Dashboard → Data Warga → Tab "Data Warga" → Tombol + (FAB)
```

#### Step 4: Isi Form (Minimal)
- **Nama Lengkap**: John Doe ⭐ (Required)
- **NIK**: 3505111512040002 ⭐ (Required)
- **Jenis Kelamin**: Laki-laki ⭐ (Required)
- Field lain boleh dikosongkan

#### Step 5: Submit
1. Scroll ke bawah
2. Klik tombol "Simpan" atau "Submit"
3. **Loading muncul** ⏳
4. **Dialog Success muncul** ✅

#### Step 6: Verifikasi di Firebase
1. Buka https://console.firebase.google.com/
2. Pilih project Anda
3. Klik "Firestore Database"
4. Lihat collection **`warga`**
5. Klik document yang baru dibuat
6. ✅ **Data tersimpan!**

---

### 🏠 Test Tambah Data Rumah (3 Menit)

#### Step 1: Navigasi ke Tambah Rumah
```
Dashboard → Data Warga → Tab "Data Rumah" → Tombol + (FAB)
```

#### Step 2: Isi Form
- **Alamat Rumah**: Jl. Merdeka No. 123 ⭐ (Required)
- **RT**: 01 (Optional)
- **RW**: 02 (Optional)
- **Kepala Keluarga**: Budi Santoso (Optional)
- **Jumlah Penghuni**: 5 (Optional)
- **Status Kepemilikan**: Milik Sendiri (Optional)

#### Step 3: Submit
1. Klik "Simpan Data"
2. **Loading muncul** ⏳
3. **Dialog Success muncul** ✅

#### Step 4: Verifikasi di Firebase
1. Buka Firebase Console
2. Lihat collection **`rumah`**
3. ✅ **Data tersimpan!**

---

## 🚨 TROUBLESHOOTING CEPAT

### ❌ Dialog Tidak Muncul?
**Solusi:**
1. Cek Flutter Console untuk error
2. Pastikan internet aktif
3. Cek Firestore rules allow write

### ❌ Error "Provider not found"?
**Solusi:**
1. Stop aplikasi
2. Run ulang (bukan hot reload!)
```bash
flutter run
```

### ❌ Data Tidak Muncul di Firebase?
**Solusi:**
1. Refresh halaman Firebase Console
2. Cek nama collection (warga/rumah)
3. Cek apakah ada error di console

---

## ✅ SUCCESS INDICATORS

### Tanda-tanda Berhasil:
- ✅ Loading indicator muncul saat save
- ✅ Dialog "Berhasil" muncul
- ✅ Dialog berisi text "...berhasil ditambahkan ke Firestore"
- ✅ Kembali ke halaman sebelumnya
- ✅ Data muncul di Firebase Console
- ✅ Field `createdAt` dan `updatedAt` ter-generate otomatis

---

## 📱 SCREENSHOT EXPECTED BEHAVIOR

### 1. Form Input
```
┌────────────────────────────────────┐
│  Tambah Warga Baru            [X]  │
├────────────────────────────────────┤
│                                    │
│  Langkah 1 dari 4                  │
│  ████░░░░░░░░░░░░░░░               │
│                                    │
│  Nama Lengkap *                    │
│  [John Doe              ]          │
│                                    │
│  NIK *                             │
│  [3505111512040002      ]          │
│                                    │
│  Jenis Kelamin *                   │
│  [Laki-laki         ▼]             │
│                                    │
│  ... more fields ...               │
│                                    │
│         [Lanjut >]                 │
└────────────────────────────────────┘
```

### 2. Loading State
```
┌────────────────────────────────────┐
│                                    │
│          ⏳ Loading...              │
│      Menyimpan data...             │
│                                    │
└────────────────────────────────────┘
```

### 3. Success Dialog
```
┌────────────────────────────────────┐
│  ✅ Berhasil                        │
├────────────────────────────────────┤
│                                    │
│  Data warga "John Doe" berhasil    │
│  ditambahkan ke Firestore.         │
│                                    │
│                         [OK]       │
└────────────────────────────────────┘
```

### 4. Firebase Console
```
Firestore Database
├── warga (collection)
│   ├── ABC123XYZ (document)
│   │   ├── nik: "3505111512040002"
│   │   ├── name: "John Doe"
│   │   ├── jenisKelamin: "Laki-laki"
│   │   ├── createdAt: November 16, 2025 at 10:30:45 AM
│   │   └── updatedAt: November 16, 2025 at 10:30:45 AM
│   └── ... more documents
└── rumah (collection)
    ├── XYZ789ABC (document)
    │   ├── alamat: "Jl. Merdeka No. 123"
    │   ├── rt: "01"
    │   ├── rw: "02"
    │   ├── createdAt: November 16, 2025 at 10:35:20 AM
    │   └── updatedAt: November 16, 2025 at 10:35:20 AM
    └── ... more documents
```

---

## 🔍 DEBUGGING TIPS

### Check Console Logs:

#### ✅ Expected Success Logs:
```
=== WargaService: createWarga ===
Creating warga: John Doe
✅ Warga created with ID: ABC123XYZ
```

#### ❌ Error Logs to Watch For:
```
❌ Error createWarga: [firebase_core/no-app]
❌ Error createWarga: [permission-denied]
❌ Error createWarga: [network-request-failed]
```

---

## 💡 PRO TIPS

### Tip 1: Use Real Data
Gunakan data yang realistis untuk testing lebih baik

### Tip 2: Check Both Collections
Pastikan test tambah warga DAN tambah rumah

### Tip 3: Monitor Firebase Console
Buka Firebase Console sebelum test untuk real-time monitoring

### Tip 4: Test Error Cases
Coba submit form kosong untuk test validasi

### Tip 5: Clear Console
Clear console sebelum test untuk melihat logs dengan jelas

---

## 🎯 CHECKLIST TEST

### Pre-Test:
- [ ] Firebase Console terbuka
- [ ] Flutter app running
- [ ] Console tab visible
- [ ] Internet connection active

### Test Warga:
- [ ] Form muncul dengan benar
- [ ] Validasi bekerja (coba submit kosong)
- [ ] Loading muncul saat submit
- [ ] Success dialog muncul
- [ ] Data di Firebase muncul
- [ ] Timestamp auto-generated

### Test Rumah:
- [ ] Form muncul dengan benar
- [ ] Validasi bekerja (coba submit kosong)
- [ ] Loading muncul saat submit
- [ ] Success dialog muncul
- [ ] Data di Firebase muncul
- [ ] Timestamp auto-generated

---

## 🎉 CONGRATULATIONS!

Jika semua checklist ✅, maka:

**🎊 DATA BERHASIL TERSIMPAN KE FIRESTORE! 🎊**

Anda sudah berhasil implement:
- ✅ Save warga to Firestore
- ✅ Save rumah to Firestore
- ✅ Clean Architecture
- ✅ Full validation
- ✅ Error handling
- ✅ Loading states
- ✅ Success confirmation

---

**Need Help?**
- Cek `README/FIX_DATA_NOT_SAVING_TO_FIRESTORE.md` untuk detail lengkap
- Cek `README/SUMMARY_FIX_FIRESTORE_SAVE.md` untuk summary
- Lihat troubleshooting section di atas

**Happy Testing! 🚀**

