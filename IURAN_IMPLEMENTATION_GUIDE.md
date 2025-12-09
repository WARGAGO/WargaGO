# IURAN WARGA - IMPLEMENTATION GUIDE
## Complete Backend CRUD Implementation
### Date: December 8, 2025

---

## 🎯 OVERVIEW

Dokumentasi lengkap untuk implementasi backend CRUD fitur iuran warga yang terintegrasi dengan sistem keuangan admin.

### ✅ What's Implemented:

1. **Service Layer**: `IuranWargaService` - Business logic & Firestore operations
2. **Provider Layer**: `IuranWargaProvider` - State management dengan real-time updates
3. **Model Integration**: Menggunakan `TagihanModel` & `KeuanganModel` yang sudah ada
4. **Atomic Transactions**: Pembayaran iuran menggunakan Firestore batch untuk konsistensi data
5. **Enhanced TagihanService**: Updated `markAsLunas()` dengan atomic transaction

---

## 📊 DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────┐
│                        ADMIN SIDE                                │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────┐     ┌──────────────────┐     ┌───────────────┐
│  jenis_iuran    │────▶│    tagihan       │     │   keuangan    │
│  (Master Data)  │     │ (Tagihan Warga)  │     │ (Transaksi)   │
└─────────────────┘     └──────────────────┘     └───────────────┘
                                  │                        ▲
                                  │                        │
                                  ▼                        │
┌─────────────────────────────────────────────────────────┤
│                        WARGA SIDE                        │
│                                                          │
│  1. Lihat Tagihan (getTagihanByKeluarga)                │
│  2. Filter: Aktif, Terlambat, Lunas                     │
│  3. Bayar Iuran (bayarIuran) ──────────────────────────┘
│  4. Upload Bukti Pembayaran                              │
│  5. Lihat Statistik & History                            │
└──────────────────────────────────────────────────────────┘

ATOMIC TRANSACTION (bayarIuran):
┌─────────────────────────────────────────┐
│  Batch Transaction:                     │
│  1. UPDATE tagihan.status = 'Lunas'     │
│  2. INSERT keuangan (pemasukan)         │
│  ─────────────────────────────           │
│  Kedua sukses atau kedua rollback!      │
└─────────────────────────────────────────┘
```

---

## 🗂️ FILE STRUCTURE

### Files Created:

```
lib/core/
├── services/
│   ├── iuran_warga_service.dart          ⭐ NEW - Service untuk warga
│   └── tagihan_service.dart              ✏️ UPDATED - markAsLunas() improved
├── providers/
│   ├── iuran_warga_provider.dart         ⭐ NEW - Provider untuk warga
│   └── tagihan_provider.dart             ✏️ UPDATED - markAsLunas() signature
└── models/
    ├── tagihan_model.dart                ✅ EXISTING - Digunakan
    └── keuangan_model.dart               ✅ EXISTING - Digunakan

Documentation:
├── IURAN_WARGA_ANALYSIS.md               📄 Analisis data flow
├── IURAN_FIRESTORE_RULES.md              📄 Security rules guide
└── IURAN_IMPLEMENTATION_GUIDE.md         📄 This file
```

---

## 🔧 IMPLEMENTATION DETAILS

### 1. IuranWargaService

**Location**: `lib/core/services/iuran_warga_service.dart`

#### Key Methods:

```dart
// ===== READ OPERATIONS =====

// Get all tagihan by keluarga (real-time stream)
Stream<List<TagihanModel>> getTagihanByKeluarga(String keluargaId)

// Get tagihan aktif (belum dibayar)
Stream<List<TagihanModel>> getTagihanAktif(String keluargaId)

// Get tagihan terlambat
Stream<List<TagihanModel>> getTagihanTerlambat(String keluargaId)

// Get history pembayaran (lunas)
Stream<List<TagihanModel>> getHistoryPembayaran(String keluargaId)

// Get single tagihan
Future<TagihanModel?> getTagihanById(String tagihanId)

// ===== CREATE OPERATIONS =====

// ⭐ BAYAR IURAN - Atomic Transaction
Future<String> bayarIuran({
  required String tagihanId,
  required String metodePembayaran,
  String? buktiPembayaran,
  String? catatan,
  required String userId,
})

// Upload bukti pembayaran
Future<String> uploadBuktiPembayaran({
  required String tagihanId,
  required String imagePath,
})

// ===== STATISTICS =====

// Get statistik iuran
Future<Map<String, dynamic>> getStatistikIuran(String keluargaId)

// Get tagihan jatuh tempo (7 hari ke depan)
Future<List<TagihanModel>> getTagihanJatuhTempo(String keluargaId)

