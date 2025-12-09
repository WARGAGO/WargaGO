# 🔍 TROUBLESHOOTING - TAGIHAN TIDAK MUNCUL DI WARGA

## ❓ **MASALAH: "Belum Ada Tagihan Iuran"**

Jika warga melihat pesan "Belum Ada Tagihan Iuran", ada **3 kemungkinan penyebab**:

---

## 🎯 **SOLUSI CEPAT (CHECK LIST)**

### ✅ **1. Check: User Punya Keluarga ID?**

**Cara Check**:
1. Login sebagai warga
2. Buka Iuran Warga
3. Klik tombol **"Debug Info"** (tombol biru di bawah)
4. Lihat baris **"Keluarga ID"**

**Jika keluargaId = "❌ TIDAK ADA"**:

**SOLUSI** → Admin harus tambahkan keluargaId:

```
1. Buka Firebase Console
2. Go to: Firestore Database
3. Collection: users
4. Find user document (by email/uid)
5. Add field:
   - Field name: keluargaId
   - Value: "KEL_XXX" (contoh: KEL_001)
6. Save
```

**ATAU** via `data_penduduk`:

```
1. Buka Firebase Console
2. Go to: Firestore Database
3. Collection: data_penduduk
4. Find user document
5. Pastikan ada field keluargaId
6. Copy keluargaId value
7. Paste ke users/{userId}/keluargaId
```

---

### ✅ **2. Check: Admin Sudah Buat Jenis Iuran?**

**Cara Check**:
1. Login sebagai warga
2. Buka Iuran Warga
3. Klik **"Debug Info"**
4. Lihat baris **"Jenis Iuran Tersedia"**

**Jika jumlah = 0**:

**SOLUSI** → Admin harus tambah jenis iuran:

```
1. Login sebagai Admin
2. Go to: Kelola Iuran → Master Jenis
3. Klik "Tambah Jenis"
4. Fill form:
   - Nama: "Iuran Sampah"
   - Kategori: Bulanan
   - Nominal: Rp 25.000
   - Periode: Bulanan
5. Klik "Simpan"
6. ✅ Auto-tagihan akan ter-generate untuk semua warga!
```

**Expected Result**:
- Jenis iuran saved ✅
- Tagihan auto-generated ✅
- Warga langsung lihat tagihan ✅

---

### ✅ **3. Check: Tagihan Sudah Ter-Generate?**

**Cara Check**:
1. Buka Firebase Console
2. Go to: Firestore Database
3. Collection: **tagihan**
4. Filter by: `keluargaId == KEL_XXX` (ganti dengan keluargaId user)

**Jika tidak ada document**:

**KEMUNGKINAN**:
- Auto-tagihan belum jalan (cek console log)
- keluargaId tidak match
- User status bukan "Terverifikasi"

**SOLUSI MANUAL** (jika auto-tagihan gagal):

```
1. Buka Firebase Console
2. Go to: Firestore → tagihan collection
3. Add document manually:

{
  "jenisIuranId": "iuran_001",
  "jenisIuranNama": "Iuran Sampah",
  "keluargaId": "KEL_001",  ← PASTIKAN SAMA dengan user!
  "nominal": 25000,
  "status": "Belum Dibayar",
  "periodeTanggal": "2025-01-08T00:00:00Z",
  "deadline": "2025-02-28T23:59:59Z",
  "isActive": true,
  "createdAt": "2025-01-08T10:00:00Z",
  "updatedAt": "2025-01-08T10:00:00Z"
}

4. Save
5. Refresh app warga → tagihan muncul!
```

---

## 🔧 **DEBUG TOOLS YANG TERSEDIA**

### **1. Debug Info Button** (di Iuran Warga)

**Fitur**:
- ✅ Show User ID
- ✅ Show Keluarga ID
- ✅ Show Jenis Iuran count
- ✅ Show Tagihan count
- ✅ Highlight masalah (keluargaId missing, dll)

**Cara Pakai**:
1. Buka Iuran Warga (warga)
2. Jika kosong, klik **"Debug Info"**
3. Read info → cari masalah

---

### **2. Console Logs** (Developer Tools)

**Buka DevTools Console**:
```
flutter run --verbose
```

**Look for**:
```
✅ User keluargaId: KEL_001
📊 Query result: 5 documents
✅ Found 5 tagihan
```

**Or errors**:
```
❌ User has no keluargaId!
⚠️ No tagihan found for keluargaId: KEL_001
```

---

### **3. IuranDebugTool** (Manual Check)

**File**: `lib/core/utils/iuran_debug_tool.dart`

**Run dari DevTools Console**:
```dart
import 'package:wargago/core/utils/iuran_debug_tool.dart';

// Run all checks
await IuranDebugTool.runAllChecks();
```

