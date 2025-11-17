import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/services/dashboard_service.dart';

/// Quick Dashboard CRUD Test
/// Script untuk test cepat di console/debug
///
/// CARA PAKAI:
/// 1. Import file ini di main.dart
/// 2. Call quickTestDashboard() di initState atau onPressed button
/// 3. Lihat hasil di Debug Console
class QuickDashboardTest {
  final DashboardService _dashboardService = DashboardService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run quick test - Buat 1 data tiap collection dan read
  Future<void> runQuickTest() async {
    print('');
    print('🔵 ============================================');
    print('🔵 QUICK DASHBOARD CRUD TEST');
    print('🔵 ============================================');
    print('');

    try {
      // 1. CREATE Test Data
      print('📝 CREATING TEST DATA...');
      await _createTestData();

      print('');

      // 2. READ Dashboard Data
      print('📖 READING DASHBOARD DATA...');
      await _readDashboardData();

      print('');
      print('✅ QUICK TEST COMPLETED!');
      print('🔵 ============================================');
    } catch (e) {
      print('❌ TEST FAILED: $e');
    }
  }

  /// Create test data
  Future<void> _createTestData() async {
    // Create pemasukan
    await _firestore.collection('keuangan').add({
      'type': 'pemasukan',
      'amount': 50000,
      'keterangan': 'Quick Test Pemasukan',
      'tanggal': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('   ✅ Created: Pemasukan Rp 50.000');

    // Create pengeluaran
    await _firestore.collection('keuangan').add({
      'type': 'pengeluaran',
      'amount': 25000,
      'keterangan': 'Quick Test Pengeluaran',
      'tanggal': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('   ✅ Created: Pengeluaran Rp 25.000');

    // Create kegiatan
    await _firestore.collection('agenda').add({
      'type': 'kegiatan',
      'title': 'Quick Test Kegiatan',
      'kategori': 'Test',
      'tanggal': Timestamp.now(),
      'lokasi': 'Test Location',
      'penanggungJawab': 'Quick Test PJ',
      'deskripsi': 'Test kegiatan',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('   ✅ Created: Kegiatan');
  }

  /// Read dashboard data
  Future<void> _readDashboardData() async {
    final kasMasuk = await _dashboardService.getTotalKasMasuk();
    print('   💰 Kas Masuk: Rp ${kasMasuk.toStringAsFixed(0)}');

    final kasKeluar = await _dashboardService.getTotalKasKeluar();
    print('   💸 Kas Keluar: Rp ${kasKeluar.toStringAsFixed(0)}');

    final saldo = kasMasuk - kasKeluar;
    print('   💵 Saldo: Rp ${saldo.toStringAsFixed(0)}');

    final totalTransaksi = await _dashboardService.getTotalTransaksi();
    print('   📊 Total Transaksi: $totalTransaksi');

    final totalKegiatan = await _dashboardService.getTotalKegiatan();
    print('   📅 Total Kegiatan: $totalKegiatan');
  }

  /// Test individual CRUD operation
  Future<void> testCreate() async {
    print('📝 Testing CREATE...');

    final doc = await _firestore.collection('keuangan').add({
      'type': 'pemasukan',
      'amount': 100000,
      'keterangan': 'Test Create',
      'tanggal': Timestamp.now(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Created: ${doc.id}');
  }

  Future<void> testRead() async {
    print('📖 Testing READ...');

    final kasMasuk = await _dashboardService.getTotalKasMasuk();
    final kasKeluar = await _dashboardService.getTotalKasKeluar();
    final totalTransaksi = await _dashboardService.getTotalTransaksi();

    print('✅ Kas Masuk: Rp $kasMasuk');
    print('✅ Kas Keluar: Rp $kasKeluar');
    print('✅ Total Transaksi: $totalTransaksi');
  }

  Future<void> testUpdate() async {
    print('✏️ Testing UPDATE...');

    final query = await _firestore
        .collection('keuangan')
        .where('type', isEqualTo: 'pemasukan')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      await doc.reference.update({
        'amount': 200000,
        'keterangan': 'Updated',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Updated: ${doc.id}');
    } else {
      print('⚠️ No data to update');
    }
  }

  Future<void> testDelete() async {
    print('🗑️ Testing DELETE...');

    final query = await _firestore
        .collection('keuangan')
        .where('keterangan', isEqualTo: 'Quick Test Pemasukan')
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      await doc.reference.delete();
      print('✅ Deleted: ${doc.id}');
    } else {
      print('⚠️ No test data to delete');
    }
  }
}

// ============================================================================
// HELPER FUNCTION - Call ini untuk quick test
// ============================================================================

Future<void> quickTestDashboard() async {
  final test = QuickDashboardTest();
  await test.runQuickTest();
}

// ============================================================================
// CARA PAKAI:
// ============================================================================
//
// 1. Di main.dart atau di mana saja:
//
// import 'quick_dashboard_test.dart';
//
// // Test saat app start
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   // Run quick test
//   await quickTestDashboard();
//
//   runApp(MyApp());
// }
//
// 2. Atau di button onPressed:
//
// ElevatedButton(
//   onPressed: () async {
//     await quickTestDashboard();
//   },
//   child: Text('Test Dashboard CRUD'),
// )
//
// 3. Lihat hasil di Debug Console (Run tab di VS Code)
//
// ============================================================================

