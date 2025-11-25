# 🚀 STEP-BY-STEP: Firebase App Distribution untuk Google Sign In

## 🎯 TUJUAN

Agar **SEMUA TESTER** (30-40 orang) bisa pakai **Google Sign In** tanpa ribet SHA-1!

## ✅ KEUNTUNGAN

- ✅ **GRATIS** - tidak perlu bayar apapun
- ✅ **MUDAH** - setup cuma 30 menit
- ✅ **SEMUA ORANG BISA GOOGLE SIGN IN** - 100% work!
- ✅ **TRACKING** - bisa lihat siapa yang sudah install
- ✅ **UPDATE MUDAH** - upload APK baru tinggal 1 command

---

## 📋 STEP-BY-STEP

### STEP 1: Install Firebase CLI

Buka PowerShell dan jalankan:

```powershell
# Install Firebase CLI via npm
npm install -g firebase-tools

# Verifikasi instalasi
firebase --version
```

Jika belum punya Node.js, download dulu di: https://nodejs.org/

---

### STEP 2: Login ke Firebase

```powershell
firebase login
```

Browser akan terbuka, login dengan akun Google yang sama dengan Firebase project Anda.

---

### STEP 3: Init Firebase di Project

Di folder project Anda:

```powershell
cd "C:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025"

firebase init appdistribution
```

Pilih:
- **Select a default Firebase project:** Pilih project JAWARA Anda
- **What file should be used for App Distribution configuration:** Tekan Enter (default)

---

### STEP 4: Build APK Release

```powershell
flutter clean
flutter build apk --release
```

APK akan ada di: `build/app/outputs/flutter-apk/app-release.apk`

---

### STEP 5: Get Firebase App ID

1. Buka Firebase Console: https://console.firebase.google.com
2. Pilih project JAWARA
3. Klik ⚙️ Settings → Project settings
4. Scroll ke bawah, pilih Android app Anda
5. Copy **App ID** (format: `1:123456789:android:abcdef123456`)

---

### STEP 6: Upload APK ke App Distribution

```powershell
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk `
  --app "1:123456789:android:abcdef123456" `
  --groups "testers" `
  --release-notes "Testing build - Google Sign In enabled for all testers"
```

Ganti `1:123456789:android:abcdef123456` dengan App ID Anda!

**ATAU** upload manual:
1. Buka Firebase Console → App Distribution
2. Klik **Get started** (jika pertama kali)
3. Drag & drop file `app-release.apk`
4. Isi Release notes
5. Klik **Next**

---

### STEP 7: Tambahkan Tester

Di Firebase Console → App Distribution → Testers & Groups:

#### Cara 1: Tambah per Email
1. Klik **Add testers**
2. Masukkan email teman-teman (pisahkan dengan koma)
3. Klik **Add**

#### Cara 2: Import dari File
1. Buat file `testers.txt`:
   ```
   teman1@gmail.com
   teman2@gmail.com
   teman3@gmail.com
   ```
2. Upload file di Firebase Console

---

### STEP 8: Get SHA-1 dari App Distribution

**PENTING!** Ini yang membuat Google Sign In work untuk semua orang!

1. Di Firebase Console → App Distribution
2. Klik release yang baru di-upload
3. Copy **SHA-1 fingerprint** yang muncul

**ATAU** dapatkan via terminal:

```powershell
# Extract SHA-1 dari APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

---

### STEP 9: Tambahkan SHA-1 ke Firebase Auth

1. Firebase Console → Project Settings
2. Scroll ke Your apps → Android app
3. Klik **Add fingerprint**
4. Paste SHA-1 dari Step 8
5. Klik **Save**

**DONE!** Sekarang semua tester yang install dari App Distribution bisa pakai Google Sign In! ✅

---

### STEP 10: Kirim Invite ke Tester

Tester akan otomatis dapat email dari Firebase dengan subject:
**"You've been invited to test [App Name]"**

Email berisi:
- Link download App Tester app
- Link untuk accept invite
- Cara install aplikasi

---

