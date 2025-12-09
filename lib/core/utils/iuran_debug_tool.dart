// ============================================================================
// IURAN DEBUG TOOL - Check why tagihan tidak muncul
// ============================================================================
// Run this from Flutter DevTools Console
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IuranDebugTool {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Check 1: User punya keluargaId?
  static Future<void> checkUserKeluargaId() async {
    print('\n' + '=' * 70);
    print('🔍 CHECK 1: User keluargaId');
    print('=' * 70);

    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No user logged in!');
      return;
    }

    print('✅ User logged in: ${user.email}');
    print('   UID: ${user.uid}');

    // Check in users collection
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      print('❌ User document not found in users collection!');
      return;
    }

    final userData = userDoc.data();
    final keluargaId = userData?['keluargaId'] as String?;

    if (keluargaId == null || keluargaId.isEmpty) {
      print('❌ User TIDAK PUNYA keluargaId!');
      print('   Solution: Tambahkan keluargaId ke user document');
      print('   Firestore Console: users/${user.uid}');
      print('   Add field: keluargaId = "KEL_XXX"');
      return;
    }

    print('✅ User punya keluargaId: $keluargaId');
    print('');
  }

  /// Check 2: Ada tagihan di Firestore?
  static Future<void> checkTagihanExists(String keluargaId) async {
    print('\n' + '=' * 70);
    print('🔍 CHECK 2: Tagihan di Firestore');
    print('=' * 70);

    final tagihanSnapshot = await _firestore
        .collection('tagihan')
        .where('keluargaId', isEqualTo: keluargaId)
        .get();

    print('📊 Total tagihan untuk keluargaId "$keluargaId": ${tagihanSnapshot.docs.length}');

    if (tagihanSnapshot.docs.isEmpty) {
      print('❌ TIDAK ADA TAGIHAN!');
      print('   Penyebab:');
      print('   1. Admin belum tambah jenis iuran');
      print('   2. Auto-tagihan tidak jalan');
      print('   3. keluargaId salah');
      print('');

      // Check if ada tagihan sama sekali
      final allTagihan = await _firestore.collection('tagihan').limit(5).get();
      print('📊 Sample tagihan di database (first 5):');
      for (var doc in allTagihan.docs) {
        final data = doc.data();
        print('   • ID: ${doc.id}');
        print('     keluargaId: ${data['keluargaId']}');
        print('     jenisIuranNama: ${data['jenisIuranNama']}');
        print('     nominal: ${data['nominal']}');
        print('     status: ${data['status']}');
        print('');
      }
      return;
    }

    print('✅ Found ${tagihanSnapshot.docs.length} tagihan:');
    for (var doc in tagihanSnapshot.docs) {
      final data = doc.data();
      print('   • ${data['jenisIuranNama'] ?? 'No Name'}');
      print('     Nominal: Rp ${data['nominal']}');
      print('     Status: ${data['status']}');
      print('     isActive: ${data['isActive']}');
      print('');
    }
  }

  /// Check 3: Data penduduk punya keluargaId?
  static Future<void> checkDataPenduduk() async {
    print('\n' + '=' * 70);
    print('🔍 CHECK 3: Data Penduduk keluargaId');
    print('=' * 70);

    final user = _auth.currentUser;
    if (user == null) return;

    final pendudukSnapshot = await _firestore
        .collection('data_penduduk')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (pendudukSnapshot.docs.isEmpty) {
      print('❌ User tidak ada di data_penduduk!');
      print('   Solution: Daftar dulu di menu Data Penduduk');
      return;
    }

    print('✅ Found user in data_penduduk:');
    for (var doc in pendudukSnapshot.docs) {
      final data = doc.data();
      print('   • Nama: ${data['namaLengkap']}');
      print('     keluargaId: ${data['keluargaId']}');
      print('     status: ${data['status']}');
      print('');
    }
  }

  /// Check 4: Jenis Iuran yang tersedia
  static Future<void> checkJenisIuran() async {
    print('\n' + '=' * 70);
    print('🔍 CHECK 4: Jenis Iuran Available');
    print('=' * 70);

    final jenisIuranSnapshot = await _firestore
        .collection('jenis_iuran')
        .where('isActive', isEqualTo: true)
        .get();

    print('📊 Total jenis iuran: ${jenisIuranSnapshot.docs.length}');

    if (jenisIuranSnapshot.docs.isEmpty) {
      print('❌ TIDAK ADA JENIS IURAN!');
      print('   Solution: Admin harus tambah jenis iuran dulu');
      return;
    }

    print('✅ Jenis iuran yang tersedia:');
    for (var doc in jenisIuranSnapshot.docs) {
      final data = doc.data();
      print('   • ${data['namaIuran']}');
      print('     ID: ${doc.id}');
      print('     Nominal: Rp ${data['jumlahIuran']}');
      print('     Kategori: ${data['kategoriIuran']}');
      print('');
    }
  }

  /// RUN ALL CHECKS
  static Future<void> runAllChecks() async {
    print('\n\n');
    print('🔍 IURAN DEBUG TOOL - RUNNING ALL CHECKS...');
    print('');

    await checkUserKeluargaId();

    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final keluargaId = userDoc.data()?['keluargaId'] as String?;

      if (keluargaId != null) {
        await checkTagihanExists(keluargaId);
      }
    }

    await checkDataPenduduk();
    await checkJenisIuran();

    print('\n' + '=' * 70);
    print('✅ ALL CHECKS COMPLETE');
    print('=' * 70);
    print('');
  }
}

// ============================================================================
// HOW TO USE:
// ============================================================================
// 1. Open Flutter DevTools Console
// 2. Run: await IuranDebugTool.runAllChecks();
// 3. Check output untuk cari masalah
// ============================================================================

