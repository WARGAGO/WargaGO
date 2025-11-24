# ============================================================================
# SOLUSI ERROR GOOGLE SIGN IN - API Exception: 10
# ============================================================================

## 🔴 Error yang Terjadi:
```
PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:)
```

## ✅ SOLUSI SUDAH DITERAPKAN:

### 1. **Menambahkan Web Client ID (serverClientId)**
File: `lib/core/providers/auth_provider.dart`

**Sebelum:**
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // JANGAN tambahkan serverClientId untuk mobile-only!
);
```

**Sesudah:**
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  // Web Client ID dari Firebase Console untuk Google Sign In
  serverClientId: '693556950050-vp8tf6ib0a5vfsqik0m3lm46o1f0786o.apps.googleusercontent.com',
);
```

### 2. **Menambahkan Better Error Handling**
- ✅ Import `PlatformException` dari `flutter/services.dart`
- ✅ Handling khusus untuk error code `sign_in_failed`
- ✅ Handling untuk `network_error`
- ✅ Pesan error yang lebih informatif

### 3. **SHA-1 Certificate Verified**
✅ **SHA-1 Sudah Benar!**
- SHA-1 Anda: `E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82`
- SHA-1 di Firebase: `e721c95e33521a0aba74305850e60a376c1e7c82` (sama, hanya lowercase)

## 📋 Penyebab Error:

**Error Code 10** = `DEVELOPER_ERROR` / `API_NOT_AVAILABLE`

**Root Cause yang Ditemukan:**
1. ❌ **Tidak menggunakan Web Client ID (serverClientId)** di GoogleSignIn config
2. ✅ SHA-1 sudah benar (bukan masalah)
3. ✅ Package name sudah sesuai (com.example.jawara)
4. ✅ google-services.json sudah benar

## 🔍 VERIFIKASI KONFIGURASI:

### Berdasarkan `google-services.json`:
```
✅ Project ID: pbl-2025-35a1c
✅ Package Name: com.example.jawara
✅ Web Client ID: 693556950050-vp8tf6ib0a5vfsqik0m3lm46o1f0786o.apps.googleusercontent.com
✅ Android Client ID: 693556950050-nggmgi9gksor75efoi9obcqi79neckjh.apps.googleusercontent.com
✅ SHA-1: e721c95e33521a0aba74305850e60a376c1e7c82
```

### SHA-1 dari Gradle signingReport:
```
Debug:   E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82 ✅
Release: E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82 ✅
(Sama karena release menggunakan debug keystore)
```

## 🚀 LANGKAH TESTING:

### 1. Clean dan Rebuild
```bash
flutter clean
flutter pub get
flutter run --release
```

### 2. Test Google Sign In
1. Buka aplikasi
2. Klik tombol "Masuk dengan Google"
3. Pilih akun Google
4. Verifikasi login berhasil

## 📝 EXPECTED BEHAVIOR:

### Jika Berhasil:
```
=== GOOGLE SIGN IN ATTEMPT ===
✅ Google account selected: user@gmail.com
🔐 Signing in with Google credential...
✅ Firebase Auth successful!
Firebase UID: abc123...
🔍 Checking user in Firestore...
✅ User found/created!
🎉 GOOGLE SIGN IN BERHASIL!
```

### Jika Masih Error:
```
❌ GOOGLE SIGN IN PLATFORM ERROR ===
Error Code: sign_in_failed
Error Message: com.google.android.gms.common.api.ApiException: 10:
```

**Solusi Tambahan:**
1. Pastikan Google Play Services terinstall di device
2. Pastikan koneksi internet aktif
3. Coba logout dari Google di device, lalu login ulang
4. Clear cache aplikasi

## ⚠️ CATATAN PENTING:

### Kenapa Perlu Web Client ID?
Google Sign In untuk Firebase memerlukan **Web Client ID (serverClientId)** karena:
1. Firebase Auth menggunakan OAuth2 flow
2. Web Client ID digunakan untuk server-side verification
3. Tanpa ini, error code 10 akan muncul

### Android Client ID vs Web Client ID
- **Android Client ID**: Untuk native Android authentication
- **Web Client ID**: Untuk Firebase backend authentication ✅ (Yang kita gunakan)

