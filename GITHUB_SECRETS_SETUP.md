# GitHub Secrets Setup Guide

## Masalah yang Diperbaiki
Error: `No file or variants found for asset: .env` saat build APK di GitHub Actions.

## Solusi
Workflow sekarang otomatis membuat file `.env` dari GitHub Secrets sebelum build.

## Setup Required: GitHub Secrets

Anda perlu menambahkan secrets berikut di GitHub Repository:

### Cara Menambahkan Secrets:
1. Buka repository di GitHub
2. Pergi ke **Settings** → **Secrets and variables** → **Actions**
3. Klik **New repository secret**
4. Tambahkan secrets berikut:

### Secrets yang Dibutuhkan:

#### 1. FIREBASE_API_KEY_WEB
- **Name:** `FIREBASE_API_KEY_WEB`
- **Value:** API Key Firebase Web Anda
- Cara mendapatkan:
  - Buka Firebase Console
  - Project Settings → General
  - Scroll ke "Your apps" → Web app
  - Copy API Key

#### 2. TEST_EMAIL (Opsional)
- **Name:** `TEST_EMAIL`
- **Value:** Email untuk testing (contoh: `test@example.com`)
- Jika tidak diperlukan, bisa isi dengan string kosong atau email dummy

#### 3. TEST_PASSWORD (Opsional)
- **Name:** `TEST_PASSWORD`
- **Value:** Password untuk testing
- Jika tidak diperlukan, bisa isi dengan string kosong atau password dummy

#### 4. FIREBASE_APP_ID (Sudah Ada)
- Firebase App ID untuk App Distribution
- Format: `1:xxxxx:android:xxxxx`

#### 5. CREDENTIAL_FILE_CONTENT (Sudah Ada)
- Service Account JSON untuk Firebase App Distribution

## Verifikasi

Setelah menambahkan secrets:
1. Push commit apapun ke branch `main`, atau
2. Pergi ke **Actions** tab → Pilih workflow → Klik **Run workflow**
3. Workflow sekarang akan:
   - ✅ Membuat file `.env` otomatis
   - ✅ Build APK tanpa error
   - ✅ Upload ke Firebase App Distribution

## Alternative: Jika Tidak Butuh .env

Jika aplikasi tidak benar-benar membutuhkan file `.env` saat runtime, Anda bisa:
1. Hapus `.env` dari `pubspec.yaml` di bagian assets
2. Update code yang menggunakan `flutter_dotenv` untuk handle jika file tidak ada

## Troubleshooting

### Error: "FIREBASE_API_KEY_WEB not found"
- Pastikan secret sudah ditambahkan dengan nama yang **PERSIS** sama
- Secret name case-sensitive!

### Build masih error setelah setup secrets
- Cek di Actions log apakah file `.env` berhasil dibuat
- Pastikan semua secrets sudah diisi (tidak kosong)

### Tidak ingin menggunakan secrets
Edit workflow file dan ganti dengan:
```yaml
- name: Create .env file
  run: |
    echo "FIREBASE_API_KEY_WEB=" > .env
    echo "TEST_EMAIL=" >> .env
    echo "TEST_PASSWORD=" >> .env
```

## Status
- ✅ Workflow sudah diupdate
- ⚠️ Perlu setup secrets di GitHub (lihat langkah di atas)
- ✅ Auto bump version sudah fix
- ✅ Git conflict sudah resolve

