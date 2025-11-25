# SOLUSI GOOGLE SIGN IN ERROR - SHA-1 FINGERPRINT

## 🔴 MASALAH

Ketika login/register dengan Google, muncul error:
```
Login Gagal
Google Sign In tidak tersedia.

Kemungkinan penyebab:
• Google Play Services belum terinstall/update
• Menggunakan emulator tanpa Google Play
• Koneksi internet tidak stabil
```

## 🔍 PENYEBAB UTAMA

**SHA-1 Fingerprint tidak terdaftar di Firebase Console**

Setiap device (HP fisik) memiliki SHA-1 fingerprint yang unik. Jika teman Anda bisa login dengan Google di HP mereka tapi Anda tidak bisa di HP Anda, artinya:

- SHA-1 fingerprint HP teman Anda **sudah terdaftar** di Firebase
- SHA-1 fingerprint HP Anda **belum terdaftar** di Firebase

## ✅ SOLUSI LENGKAP

### Step 1: Dapatkan SHA-1 Fingerprint

Ada 2 cara:

#### Cara 1: Menggunakan Script (Otomatis)
```powershell
.\get_sha1_fingerprint.ps1
```

#### Cara 2: Manual
```powershell
cd android
./gradlew signingReport
```

### Step 2: Copy SHA-1 dari Output

Cari di output yang mirip seperti ini:

```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD  ← COPY INI
SHA-256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX  ← COPY INI JUGA
Valid until: ...
```

**PENTING:** Copy kedua SHA-1 dan SHA-256!

### Step 3: Tambahkan ke Firebase Console

1. Buka **Firebase Console**: https://console.firebase.google.com
2. Pilih **project Anda** (JAWARA)
3. Klik ⚙️ **Settings** (di sebelah Project Overview)
4. Pilih tab **Your apps**
5. Scroll ke bawah sampai ketemu Android app Anda
6. Klik **Add fingerprint**
7. **Paste SHA-1** yang sudah di-copy
8. Klik **Save**
9. Ulangi untuk **SHA-256**

### Step 4: Download google-services.json Baru

1. Masih di Firebase Console, scroll ke atas
2. Klik **Download google-services.json**
3. Replace file di: `android/app/google-services.json`

### Step 5: Rebuild Aplikasi

```powershell
flutter clean
flutter pub get
flutter run
```

## 📱 UNTUK MULTIPLE DEVICES

Jika ada beberapa HP yang digunakan untuk testing:

1. Lakukan Step 1-2 di **setiap HP**
2. **Tambahkan semua SHA-1** ke Firebase Console
3. Download google-services.json yang baru (sudah include semua SHA-1)
4. Rebuild aplikasi

## 🎯 QUICK CHECKLIST

- [ ] Jalankan `cd android && ./gradlew signingReport`
- [ ] Copy SHA-1 dan SHA-256
- [ ] Buka Firebase Console
- [ ] Tambahkan SHA-1 ke Project Settings > Your apps > Android
- [ ] Tambahkan SHA-256 juga
- [ ] Download google-services.json baru
- [ ] Replace android/app/google-services.json
- [ ] Jalankan `flutter clean && flutter pub get && flutter run`
- [ ] Test Google Sign In lagi

## ⚠️ TROUBLESHOOTING

### Masih error setelah tambahkan SHA-1?

1. **Pastikan SHA-1 yang benar:**
   - Cek lagi output dari `gradlew signingReport`
   - Pastikan copy dari bagian **Variant: debug**
   - Jangan sampai salah copy (ada spasi, kurang digit, dll)

2. **Pastikan google-services.json sudah di-replace:**
   - Cek timestamp file `android/app/google-services.json`
   - Pastikan file baru (setelah download dari Firebase)

3. **Clean dan rebuild:**
   ```powershell
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   flutter pub get
   flutter run
   ```

4. **Restart HP:**
   - Kadang Google Play Services perlu restart
   - Matikan HP, nyalakan lagi
   - Coba Google Sign In lagi

### Google Play Services perlu update?

1. Buka **Google Play Store**
2. Search "Google Play Services"
3. Jika ada tombol **Update**, klik
4. Tunggu selesai
5. Restart aplikasi

## 🔧 ALTERNATIVE: Jika Masih Tidak Bisa

Jika setelah semua step di atas masih tidak bisa, kemungkinan ada issue lain:

1. **Periksa koneksi internet:**
   - Pastikan stabil
   - Coba ganti WiFi/Mobile data

2. **Periksa Firebase Console:**
   - Pastikan Authentication > Sign-in method > Google sudah **Enabled**
   - Pastikan email support sudah diisi

3. **Periksa package name:**
   - Di `android/app/build.gradle`, cek `applicationId`
   - Harus sama dengan yang di Firebase Console

## 📞 BANTUAN LEBIH LANJUT

Jika masih ada masalah, jalankan command ini dan share output-nya:

```powershell
cd android
./gradlew signingReport > signing_report.txt
cd ..
```

Lalu kirim file `signing_report.txt` untuk debugging lebih lanjut.

---

**Last Updated:** November 25, 2025
**Status:** ✅ Tested and Working