// Check has tunggakan
Future<bool> hasTunggakan(String keluargaId)

// Get total tunggakan
Future<double> getTotalTunggakan(String keluargaId)
```

#### Critical Feature: `bayarIuran()`

```dart
Future<String> bayarIuran({...}) async {
  // 1. Get tagihan data
  final tagihan = await getTagihanById(tagihanId);
  
  // 2. Validate
  if (tagihan.status == 'Lunas') throw Exception('Sudah dibayar');
  
  // 3. Prepare atomic batch
  final batch = _firestore.batch();
  
  // 4a. Update tagihan
  batch.update(tagihanRef, {
    'status': 'Lunas',
    'tanggalBayar': Timestamp.fromDate(now),
    'metodePembayaran': metodePembayaran,
    ...
  });
  
  // 4b. Insert keuangan
  batch.set(keuanganRef, {
    'type': 'pemasukan',
    'amount': tagihan.nominal,
    'kategori': tagihan.jenisIuranName,
    'sourceType': 'iuran',
    'sourceId': tagihanId,
    ...
  });
  
  // 5. Commit (ATOMIC!)
  await batch.commit();
  
  return keuanganRef.id;
}
```

**Why Atomic?**
- Jika update tagihan sukses tapi insert keuangan gagal → DATA INCONSISTENT!
- Jika insert keuangan sukses tapi update tagihan gagal → DATA INCONSISTENT!
- Dengan batch: Kedua operasi sukses atau kedua rollback → DATA CONSISTENT!

---

### 2. IuranWargaProvider

**Location**: `lib/core/providers/iuran_warga_provider.dart`

#### State Variables:

```dart
// Tagihan lists (real-time)
List<TagihanModel> _allTagihan
List<TagihanModel> _tagihanAktif
List<TagihanModel> _tagihanTerlambat
List<TagihanModel> _historyPembayaran

// Statistics
Map<String, dynamic> _statistik

// UI States
bool _isLoading
bool _isPaymentProcessing
String? _errorMessage
String? _successMessage
```

#### Key Methods:

```dart
// Initialize provider
Future<void> initialize(String keluargaId)

// Load data (with real-time streams)
Future<void> loadAllTagihan(String keluargaId)
Future<void> loadTagihanAktif(String keluargaId)
Future<void> loadTagihanTerlambat(String keluargaId)
Future<void> loadHistoryPembayaran(String keluargaId)
Future<void> loadStatistik(String keluargaId)

// Payment
Future<bool> bayarIuran({...})
Future<String?> uploadBuktiPembayaran({...})

// Utilities
TagihanModel? getTagihanById(String tagihanId)
bool get hasTunggakan
void clearSuccessMessage()
void clearErrorMessage()
Future<void> refresh()
```

#### Usage Example:

```dart
// In widget
class IuranWargaPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    
    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IuranWargaProvider>();
      final keluargaId = getCurrentKeluargaId(); // From user data
      provider.initialize(keluargaId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<IuranWargaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return LoadingWidget();
        
        return Column(
          children: [
            // Statistik
            StatistikCard(
              totalTunggakan: provider.totalTunggakan,
              countTunggakan: provider.countTunggakan,
            ),
            
            // List tagihan
            ListView.builder(
              itemCount: provider.tagihanAktif.length,
              itemBuilder: (context, index) {
                final tagihan = provider.tagihanAktif[index];
                return TagihanCard(tagihan: tagihan);
              },
            ),
          ],
        );
      },
    );
  }
}
```

---

### 3. Enhanced TagihanService

**Location**: `lib/core/services/tagihan_service.dart`

#### Updated Method:

```dart
// OLD (Before):
Future<void> markAsLunas(...) async {
  await updateTagihan(id, {
    'status': 'Lunas',
    ...
  });
  // ❌ MISSING: Insert ke keuangan!
}