### STEP 11: Panduan untuk Tester

Kirim panduan ini ke tester via WhatsApp/email:

```
=====================================
CARA INSTALL APLIKASI JAWARA
=====================================

1. CEK EMAIL
   - Buka email dari Firebase App Distribution
   - Subject: "You've been invited to test JAWARA"

2. INSTALL FIREBASE APP TESTER
   - Klik link di email
   - Install "Firebase App Tester" dari Play Store
   - Atau download langsung: 
     https://play.google.com/store/apps/details?id=com.google.firebase.appdistribution

3. ACCEPT INVITE
   - Buka Firebase App Tester app
   - Login dengan email yang di-invite
   - Klik "Accept" pada invite JAWARA

4. DOWNLOAD & INSTALL APLIKASI
   - Klik "Download" di Firebase App Tester
   - Install aplikasi JAWARA
   - Klik "Open"

5. LOGIN DENGAN GOOGLE
   - Klik "Sign in with Google"
   - Pilih akun Google Anda
   - SELESAI! Langsung bisa testing 🎉

CATATAN:
✅ Google Sign In PASTI BERHASIL untuk semua orang!
✅ Tidak perlu setting apapun!

Selamat testing! 🚀
=====================================
```

---

## 🔄 UPDATE APK (Jika Ada Perubahan)

Jika ada bug fix atau update fitur:

```powershell
# Build APK baru
flutter build apk --release

# Upload ke App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk `
  --app "YOUR_APP_ID" `
  --groups "testers" `
  --release-notes "Bug fixes: [list bug fixes here]"
```

Tester akan otomatis dapat notifikasi ada update baru!

---

## 📊 MONITORING

Di Firebase Console → App Distribution, Anda bisa lihat:
- ✅ Siapa yang sudah download
- ✅ Siapa yang sudah install
- ✅ Siapa yang belum accept invite
- ✅ Device apa yang dipakai
- ✅ Berapa lama waktu testing

---

## ❓ TROUBLESHOOTING

### Q: Tester tidak dapat email invite?
**A:** 
1. Cek spam folder
2. Re-send invite di Firebase Console
3. Pastikan email benar

### Q: Firebase App Tester tidak bisa download?
**A:**
1. Pastikan tester sudah login dengan email yang di-invite
2. Pastikan koneksi internet stabil
3. Clear cache Firebase App Tester

### Q: Google Sign In masih error?
**A:**
1. Pastikan SHA-1 dari App Distribution sudah ditambahkan ke Firebase Auth
2. Tester restart aplikasi
3. Tester re-install aplikasi

---

## 🎯 CHECKLIST

Sebelum invite tester:

- [ ] Firebase CLI terinstall
- [ ] Login ke Firebase
- [ ] APK berhasil di-build
- [ ] APK berhasil di-upload ke App Distribution
- [ ] SHA-1 dari App Distribution sudah ditambahkan ke Firebase Auth
- [ ] Tester sudah ditambahkan (email)
- [ ] Panduan untuk tester sudah disiapkan
- [ ] Siap monitor hasil testing!

---

## 💰 BIAYA

**GRATIS!** ✅

Firebase App Distribution free tier:
- Unlimited releases
- Unlimited testers
- Unlimited downloads

---

## 🚀 KESIMPULAN

Dengan Firebase App Distribution:

✅ **Setup sekali** (30 menit)
✅ **SEMUA TESTER** (30-40 orang atau lebih) bisa pakai Google Sign In
✅ **TIDAK PERLU** tambah SHA-1 per HP
✅ **GRATIS** selamanya
✅ **PROFESIONAL** - seperti distribusi app asli
✅ **MUDAH UPDATE** - tinggal upload APK baru

**Masalah SHA-1 fingerprint per HP = SOLVED!** 🎉

---

**Next:** Jalankan step-by-step di atas dan dalam 30 menit aplikasi Anda siap untuk testing dengan Google Sign In untuk SEMUA ORANG! 🚀

---

**Last Updated:** November 25, 2025  
**Status:** ✅ Ready to Implement

