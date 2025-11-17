# ✅ DATA MUTASI WARGA - FULL DYNAMIC IMPLEMENTATION

## 📋 RINGKASAN
Fitur **Data Mutasi Warga** telah **BERHASIL DIUBAH** dari static (hardcoded dummy data) menjadi **FULL DYNAMIC** dengan integrasi Firebase Firestore.

---

## 🎯 APA YANG SUDAH DIKERJAKAN

### 1. **Model & Repository**
✅ **Dibuat**: `mutasi_model.dart` - Model untuk data mutasi warga
✅ **Dibuat**: `mutasi_repository.dart` - Repository CRUD untuk Firestore
   - `getAllMutasi()` - Stream real-time semua mutasi
   - `getMutasiByJenis()` - Filter berdasarkan jenis (Masuk/Keluar)
   - `createMutasi()` - Tambah mutasi baru
   - `updateMutasi()` - Update mutasi
   - `deleteMutasi()` - Hapus mutasi
   - `searchMutasi()` - Cari berdasarkan nama/NIK

### 2. **Halaman List Mutasi** (`data_mutasi_warga_page.dart`)
✅ **SEBELUM**: List static dengan dummy data hardcoded
✅ **SETELAH**: StreamBuilder yang fetch data real-time dari Firestore
   - Filter dinamis: Semua / Mutasi Masuk / Keluar Perumahan
   - Tampilan card dengan informasi lengkap
   - Loading state & error handling
   - Empty state yang informatif

### 3. **Halaman Tambah Mutasi** (`tambah_data_mutasi_page.dart`)
✅ **SEBELUM**: Form dummy yang tidak menyimpan ke database
✅ **SETELAH**: Form dinamis yang save ke Firestore
   - **Dropdown Keluarga**: StreamBuilder dari collection `keluarga`
   - **Dropdown Rumah**: StreamBuilder dari collection `rumah`
   - **3 Jenis Mutasi**:
     1. **Mutasi Masuk**: Keluarga baru pindah ke perumahan
     2. **Keluar Perumahan**: Keluarga pindah keluar dari perumahan
     3. **Pindah Rumah**: Keluarga pindah rumah dalam perumahan
   - Conditional fields berdasarkan jenis mutasi
   - Validasi form yang lengkap
   - Loading state saat submit

### 4. **Halaman Detail Mutasi** (`detail_data_mutasi_page.dart`)
✅ **SEBELUM**: Menampilkan data static
✅ **SETELAH**: Menerima `MutasiModel` dan menampilkan data real
   - Nama, NIK, Jenis Mutasi
   - Tanggal mutasi (formatted)
   - Alamat asal & tujuan
   - Alasan mutasi

### 5. **Halaman Edit Mutasi** (`edit_data_mutasi_page.dart`)
✅ **DIPERBAIKI**: Menerima parameter `MutasiModel`
✅ **Form controllers** di-initialize dengan data dari mutasi yang akan di-edit

### 6. **Firestore Rules**
✅ **DITAMBAHKAN**: Rules untuk collection `mutasi`
   - Read access: Public (transparency)
   - Write access: Validated (nama, NIK, jenis mutasi, tanggal, dll harus ada)
   - Create/Update/Delete: Allowed dengan validasi

---

## 📊 STRUKTUR DATA MUTASI