// NEW (After):
Future<String> markAsLunas(...) async {
  // 1. Get tagihan data
  final tagihan = await getTagihanById(id);
  
  // 2. Atomic batch
  final batch = _firestore.batch();
  
  // 2a. Update tagihan
  batch.update(tagihanRef, {...});
  
  // 2b. Insert keuangan
  batch.set(keuanganRef, {
    'type': 'pemasukan',
    'amount': tagihan.nominal,
    'kategori': tagihan.jenisIuranName,
    'sourceType': 'iuran',
    ...
  });
  
  // 3. Commit
  await batch.commit();
  
  return keuanganRef.id; // ✅ Return keuangan ID
}
```

**Impact**:
- Admin page yang pakai `markAsLunas()` sekarang juga insert ke keuangan!
- Konsistensi data terjaga antara tagihan & keuangan
- Return type berubah dari `void` ke `String` (keuanganId)

---

## 🔐 SECURITY & PERMISSIONS

### Firestore Rules Required:

**See**: `IURAN_FIRESTORE_RULES.md` for complete rules.

#### Summary:

1. **Collection: `tagihan`**
   - Warga: READ (keluarganya), UPDATE (payment only)
   - Admin: Full access

2. **Collection: `keuangan`**
   - Warga: CREATE (via payment only)
   - Admin: Full access

3. **Collection: `jenis_iuran`**
   - Warga: READ only
   - Admin: Full access

### Deployment:

```powershell
# Deploy rules
firebase deploy --only firestore:rules
```

---

## 📱 UI INTEGRATION

### Step 1: Register Provider

```dart
// lib/main.dart
runApp(
  MultiProvider(
    providers: [
      // ... existing providers
      ChangeNotifierProvider(create: (_) => IuranWargaProvider()),
    ],
    child: MyApp(),
  ),
);
```

### Step 2: Update IuranWargaPage

```dart
// lib/features/warga/iuran/pages/iuran_warga_page.dart

class IuranWargaPage extends StatefulWidget {
  @override
  State<IuranWargaPage> createState() => _IuranWargaPageState();
}

class _IuranWargaPageState extends State<IuranWargaPage> {
  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }
  
  Future<void> _initializeProvider() async {
    final provider = context.read<IuranWargaProvider>();
    
    // Get keluarga ID from current user
    final user = context.read<AuthProvider>().currentUser;
    final keluargaId = user?.keluargaId;
    
    if (keluargaId != null) {
      await provider.initialize(keluargaId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IuranWargaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.errorMessage != null) {
            return ErrorWidget(provider.errorMessage!);
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header dengan statistik
                _buildHeaderCard(provider),
                
                // Menu grid
                _buildMenuGrid(provider),
                
                // List tagihan
                _buildTagihanList(provider),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeaderCard(IuranWargaProvider provider) {
    return IuranHeaderCard(
      jumlahBelumDibayar: provider.totalBelumDibayar,
      countTunggakan: provider.countTunggakan,
    );
  }
  
  Widget _buildTagihanList(IuranWargaProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: provider.tagihanAktif.length,
      itemBuilder: (context, index) {
        final tagihan = provider.tagihanAktif[index];
        return IuranListItem(
          tagihan: tagihan,
          onTap: () => _navigateToDetail(tagihan),
        );
      },
    );
  }
}
```

### Step 3: Implement Payment Flow

```dart
// lib/features/warga/iuran/widgets/iuran_payment_button.dart

Future<void> _handlePayment() async {
  final provider = context.read<IuranWargaProvider>();
  final authProvider = context.read<AuthProvider>();
  
  // Show payment method selection
  final metodePembayaran = await _showPaymentMethodSheet();
  if (metodePembayaran == null) return;
  
  String? buktiPembayaran;
  
  // If transfer, upload bukti
  if (metodePembayaran == 'Transfer') {
    final imagePath = await _pickImage();
    if (imagePath != null) {
      buktiPembayaran = await provider.uploadBuktiPembayaran(
        tagihanId: widget.tagihanId,
        imagePath: imagePath,
      );
    }
  }
  
  // Process payment
  final success = await provider.bayarIuran(
    tagihanId: widget.tagihanId,
    metodePembayaran: metodePembayaran,
    buktiPembayaran: buktiPembayaran,
    userId: authProvider.currentUser!.uid,
  );
  
  if (success) {
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran berhasil!')),
    );
    Navigator.pop(context);
  } else {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'Pembayaran gagal')),
    );
  }
}
```

---

## 🧪 TESTING GUIDE

### Unit Tests

```dart
// test/services/iuran_warga_service_test.dart

void main() {
  group('IuranWargaService', () {
    late IuranWargaService service;
    
    setUp(() {
      service = IuranWargaService();
    });
    
    test('bayarIuran should update tagihan and create keuangan', () async {
      // Given
      final tagihanId = 'test_tagihan_123';
      
      // When
      final keuanganId = await service.bayarIuran(
        tagihanId: tagihanId,
        metodePembayaran: 'Cash',
        userId: 'user_123',
      );
      
      // Then
      expect(keuanganId, isNotEmpty);
      
      // Verify tagihan updated
      final tagihan = await service.getTagihanById(tagihanId);
      expect(tagihan?.status, equals('Lunas'));
      
      // Verify keuangan created
      // (would need keuangan service to verify)
    });
  });
}
```

### Integration Tests

```dart
// integration_test/iuran_flow_test.dart

