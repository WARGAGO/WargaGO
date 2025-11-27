// ============================================================================
// KELOLA LAPAK CRUD TEST
// ============================================================================
// Test script untuk verify semua CRUD operations berfungsi
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/models/pending_seller_model.dart';
import '../../../core/repositories/pending_seller_repository.dart';

class KelolaLapakCRUDTest {
  final PendingSellerRepository _repository = PendingSellerRepository();

  /// Test CREATE - Buat pending seller baru
  Future<void> testCreate() async {
    print('🧪 TEST CREATE - Creating pending seller...');

    final testSeller = PendingSellerModel(
      userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      nik: '1234567890123456',
      namaLengkap: 'Test Seller',
      namaToko: 'Toko Test',
      nomorTelepon: '08123456789',
      alamatToko: 'Jl. Test No. 123',
      rt: '001',
      rw: '002',
      deskripsiUsaha: 'Menjual produk test',
      kategoriProduk: ['Sayuran', 'Buah-buahan'],
      fotoKTPUrl: 'https://example.com/ktp.jpg',
      fotoSelfieKTPUrl: 'https://example.com/selfie.jpg',
      fotoTokoUrl: 'https://example.com/toko.jpg',
      status: SellerVerificationStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final result = await _repository.createPendingSeller(testSeller);
      if (result != null) {
        print('✅ CREATE SUCCESS - ID: $result');
        return;
      }
      print('❌ CREATE FAILED - Returned null');
    } catch (e) {
      print('❌ CREATE ERROR: $e');
    }
  }

  /// Test READ - Get all pending sellers
  Future<void> testRead() async {
    print('🧪 TEST READ - Getting pending sellers...');

    try {
      final stream = _repository.getAllPendingSellers();
      final sellers = await stream.first;

      print('✅ READ SUCCESS - Found ${sellers.length} pending sellers');
      for (var seller in sellers) {
        print('   - ${seller.namaLengkap} (${seller.namaToko})');
      }
    } catch (e) {
      print('❌ READ ERROR: $e');
    }
  }

  /// Test READ BY STATUS - Get sellers by status
  Future<void> testReadByStatus() async {
    print('🧪 TEST READ BY STATUS...');

    final statuses = [
      SellerVerificationStatus.pending,
      SellerVerificationStatus.approved,
      SellerVerificationStatus.rejected,
      SellerVerificationStatus.suspended,
    ];

    for (var status in statuses) {
      try {
        final stream = _repository.getSellersByStatus(status);
        final sellers = await stream.first;
        print('✅ Status ${status.toString().split('.').last}: ${sellers.length} sellers');
      } catch (e) {
        print('❌ ERROR for status $status: $e');
      }
    }
  }

  /// Test UPDATE - Update pending seller data
  Future<void> testUpdate(String sellerId) async {
    print('🧪 TEST UPDATE - Updating seller $sellerId...');

    try {
      final result = await _repository.updatePendingSeller(
        sellerId,
        {
          'namaToko': 'Toko Updated',
          'deskripsiUsaha': 'Updated description',
        },
      );

      if (result) {
        print('✅ UPDATE SUCCESS');
      } else {
        print('❌ UPDATE FAILED');
      }
    } catch (e) {
      print('❌ UPDATE ERROR: $e');
    }
  }

  /// Test APPROVE - Approve seller
  Future<void> testApprove(String sellerId) async {
    print('🧪 TEST APPROVE - Approving seller $sellerId...');

    try {
      final result = await _repository.approveSeller(
        sellerId,
        'test_admin',
        catatanAdmin: 'Approved by test',
      );

      if (result) {
        print('✅ APPROVE SUCCESS');
      } else {
        print('❌ APPROVE FAILED');
      }
    } catch (e) {
      print('❌ APPROVE ERROR: $e');
    }
  }

  /// Test REJECT - Reject seller
  Future<void> testReject(String sellerId) async {
    print('🧪 TEST REJECT - Rejecting seller $sellerId...');

    try {
      final result = await _repository.rejectSeller(
        sellerId,
        'test_admin',
        'Dokumen tidak lengkap',
      );

      if (result) {
        print('✅ REJECT SUCCESS');
      } else {
        print('❌ REJECT FAILED');
      }
    } catch (e) {
      print('❌ REJECT ERROR: $e');
    }
  }

