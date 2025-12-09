# ANALISIS SISTEM IURAN WARGA
## Analisis Data Flow & Kesinambungan Data
### Tanggal: 8 Desember 2025

---

## 📊 STRUKTUR DATA YANG ADA

### 1. **Collection: `jenis_iuran`** (Master Data Jenis Iuran)
**Lokasi**: Dikelola oleh Admin di Kelola Pemasukan
**File Model**: `lib/core/models/jenis_iuran_model.dart`

```dart
{
  id: String,                    // Auto-generated document ID
  namaIuran: String,             // "Iuran Sampah", "Iuran Keamanan"
  jumlahIuran: double,           // 50000, 100000
  kategoriIuran: String,         // 'bulanan' atau 'khusus'
  createdBy: String,             // Admin user ID
  createdAt: Timestamp,
  updatedAt: Timestamp,
  isActive: bool                 // true/false (soft delete)
}
```

**Service**: `lib/core/services/jenis_iuran_service.dart`
**Provider**: `lib/core/providers/jenis_iuran_provider.dart`

---

### 2. **Collection: `tagihan`** (Tagihan Individual per Keluarga)
**Lokasi**: Dikelola oleh Admin di Kelola Tagihan
**File Model**: `lib/core/models/tagihan_model.dart`

```dart
{
  id: String,                    // Auto-generated document ID
  kodeTagihan: String,           // "TGH2411001" (auto-generated)
  jenisIuranId: String,          // Reference ke jenis_iuran.id
  jenisIuranName: String,        // "Iuran Sampah" (denormalized)
  keluargaId: String,            // Reference ke keluarga.id
  keluargaName: String,          // "Keluarga Budi" (denormalized)
  nominal: double,               // 50000 (dari jenis_iuran.jumlahIuran)
  periode: String,               // "November 2025"
  periodeTanggal: Timestamp,     // Tanggal jatuh tempo
  status: String,                // 'Belum Dibayar', 'Lunas', 'Terlambat'
  metodePembayaran: String?,     // 'Cash', 'Transfer', 'E-Wallet' (saat lunas)
  tanggalBayar: Timestamp?,      // Tanggal pembayaran (saat lunas)
  buktiPembayaran: String?,      // URL foto bukti transfer
  catatan: String?,              // Catatan pembayaran
  createdBy: String,             // Admin user ID
  createdAt: Timestamp,
  updatedAt: Timestamp,
  isActive: bool
}
```

**Service**: `lib/core/services/tagihan_service.dart`
**Provider**: `lib/core/providers/tagihan_provider.dart`

---

### 3. **Collection: `keuangan`** (Transaksi Keuangan)
**Lokasi**: Dashboard & Laporan Keuangan
**File Model**: `lib/core/models/keuangan_model.dart`

```dart
{
  id: String,
  type: String,                  // 'pemasukan' atau 'pengeluaran'
  amount: double,                // Total nominal
  kategori: String,              // 'Iuran Sampah', 'Iuran Keamanan', dll
  deskripsi: String?,            // Keterangan tambahan
  tanggal: Timestamp,            // Tanggal transaksi
  bukti: String?,                // URL bukti
  createdBy: String,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  isActive: bool
}
```

---

### 4. **Collection: `pemasukan_lain`** (Pemasukan Non-Iuran)
**Lokasi**: Kelola Pemasukan > Tab Lainnya
**File Model**: `lib/core/models/pemasukan_lain_model.dart`

```dart
{
  id: String,
  name: String,                  // Nama pemasukan
  category: String,              // Kategori
  nominal: double,
  deskripsi: String?,
  tanggal: Timestamp,
  status: String,                // 'Menunggu', 'Disetujui'
  bukti: String?,
  createdBy: String,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  isActive: bool
}
```

---

## 🔄 ANALISIS ALUR DATA (CRITICAL!)

### ❌ MASALAH YANG DITEMUKAN:

#### **1. TIDAK ADA KESINAMBUNGAN OTOMATIS!**
Saat ini sistem memiliki **GAP KRITIS**:

```
Admin membuat Jenis Iuran (jenis_iuran)
    ↓
Admin membuat Tagihan per Keluarga (tagihan)
    ↓
Warga melihat Tagihan (BELUM ADA SERVICE!)
    ↓
Warga membayar Tagihan (BELUM ADA FITUR!)
    ↓
❌ TIDAK ADA PROSES: tagihan.status = 'Lunas'
    ↓
❌ TIDAK ADA PROSES: Insert ke collection 'keuangan' sebagai pemasukan
```