## 🔍 TROUBLESHOOTING:

### Jika Error Tetap Muncul:

#### Cek 1: Google Play Services
```bash
# Di terminal Android device
adb shell pm list packages | grep google
```
Pastikan ada `com.google.android.gms`

#### Cek 2: Firebase Console
1. Buka: https://console.firebase.google.com
2. Project: pbl-2025-35a1c
3. ⚙️ Project Settings → Your apps
4. Pastikan SHA-1 tercantum:
   - `E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82`

#### Cek 3: Google Cloud Console
1. Buka: https://console.cloud.google.com
2. Pilih project: pbl-2025-35a1c
3. APIs & Services → Credentials
4. Pastikan OAuth 2.0 Client IDs ada:
   - Web client
   - Android client

## ✅ CHECKLIST PERBAIKAN:

- [x] Web Client ID ditambahkan ke GoogleSignIn config
- [x] PlatformException import ditambahkan
- [x] Better error handling implemented
- [x] SHA-1 certificate verified (sudah benar)
- [x] google-services.json verified (sudah benar)
- [x] Package name verified (sudah benar)
- [ ] Testing Google Sign In (belum ditest setelah perbaikan)
- [ ] Verifikasi error teratasi

## 🎯 NEXT STEPS:

1. **Rebuild aplikasi:**
   ```bash
   flutter clean
   flutter pub get
   flutter run --release
   ```

2. **Test Google Sign In:**
   - Coba login dengan akun Google
   - Verifikasi tidak ada error code 10
   - Verifikasi user berhasil dibuat/login

3. **Jika berhasil:**
   - Google Sign In akan berfungsi normal
   - User bisa login dengan akun Google
   - Data user tersimpan di Firestore

4. **Jika masih error:**
   - Check logs untuk detail error
   - Pastikan Google Play Services up to date
   - Coba dengan akun Google lain
   - Restart device

---

## 📊 STATUS PERBAIKAN:

✅ **Code Changes Applied:**
- Web Client ID configured
- Error handling improved
- PlatformException handling added

⏳ **Pending:**
- Testing setelah rebuild
- Verifikasi Google Sign In works

🔧 **Modified Files:**
- `lib/core/providers/auth_provider.dart`

---

**Catatan:** Error code 10 seharusnya sudah teratasi dengan penambahan Web Client ID. Silakan rebuild dan test aplikasi.

**Error Code 10** = `DEVELOPER_ERROR` / `API_NOT_AVAILABLE`

Artinya:
1. ❌ **SHA-1 Certificate Hash** belum ditambahkan ke Firebase Console
2. ❌ **OAuth Client ID** tidak cocok dengan aplikasi
3. ❌ **Package Name** tidak sesuai
4. ❌ **google-services.json** belum ter-update

## ✅ SOLUSI LENGKAP:

### STEP 1: Dapatkan SHA-1 Certificate Hash

#### Untuk DEBUG Build:
```bash
cd android
./gradlew signingReport
```

Atau gunakan keytool:
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Output yang dicari:
# SHA1: E7:21:C9:5E:33:52:1A:0A:BA:74:30:58:50:E6:0A:37:6C:1E:7C:82
```

#### Untuk RELEASE Build:
```bash
# Jika menggunakan debug key untuk release (seperti sekarang):
# SHA-1 sama dengan debug

