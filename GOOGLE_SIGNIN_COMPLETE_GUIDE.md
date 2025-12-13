# 🔐 PANDUAN LENGKAP: Cara Buat Google Sign-In Berfungsi di App Kita

**Dibuat untuk:** Pemula sampai Advanced  
**Bahasa:** Sesimpel mungkin, kayak ngobrol sama temen  
**Target:** Biar Google Sign-In bisa dipake di semua HP orang  
**Update terakhir:** 13 Desember 2025

---

## 📋 **ISI PANDUAN INI**

1. [Penjelasan Masalahnya](#penjelasan-masalahnya) - Kenapa Google Sign-In gagal?
2. [Yang Harus Disiapkan Dulu](#yang-harus-disiapkan-dulu) - Persiapan sebelum mulai
3. [Bikin Kunci Khusus (Keystore)](#bikin-kunci-khusus-keystore) - Kunci untuk production
4. [Daftar Kunci ke Firebase](#daftar-kunci-ke-firebase) - Biar Firebase kenal
5. [Test di Komputer Kita](#test-di-komputer-kita) - Coba dulu sebelum deploy
6. [Otomatis Pakai GitHub](#otomatis-pakai-github) - Biar gak manual terus
7. [Kalau Ada Masalah](#kalau-ada-masalah) - Troubleshooting
8. [Tips Keamanan](#tips-keamanan) - Biar data aman

---

## 🤔 **PENJELASAN MASALAHNYA**

### **Ceritanya begini...**

Bayangin kamu punya aplikasi dengan fitur login pakai akun Google. Pas kamu test di emulator atau HP kamu sendiri → **JALAN LANCAR** ✅

Tapi pas kamu kasih ke temen atau upload ke App Distribution → **ERROR!** ❌  
Muncul pesan: *"Google Sign In tidak tersedia"*

**Kenapa bisa begitu?**

Ini seperti kamu punya 2 kunci rumah:
- **Kunci Biru** (Debug) → Untuk development, buat kamu sendiri
- **Kunci Merah** (Production) → Untuk orang lain pakai

Nah, **Google cuma kenal kunci biru kamu**. Makanya pas temen pakai (yang butuh kunci merah), Google bilang: *"Eh, sapa lu? Gue gak kenal!"*

### **Solusinya?**

Kita harus:
1. **Bikin kunci merah** (production keystore)
2. **Kasih tau Google** kunci merah kita (daftar SHA-1 ke Firebase)
3. **Pakai kunci merah** pas build APK
4. **Selesai!** Sekarang Google kenal kedua kunci kita ✅

### **Visualisasi:**

```
SEBELUM (❌ Gagal):
┌─────────────┐
│  APK Kamu   │ → Pakai kunci biru (debug)
└─────────────┘
       ↓
┌─────────────┐
│   Google    │ → "Gue cuma kenal kunci biru!"
└─────────────┘
       ↓
Temen download APK → Pakai kunci merah
       ↓
❌ DITOLAK! Google gak kenal kunci merah!


SESUDAH (✅ Berhasil):
┌─────────────┐
│  APK Kamu   │ → Pakai kunci merah (production)
└─────────────┘
       ↓
┌─────────────┐
│   Google    │ → "Oh iya, gue kenal kunci ini!"
└─────────────┘
       ↓
Temen download APK
       ↓
✅ BERHASIL LOGIN!
```

---

## 🎯 **YANG HARUS DISIAPKAN DULU**

Sebelum mulai, pastikan hal-hal ini sudah ada:

### **1. Project Firebase Sudah Setup** ✅

Kayak sudah punya akun dan project di Firebase Console.

**Cek:** Buka https://console.firebase.google.com/ → Ada project kamu?

### **2. App Android Sudah Terdaftar** ✅

App Flutter kamu sudah didaftarkan sebagai Android app di Firebase.

**Cek:** Firebase Console → Project Settings → Apps → Ada ikon Android?

### **3. Google Sign-In Sudah Aktif** ✅

Fitur Google Sign-In sudah dinyalakan di Firebase.

**Cek:** Firebase Console → Authentication → Sign-in method → Google ada toggle hijau?

### **4. Package Sudah Install** ✅

Di file `pubspec.yaml` ada:
```yaml
dependencies:
  google_sign_in: ^6.3.0
  firebase_auth: ^5.7.0
```

### **5. Tools Terinstall** ✅

- **Flutter SDK** → Udah ada kan? Coba: `flutter --version`
- **Java JDK** → Coba: `java -version` (minimal Java 11)
- **Editor** → Android Studio atau VS Code
- **Terminal** → PowerShell (Windows) atau Terminal (Mac)

**Kalau semua sudah ✅ → LANJUT!**

---

## 🔑 **BIKIN KUNCI KHUSUS (KEYSTORE)**

Ini bagian paling penting! Kita akan bikin "kunci merah" untuk production.

### **🎯 TUJUAN:**
Bikin file kunci (keystore) yang dipakai untuk "tanda tangan" APK production kita.

### **📝 STEP 1: Buka Terminal/PowerShell**

- **Windows:** Tekan `Win + X` → PowerShell
- **Mac:** Tekan `Cmd + Space` → ketik "Terminal"

### **📝 STEP 2: Masuk ke Folder Project**

```powershell
cd "C:\path\ke\project\flutter\kamu"
```

**Contoh:**
```powershell
cd "C:\Users\NamaKamu\Documents\my_app"
```

**Tips:** Kalau bingung pathnya, buka folder project di File Explorer, terus drag ke PowerShell!

### **📝 STEP 3: Bikin Keystore**

Copy-paste command ini, tapi **GANTI YA**:

```powershell
keytool -genkey -v `
  -keystore android/app/upload-keystore.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload `
  -storepass "Password123Aman!" `
  -keypass "Password123Aman!" `
  -dname "CN=Nama App, OU=Tim, O=Perusahaan, L=Jakarta, ST=DKI, C=ID"
```

**PENTING! Ganti yang ini:**

1. **`Password123Aman!`** → Ganti dengan password KUAT kamu!
   - Contoh: `MySuper$ecretP@ss2025`
   - **CATAT PASSWORD INI!** Simpan di tempat aman (Notes HP, password manager)
   - Kalau hilang, GG! Gak bisa update app di Play Store!

2. **`CN=Nama App`** → Ganti dengan nama app kamu
   - Contoh: `CN=Jawara App`

3. **`O=Perusahaan`** → Ganti dengan nama perusahaan/tim
   - Contoh: `O=Jawara Team`

**Tekan Enter!**

**Tunggu sebentar...**

**Output yang bagus:**
```
Generating 2,048 bit RSA key pair...
[Storing android/app/upload-keystore.jks]
```

**Cek:** Buka folder `android/app/` → Ada file `upload-keystore.jks`? ✅

### **📝 STEP 4: Ambil SHA-1 dari Keystore**

Sekarang kita perlu "sidik jari" dari kunci ini (SHA-1).

```powershell
keytool -list -v `
  -keystore android/app/upload-keystore.jks `
  -alias upload `
  -storepass "Password123Aman!" | Select-String "SHA1"
```

**GANTI:** `Password123Aman!` dengan password kamu tadi!

**Output:**
```
SHA1: 6D:9A:2E:23:97:E5:2E:BF:B5:B0:F9:8A:C0:8A:95:13:0D:BB:2B:BB
```

**📝 CATAT SHA-1 INI!** 

Copy ke Notepad, karena nanti dipakai di Firebase!

**Penjelasan SHA-1:**
- SHA-1 itu kayak "sidik jari" unik dari keystore kamu
- Setiap keystore punya SHA-1 berbeda
- Google pakai ini untuk kenal keystore kamu

### **📝 STEP 5: Bikin File Password**

Buat file baru: `android/key.properties`

**Isi file:**
```properties
storePassword=Password123Aman!
keyPassword=Password123Aman!
keyAlias=upload
storeFile=upload-keystore.jks
```

**GANTI:** `Password123Aman!` dengan password kamu!

**Cara buat:**
1. Buka VS Code / Android Studio
2. Klik kanan folder `android`
3. New File → `key.properties`
4. Copy-paste isi di atas
5. Save

**⚠️ FILE INI BERISI PASSWORD!**
- Jangan pernah commit ke Git!
- Nanti kita bakal gitignore

### **📝 STEP 6: Kasih Tau Flutter untuk Pakai Keystore**

Buka file: `android/app/build.gradle.kts`

Cari bagian ini (biasanya di atas):
```kotlin
plugins {
    id("com.android.application")
    // ...
}

android {
    // ...
}
```

**Ganti jadi:**

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.jawara"  // Sesuaikan package name kamu
    compileSdk = flutter.compileSdkVersion

    // ⚡ INI YANG PENTING! Kasih tau pakai keystore
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "Password123Aman!"  // GANTI password kamu!
            storeFile = file("upload-keystore.jks")
            storePassword = "Password123Aman!"  // GANTI password kamu!
        }
    }

    defaultConfig {
        applicationId = "com.example.jawara"  // Sesuaikan package name kamu
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ⚡ Pakai keystore yang tadi kita bikin
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

**GANTI:**
- `Password123Aman!` → Password kamu (2 tempat!)
- `com.example.jawara` → Package name app kamu

**Save file!**

### **📝 STEP 7: Gitignore File Penting**

Buka file `.gitignore` (di root project)

**Tambahkan di paling bawah:**

```gitignore
# ⚠️ JANGAN PERNAH UPLOAD FILE INI KE GITHUB!
# File keystore (kunci rahasia)
*.jks
*.keystore
android/app/upload-keystore.jks

# File password (super rahasia!)
android/key.properties
**/key.properties

# File base64 keystore (untuk CI/CD)
keystore_base64.txt
```

**Save!**

**Verify gitignore works:**

```bash
git check-ignore android/key.properties android/app/upload-keystore.jks
```

**Harus muncul:**
```
android/key.properties
android/app/upload-keystore.jks
```

✅ Berarti sudah di-ignore, aman!

---

## 🔥 **DAFTAR KUNCI KE FIREBASE**

Sekarang kita kasih tau Google/Firebase tentang "kunci merah" kita.

### **🎯 TUJUAN:**
Daftarkan SHA-1 production ke Firebase, biar Google kenal kunci kita.

### **📝 STEP 1: Ambil SHA-1 Debug Juga**

Kita butuh **2 SHA-1**:
- SHA-1 Debug (untuk development)
- SHA-1 Production (yang tadi kita bikin)

**Ambil SHA-1 Debug:**

```powershell
keytool -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey `
  -storepass android `
  -keypass android | Select-String "SHA1"
```

**Output:**
```
SHA1: E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82
```

**📝 CATAT SHA-1 DEBUG INI JUGA!**

Jadi sekarang kamu punya **2 SHA-1**:
1. **SHA-1 Debug** → E7:21:... (contoh)
2. **SHA-1 Production** → 6D:9A:... (yang tadi kita bikin)

### **📝 STEP 2: Buka Firebase Console**

1. **Buka browser**
2. **Ke:** https://console.firebase.google.com/
3. **Login** dengan akun Google kamu
4. **Pilih project** app kamu

### **📝 STEP 3: Masuk ke Settings**

1. **Klik icon ⚙️** (gear/roda gigi) di kiri atas
2. **Klik "Project Settings"**

### **📝 STEP 4: Pilih Android App**

1. **Scroll ke bawah** sampai ke bagian "Your apps"
2. **Klik Android app kamu** (yang ada logo Android hijau)

**Kalau belum ada app Android:**
- Klik "Add app" → Android
- Isi package name (contoh: `com.example.jawara`)
- Download `google-services.json`
- Taruh di `android/app/`

### **📝 STEP 5: Scroll ke "SHA certificate fingerprints"**

Cari section **"SHA certificate fingerprints"**

Mungkin sudah ada 1 SHA-1 (debug), atau kosong.

### **📝 STEP 6: Tambahkan SHA-1**

**Klik tombol "Add fingerprint"**

**Masukkan SHA-1 Debug:**
1. Paste SHA-1 debug yang tadi: `E7:21:C9:5E:...`
2. Klik "Save"

**Klik "Add fingerprint" lagi**

**Masukkan SHA-1 Production:**
1. Paste SHA-1 production yang tadi: `6D:9A:2E:23:...`
2. Klik "Save"

**Hasil akhir harus seperti ini:**

```
SHA certificate fingerprints:
┌─────────────────────────────────────────────────────────┐
│ 1. E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:...    │ (Debug)
│ 2. 6D:9A:2E:23:97:E5:2E:BF:B5:B0:F9:8A:C0:8A:95:...    │ (Production)
└─────────────────────────────────────────────────────────┘
```

**HARUS ADA 2!** Ini kunci utamanya! ✅

### **📝 STEP 7: Download google-services.json BARU**

Setelah tambah SHA-1, kita harus download file config baru!

1. **Masih di halaman yang sama**, scroll ke atas
2. **Cari tombol "google-services.json"**
3. **Klik untuk download**
4. **File baru akan ke-download**

**PENTING!** File baru ini berisi info 2 SHA-1!

### **📝 STEP 8: Replace File Lama**

1. **Buka folder project:** `android/app/`
2. **Hapus file lama:** `google-services.json`
3. **Taruh file baru** yang tadi di-download
4. **Rename** (kalau perlu) jadi `google-services.json`

**Verify:** Buka file `google-services.json`, cari kata `certificate_hash`:

**Harus ada 2 seperti ini:**
```json
"oauth_client": [
  {
    "android_info": {
      "certificate_hash": "e721c95e33521a0aba..."  ← Debug
    }
  },
  {
    "android_info": {
      "certificate_hash": "6d9a2e2397e52ebfb5..."  ← Production
    }
  }
]
```

✅ Kalau ada 2 → SEMPURNA!

### **📝 STEP 9: Enable Google Sign-In**

1. **Firebase Console** → **Authentication**
2. **Tab "Sign-in method"**
3. **Cari "Google"**
4. **Klik** → **Toggle jadi Enable (hijau)**
5. **Pilih email support** (email kamu)
6. **Klik "Save"**

---

## 💻 **TEST DI KOMPUTER KITA**

Sekarang kita test apakah setup kita berhasil!

### **🎯 TUJUAN:**
Build APK production dan test Google Sign-In works!

### **📝 STEP 1: Clean Project**

```bash
flutter clean
```

**Tunggu sebentar...**

**Penjelasan:** Ini kayak "bersih-bersih" file cache lama.

### **📝 STEP 2: Get Dependencies**

```bash
flutter pub get
```

**Tunggu download package...**

### **📝 STEP 3: Build APK Release**

```bash
flutter build apk --release
```

**Tunggu build... (bisa 2-5 menit)**

**Kalau berhasil:**
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (140MB)
```

**Kalau error:**
- Cek `build.gradle.kts` sudah benar?
- Cek password di `build.gradle.kts` sama dengan keystore?
- Cek file `upload-keystore.jks` ada di `android/app/`?

### **📝 STEP 4: Install di HP**

**Cara 1: Via Kabel USB**

1. Colok HP ke laptop
2. Aktifkan USB Debugging di HP
3. Run:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Cara 2: Via File Transfer**

1. Copy file APK ke HP (via WhatsApp, Bluetooth, dll)
2. Buka File Manager di HP
3. Tap APK
4. Install

### **📝 STEP 5: TEST GOOGLE SIGN-IN!**

1. **Buka app** di HP
2. **Klik tombol "Sign in with Google"**
3. **Pilih akun Google**
4. **Harus BERHASIL LOGIN!** ✅

**Kalau berhasil:** SELAMAT! Setup kamu BENAR! 🎉

**Kalau masih gagal:**
- Cek lagi Firebase Console → SHA-1 sudah 2?
- Cek `google-services.json` sudah yang baru?
- Tunggu 5-10 menit (kadang butuh waktu propagasi)
- Uninstall app, install lagi

---

## 🤖 **OTOMATIS PAKAI GITHUB (OPSIONAL)**

Bagian ini untuk yang mau setup CI/CD (automated build).

**Kalau belum butuh, skip aja dulu!**

### **🎯 TUJUAN:**
Setiap push code ke GitHub → Otomatis build APK → Upload ke App Distribution

### **📝 STEP 1: Encode Keystore ke Base64**

Kenapa? GitHub Actions gak bisa simpan file `.jks`, jadi kita ubah jadi text (base64).

```powershell
cd "C:\path\to\project"

$bytes = [System.IO.File]::ReadAllBytes("android\app\upload-keystore.jks")
$base64 = [System.Convert]::ToBase64String($bytes, [System.Base64FormattingOptions]::None)
$base64 | Set-Clipboard

Write-Host "✓ Base64 sudah di-copy ke clipboard!"
```

**Output:** Base64 string (panjang banget!) di clipboard kamu.

**JANGAN PASTE KE MANA-MANA!** Ini rahasia!

### **📝 STEP 2: Tambah ke GitHub Secrets**

1. **Buka GitHub Repository kamu**
2. **Settings** → **Secrets and variables** → **Actions**
3. **Klik "New repository secret"**

**Tambahkan 4 secrets:**

**Secret 1:**
- Name: `KEYSTORE_BASE64`
- Value: **Paste dari clipboard** (Ctrl+V)
- Add secret

**Secret 2:**
- Name: `KEYSTORE_PASSWORD`
- Value: `Password123Aman!` (password keystore kamu)
- Add secret

**Secret 3:**
- Name: `KEY_ALIAS`
- Value: `upload`
- Add secret

**Secret 4:**
- Name: `KEY_PASSWORD`
- Value: `Password123Aman!` (sama dengan password keystore)
- Add secret

**Penjelasan Secrets:**
- Secrets itu kayak "brankas" di GitHub
- Data di-encrypt, aman!
- Cuma GitHub Actions yang bisa akses

### **📝 STEP 3: Buat Workflow File**

Buat file: `.github/workflows/firebase-app-distribution.yml`

**Isi:**

```yaml
name: Build & Deploy APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      # Download code
      - name: Download code
        uses: actions/checkout@v4

      # Setup Java (untuk Android)
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      # Setup Flutter
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'
          channel: 'stable'

      # Download package
      - name: Download dependencies
        run: flutter pub get

      # Decode keystore dari base64
      - name: Buat keystore dari base64
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
        run: |
          echo "Membuat keystore..."
          echo "$KEYSTORE_BASE64" | tr -d '\n' | tr -d ' ' | base64 -d > android/app/upload-keystore.jks
          echo "✓ Keystore berhasil dibuat!"

      # Buat file key.properties
      - name: Buat key.properties
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          echo "Membuat key.properties..."
          cat > android/key.properties << EOF
          storePassword=$KEYSTORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF
          echo "✓ key.properties berhasil dibuat!"

      # Build APK
      - name: Build APK Release
        run: flutter build apk --release

      # Upload ke Firebase App Distribution
      - name: Upload ke App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.CREDENTIAL_FILE_CONTENT }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk
```

**Save file!**

### **📝 STEP 4: Push & Test**

```bash
git add .
git commit -m "Setup CI/CD untuk auto-build APK"
git push
```

**Check:**
1. Buka GitHub → Tab "Actions"
2. Lihat workflow running
3. Tunggu sampai selesai (biasanya 5-10 menit)
4. Kalau hijau ✅ → Berhasil!
5. APK otomatis ke-upload ke App Distribution

---

## 🧪 **KALAU ADA MASALAH**

### **❌ Problem 1: "Google Sign In tidak tersedia"**

**Penyebab:** SHA-1 production belum terdaftar atau salah.

**Solusi:**
1. ✅ Cek Firebase Console → SHA fingerprints → Harus ada 2!
2. ✅ Download `google-services.json` baru
3. ✅ Replace file lama di `android/app/`
4. ✅ `flutter clean` → `flutter build apk --release`
5. ✅ Test lagi

---

### **❌ Problem 2: Build gagal "Keystore not found"**

**Penyebab:** File keystore tidak ada atau path salah.

**Solusi:**
1. ✅ Cek file ada: `android/app/upload-keystore.jks`
2. ✅ Kalau gak ada, bikin lagi (ikuti Step 3 di atas)
3. ✅ Cek `build.gradle.kts`:
   ```kotlin
   storeFile = file("upload-keystore.jks")  // Path harus benar!
   ```

---

### **❌ Problem 3: "Wrong password" saat build**

**Penyebab:** Password di `build.gradle.kts` beda dengan password keystore.

**Solusi:**
1. ✅ Inget password keystore kamu
2. ✅ Cek `build.gradle.kts`:
   ```kotlin
   keyPassword = "Password123Aman!"  // Harus sama!
   storePassword = "Password123Aman!"  // Harus sama!
   ```
3. ✅ Ganti dengan password yang benar
4. ✅ Build lagi

---

### **❌ Problem 4: GitHub Actions error "base64: invalid input"**

**Penyebab:** Base64 string ada line breaks (enter).

**Solusi:**
1. ✅ Generate ulang base64:
   ```powershell
   $bytes = [System.IO.File]::ReadAllBytes("android\app\upload-keystore.jks")
   $base64 = [System.Convert]::ToBase64String($bytes, [System.Base64FormattingOptions]::None)
   $base64 | Set-Clipboard
   ```
   **PENTING:** Parameter `, [System.Base64FormattingOptions]::None` → Bikin single line!
   
2. ✅ Update GitHub Secret `KEYSTORE_BASE64` dengan base64 baru
3. ✅ Push lagi

---

## 🔒 **TIPS KEAMANAN**

### **📝 Yang JANGAN PERNAH Di-commit ke Git:**

```
❌ upload-keystore.jks         → Kunci rahasia!
❌ key.properties              → Ada password!
❌ keystore_base64.txt         → Base64 keystore!
❌ google-services.json        → (opsional, tergantung policy)
```

**Pastikan sudah di `.gitignore`!**

### **📝 Backup Keystore!**

**SUPER PENTING!**

Kalau keystore hilang → GG! Tidak bisa update app di Play Store selamanya!

**Backup ke:**
1. ✅ Google Drive / OneDrive (di-encrypt dulu!)
2. ✅ USB Flash drive (simpan di tempat aman)
3. ✅ External hard drive
4. ✅ Password manager (Bitwarden, 1Password)
5. ❌ **JANGAN** di Git/GitHub!

**Cara encrypt keystore:**
```bash
7z a -p"PasswordSuperKuat" upload-keystore.7z android/app/upload-keystore.jks
```
→ Bikin file `.7z` ter-encrypt dengan password

### **📝 Share ke Team Secara Aman**

**Kalau mau share keystore ke team:**

1. ✅ Encrypt file keystore (pakai 7zip/WinRAR dengan password)
2. ✅ Share file encrypted via Google Drive (private)
3. ✅ Share password via chat encrypted (WhatsApp/Telegram)
4. ✅ JANGAN share password di tempat yang sama dengan file!

---

## ✅ **CHECKLIST FINAL**

Sebelum deploy ke production, cek semua ini:

### **Setup Keystore:**
- [ ] ✅ Keystore production sudah dibuat
- [ ] ✅ SHA-1 production sudah dicatat
- [ ] ✅ Keystore sudah di-backup (minimal 2 tempat!)
- [ ] ✅ Password keystore sudah disimpan aman

### **Firebase:**
- [ ] ✅ SHA-1 debug sudah didaftarkan
- [ ] ✅ SHA-1 production sudah didaftarkan
- [ ] ✅ Total ada 2 SHA-1 di Firebase Console
- [ ] ✅ `google-services.json` baru sudah di-download
- [ ] ✅ File `google-services.json` sudah di-replace
- [ ] ✅ Google Sign-In sudah di-enable di Firebase

### **Build Config:**
- [ ] ✅ `build.gradle.kts` sudah dikonfigurasi
- [ ] ✅ Password di `build.gradle.kts` sudah benar
- [ ] ✅ `.gitignore` sudah diupdate
- [ ] ✅ File sensitif sudah ter-gitignore

### **Testing:**
- [ ] ✅ `flutter build apk --release` berhasil
- [ ] ✅ APK bisa di-install di HP
- [ ] ✅ Google Sign-In works di HP fisik
- [ ] ✅ Google Sign-In works via App Distribution

### **CI/CD (Opsional):**
- [ ] ✅ Base64 keystore sudah dibuat
- [ ] ✅ GitHub Secrets sudah ditambahkan (4 secrets)
- [ ] ✅ Workflow file sudah dibuat
- [ ] ✅ GitHub Actions build berhasil

**Kalau semua ✅ → SIAP PRODUCTION!** 🚀

---

## 🎉 **SELAMAT!**

Kalau kamu sudah sampai sini dan semua checklist ✅, berarti:

✅ Google Sign-In kamu sekarang works di semua HP!  
✅ APK production ter-sign dengan benar!  
✅ Setup kamu aman dan professional!  
✅ Siap upload ke Play Store!

**Sekarang app kamu bisa dipakai orang banyak dengan Google Sign-In yang lancar!**

---

## 📞 **BUTUH BANTUAN?**

### **Cek Dulu:**

1. **Firebase Console:**
   - Authentication → Users (ada yang berhasil login?)
   - Authentication → Sign-in method (Google hijau?)
   - Project Settings → SHA fingerprints (ada 2?)

2. **Build Settings:**
   - File keystore ada di `android/app/upload-keystore.jks`?
   - Password di `build.gradle.kts` benar?
   - File `google-services.json` yang baru?

3. **Logs:**
   - Buka Logcat (Android Studio)
   - Filter: "Google" atau "Auth"
   - Lihat error message detail

### **Masih Stuck?**

- Baca ulang bagian yang error
- Google error message yang spesifik
- Tanya di Discord/Slack team
- Stack Overflow (search dulu!)

---

**📅 Versi Dokumentasi:** 2.0 - Bahasa Super Mudah  
**📅 Update Terakhir:** 13 Desember 2025  
**✍️ Dibuat untuk:** Semua level (Pemula-Advanced)  
**🎯 Goal:** Biar Google Sign-In works tanpa pusing!

---

**💪 SEMANGAT! YOU CAN DO IT!**

Kalau ada yang kurang jelas, baca lagi pelan-pelan. Setiap langkah penting!

**Happy Coding!** 🚀

---

## 🔑 **SETUP KEYSTORE PRODUCTION**

### **Step 1: Buat Keystore File**

```powershell
cd "path/to/your/flutter/project"

keytool -genkey -v `
  -keystore android/app/upload-keystore.jks `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload `
  -storepass "YOUR_SECURE_PASSWORD" `
  -keypass "YOUR_SECURE_PASSWORD" `
  -dname "CN=Your App Name, OU=Development, O=Your Company, L=City, ST=State, C=ID"
```

**⚠️ PENTING:**
- Ganti `YOUR_SECURE_PASSWORD` dengan password yang kuat!
- Simpan password ini di tempat aman (password manager)
- JANGAN commit keystore ke Git!

**Output:** File `android/app/upload-keystore.jks` akan dibuat

---

### **Step 2: Dapatkan SHA-1 Production**

```powershell
keytool -list -v `
  -keystore android/app/upload-keystore.jks `
  -alias upload `
  -storepass "YOUR_SECURE_PASSWORD" | Select-String "SHA1"
```

**Output:**
```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**📝 CATAT SHA-1 INI!** Akan digunakan di Firebase Console.

---

### **Step 3: Buat File key.properties**

**File:** `android/key.properties`

```properties
storePassword=YOUR_SECURE_PASSWORD
keyPassword=YOUR_SECURE_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ KEAMANAN:**
- File ini berisi PASSWORD dalam plain text!
- WAJIB di-gitignore!
- JANGAN commit ke Git!

---

### **Step 4: Konfigurasi build.gradle.kts**

**File:** `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.yourapp"
    compileSdk = flutter.compileSdkVersion

    // Signing configurations
    signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "YOUR_SECURE_PASSWORD"
            storeFile = file("upload-keystore.jks")
            storePassword = "YOUR_SECURE_PASSWORD"
        }
    }

    defaultConfig {
        applicationId = "com.example.yourapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

**📝 NOTE:** Ganti `YOUR_SECURE_PASSWORD` dengan password Anda!

---

### **Step 5: Update .gitignore**

**File:** `.gitignore`

Tambahkan baris berikut:

```gitignore
# Keystore files (DO NOT COMMIT!)
*.jks
*.keystore
**/key.properties
android/key.properties
android/app/upload-keystore.jks
keystore_base64.txt
```

**Verify:**
```bash
git check-ignore android/key.properties android/app/upload-keystore.jks
```

Harus muncul kedua file → Berarti sudah di-ignore ✅

---

## 🔥 **SETUP FIREBASE CONSOLE**

### **Step 1: Dapatkan SHA-1 Debug**

```powershell
keytool -list -v `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -alias androiddebugkey `
  -storepass android `
  -keypass android | Select-String "SHA1"
```

**Output (contoh):**
```
SHA1: E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82
```

---

### **Step 2: Daftarkan SHA-1 ke Firebase**

1. **Buka Firebase Console:**
   ```
   https://console.firebase.google.com/
   ```

2. **Pilih project Anda**

3. **Klik icon ⚙️ (Settings) → Project Settings**

4. **Scroll ke "Your apps" → Pilih Android app**

5. **Scroll ke "SHA certificate fingerprints"**

6. **Klik "Add fingerprint"**

7. **Tambahkan 2 SHA-1:**
   - **Debug SHA-1** (dari Step 1)
   - **Production SHA-1** (dari keystore production)

8. **Klik "Save"**

**Contoh hasil akhir:**
```
SHA certificate fingerprints:
1. E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82  (Debug)
2. 6D:9A:2E:23:97:E5:2E:BF:B5:B0:F9:8A:C0:8A:95:13:0D:BB:2B:BB  (Production)
```

**⚠️ PENTING:**
- HARUS ada MINIMAL 2 SHA-1!
- 1 untuk debug (development)
- 1 untuk production (release APK)

---

### **Step 3: Download google-services.json Baru**

1. **Masih di Firebase Console** (halaman yang sama)

2. **Scroll ke atas**

3. **Klik tombol "google-services.json"** untuk download

4. **File baru akan di-download** (sekarang berisi 2 SHA-1!)

5. **Replace file lama** di: `android/app/google-services.json`

**Verify:** Buka `google-services.json`, cari `certificate_hash`:

```json
{
  "client": [
    {
      "oauth_client": [
        {
          "android_info": {
            "certificate_hash": "e721c95e33521a0aba74305850e60a376c1e7c82"
          }
        },
        {
          "android_info": {
            "certificate_hash": "6d9a2e2397e52ebfb5b0f98ac08a95130dbb2bbb"
          }
        }
      ]
    }
  ]
}
```

Harus ada **2 certificate_hash** ✅

---

### **Step 4: Enable Google Sign-In di Firebase**

1. **Firebase Console → Authentication**

2. **Sign-in method tab**

3. **Google** → Enable

4. **Project support email** → Pilih email Anda

5. **Save**

---

## 💻 **KONFIGURASI LOCAL DEVELOPMENT**

### **Step 1: Build Release APK**

```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

### **Step 2: Test di Device**

**Via ADB:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Via File Manager:**
1. Transfer APK ke device
2. Install manual
3. Test Google Sign-In

**Expected:** Google Sign-In berhasil! ✅

---

### **Step 3: Upload ke Firebase App Distribution**

**Via Firebase CLI:**
```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers"
```

**Via Firebase Console:**
1. Firebase Console → App Distribution
2. Upload APK
3. Add testers
4. Distribute

---

## 🤖 **SETUP GITHUB ACTIONS (CI/CD)**

### **Step 1: Generate Base64 Keystore**

```powershell
cd "path/to/your/flutter/project"

$bytes = [System.IO.File]::ReadAllBytes("android\app\upload-keystore.jks")
$base64 = [System.Convert]::ToBase64String($bytes, [System.Base64FormattingOptions]::None)
$base64 | Set-Clipboard

Write-Host "✓ Base64 di-copy ke clipboard!"
```

**Output:** Base64 string (single line, no line breaks) di clipboard

---

### **Step 2: Tambahkan GitHub Secrets**

1. **Buka GitHub Repository:**
   ```
   https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions
   ```

2. **Klik "New repository secret"**

3. **Tambahkan 4 secrets:**

   | Name | Value | Note |
   |------|-------|------|
   | `KEYSTORE_BASE64` | [Paste dari clipboard] | Base64 keystore |
   | `KEYSTORE_PASSWORD` | `YOUR_SECURE_PASSWORD` | Store password |
   | `KEY_ALIAS` | `upload` | Key alias |
   | `KEY_PASSWORD` | `YOUR_SECURE_PASSWORD` | Key password |

**⚠️ KEAMANAN:**
- Secrets di-encrypt oleh GitHub
- Tidak bisa dilihat setelah disimpan
- Hanya bisa diakses di GitHub Actions

---

### **Step 3: Update Workflow File**

**File:** `.github/workflows/firebase-app-distribution.yml`

```yaml
name: Build and Deploy Flutter Android App

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.0'
          channel: 'stable'

      - name: Get dependencies
        run: flutter pub get

      # Decode keystore from base64
      - name: Decode Keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
        run: |
          echo "Decoding keystore from base64..."
          echo "$KEYSTORE_BASE64" | tr -d '\n' | tr -d ' ' | base64 -d > android/app/upload-keystore.jks
          
          if [ -f android/app/upload-keystore.jks ]; then
            echo "✓ Keystore decoded successfully"
            echo "Size: $(ls -lh android/app/upload-keystore.jks | awk '{print $5}')"
          else
            echo "✗ Error: Keystore not created!"
            exit 1
          fi

      # Create key.properties
      - name: Create key.properties
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          echo "Creating key.properties..."
          cat > android/key.properties << EOF
          storePassword=$KEYSTORE_PASSWORD
          keyPassword=$KEY_PASSWORD
          keyAlias=$KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF
          echo "✓ key.properties created"

      # Build release APK
      - name: Build APK
        run: flutter build apk --release

      # Upload to Firebase App Distribution
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.CREDENTIAL_FILE_CONTENT }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk
```

**📝 NOTE:**
- `tr -d '\n'` → Remove newlines dari base64
- `tr -d ' '` → Remove spaces dari base64
- Fix untuk error "base64: invalid input"

---

### **Step 4: Push & Test**

```bash
git add .github/workflows/firebase-app-distribution.yml
git commit -m "ci: add keystore signing to GitHub Actions"
git push
```

**Check:**
1. Buka GitHub → Actions tab
2. Workflow harus running
3. Build harus SUCCESS ✅
4. APK auto-upload ke App Distribution

---

## 🧪 **TESTING & TROUBLESHOOTING**

### **Test Checklist:**

**Development (Debug):**
- [ ] `flutter run` works
- [ ] Google Sign-In works di emulator
- [ ] Google Sign-In works di physical device

**Production (Release):**
- [ ] `flutter build apk --release` success
- [ ] APK bisa diinstall manual
- [ ] Google Sign-In works setelah install manual
- [ ] Google Sign-In works via App Distribution

**CI/CD:**
- [ ] GitHub Actions build success
- [ ] APK auto-uploaded ke App Distribution
- [ ] Testers bisa download & install
- [ ] Google Sign-In works untuk semua tester

---

### **Common Errors & Solutions:**

#### **1. "Google Sign In tidak tersedia"**

**Cause:** SHA-1 production belum terdaftar di Firebase

**Solution:**
1. Check Firebase Console → SHA fingerprints
2. Pastikan ada 2 SHA-1 (debug + production)
3. Download google-services.json baru
4. Replace di `android/app/google-services.json`
5. Rebuild APK

---

#### **2. "base64: invalid input" di GitHub Actions**

**Cause:** Base64 string ada line breaks

**Solution:**
1. Generate ulang base64 dengan flag `None`:
   ```powershell
   $base64 = [System.Convert]::ToBase64String($bytes, [System.Base64FormattingOptions]::None)
   ```
2. Update GitHub Secret
3. Pastikan workflow pakai `tr -d '\n'`

---

#### **3. Build gagal: "Keystore not found"**

**Cause:** Path keystore salah atau file tidak ada

**Solution:**
1. Verify file ada: `android/app/upload-keystore.jks`
2. Check path di `build.gradle.kts`:
   ```kotlin
   storeFile = file("upload-keystore.jks")
   ```
3. Untuk local: file harus ada
4. Untuk CI/CD: keystore di-decode dari base64

---

#### **4. "SHA-1 mismatch" error**

**Cause:** APK di-build dengan keystore berbeda

**Solution:**
1. Verify SHA-1 dari APK:
   ```bash
   unzip -p app-release.apk META-INF/*.RSA | keytool -printcert
   ```
2. SHA-1 harus match dengan yang di Firebase
3. Rebuild dengan keystore yang benar

---

## 🔒 **SECURITY BEST PRACTICES**

### **Files yang JANGAN COMMIT:**

```gitignore
# Keystore files
*.jks
*.keystore
android/app/upload-keystore.jks

# Credentials
android/key.properties
keystore_base64.txt

# Firebase config (optional - tergantung policy)
android/app/google-services.json

# Environment variables
.env
.env.*
```

---

### **Password Management:**

**✅ DO:**
- Gunakan password manager (Bitwarden, 1Password)
- Store di GitHub Secrets (untuk CI/CD)
- Share via encrypted channel (team)
- Document di secure place (not Git!)

**❌ DON'T:**
- Hardcode di code
- Commit ke Git
- Share via email plain text
- Share via chat unencrypted

---

### **Keystore Backup:**

**⚠️ CRITICAL!**

Keystore tidak bisa di-regenerate! Jika hilang, tidak bisa update app di Play Store!

**Backup locations:**
1. ✅ Cloud storage (Google Drive, OneDrive) - encrypted!
2. ✅ External hard drive - multiple copies
3. ✅ USB flash drive - secure location
4. ✅ Password manager - as attachment
5. ❌ Git repository - NEVER!

---

### **Team Collaboration:**

**Share keystore securely:**
1. Encrypt file dengan password
2. Share encrypted file via secure channel
3. Share password separately via different channel
4. Document di team wiki (secure, not Git)

**Example:**
```bash
# Encrypt keystore
7z a -p"STRONG_PASSWORD" upload-keystore.7z android/app/upload-keystore.jks

# Share .7z file via Google Drive
# Share password via encrypted chat
```

---

## 📊 **MONITORING & MAINTENANCE**

### **Regular Checks:**

**Monthly:**
- [ ] Verify keystore backup masih ada & accessible
- [ ] Test Google Sign-In di production
- [ ] Check SHA-1 masih terdaftar di Firebase

**Before Release:**
- [ ] Test di multiple devices
- [ ] Verify SHA-1 production terdaftar
- [ ] Check google-services.json up to date

**After Release:**
- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Check authentication errors di Firebase Console
- [ ] Verify user feedback untuk sign-in issues

---

## 📝 **SUMMARY CHECKLIST**

### **Setup Awal (One Time):**
- [ ] Buat production keystore
- [ ] Dapatkan SHA-1 production
- [ ] Daftarkan SHA-1 ke Firebase Console
- [ ] Download google-services.json baru
- [ ] Update build.gradle.kts
- [ ] Setup .gitignore
- [ ] Backup keystore ke tempat aman

### **Setiap Build Production:**
- [ ] Verify google-services.json up to date
- [ ] `flutter build apk --release`
- [ ] Test APK di device
- [ ] Upload ke App Distribution / Play Store

### **Setup CI/CD (Optional):**
- [ ] Generate base64 keystore
- [ ] Tambahkan GitHub Secrets
- [ ] Update workflow file
- [ ] Test GitHub Actions build
- [ ] Verify auto-deploy works

---

## 🎯 **FINAL CHECKLIST**

**Sebelum Deploy ke Production:**

```
✅ Production keystore created & backed up
✅ SHA-1 production terdaftar di Firebase
✅ google-services.json punya 2 SHA-1
✅ Build.gradle.kts configured correctly
✅ .gitignore includes keystore & credentials
✅ APK built & tested manually
✅ Google Sign-In tested & works
✅ GitHub Actions configured (if using CI/CD)
✅ Team punya akses ke keystore (encrypted)
✅ Documentation complete
```

**Jika semua ✅ → READY FOR PRODUCTION!** 🚀

---

## 📞 **SUPPORT**

Jika ada masalah:

1. **Check Firebase Console:**
   - Authentication → Users (ada user login?)
   - Authentication → Sign-in method (Google enabled?)
   - Project Settings → SHA fingerprints (2 SHA-1?)

2. **Check Logs:**
   - Logcat (Android): `adb logcat | grep -i "google"`
   - Firebase Console → Analytics → DebugView
   - Crashlytics (jika ada crash)

3. **Verify Setup:**
   - SHA-1 match antara APK & Firebase
   - google-services.json up to date
   - Keystore valid & accessible

---

## 📚 **REFERENCES**

- [Firebase Authentication - Google Sign-In](https://firebase.google.com/docs/auth/android/google-signin)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Flutter - Build and release an Android app](https://flutter.dev/docs/deployment/android)
- [GitHub Actions - Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**📅 Document Version:** 1.0  
**📅 Last Updated:** 13 December 2025  
**✍️ Author:** Development Team  
**🔒 Classification:** Internal - Team Only

---

**🎉 CONGRATULATIONS!**

Dengan mengikuti dokumentasi ini, Google Sign-In Anda sekarang:
- ✅ Works di development & production
- ✅ Secured dengan production keystore
- ✅ Ready untuk App Distribution & Play Store
- ✅ Automated via CI/CD (optional)

**Happy Coding! 🚀**