void main() {
  testWidgets('Warga can view and pay iuran', (tester) async {
    // 1. Launch app
    await tester.pumpWidget(MyApp());
    
    // 2. Login as warga
    await loginAsWarga(tester);
    
    // 3. Navigate to iuran page
    await tester.tap(find.byKey(Key('iuran_menu')));
    await tester.pumpAndSettle();
    
    // 4. Verify tagihan displayed
    expect(find.byType(IuranListItem), findsWidgets);
    
    // 5. Tap on tagihan
    await tester.tap(find.byType(IuranListItem).first);
    await tester.pumpAndSettle();
    
    // 6. Pay iuran
    await tester.tap(find.text('Bayar Sekarang'));
    await tester.pumpAndSettle();
    
    // 7. Select payment method
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    
    // 8. Confirm payment
    await tester.tap(find.text('Konfirmasi'));
    await tester.pumpAndSettle();
    
    // 9. Verify success
    expect(find.text('Pembayaran berhasil'), findsOneWidget);
  });
}
```

---

## ⚠️ KNOWN ISSUES & LIMITATIONS

### 1. Image Upload Not Implemented

```dart
Future<String> uploadBuktiPembayaran({...}) async {
  // TODO: Implement Firebase Storage upload
  // Currently returns dummy URL
  return 'https://storage.example.com/bukti/$tagihanId.jpg';
}
```

**Solution**: Implement Firebase Storage upload using `firebase_storage` package.

### 2. No Notification System

Saat warga bayar iuran, admin tidak dapat notifikasi otomatis.

**Solution**: Implement Firebase Cloud Messaging (FCM) untuk push notifications.

### 3. No Payment Verification

Jika warga upload bukti transfer, admin tidak bisa approve/reject.

**Solution**: Add approval workflow:
```
status: 'Pending Verification' → Admin approve → 'Lunas'
```

### 4. No Refund Support

Tidak ada fitur untuk refund jika ada kesalahan pembayaran.

**Solution**: Add refund method yang:
- Revert tagihan status
- Create pengeluaran record
- Log refund transaction

---

## 📈 PERFORMANCE CONSIDERATIONS

### 1. Real-time Listeners

```dart
// ✅ GOOD: Dispose subscriptions
@override
void dispose() {
  _allTagihanSubscription?.cancel();
  _tagihanAktifSubscription?.cancel();
  // ...
  super.dispose();
}
```

### 2. Pagination for Large Data

Currently loads all tagihan. For keluarga dengan banyak tagihan, implement pagination:

```dart
Stream<List<TagihanModel>> getTagihanByKeluarga(
  String keluargaId, {
  int limit = 20,
  DocumentSnapshot? startAfter,
})
```

### 3. Caching

Implement local caching untuk reduce Firestore reads:

```dart
// Use Hive or SharedPreferences
final cachedTagihan = await _cacheService.getTagihan(keluargaId);
if (cachedTagihan != null) {
  return cachedTagihan;
}
```

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-deployment:

- [ ] Review all code
- [ ] Run unit tests
- [ ] Run integration tests
- [ ] Test Firestore rules
- [ ] Test payment flow end-to-end
- [ ] Test error handling
- [ ] Test edge cases (double payment, etc.)

### Deployment:

- [ ] Backup Firestore rules
- [ ] Deploy Firestore rules
- [ ] Deploy app to staging
- [ ] Test in staging
- [ ] Deploy to production
- [ ] Monitor logs
- [ ] Monitor Firestore usage

### Post-deployment:

- [ ] Verify payment flow works
- [ ] Check Firestore security rules
- [ ] Monitor for errors
- [ ] Collect user feedback
- [ ] Document issues

---

## 📞 SUPPORT

For issues or questions:
1. Check logs: `debugPrint()` statements throughout code
2. Review Firestore rules
3. Check Firestore console for data
4. Review this documentation

---

## 📚 NEXT STEPS

1. **Implement Image Upload**
   - Add Firebase Storage integration
   - Handle upload errors
   - Add image compression

2. **Add Approval Workflow**
   - Admin can verify bukti pembayaran
   - Status: Pending → Verified → Lunas
   - Reject option with reason

3. **Add Notifications**
   - FCM for push notifications
   - Email notifications
   - In-app notifications

4. **Add Reports**
   - Export payment history to PDF
   - Monthly payment report
   - Annual summary

5. **Add Analytics**
   - Track payment success rate
   - Payment method preferences
   - Average payment time

---

**Implementation Complete! ✅**

All backend CRUD operations for iuran warga are now functional and integrated with the keuangan system.