#### **2. FUNGSI `markAsLunas()` TIDAK LENGKAP**
File: `lib/core/services/tagihan_service.dart`

```dart
Future<void> markAsLunas(String id, {
  required String metodePembayaran,
  String? buktiPembayaran,
  String? catatan,
}) async {
  // ✅ Update status tagihan jadi 'Lunas'
  await updateTagihan(id, {
    'status': 'Lunas',
    'tanggalBayar': FieldValue.serverTimestamp(),
    'metodePembayaran': metodePembayaran,
    ...
  });
  
  // ❌ MISSING: Tidak ada insert ke collection 'keuangan'!
  // ❌ MISSING: Tidak ada notifikasi ke admin!
}
```

---

## ✅ SOLUSI: IMPLEMENTASI LENGKAP

### **Flow yang Benar:**

```
1. Admin: Create Jenis Iuran
   Collection: jenis_iuran
   
2. Admin: Generate Tagihan Massal untuk Semua Keluarga
   Collection: tagihan (status: 'Belum Dibayar')
   
3. Warga: Lihat Daftar Tagihan (NEW!)
   Service: IuranWargaService.getTagihanByKeluarga(keluargaId)
   
4. Warga: Bayar Tagihan (NEW!)
   Service: IuranWargaService.bayarIuran(tagihanId, metodePembayaran)
   
5. System: Update Tagihan + Insert Keuangan (ATOMIC!)
   a. Update: tagihan.status = 'Lunas'
   b. Insert: keuangan (type: 'pemasukan', kategori: jenisIuranName)
   c. Notif: Kirim notifikasi ke admin
   
6. Admin: Verifikasi Pembayaran (jika ada bukti transfer)
   Service: Admin approve bukti pembayaran
```

---

## 🎯 BACKEND CRUD YANG PERLU DIBUAT

### **File Baru yang Harus Dibuat:**

#### 1. **Model: `pembayaran_iuran_model.dart`** (Optional - untuk tracking detail)
```dart
// Model untuk history pembayaran iuran
class PembayaranIuranModel {
  final String id;
  final String tagihanId;
  final String jenisIuranId;
  final String keluargaId;
  final double nominal;
  final String metodePembayaran;
  final DateTime tanggalBayar;
  final String? buktiPembayaran;
  final String status; // 'Pending', 'Verified'
  ...
}
```

#### 2. **Service: `iuran_warga_service.dart`** ⭐ CRITICAL!
```dart
class IuranWargaService {
  // READ - Get tagihan by keluarga
  Stream<List<TagihanModel>> getTagihanByKeluarga(String keluargaId);
  
  // READ - Get tagihan aktif (belum dibayar)
  Stream<List<TagihanModel>> getTagihanAktif(String keluargaId);
  
  // READ - Get history pembayaran
  Stream<List<TagihanModel>> getHistoryPembayaran(String keluargaId);
  
  // CREATE - Bayar iuran (ATOMIC TRANSACTION!)
  Future<String> bayarIuran({
    required String tagihanId,
    required String metodePembayaran,
    String? buktiPembayaran,
    String? catatan,
    required String userId,
  });
  
  // READ - Get statistik iuran warga
  Future<Map<String, dynamic>> getStatistikIuran(String keluargaId);
}
```

#### 3. **Provider: `iuran_warga_provider.dart`**
```dart
class IuranWargaProvider extends ChangeNotifier {
  List<TagihanModel> _tagihanList = [];
  Map<String, dynamic> _statistik = {};
  
  void loadTagihanWarga(String keluargaId);
  Future<bool> bayarIuran(...);
  void loadStatistik(String keluargaId);
}
```

#### 4. **Update: `tagihan_service.dart`**
```dart
// ⚠️ PERBAIKAN FUNGSI markAsLunas()
Future<void> markAsLunas(...) async {
  // 1. Get tagihan data
  final tagihan = await getTagihanById(id);
  
  // 2. Atomic transaction
  final batch = _firestore.batch();
  
  // 2a. Update tagihan
  batch.update(_firestore.collection('tagihan').doc(id), {...});
  
  // 2b. Insert to keuangan
  batch.set(_firestore.collection('keuangan').doc(), {
    'type': 'pemasukan',
    'amount': tagihan.nominal,
    'kategori': tagihan.jenisIuranName,
    'deskripsi': 'Pembayaran ${tagihan.jenisIuranName} - ${tagihan.keluargaName}',
    'tanggal': FieldValue.serverTimestamp(),
    ...
  });
  
  // 3. Commit atomic
  await batch.commit();
}
```

