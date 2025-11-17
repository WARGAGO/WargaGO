# 📋 CARA GENERATE DUMMY DATA PENDUDUK

## 🎯 Deskripsi
Script untuk generate data dummy penduduk ke Firestore secara otomatis tanpa perlu input manual di Firebase Console.

## ✨ Fitur
- ✅ Generate keluarga lengkap (Kepala Keluarga, Istri, Anak)
- ✅ Data tersebar di beberapa RT/RW (RT 001-005, RW 001-003)
- ✅ Variasi umur, pekerjaan, pendidikan yang realistis
- ✅ NIK dan Nomor KK unik untuk setiap warga
- ✅ Relasi keluarga yang konsisten
- ✅ Data sesuai dengan model WargaModel yang ada

## 📊 Data yang Digenerate
Script ini akan membuat:
- **5-8 keluarga** per RT
- **5 RT** x **3 RW** = 15 kombinasi
- **Total estimasi: 100-300+ data warga**

Setiap keluarga terdiri dari:
- 1 Kepala Keluarga (Laki-laki, 30-60 tahun)
- 0-1 Istri (Perempuan, 25-55 tahun)
- 0-4 Anak (1-25 tahun)

## 🚀 Cara Menggunakan

### Method 1: Run Langsung (Recommended)
```bash
flutter run lib/generate_dummy_penduduk.dart
```

### Method 2: Dari VS Code
1. Buka file `lib/generate_dummy_penduduk.dart`
2. Klik kanan pada file
3. Pilih "Run Without Debugging" atau tekan `Ctrl+F5`

### Method 3: Dari Terminal dengan Device Spesifik
```bash
# Lihat daftar device
flutter devices

# Run di Chrome
flutter run -d chrome lib/generate_dummy_penduduk.dart

# Run di Android
flutter run -d android lib/generate_dummy_penduduk.dart

# Run di Windows
flutter run -d windows lib/generate_dummy_penduduk.dart
```

## 📱 Cara Pakai Aplikasi

1. **Buka aplikasi** - Setelah run, aplikasi akan terbuka
2. **Klik tombol "Generate Data Dummy"** - Tunggu proses selesai
3. **Lihat progress** - Status akan update real-time
4. **Selesai!** - Data sudah masuk ke Firestore

### Fitur Tambahan
- **Hapus Semua Data** - Tombol merah untuk menghapus semua data warga jika ingin reset

## 📋 Struktur Data yang Digenerate

```dart
{
  'nik': '1234567890123456',           // 16 digit unik
  'nomorKK': '1234567890123456',       // 16 digit per keluarga
  'name': 'Ahmad Sudirman',
  'tempatLahir': 'Jakarta',
  'birthDate': Timestamp,              // Sesuai umur
  'jenisKelamin': 'Laki-laki',        // atau 'Perempuan'
  'agama': 'Islam',                    // 6 pilihan
  'golonganDarah': 'O',                // A, B, AB, O, -
  'pendidikan': 'S1',                  // Sesuai umur
  'pekerjaan': 'Wiraswasta',           // Sesuai umur
  'statusPerkawinan': 'Kawin',         // 4 status
  'statusPenduduk': 'Aktif',
  'statusHidup': 'Hidup',
  'peranKeluarga': 'Kepala Keluarga',  // Kepala/Istri/Anak
  'namaIbu': '-',
  'namaAyah': '-',
  'rt': '001',
  'rw': '001',
  'alamat': 'Jl. Merdeka No. 45',
  'phone': '081234567890',             // 12 digit random
  'kewarganegaraan': 'Indonesia',
  'namaKeluarga': 'Sudirman',
  'photoUrl': '',
  'createdBy': 'system',
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
}
```

## 🎨 Variasi Data

### Nama
- **Pria**: 20 variasi nama
- **Wanita**: 20 variasi nama  
- **Anak**: 25 variasi nama

### Tempat Lahir
- Jakarta, Bandung, Surabaya, Medan, Semarang, dll (12 kota)

