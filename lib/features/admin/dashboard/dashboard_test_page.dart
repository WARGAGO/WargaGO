import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/services/dashboard_service.dart';

/// Dashboard CRUD Test Page
/// Halaman untuk test semua fungsi Dashboard CRUD
class DashboardTestPage extends StatefulWidget {
  const DashboardTestPage({super.key});

  @override
  State<DashboardTestPage> createState() => _DashboardTestPageState();
}

class _DashboardTestPageState extends State<DashboardTestPage> {
  final DashboardService _dashboardService = DashboardService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _logs = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard CRUD Test'),
        backgroundColor: const Color(0xFF2988EA),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Test Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runAllTests,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run All Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2988EA),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testCreate,
                        child: const Text('Test CREATE'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testRead,
                        child: const Text('Test READ'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testUpdate,
                        child: const Text('Test UPDATE'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isRunning ? null : _testDelete,
                        child: const Text('Test DELETE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Logs'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),

          // Logs Display
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color textColor = Colors.white;

                  if (log.startsWith('✅')) {
                    textColor = Colors.greenAccent;
                  } else if (log.startsWith('❌')) {
                    textColor = Colors.redAccent;
                  } else if (log.startsWith('⚠️')) {
                    textColor = Colors.orangeAccent;
                  } else if (log.startsWith('🔵')) {
                    textColor = Colors.blueAccent;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      log,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} | $message');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  // ============================================================================
  // RUN ALL TESTS
  // ============================================================================

  Future<void> _runAllTests() async {
    setState(() => _isRunning = true);
    _clearLogs();

    _addLog('🔵 ============================================');
    _addLog('🔵 STARTING DASHBOARD CRUD TESTS');
    _addLog('🔵 ============================================');
    _addLog('');

    try {
      // Test 1: CREATE
      _addLog('🔵 TEST 1: CREATE Operations');
      await _testCreate();
      await Future.delayed(const Duration(seconds: 1));

      // Test 2: READ
      _addLog('');
      _addLog('🔵 TEST 2: READ Operations');
      await _testRead();
      await Future.delayed(const Duration(seconds: 1));

      // Test 3: UPDATE
      _addLog('');
      _addLog('🔵 TEST 3: UPDATE Operations');
      await _testUpdate();
      await Future.delayed(const Duration(seconds: 1));

      // Test 4: DELETE
      _addLog('');
      _addLog('🔵 TEST 4: DELETE Operations');
      await _testDelete();

      _addLog('');
      _addLog('🔵 ============================================');
      _addLog('✅ ALL TESTS COMPLETED!');
      _addLog('🔵 ============================================');
    } catch (e) {
      _addLog('❌ TEST FAILED: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  // ============================================================================
  // TEST CREATE
  // ============================================================================

  Future<void> _testCreate() async {
    try {
      _addLog('📝 Creating test data...');

      // 1. Create Keuangan - Pemasukan
      _addLog('   → Creating pemasukan...');
      final pemasukanDoc = await _firestore.collection('keuangan').add({
        'type': 'pemasukan',
        'amount': 100000,
        'keterangan': 'Test Pemasukan - ${DateTime.now()}',
        'tanggal': Timestamp.now(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _addLog('   ✅ Pemasukan created: ${pemasukanDoc.id}');

      // 2. Create Keuangan - Pengeluaran
      _addLog('   → Creating pengeluaran...');
      final pengeluaranDoc = await _firestore.collection('keuangan').add({
        'type': 'pengeluaran',
        'amount': 50000,
        'keterangan': 'Test Pengeluaran - ${DateTime.now()}',
        'tanggal': Timestamp.now(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _addLog('   ✅ Pengeluaran created: ${pengeluaranDoc.id}');

      // 3. Create Kegiatan
      _addLog('   → Creating kegiatan...');
      final kegiatanDoc = await _firestore.collection('agenda').add({
        'type': 'kegiatan',
        'title': 'Test Kegiatan - ${DateTime.now()}',
        'kategori': 'Kebersihan & Keamanan',
        'tanggal': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'lokasi': 'Test Location',
        'penanggungJawab': 'Test PJ',
        'deskripsi': 'Test description',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _addLog('   ✅ Kegiatan created: ${kegiatanDoc.id}');

      // 4. Create Warga
      _addLog('   → Creating warga...');
      final wargaDoc = await _firestore.collection('warga').add({
        'nama': 'Test Warga - ${DateTime.now().millisecondsSinceEpoch}',
        'nik': '${1234567890123456 + DateTime.now().millisecondsSinceEpoch % 10000}',
        'jenisKelamin': 'Laki-laki',
        'tanggalLahir': Timestamp.fromDate(DateTime(1990, 1, 1)),
        'alamat': 'Test Address',
        'rt': '01',
        'rw': '02',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _addLog('   ✅ Warga created: ${wargaDoc.id}');

      _addLog('✅ CREATE Test Passed!');
    } catch (e) {
      _addLog('❌ CREATE Test Failed: $e');
    }
  }

  // ============================================================================
  // TEST READ
  // ============================================================================

  Future<void> _testRead() async {
    try {
      _addLog('📖 Reading dashboard data...');

      // 1. Test Kas Masuk
      _addLog('   → Getting total kas masuk...');
      final kasMasuk = await _dashboardService.getTotalKasMasuk();
      _addLog('   ✅ Kas Masuk: Rp ${kasMasuk.toStringAsFixed(0)}');

      // 2. Test Kas Keluar
      _addLog('   → Getting total kas keluar...');
      final kasKeluar = await _dashboardService.getTotalKasKeluar();
      _addLog('   ✅ Kas Keluar: Rp ${kasKeluar.toStringAsFixed(0)}');

      // 3. Test Saldo
      final saldo = kasMasuk - kasKeluar;
      _addLog('   ✅ Saldo: Rp ${saldo.toStringAsFixed(0)}');

      // 4. Test Total Transaksi
      _addLog('   → Getting total transaksi...');
      final totalTransaksi = await _dashboardService.getTotalTransaksi();
      _addLog('   ✅ Total Transaksi: $totalTransaksi');

      // 5. Test Total Kegiatan
      _addLog('   → Getting total kegiatan...');
      final totalKegiatan = await _dashboardService.getTotalKegiatan();
      _addLog('   ✅ Total Kegiatan: $totalKegiatan');

      // 6. Test Timeline
      _addLog('   → Getting kegiatan timeline...');
      final timeline = await _dashboardService.getKegiatanByTimeline();
      _addLog('   ✅ Sudah Lewat: ${timeline['sudah_lewat']}');
      _addLog('   ✅ Hari Ini: ${timeline['hari_ini']}');
      _addLog('   ✅ Akan Datang: ${timeline['akan_datang']}');

      // 7. Test Top PJ
      _addLog('   → Getting top penanggung jawab...');
      final topPJ = await _dashboardService.getTopPenanggungJawab();
      _addLog('   ✅ Top PJ: ${topPJ['nama']} (${topPJ['jumlah']} kegiatan)');

      // 8. Test Total Warga
      _addLog('   → Getting total warga...');
      final totalWarga = await _dashboardService.getTotalWarga();
      _addLog('   ✅ Total Warga: $totalWarga');

      // 9. Test Recent Activities
      _addLog('   → Getting recent activities...');
      final activities = await _dashboardService.getRecentActivities(limit: 5);
      _addLog('   ✅ Recent Activities: ${activities.length} items');

      // 10. Test Dashboard Summary (All in One)
      _addLog('   → Getting dashboard summary...');
      final summary = await _dashboardService.getDashboardSummary();
      _addLog('   ✅ Dashboard Summary loaded successfully');

      _addLog('✅ READ Test Passed!');
    } catch (e) {
      _addLog('❌ READ Test Failed: $e');
    }
  }

  // ============================================================================
  // TEST UPDATE
  // ============================================================================

  Future<void> _testUpdate() async {
    try {
      _addLog('✏️ Updating test data...');

      // 1. Find and Update Keuangan
      _addLog('   → Finding keuangan to update...');
      final keuanganQuery = await _firestore
          .collection('keuangan')
          .where('type', isEqualTo: 'pemasukan')
          .limit(1)
          .get();

      if (keuanganQuery.docs.isNotEmpty) {
        final doc = keuanganQuery.docs.first;
        _addLog('   → Updating keuangan: ${doc.id}...');

        await doc.reference.update({
          'amount': 150000,
          'keterangan': 'Updated - ${DateTime.now()}',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _addLog('   ✅ Keuangan updated successfully');
      } else {
        _addLog('   ⚠️ No keuangan found to update');
      }

      // 2. Find and Update Kegiatan
      _addLog('   → Finding kegiatan to update...');
      final kegiatanQuery = await _firestore
          .collection('agenda')
          .where('type', isEqualTo: 'kegiatan')
          .limit(1)
          .get();

      if (kegiatanQuery.docs.isNotEmpty) {
        final doc = kegiatanQuery.docs.first;
        _addLog('   → Updating kegiatan: ${doc.id}...');

        await doc.reference.update({
          'title': 'Updated Kegiatan - ${DateTime.now()}',
          'lokasi': 'Updated Location',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _addLog('   ✅ Kegiatan updated successfully');
      } else {
        _addLog('   ⚠️ No kegiatan found to update');
      }

      // 3. Find and Update Warga
      _addLog('   → Finding warga to update...');
      final wargaQuery = await _firestore
          .collection('warga')
          .limit(1)
          .get();

      if (wargaQuery.docs.isNotEmpty) {
        final doc = wargaQuery.docs.first;
        _addLog('   → Updating warga: ${doc.id}...');

        await doc.reference.update({
          'alamat': 'Updated Address - ${DateTime.now()}',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _addLog('   ✅ Warga updated successfully');
      } else {
        _addLog('   ⚠️ No warga found to update');
      }

      _addLog('✅ UPDATE Test Passed!');
    } catch (e) {
      _addLog('❌ UPDATE Test Failed: $e');
    }
  }

  // ============================================================================
  // TEST DELETE
  // ============================================================================

  Future<void> _testDelete() async {
    try {
      _addLog('🗑️ Deleting test data...');

      // 1. Delete Test Keuangan
      _addLog('   → Finding test keuangan to delete...');
      final keuanganQuery = await _firestore
          .collection('keuangan')
          .where('keterangan', isGreaterThanOrEqualTo: 'Test')
          .where('keterangan', isLessThanOrEqualTo: 'Test\uf8ff')
          .limit(5)
          .get();

      if (keuanganQuery.docs.isNotEmpty) {
        for (var doc in keuanganQuery.docs) {
          await doc.reference.delete();
          _addLog('   ✅ Deleted keuangan: ${doc.id}');
        }
      } else {
        _addLog('   ⚠️ No test keuangan found to delete');
      }

      // 2. Delete Test Kegiatan
      _addLog('   → Finding test kegiatan to delete...');
      final kegiatanQuery = await _firestore
          .collection('agenda')
          .where('title', isGreaterThanOrEqualTo: 'Test')
          .where('title', isLessThanOrEqualTo: 'Test\uf8ff')
          .limit(5)
          .get();

      if (kegiatanQuery.docs.isNotEmpty) {
        for (var doc in kegiatanQuery.docs) {
          await doc.reference.delete();
          _addLog('   ✅ Deleted kegiatan: ${doc.id}');
        }
      } else {
        _addLog('   ⚠️ No test kegiatan found to delete');
      }

      // 3. Delete Test Warga
      _addLog('   → Finding test warga to delete...');
      final wargaQuery = await _firestore
          .collection('warga')
          .where('nama', isGreaterThanOrEqualTo: 'Test')
          .where('nama', isLessThanOrEqualTo: 'Test\uf8ff')
          .limit(5)
          .get();

      if (wargaQuery.docs.isNotEmpty) {
        for (var doc in wargaQuery.docs) {
          await doc.reference.delete();
          _addLog('   ✅ Deleted warga: ${doc.id}');
        }
      } else {
        _addLog('   ⚠️ No test warga found to delete');
      }

      _addLog('✅ DELETE Test Passed!');
    } catch (e) {
      _addLog('❌ DELETE Test Failed: $e');
    }
  }
}