---

## 🔐 FIRESTORE RULES YANG DIPERLUKAN

```javascript
// Collection: tagihan
match /tagihan/{tagihanId} {
  // Warga hanya bisa READ tagihan keluarganya sendiri
  allow read: if isSignedIn() && 
              resource.data.keluargaId == getUserKeluargaId();
  
  // Warga bisa UPDATE untuk pembayaran (hanya field tertentu)
  allow update: if isSignedIn() &&
                resource.data.keluargaId == getUserKeluargaId() &&
                request.resource.data.status == 'Lunas' &&
                request.resource.data.diff(resource.data)
                  .affectedKeys()
                  .hasOnly(['status', 'tanggalBayar', 'metodePembayaran', 
                           'buktiPembayaran', 'catatan', 'updatedAt']);
  
  // Admin bisa semua operasi
  allow create, update, delete: if isAdmin();
}

// Collection: keuangan
match /keuangan/{keuanganId} {
  // Warga TIDAK bisa akses langsung
  allow read: if isAdmin();
  
  // System bisa INSERT via service (pakai admin SDK di backend)
  allow create: if isSignedIn();
  
  // Admin bisa semua
  allow update, delete: if isAdmin();
}
```

---

## 📋 CHECKLIST IMPLEMENTASI

### Phase 1: Backend Core ✅
- [ ] Create `iuran_warga_service.dart`
- [ ] Create `iuran_warga_provider.dart`
- [ ] Update `tagihan_service.dart` - Fix `markAsLunas()`
- [ ] Add atomic transaction untuk pembayaran
- [ ] Add validation & error handling

### Phase 2: UI Integration
- [ ] Update `iuran_warga_page.dart` - Connect ke real data
- [ ] Update `iuran_detail_page.dart` - Add payment flow
- [ ] Update `iuran_payment_button.dart` - Implement bayar logic
- [ ] Add loading & error states
- [ ] Add success/failure feedback

### Phase 3: Testing
- [ ] Test pembayaran iuran
- [ ] Verify data masuk ke `keuangan`
- [ ] Test Firestore rules
- [ ] Test edge cases (double payment, etc.)

### Phase 4: Firestore Rules
- [ ] Update rules untuk collection `tagihan`
- [ ] Update rules untuk collection `keuangan`
- [ ] Deploy rules ke Firebase
- [ ] Test permissions

---

## ⚠️ CATATAN PENTING

1. **ATOMIC TRANSACTION WAJIB**: Pembayaran iuran HARUS menggunakan Firestore batch/transaction untuk memastikan:
   - Update tagihan.status = 'Lunas'
   - Insert ke keuangan
   - Kedua operasi sukses atau gagal bersama (no partial update!)

2. **DENORMALIZED DATA**: 
   - `jenisIuranName` dan `keluargaName` disimpan di tagihan (denormalized)
   - Ini BENAR untuk performa dan konsistensi historical data
   - Jika nama berubah, tagihan lama tetap pakai nama lama

3. **STATUS FLOW**:
   ```
   'Belum Dibayar' → 'Lunas' (normal flow)
   'Belum Dibayar' → 'Terlambat' (auto-update by system)
   'Terlambat' → 'Lunas' (payment late)
   ```

4. **SECURITY**:
   - Warga HANYA bisa lihat tagihan keluarganya
   - Warga HANYA bisa bayar tagihan keluarganya
   - Admin bisa lihat & manage semua

---

## 🎯 NEXT STEPS

1. ✅ Review analisis ini
2. ⏳ Implementasi `iuran_warga_service.dart`
3. ⏳ Implementasi `iuran_warga_provider.dart`
4. ⏳ Fix `tagihan_service.markAsLunas()`
5. ⏳ Update UI pages
6. ⏳ Deploy Firestore rules
7. ⏳ Testing end-to-end

---

**Dokumentasi ini adalah panduan lengkap untuk implementasi sistem iuran warga yang terintegrasi dengan sistem keuangan admin.**