### Agama
- Islam, Kristen, Katolik, Hindu, Buddha, Konghucu

### Pendidikan
- Tidak/Belum Sekolah, SD, SMP, SMA/SMK, D3, S1, S2, S3
- **Disesuaikan dengan umur**

### Pekerjaan
- Wiraswasta, PNS, Pegawai Swasta, Guru, Dokter, dll
- **Disesuaikan dengan umur dan status**

### Status Perkawinan
- Belum Kawin, Kawin, Cerai Hidup, Cerai Mati

## ⚙️ Kustomisasi (Opsional)

### Mengubah Jumlah Keluarga per RT
Edit di file `generate_dummy_penduduk.dart`:
```dart
// Baris ~270
final jumlahKeluarga = 5 + Random().nextInt(4); // 5-8 keluarga
// Ubah menjadi:
final jumlahKeluarga = 10 + Random().nextInt(6); // 10-15 keluarga
```

### Mengubah RT/RW
Edit di file `generate_dummy_penduduk.dart`:
```dart
// Baris ~267-268
final rts = ['001', '002', '003', '004', '005'];
final rws = ['001', '002', '003'];
// Tambah atau kurangi sesuai kebutuhan
```

### Mengubah Jumlah Anak per Keluarga
Edit di file `generate_dummy_penduduk.dart`:
```dart
// Baris ~211
final jumlahAnak = random.nextInt(5); // 0-4 anak
// Ubah menjadi:
final jumlahAnak = random.nextInt(3); // 0-2 anak
```

## 🔍 Verifikasi Data

Setelah generate, cek di Firebase Console:
1. Buka **Firestore Database**
2. Pilih collection **warga**
3. Lihat data yang sudah digenerate

Atau cek langsung di aplikasi:
1. Buka menu **Data Warga** > **Data Penduduk**
2. Lihat daftar warga yang sudah digenerate

## 🗑️ Menghapus Data

### Dari Aplikasi
1. Klik tombol **"Hapus Semua Data"** (merah)
2. Konfirmasi penghapusan
3. Tunggu hingga selesai

### Dari Firebase Console
1. Buka Firestore Database
2. Pilih collection **warga**
3. Hapus manual atau gunakan batch delete

## ⚠️ Catatan Penting

1. **Pastikan Firebase sudah terkonfigurasi** dengan benar
2. **Data yang digenerate adalah dummy** - gunakan untuk testing/development
3. **NIK dan Nomor KK adalah random** - tidak valid untuk data real
4. **Backup data lama** sebelum menghapus jika ada data penting
5. **Proses generate membutuhkan waktu** - tunggu hingga selesai (1-5 menit)

## 🐛 Troubleshooting

### Error: Firebase not initialized
```bash
# Pastikan Firebase sudah di-setup
flutter pub get
```

### Error: Permission denied
Cek Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /warga/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Data tidak muncul di aplikasi
1. Refresh aplikasi (hot reload: `r`)
2. Restart aplikasi (hot restart: `R`)
3. Cek connection ke Firebase

## 📝 Log Output

Script akan menampilkan log seperti ini:
```
Generated 1 warga: Ahmad Sudirman
Generated 2 warga: Ani Suryani
Generated 3 warga: Andi Sudirman
...
Generate data untuk RT 002 RW 001...
...
✅ Berhasil generate 150 data warga!
```

## 🎯 Best Practices

1. **Generate di development environment** dulu
2. **Test dengan jumlah kecil** dulu (ubah ke 1-2 keluarga)
3. **Backup database** sebelum generate banyak data
4. **Hapus data dummy** setelah selesai testing
5. **Jangan gunakan di production** tanpa review

## 📞 Support

Jika ada masalah atau pertanyaan:
1. Cek file ini dulu untuk troubleshooting
2. Cek Firebase Console untuk error
3. Lihat log di terminal/debug console

---

**Created**: November 2025  
**Version**: 1.0.0  
**Status**: ✅ Ready to Use