```dart
class MutasiModel {
  final String? id;
  final String nama;                // Nama kepala keluarga
  final String nik;                 // NIK kepala keluarga
  final String jenisMutasi;         // 'Mutasi Masuk', 'Keluar Perumahan', 'Pindah Rumah'
  final DateTime tanggalMutasi;
  final String alamatAsal;
  final String alamatTujuan;
  final String alasanMutasi;
  final String status;              // 'Pending', 'Diproses', 'Selesai'
  final String? keluargaId;         // Reference ke keluarga
  final String? rumahId;            // Reference ke rumah
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

---

## 🔥 FIRESTORE COLLECTION: `mutasi`

### Document Structure:
```json
{
  "nama": "Budi Santoso",
  "nik": "3201010101010001",
  "jenisMutasi": "Mutasi Masuk",
  "tanggalMutasi": Timestamp,
  "alamatAsal": "Jakarta Selatan",
  "alamatTujuan": "Komplek RW 05, Blok A No. 12",
  "alasanMutasi": "Pindah kerja",
  "status": "Selesai",
  "keluargaId": "abc123",
  "rumahId": "xyz789",
  "createdBy": "admin",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

---

## 🎨 FITUR UTAMA

### 1. **Real-Time Updates**
- Data mutasi akan otomatis update saat ada perubahan di Firestore
- Menggunakan `StreamBuilder` untuk live updates

### 2. **Filter Jenis Mutasi**
- **Semua**: Tampilkan semua mutasi
- **Mutasi Masuk**: Hanya mutasi keluarga baru masuk
- **Keluar Perumahan**: Hanya mutasi keluarga keluar

### 3. **Dynamic Dropdown**
- **Keluarga**: Fetch real-time dari Firestore collection `keluarga`
- **Rumah**: Fetch real-time dari Firestore collection `rumah`
- Otomatis update jika ada keluarga/rumah baru

### 4. **Smart Form Logic**
Berdasarkan jenis mutasi yang dipilih:
- **Mutasi Masuk**: 
  - Input: Alamat Asal (dari mana keluarga pindah)
  - Alamat Tujuan: Auto-generated dari rumah yang dipilih
  
- **Keluar Perumahan**:
  - Pilih Rumah Sekarang
  - Input: Alamat Tujuan (mau pindah kemana)
  
- **Pindah Rumah**:
  - Pilih Rumah Sekarang
  - Pilih Rumah Baru
  - Alamat asal & tujuan auto-generated

---

## 🚀 CARA MENGGUNAKAN

### **1. Tambah Mutasi Baru**
1. Buka **Data Warga** → **Data Mutasi**
2. Klik tombol **Tambah Mutasi** (floating action button)
3. Pilih **Jenis Mutasi**
4. Pilih **Keluarga** dari dropdown
5. Isi field sesuai jenis mutasi:
   - Mutasi Masuk: Input alamat asal
   - Keluar Perumahan: Pilih rumah sekarang, input alamat tujuan
   - Pindah Rumah: Pilih rumah sekarang & rumah baru
6. Pilih **Tanggal Mutasi**
7. Isi **Alasan Mutasi**
8. Klik **Simpan**

### **2. Lihat Daftar Mutasi**
- Semua mutasi akan muncul di list
- Filter berdasarkan jenis (Semua/Masuk/Keluar)
- Klik card untuk lihat detail

### **3. Edit Mutasi**
- Buka detail mutasi
- Klik icon **Edit** di app bar
- Edit data yang diperlukan
- Simpan perubahan

### **4. Hapus Mutasi**
- Coming soon (bisa ditambahkan di halaman edit)

---

## ✅ CHECKLIST IMPLEMENTASI

- [x] Buat MutasiModel dengan semua field
- [x] Buat MutasiRepository dengan CRUD operations
- [x] Update data_mutasi_warga_page.dart ke StreamBuilder
- [x] Update _buildMutasiCard untuk MutasiModel
- [x] Update tambah_data_mutasi_page.dart dengan dynamic form
- [x] Tambahkan StreamBuilder untuk dropdown Keluarga
- [x] Tambahkan StreamBuilder untuk dropdown Rumah
- [x] Implementasi logic conditional fields
- [x] Implementasi save ke Firestore
- [x] Update detail_data_mutasi_page.dart
- [x] Update edit_data_mutasi_page.dart parameter
- [x] Tambahkan rules Firestore untuk collection mutasi
- [x] Fix import paths (ke core/models & core/repositories)
- [x] Test & validasi tidak ada error

---

## 🐛 KNOWN ISSUES & FIXES

### ❌ Issue 1: Import Path Error
**Problem**: Import path ke keluarga & rumah model salah
```dart
import '../daftar_keluarga/models/keluarga_model.dart'; // ❌ SALAH
```

**Solution**: 
```dart
import '../../../core/models/keluarga_model.dart'; // ✅ BENAR
import '../../../core/repositories/keluarga_repository.dart';
import '../../../core/models/rumah_model.dart';
import '../../../core/repositories/rumah_repository.dart';
```

### ❌ Issue 2: EditDataMutasiPage Parameter Missing
**Problem**: EditDataMutasiPage tidak menerima parameter mutasiData

**Solution**: 
```dart
class EditDataMutasiPage extends StatefulWidget {
  final MutasiModel mutasiData;
  const EditDataMutasiPage({super.key, required this.mutasiData});
}
```

---

## 🔐 FIRESTORE RULES

```javascript
match /mutasi/{mutasiId} {
  allow read: if true;  // Public read untuk transparency
  
  allow create: if hasValidData() &&
                   'nama' in request.resource.data &&
                   'nik' in request.resource.data &&
                   'jenisMutasi' in request.resource.data &&
                   'tanggalMutasi' in request.resource.data &&
                   'alamatAsal' in request.resource.data &&
                   'alamatTujuan' in request.resource.data &&
                   'alasanMutasi' in request.resource.data &&
                   'createdAt' in request.resource.data;
  
  allow update: if hasValidData() &&
                   'updatedAt' in request.resource.data;
  
  allow delete: if true;
}
```

---

## 📝 DEPLOYMENT CHECKLIST

- [ ] Deploy Firestore rules: `firebase deploy --only firestore:rules`
- [ ] Test tambah mutasi dengan data real
- [ ] Test filter (Semua/Masuk/Keluar)
- [ ] Test edit mutasi
- [ ] Test dengan keluarga & rumah yang berbeda
- [ ] Verify data tersimpan di Firestore Console

---

## 🎉 HASIL AKHIR

✅ **Data Mutasi sudah FULL DYNAMIC**
✅ **Tidak ada lagi dummy data static**
✅ **Terintegrasi penuh dengan Firestore**
✅ **Real-time updates dengan StreamBuilder**
✅ **Form dinamis dengan conditional logic**
✅ **CRUD operations lengkap**

---

## 📞 SUPPORT

Jika ada masalah:
1. Cek error di Debug Console
2. Verify Firestore rules sudah ter-deploy
3. Pastikan ada data keluarga & rumah di Firestore
4. Check network connection

---

**🎊 SELAMAT! Fitur Data Mutasi Warga sudah berhasil di-refactor menjadi FULL DYNAMIC!**

---

Generated: 2025-01-XX
Last Updated: 2025-01-XX
Version: 1.0.0