# Jika sudah ada release keystore sendiri:
keytool -list -v -keystore "path/to/release.keystore" -alias your-key-alias
```

### STEP 2: Tambahkan SHA-1 ke Firebase Console

1. **Buka Firebase Console**: https://console.firebase.google.com
2. Pilih project: **pbl-2025-35a1c**
3. Klik **⚙️ Project Settings**
4. Scroll ke **Your apps** → pilih Android app
5. Klik **Add fingerprint**
6. Paste SHA-1 certificate yang didapat dari Step 1
7. Klik **Save**

### STEP 3: Download google-services.json Baru

1. Di Firebase Console, masih di halaman yang sama
2. Klik **Download google-services.json**
3. Replace file lama:
   ```
   android/app/google-services.json
   ```

### STEP 4: Verifikasi Konfigurasi

#### Cek Package Name
File: `android/app/build.gradle.kts`
```kotlin
defaultConfig {
    applicationId = "com.example.jawara"  // ✅ Harus sama dengan Firebase
}
```

#### Cek OAuth Client ID
File: `lib/core/providers/auth_provider.dart`
Pastikan menggunakan **Web Client ID** dari Firebase Console:
```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn(
  clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',  // ← Harus Web Client ID
).signIn();
```

### STEP 5: Rebuild Aplikasi

```bash
flutter clean
flutter pub get
flutter run --release
```

## 🔍 TROUBLESHOOTING:

### Masalah 1: SHA-1 Tidak Cocok
**Gejala:** Error code 10 tetap muncul setelah tambah SHA-1

**Solusi:**
1. Hapus semua SHA-1 fingerprint di Firebase Console
2. Tambahkan ulang SHA-1 yang benar
3. Download google-services.json baru
4. Flutter clean dan rebuild

### Masalah 2: Multiple OAuth Client
**Gejala:** Ada beberapa OAuth client di google-services.json

**Solusi:**
Pastikan menggunakan **Web Client ID (client_type: 3)**, bukan Android Client ID:
```json
{
  "client_id": "693556950050-vp8tf6ib0a5vfsqik0m3lm46o1f0786o.apps.googleusercontent.com",
  "client_type": 3  // ✅ Web Client ID
}
```

### Masalah 3: Package Name Berbeda
**Gejala:** Error 10 di release tapi debug work

**Solusi:**
1. Cek package name di `build.gradle.kts`
2. Cek di Firebase Console → Apps → Package name
3. Harus exact match, termasuk case-sensitive

## 📝 KONFIGURASI SAAT INI:

Berdasarkan `google-services.json` Anda:
```
Project ID: pbl-2025-35a1c
Package Name: com.example.jawara
Web Client ID: 693556950050-vp8tf6ib0a5vfsqik0m3lm46o1f0786o.apps.googleusercontent.com
Android Client ID: 693556950050-nggmgi9gksor75efoi9obcqi79neckjh.apps.googleusercontent.com
SHA-1 Terdaftar: e721c95e33521a0aba74305850e60a376c1e7c82
```

## 🎯 QUICK FIX:

### Opsi 1: Tambah SHA-1 untuk Release (RECOMMENDED)

1. Get SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. Copy SHA-1 dari output variant "release"

3. Tambahkan ke Firebase Console

4. Download google-services.json baru

5. Rebuild:
   ```bash
   flutter clean
   flutter run --release
   ```

### Opsi 2: Gunakan Debug Build untuk Testing

Jika hanya untuk testing, gunakan debug build yang sudah work:
```bash
flutter run --debug
```

## ✅ CHECKLIST:

- [ ] SHA-1 debug ditambahkan ke Firebase Console
- [ ] SHA-1 release ditambahkan ke Firebase Console  
- [ ] google-services.json ter-update
- [ ] Package name sesuai (com.example.jawara)
- [ ] Web Client ID digunakan di kode
- [ ] Flutter clean dilakukan
- [ ] App di-rebuild
- [ ] Google Sign In berhasil

## 🚀 LANGKAH SELANJUTNYA:

1. **Dapatkan SHA-1 certificate Anda**:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. **Tambahkan ke Firebase Console**

3. **Download google-services.json baru**

4. **Rebuild app**:
   ```bash
   flutter clean && flutter pub get && flutter run --release
   ```

## 📞 BANTUAN:

Jika masih error setelah langkah di atas, pastikan:
1. ✅ Google Sign In API enabled di Google Cloud Console
2. ✅ OAuth consent screen sudah dikonfigurasi
3. ✅ SHA-1 untuk debug DAN release sudah ditambahkan
4. ✅ google-services.json adalah versi terbaru

---

**Catatan Penting:**
- SHA-1 untuk debug key biasanya sama untuk semua developer
- SHA-1 untuk release key berbeda untuk setiap keystore
- Anda saat ini menggunakan debug key untuk release build, jadi SHA-1 sama
- Untuk production, sebaiknya buat release keystore sendiri