  /// Test SUSPEND - Suspend approved seller
  Future<void> testSuspend(String userId) async {
    print('🧪 TEST SUSPEND - Suspending seller $userId...');

    try {
      final result = await _repository.suspendSeller(
        userId,
        'test_admin',
        'Pelanggaran aturan',
      );

      if (result) {
        print('✅ SUSPEND SUCCESS');
      } else {
        print('❌ SUSPEND FAILED');
      }
    } catch (e) {
      print('❌ SUSPEND ERROR: $e');
    }
  }

  /// Test REACTIVATE - Reactivate suspended seller
  Future<void> testReactivate(String userId) async {
    print('🧪 TEST REACTIVATE - Reactivating seller $userId...');

    try {
      final result = await _repository.reactivateSeller(
        userId,
        'test_admin',
      );

      if (result) {
        print('✅ REACTIVATE SUCCESS');
      } else {
        print('❌ REACTIVATE FAILED');
      }
    } catch (e) {
      print('❌ REACTIVATE ERROR: $e');
    }
  }

  /// Test DELETE - Delete pending seller
  Future<void> testDelete(String sellerId) async {
    print('🧪 TEST DELETE - Deleting seller $sellerId...');

    try {
      final result = await _repository.deletePendingSeller(sellerId);

      if (result) {
        print('✅ DELETE SUCCESS');
      } else {
        print('❌ DELETE FAILED');
      }
    } catch (e) {
      print('❌ DELETE ERROR: $e');
    }
  }

  /// Test STATISTICS - Get statistics
  Future<void> testStatistics() async {
    print('🧪 TEST STATISTICS - Getting statistics...');

    try {
      final stats = await _repository.getStatistics();

      print('✅ STATISTICS SUCCESS:');
      print('   - Pending: ${stats['pending']}');
      print('   - Approved: ${stats['approved']}');
      print('   - Rejected: ${stats['rejected']}');
      print('   - Suspended: ${stats['suspended']}');
    } catch (e) {
      print('❌ STATISTICS ERROR: $e');
    }
  }

  /// Run all tests
  Future<void> runAllTests() async {
    print('\n🚀 ========== KELOLA LAPAK CRUD TESTS ==========\n');

    // Test READ operations
    await testRead();
    print('');

    await testReadByStatus();
    print('');

    await testStatistics();
    print('');

    // Test CREATE
    await testCreate();
    print('');

    // Get first pending seller untuk test UPDATE, APPROVE, dll
    try {
      final sellers = await _repository.getAllPendingSellers().first;
      if (sellers.isNotEmpty) {
        final testSeller = sellers.first;
        final sellerId = testSeller.id;
        final userId = testSeller.userId;

        if (sellerId != null) {
          // Test UPDATE
          await testUpdate(sellerId);
          print('');

          // Uncomment untuk test operations lainnya:
          // await testApprove(sellerId);
          // await testReject(sellerId);
          // await testSuspend(userId);
          // await testReactivate(userId);
          // await testDelete(sellerId);
        }
      } else {
        print('⚠️ No pending sellers found for update/approve/reject tests');
      }
    } catch (e) {
      print('⚠️ Error getting test seller: $e');
    }

    print('\n🏁 ========== TESTS COMPLETED ==========\n');
  }
}

/// Widget untuk menjalankan test dari UI
class CRUDTestPage extends StatefulWidget {
  const CRUDTestPage({super.key});

  @override
  State<CRUDTestPage> createState() => _CRUDTestPageState();
}

class _CRUDTestPageState extends State<CRUDTestPage> {
  final KelolaLapakCRUDTest _test = KelolaLapakCRUDTest();
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Test - Kelola Lapak'),
        backgroundColor: const Color(0xFF2F80ED),
      ),
      body: Center(
        child: _isRunning
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  setState(() => _isRunning = true);
                  await _test.runAllTests();
                  setState(() => _isRunning = false);
                },
                child: const Text('Run All Tests'),
              ),
      ),
    );
  }
}