**Output**:
```
🔍 CHECK 1: User keluargaId
✅ User punya keluargaId: KEL_001

🔍 CHECK 2: Tagihan di Firestore
📊 Total tagihan: 5
✅ Found 5 tagihan

🔍 CHECK 3: Data Penduduk
✅ Found user in data_penduduk

🔍 CHECK 4: Jenis Iuran
📊 Total jenis iuran: 53
```

---

## 📊 **COMMON SCENARIOS**

### **Scenario 1: User Baru**

**Masalah**: User baru daftar, belum ada keluargaId

**Solusi**:
```
1. Admin approve di Data Penduduk
2. Set keluargaId di data_penduduk
3. Copy keluargaId ke users collection
4. User refresh → tagihan muncul
```

---

### **Scenario 2: Admin Baru Buat Jenis Iuran**

**Expected Flow**:
```
Admin: Tambah "Iuran Sampah" → Simpan
  ↓ (Auto dalam 5 detik)
System: Generate 100 tagihan
  ↓ (Real-time)
Warga: Refresh → Lihat tagihan baru!
```

**Jika tidak muncul**:
```
1. Check console log → ada error?
2. Check Firestore tagihan collection → ada docs baru?
3. Check user keluargaId → match dengan tagihan?
```

---

### **Scenario 3: Semua Sudah Benar, Tapi Tetap Kosong**

**Debug Steps**:

**Step 1 - Verify keluargaId Match**:
```sql
-- Firebase Console Query
Collection: users/{userId}
Field: keluargaId = "KEL_001"

Collection: tagihan
Filter: keluargaId == "KEL_001"
Result: Should have docs!
```

**Step 2 - Check Status**:
```
Collection: data_penduduk
Filter: userId == "{userId}"
Check: status == "Terverifikasi"
```

**Step 3 - Manual Test Query**:
```dart
// Di DevTools Console
final keluargaId = "KEL_001";
final snapshot = await FirebaseFirestore.instance
    .collection('tagihan')
    .where('keluargaId', isEqualTo: keluargaId)
    .where('isActive', isEqualTo: true)
    .get();

print('Found: ${snapshot.docs.length} documents');
```

---

## 🎯 **QUICK FIX CHECKLIST**

Jika tagihan tidak muncul, check dalam urutan:

- [ ] **1. User logged in?** (Firebase Auth)
- [ ] **2. User punya keluargaId?** (users collection)
- [ ] **3. Admin sudah buat jenis iuran?** (jenis_iuran collection)
- [ ] **4. Tagihan sudah ter-generate?** (tagihan collection)
- [ ] **5. keluargaId match?** (users vs tagihan)
- [ ] **6. Status Terverifikasi?** (data_penduduk)
- [ ] **7. tagihan.isActive = true?**
- [ ] **8. App sudah refresh?** (pull to refresh)

---

## 💡 **PREVENTION TIPS**

### **For Admin**:

1. **Pastikan semua warga punya keluargaId**
   - Check data_penduduk saat approve
   - Sync keluargaId ke users collection

2. **Test setelah tambah jenis iuran**
   - Check console log → tagihan generated?
   - Login sebagai warga test → tagihan muncul?

3. **Monitor Firestore tagihan collection**
   - Jumlah docs bertambah setelah buat jenis iuran?
   - All keluargaId covered?

---

### **For Developers**:

1. **Enable verbose logging**
   ```dart
   flutter run --verbose
   ```

2. **Check Firestore indexes**
   - tagihan where keluargaId + isActive
   - Create index jika belum ada

3. **Test auto-tagihan**
   - Add jenis iuran → check console
   - Verify batch commits success
   - Check Firestore docs count

---

## 📞 **JIKA MASALAH TETAP ADA**

**Contact Developer dengan info**:

```
1. Screenshot "Debug Info" dari app
2. User email/UID
3. keluargaId (jika ada)
4. Console error logs
5. Screenshot Firestore tagihan collection
```

**Info yang dibutuhkan**:
- [ ] User ID
- [ ] Keluarga ID
- [ ] Jenis Iuran count
- [ ] Tagihan count di Firestore
- [ ] Error messages (jika ada)
- [ ] Screenshot

---

## ✅ **SUCCESS INDICATORS**

Jika semua benar, warga akan lihat:

```
✅ Keluarga ID: keluargacemara
✅ Jenis Iuran: 53
✅ Total Tagihan: 5
✅ Belum Bayar: 2
✅ Lunas: 3

📄 Daftar Tagihan:
  • Iuran Sampah - Rp 25.000
  • Iuran Keamanan - Rp 50.000
```

---

**Last Updated**: December 8, 2025  
**Status**: Troubleshooting Guide Active  
**Tools**: Debug Info Button, IuranDebugTool, Console Logs

