# Fix Bug - Kelola Pengguna & UserModel Timestamp Parsing

## Tanggal: 29 November 2025

## Masalah yang Diperbaiki

### 1. Error Timestamp Parsing di UserModel

**Error:**
```
type 'Timestamp' is not a subtype of type 'String'
```

**Penyebab:**
- Field `createdAt` dan `updatedAt` di Firestore bisa berupa:
  - `Timestamp` (dari Firestore)
  - `String` (ISO 8601 format)
  - `DateTime` (objek Dart)
- UserModel.fromMap() hanya bisa parse String dengan `DateTime.parse()`

**Solusi:**
Ditambahkan helper method `_parseDateTime()` yang bisa handle semua format:

```dart
static DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      print('Warning: Failed to parse DateTime from string: $value');
      return null;
    }
  } else if (value is DateTime) {
    return value;
  }
  
  print('Warning: Unknown DateTime format: ${value.runtimeType}');
  return null;
}
```

**Perubahan di user_model.dart:**
- Import `package:cloud_firestore/cloud_firestore.dart`
- Tambah helper method `_parseDateTime()`
- Update parsing `createdAt` dan `updatedAt` menggunakan helper method
- Update parsing `nik` untuk convert ke string jika berupa number

### 2. Struktur File detail_pengguna_page.dart

**Status:** ✅ Sudah benar, tidak ada error syntax

File ini menampilkan detail user dengan fitur:
- Lihat detail akun lengkap (email, NIK, no telepon, alamat, tanggal daftar)
- Approve/Reject verifikasi KYC (untuk status pending/unverified)
- Ubah role (admin/user) - hanya untuk status approved
- Hapus akun

## Tujuan Kelola Pengguna

Berdasarkan implementasi saat ini, **Kelola Pengguna** berfungsi untuk:

### 1. **Manajemen Akun Login (Users Collection)**

Kelola Pengguna menampilkan semua akun yang ada di collection `users`, yang meliputi:

#### a. **User dengan Status Unverified**
- User yang baru mendaftar via Google Sign-In
- Belum melakukan verifikasi KYC
- Data minimal: email, nama
- **Aksi:** Admin bisa hapus akun atau menunggu user verifikasi KYC

#### b. **User dengan Status Pending**
- User yang sudah submit KYC dan menunggu approval
- Data lengkap: NIK, alamat, no telepon, jenis kelamin
- **Aksi:** Admin bisa Approve atau Reject

#### c. **User dengan Status Approved**
- User yang sudah diverifikasi dan bisa menggunakan aplikasi
- **Aksi:** Admin bisa ubah role (user/admin) atau hapus akun

#### d. **User dengan Status Rejected**
- User yang KYC-nya ditolak
- **Aksi:** Admin bisa hapus akun

### 2. **Manajemen Role**

Kelola Pengguna juga untuk mengatur role:
- **Role: warga** - User biasa yang sudah/belum verifikasi KYC
- **Role: user** - User terverifikasi (mungkin dari migrasi data)
- **Role: admin** - Administrator dengan akses penuh

Admin bisa mengubah role user yang sudah approved.

### 3. **Filter yang Tersedia**

Berdasarkan `user_repository.dart`, ada beberapa filter:

```dart
// Semua user
getAllUsers()

// User berdasarkan role
getUsersByRole('admin')  // Hanya admin
getUsersByRole('user')   // Hanya user/warga

// User berdasarkan status
getUsersByStatus('approved')
getUsersByStatus('pending')
getUsersByStatus('unverified')
getUsersByStatus('rejected')

// User yang perlu approval
getPendingUsers()  // status: unverified atau pending
```

## Flow Verifikasi User

```
1. User Sign Up (Google)
   ↓
   Status: unverified
   Role: warga
   Data: email, nama
   
2. User Submit KYC
   ↓
   Status: pending
   Data: + NIK, alamat, no telepon, jenis kelamin
   
3. Admin Review di Kelola Pengguna
   ↓
   [Approve] → Status: approved → User bisa akses penuh
   [Reject]  → Status: rejected → User tidak bisa akses
```

## Firestore Indexes Required ⚠️ PENTING!

### Error yang Muncul:
```
W/Firestore: Listen for Query(users where role==user order by -createdAt) failed
Status: FAILED_PRECONDITION - The query requires an index
```

### Solusi: Buat 3 Composite Indexes

#### **Index 1: role + createdAt** (PRIORITY HIGH!)

**Klik link ini untuk membuat otomatis:**
```
https://console.firebase.google.com/v1/r/project/pbl-2025-35a1c/firestore/indexes?create_composite=Ckxwcm9qZWN0cy9wYmwtMjAyNS0zNWExYy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvdXNlcnMvaW5kZXhlcy9fEAEaCAoEcm9sZRABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI
```

**Atau buat manual:**
1. Buka [Firebase Console - Firestore Indexes](https://console.firebase.google.com/project/pbl-2025-35a1c/firestore/indexes)
2. Klik **"Create Index"**
3. Isi form:
   - Collection ID: `users`
   - Field 1: `role` - **Ascending**
   - Field 2: `createdAt` - **Descending**
   - Query scope: **Collection**
4. Klik **"Create"**
5. Tunggu 2-5 menit sampai status jadi **"Enabled"** (hijau)

#### **Index 2: status + createdAt**

Buat manual dengan detail:
- Collection: `users`
- Field 1: `status` - **Ascending**
- Field 2: `createdAt` - **Descending**

#### **Index 3: status (whereIn) + createdAt**

Buat manual dengan detail:
- Collection: `users`
- Field 1: `status` - **Array-contains-any**
- Field 2: `createdAt` - **Descending**

### Verifikasi Index Berhasil:

1. Refresh Firebase Console
2. Pastikan status index = **"Enabled"** (hijau)
3. Restart aplikasi Flutter
4. Buka Kelola Pengguna
5. Coba filter by role/status - seharusnya tidak error lagi

⏱️ **Estimasi waktu build index:** 2-5 menit

📄 **Lihat detail lengkap:** `FIRESTORE_INDEXES_REQUIRED.md`

## Testing

Setelah perubahan:
1. ✅ UserModel bisa parse Timestamp dari Firestore
2. ✅ UserModel bisa parse String ISO 8601
3. ✅ UserModel bisa handle DateTime object
4. ✅ NIK yang berupa number di-convert ke string
5. ✅ detail_pengguna_page tidak ada error syntax

## File yang Diubah

1. `lib/core/models/user_model.dart`
   - Tambah import cloud_firestore
   - Tambah helper method _parseDateTime()
   - Update parsing createdAt dan updatedAt
   - Update parsing NIK

2. `lib/features/admin/data_warga/kelola_pengguna/detail_pengguna_page.dart`
   - File sudah benar, tidak ada perubahan

## Next Steps

1. **Buat Firestore Indexes** - Klik link di error message atau buat manual
2. **Test Kelola Pengguna** - Pastikan semua filter bekerja
3. **Test Approve/Reject** - Pastikan status update berhasil
4. **Test Change Role** - Pastikan role update berhasil
5. **Test Delete User** - Pastikan delete berhasil

## Catatan Penting

⚠️ **Kelola Pengguna ≠ Data Penduduk**

- **Kelola Pengguna** → Manajemen akun login (collection: `users`)
- **Data Penduduk** → Data warga RT/RW (collection: `penduduk`)

Kedua fitur ini terpisah, meskipun user yang approved mungkin juga punya data di collection `penduduk`.

