# ============================================================================
# SOLUSI ERROR BUILD RELEASE APK - ML KIT R8 MISSING CLASSES
# ============================================================================

## 🔴 Error yang Terjadi:
```
ERROR: R8: Missing class com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
Missing class com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
Missing class com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
Missing class com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
```

## ✅ Solusi yang Diterapkan:

### 1. **ProGuard Rules Ditambahkan**
File: `android/app/proguard-rules.pro`

Rules yang ditambahkan:
- Keep Google ML Kit classes
- Keep ML Kit Text Recognition (semua bahasa)
- Keep ML Kit Face Detection
- Keep Firebase classes
- Keep Google Sign In

### 2. **Build Configuration Diperbarui**
File: `android/app/build.gradle.kts`

Perubahan pada `buildTypes.release`:
```kotlin
release {
    signingConfig = signingConfigs.getByName("debug")
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
}
```

## 📋 Langkah-Langkah Build Ulang:

### Opsi 1: Clean Build (Recommended)
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Opsi 2: Build Langsung
```bash
flutter build apk --release
```

### Opsi 3: Build dengan Verbose (Untuk Debugging)
```bash
flutter build apk --release --verbose
```

## 🎯 Yang Akan Terjadi:

1. **ProGuard rules** akan mencegah R8 menghapus class ML Kit
2. **Code shrinking** tetap aktif untuk mengurangi ukuran APK
3. **Resource shrinking** tetap aktif untuk menghapus resource yang tidak digunakan
4. **Build akan berhasil** tanpa error missing classes

## ⚠️ Catatan Penting:

1. **Ukuran APK**: Dengan keep rules untuk ML Kit, ukuran APK akan sedikit lebih besar (~5-10MB) karena class ML Kit tidak di-shrink
2. **Build Time**: Build pertama setelah perubahan akan lebih lama (~3-5 menit)
3. **Testing**: Pastikan test semua fitur ML Kit (OCR KTP, Face Detection) setelah build release

## 🔍 Jika Masih Error:

### Alternatif 1: Disable Minify (Sementara)
Edit `android/app/build.gradle.kts`:
```kotlin
release {
    isMinifyEnabled = false
    isShrinkResources = false
}
```

### Alternatif 2: Tambahkan Dependency Eksplisit
Edit `android/app/build.gradle.kts` di section `dependencies`:
```kotlin
dependencies {
    implementation("com.google.android.gms:play-services-mlkit-text-recognition:19.0.0")
    implementation("com.google.mlkit:face-detection:16.1.5")
}
```

## 📊 Status:
- ✅ ProGuard rules ditambahkan
- ✅ Build configuration diperbarui
- ⏳ Siap untuk build ulang

## 🚀 Eksekusi:
Jalankan command berikut untuk build APK release:
```bash
flutter clean && flutter pub get && flutter build apk --release
```

