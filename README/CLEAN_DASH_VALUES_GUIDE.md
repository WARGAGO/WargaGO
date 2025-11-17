# Clean Dash Values Script

## 📋 Deskripsi
Script untuk membersihkan nilai `-` (dash) dari database Firestore yang menyebabkan error pada form edit data warga.

## 🎯 Tujuan
Mengganti semua nilai `-`, `--`, atau `---` dengan string kosong (`''`) di collection:
- `warga` 
- `keluarga`

## 🚀 Cara Menggunakan

### 1. Pastikan Firebase sudah terkoneksi
```bash
flutter pub get
```

### 2. Jalankan script
```bash
flutter run lib/clean_dash_values.dart
```

Atau bisa juga menggunakan dart CLI:
```bash
dart run lib/clean_dash_values.dart
```

### 3. Monitor output
Script akan menampilkan:
- Jumlah dokumen yang ditemukan
- Dokumen mana saja yang diupdate
- Field apa saja yang berubah
- Statistik akhir (total updated vs skipped)

## 📊 Output Example
```
╔════════════════════════════════════════════════════════════╗
║         CLEAN DASH VALUES FROM FIRESTORE                   ║
║         Script untuk membersihkan nilai '-' dari DB        ║
╚════════════════════════════════════════════════════════════╝

🚀 Starting clean up dash values...
📊 Found 50 warga documents
  🔧 abc123: agama = "-" → ""
  🔧 abc123: golonganDarah = "-" → ""
  ✅ Updated abc123 (2 fields)
  🔧 def456: pekerjaan = "-" → ""
  ✅ Updated def456 (1 fields)
...

✅ Clean up completed!
📈 Statistics:
   - Total documents: 50
   - Updated: 15
   - Skipped (no changes): 35

╔════════════════════════════════════════════════════════════╗
║                    ✅ ALL DONE!                            ║
╚════════════════════════════════════════════════════════════╝
```

## ⚠️ Warning
- Script ini akan **mengubah data** di Firestore
- Disarankan untuk backup data terlebih dahulu
- Jalankan script ini **hanya sekali**
- Pastikan Firebase credentials sudah benar

## 🔍 Fields yang Dicek

### Collection `warga`:
- jenisKelamin
- agama
- golonganDarah
- pendidikan
- pekerjaan
- statusPerkawinan
- peranKeluarga
- namaIbu
- namaAyah
- tempatLahir
- rt
- rw
- alamat
- phone
- namaKeluarga
- nomorKK
- kewarganegaraan

### Collection `keluarga`:
- namaKeluarga
- kepalaKeluarga
- rumahSaatIni
- statusKepemilikan
- statusKeluarga

## 💡 Best Practices

### Setelah Clean Up
1. Test edit data warga - pastikan tidak ada error
2. Test tambah data warga baru - jangan gunakan `-` sebagai placeholder
3. Update form validation - pastikan tidak accept `-` sebagai input

### Untuk Data Baru
**JANGAN** gunakan `-` sebagai placeholder. Gunakan:
- Empty string (`''`) untuk optional fields
- Default values (`'Aktif'`, `'Hidup'`) untuk required fields
- `null` untuk truly optional fields

### Validation Example
```dart
// ❌ BAD
if (agama == null || agama.isEmpty) {
  agama = '-';  // JANGAN!
}

// ✅ GOOD
if (agama == null || agama.isEmpty) {
  agama = '';  // atau biarkan null
}
```

## 🔗 Related
- [FIX_EDIT_DATA_WARGA_DROPDOWN_ERROR.md](./FIX_EDIT_DATA_WARGA_DROPDOWN_ERROR.md)
- [DATA_WARGA_CRUD_IMPLEMENTATION.md](./DATA_WARGA_CRUD_IMPLEMENTATION.md)

---
**Created**: November 16, 2025  
**Purpose**: Clean up dash values causing dropdown assertion errors

