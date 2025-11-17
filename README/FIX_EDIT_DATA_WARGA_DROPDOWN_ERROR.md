# Fix: Error Edit Data Warga - Dropdown Assertion Failed

## 🐛 Problem
Ketika klik **Edit Data Warga**, muncul error:
```
Error memuat data warga
Terjadi kesalahan saat memuat form edit.
'package:flutter/src/material/dropdown.dart': Failed assertion: line 1796 pos 10: 
'items == null || items.isEmpty || (initialValue == null && value == null) || 
items.where((DropdownMenuItem<T> item) => item.value == (initialValue ?? value)).length == 1': 
There should be exactly one item with [DropdownButton]'s value: -.
Either zero or 2 or more [DropdownMenuItem]s were detected with the same value
```

## 🔍 Root Cause
Data di Firestore memiliki nilai `-` (dash) untuk beberapa field dropdown, sedangkan nilai `-` tidak ada dalam daftar valid options di dropdown. Flutter's DropdownButtonFormField memerlukan bahwa nilai yang di-set harus ada dalam daftar items.

## ✅ Solution

### 1. Validasi Nilai Dropdown di InitState
Tambahkan helper function untuk memvalidasi nilai dropdown dan mengganti nilai yang tidak valid dengan `null`:

```dart
// Helper function to validate dropdown value
String? _validateDropdownValue(String? value, List<String> validOptions) {
  if (value == null || value.isEmpty || value == '-') return null;
  return validOptions.contains(value) ? value : null;
}
```

### 2. Gunakan Helper Function untuk Semua Dropdown
```dart
// Initialize dropdown values - ONLY set if value exists in valid options
_jenisKelamin = _validateDropdownValue(widget.warga.jenisKelamin, validJenisKelamin);
_agama = _validateDropdownValue(widget.warga.agama, validAgama);
_golonganDarah = _validateDropdownValue(widget.warga.golonganDarah, validGolonganDarah);
_pendidikan = _validateDropdownValue(widget.warga.pendidikan, validPendidikan);
_pekerjaan = _validateDropdownValue(widget.warga.pekerjaan, validPekerjaan);
_statusPerkawinan = _validateDropdownValue(widget.warga.statusPerkawinan, validStatusPerkawinan);
_peranKeluarga = _validateDropdownValue(widget.warga.peranKeluarga, validPeranKeluarga);
```

### 3. Set Default Value untuk Field Wajib
Untuk field yang wajib diisi (seperti status penduduk dan status hidup), berikan default value:

```dart
// Status penduduk dan status hidup dengan default values
final statusPendudukValue = _validateDropdownValue(widget.warga.statusPenduduk, validStatusPenduduk);
_statusPenduduk = statusPendudukValue ?? 'Aktif'; // Default ke Aktif jika tidak valid

final statusHidupValue = _validateDropdownValue(widget.warga.statusHidup, validStatusHidup);
_statusHidup = statusHidupValue ?? 'Hidup'; // Default ke Hidup jika tidak valid
```

## 📝 Files Modified
- ✅ `lib/features/data_warga/data_penduduk/edit_data_warga_page.dart`

## 🔧 Additional Recommendations

### Clean Up Data di Firestore (Optional)
Jika ingin membersihkan data yang berisi `-` di Firestore, buat script migration:

```dart
// clean_dash_values.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> cleanDashValues() async {
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  
  final wargas = await firestore.collection('warga').get();
  
  for (var doc in wargas.docs) {
    final data = doc.data();
    final updates = <String, dynamic>{};
    
    // Check each field and replace '-' with empty string
    final fieldsToCheck = [
      'jenisKelamin', 'agama', 'golonganDarah', 'pendidikan',
      'pekerjaan', 'statusPerkawinan', 'peranKeluarga',
      'namaIbu', 'namaAyah', 'tempatLahir', 'rt', 'rw', 'alamat'
    ];
    
    for (var field in fieldsToCheck) {
      if (data[field] == '-') {
        updates[field] = '';
      }
    }
    
    if (updates.isNotEmpty) {
      await doc.reference.update(updates);
      print('Updated ${doc.id}: ${updates.keys.join(", ")}');
    }
  }
  
  print('✅ Clean up completed!');
}
```

### Best Practices untuk Dropdown
1. **Selalu validasi nilai sebelum set ke dropdown**
2. **Gunakan `initialValue` untuk StatefulWidget (lebih aman)**
3. **Gunakan `value` dengan setState untuk dynamic changes**
4. **Handle null values dengan graceful defaults**
5. **Jangan simpan karakter placeholder (`-`, `--`, dll) ke database**

## 🧪 Testing
1. ✅ Buka halaman Data Warga
2. ✅ Klik Edit pada warga yang memiliki data dengan nilai `-`
3. ✅ Form edit harus terbuka tanpa error
4. ✅ Field yang berisi `-` akan muncul sebagai kosong (null)
5. ✅ User dapat memilih nilai baru dari dropdown
6. ✅ Simpan perubahan berhasil

## 📊 Impact
- **Before**: Edit form crash ketika data mengandung nilai `-`
- **After**: Edit form terbuka dengan sukses, nilai `-` dikonversi ke `null` atau default value

## 🎯 Status
✅ **FIXED** - Edit data warga sekarang berfungsi dengan baik meskipun data mengandung nilai `-`

---
**Date**: November 16, 2025
**Fixed By**: GitHub Copilot
**Related Issue**: Dropdown assertion error pada edit data warga

