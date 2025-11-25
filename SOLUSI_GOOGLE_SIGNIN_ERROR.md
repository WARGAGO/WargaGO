# 🔴 SOLUSI CEPAT: Google Sign In Error

## MASALAH ANDA

Teman Anda bisa login dengan Google ✅  
Tapi Anda tidak bisa ❌

**Penyebab:** SHA-1 fingerprint HP Anda belum terdaftar di Firebase!

---

## ⚡ SOLUSI CEPAT (5 MENIT)

### 1️⃣ Dapatkan SHA-1 HP Anda

Buka **PowerShell** di folder project, lalu jalankan:

```powershell
cd android
./gradlew signingReport
```

**TUNGGU sampai selesai** (mungkin 1-2 menit pertama kali)

### 2️⃣ Copy SHA-1 dari Output

Cari yang seperti ini di output terminal:

```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
MD5: ...
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD  👈 COPY INI
SHA-256: XX:XX:...  👈 COPY INI JUGA
```

**SELECT dan COPY kedua nilai SHA-1 dan SHA-256!**

### 3️⃣ Tambahkan ke Firebase

1. Buka: https://console.firebase.google.com
2. Pilih project **JAWARA** Anda
3. Klik ⚙️ **Settings** (pojok kiri bawah)
4. Pilih tab **Your apps**
5. Scroll ke bawah, cari Android app Anda
6. Klik **"Add fingerprint"**
7. **PASTE SHA-1** yang tadi di-copy
8. Klik **Save**
9. **Ulangi** untuk SHA-256 (Add fingerprint lagi)

### 4️⃣ Download google-services.json Baru

Masih di Firebase Console:
1. Scroll ke atas
2. Klik **Download google-services.json**
3. **REPLACE** file ini: `android/app/google-services.json`

### 5️⃣ Rebuild App

```powershell
flutter clean
flutter pub get
flutter run
```

### 6️⃣ Test Google Sign In

Coba login dengan Google lagi! ✅

---

## 🎯 UNTUK TIM DENGAN BANYAK HP

### ✅ CARA PALING MUDAH (Setiap Orang Langsung Bisa Coba)

**Setiap anggota tim bisa langsung tambahkan SHA-1 sendiri:**

1. **Setiap orang** jalankan Step 1-2 di HP masing-masing
2. **Setiap orang** langsung tambahkan SHA-1 sendiri ke Firebase (Step 3)
   - Login ke Firebase Console dengan akun Google yang sama
   - Tambahkan SHA-1 HP masing-masing
3. **TIDAK PERLU** download google-services.json baru!
   - Firebase akan otomatis update di server
   - File google-services.json yang lama tetap bisa dipakai
4. **Langsung flutter run** dan coba!

**Catatan:** Firebase Console bisa diakses oleh semua anggota tim yang punya akses ke project. Jadi setiap orang bisa tambahkan SHA-1 sendiri tanpa perlu nunggu yang lain! 🎉

### 🔄 ALTERNATIF: Cara Kumpul Semua SHA-1 (Opsional)

Jika ingin lebih rapi, bisa juga kumpulkan dulu:

1. **Setiap orang** jalankan Step 1-2 di HP masing-masing
2. **Kumpulkan semua SHA-1** (kirim via chat)
3. **Satu orang** tambahkan SEMUA SHA-1 ke Firebase sekaligus
4. **Download google-services.json baru**
5. **Share file google-services.json** ke semua anggota tim
6. **Semua orang** replace file dan rebuild

**Tapi cara ini TIDAK WAJIB!** Cara pertama lebih cepat dan praktis.

---

## 🔑 AKSES FIREBASE CONSOLE UNTUK TIM

**Pertanyaan:** Apa semua anggota tim bisa akses Firebase Console?

**Jawaban:** 
- Jika project Firebase dibuat dengan **akun Google bersama** → Semua yang punya akses akun tersebut bisa login
- Jika project Firebase dibuat dengan **akun pribadi** → Hanya pemilik akun yang bisa akses

### Jika Hanya 1 Orang yang Punya Akses Firebase:

**Opsi 1: Tambahkan Anggota Tim ke Firebase Project**
1. Yang punya akses buka Firebase Console
2. Klik ⚙️ Settings → Users and permissions
3. Klik **Add member**
4. Masukkan email Google teman tim
5. Set role: **Editor** (biar bisa tambah SHA-1)
6. Klik **Add member**

Sekarang teman tim bisa login Firebase Console dan tambah SHA-1 sendiri!

**Opsi 2: Satu Orang yang Kelola (Manual)**
1. Teman kirim SHA-1 mereka via chat
2. Yang punya akses Firebase tambahkan semua SHA-1
3. Selesai! Tidak perlu share file apapun

**PENTING:** Setelah SHA-1 ditambahkan ke Firebase, **TIDAK PERLU** download ulang google-services.json! File yang lama tetap bisa dipakai karena Firebase update di server.

---

- Setiap HP punya SHA-1 **unik** (seperti sidik jari)
- SHA-1 HP teman Anda **sudah terdaftar** di Firebase
- SHA-1 HP Anda **belum terdaftar**
- Makanya teman bisa, Anda tidak bisa

**Solusi:** Tambahkan SHA-1 HP Anda ke Firebase!

---

## 🆘 MASIH ERROR?

### Cek 1: SHA-1 sudah benar?
- Pastikan copy dari bagian **"Variant: debug"**
- Jangan sampai ada yang kurang/lebih

### Cek 2: google-services.json sudah di-replace?
- Cek timestamp file `android/app/google-services.json`
- Harus file yang baru download dari Firebase

### Cek 3: Sudah rebuild?
```powershell
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

### Cek 4: Google Play Services di HP
- Buka **Play Store**
- Search **"Google Play Services"**
- Klik **Update** jika ada
- Restart HP

---

## 📞 BUTUH BANTUAN?

Jalankan command ini dan kirim outputnya:

```powershell
cd android
./gradlew signingReport > sha1_output.txt
cd ..
```

Lalu kirim file `sha1_output.txt`

---

**Dibuat:** 25 November 2025  
**Status:** ✅ Tested - Working

