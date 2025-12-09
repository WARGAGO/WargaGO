import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ============================================================================
/// IURAN WARGA DEBUG & TROUBLESHOOTING SCRIPT
/// ============================================================================
/// Script untuk debug kenapa tagihan tidak muncul di iuran warga
/// 
/// Cara pakai:
/// 1. Import file ini di iuran_warga_page.dart
/// 2. Panggil IuranDebugger.runDiagnostics() di initState
/// 3. Check console output untuk detail masalah
/// ============================================================================

class IuranDebugger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Run complete diagnostics
  static Future<void> runDiagnostics() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('🔍 IURAN WARGA DIAGNOSTICS - START');
    debugPrint('=' * 70);

    await _checkAuthentication();
    await _checkUserData();
    await _checkTagihanData();
    await _checkQueryResult();

    debugPrint('=' * 70);
    debugPrint('🔍 IURAN WARGA DIAGNOSTICS - COMPLETE');
    debugPrint('=' * 70 + '\n');
  }

  /// Step 1: Check if user is authenticated
  static Future<void> _checkAuthentication() async {
    debugPrint('\n📌 STEP 1: Checking Authentication...');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('❌ PROBLEM: No user logged in!');
      debugPrint('   Solution: Please login first');
      return;
    }

    debugPrint('✅ User authenticated');
    debugPrint('   - UID: ${currentUser.uid}');
    debugPrint('   - Email: ${currentUser.email}');
  }

  /// Step 2: Check user document and keluargaId
  static Future<void> _checkUserData() async {
    debugPrint('\n📌 STEP 2: Checking User Document...');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        debugPrint('❌ PROBLEM: User document not found!');
        debugPrint('   Collection: users');
        debugPrint('   Document ID: ${currentUser.uid}');
        debugPrint('   Solution: Create user document in Firestore');
        return;
      }

      debugPrint('✅ User document exists');
      
      final data = userDoc.data();
      debugPrint('   - Document data:');
      data?.forEach((key, value) {
        if (key != 'password') {
          debugPrint('     • $key: $value');
        }
      });

      final keluargaId = data?['keluargaId'] as String?;
      if (keluargaId == null || keluargaId.isEmpty) {
        debugPrint('❌ PROBLEM: User has no keluargaId!');
        debugPrint('   Field: keluargaId');
        debugPrint('   Current value: $keluargaId');
        debugPrint('   Solution: Add keluargaId field to user document');
        debugPrint('   Example: keluargaId: "keluarga_001"');
      } else {
        debugPrint('✅ User has keluargaId: $keluargaId');
      }
    } catch (e) {
      debugPrint('❌ ERROR reading user document: $e');
    }
  }

  /// Step 3: Check tagihan collection
  static Future<void> _checkTagihanData() async {
    debugPrint('\n📌 STEP 3: Checking Tagihan Collection...');
    
    try {
      // Get ALL tagihan (no filter)
      final allTagihan = await _firestore
          .collection('tagihan')
          .limit(10)
          .get();

      debugPrint('   Total tagihan in collection: ${allTagihan.docs.length}');

      if (allTagihan.docs.isEmpty) {
        debugPrint('❌ PROBLEM: No tagihan found in Firestore!');
        debugPrint('   Collection: tagihan');
        debugPrint('   Solution: Create tagihan from admin panel first');
        return;
      }

      debugPrint('✅ Found ${allTagihan.docs.length} tagihan documents:');
      
      for (var doc in allTagihan.docs) {
        final data = doc.data();
        debugPrint('\n   📄 Document: ${doc.id}');
        debugPrint('      - keluargaId: ${data['keluargaId']}');
        debugPrint('      - keluargaName: ${data['keluargaName']}');
        debugPrint('      - jenisIuranName: ${data['jenisIuranName']}');
        debugPrint('      - nominal: ${data['nominal']}');
        debugPrint('      - status: ${data['status']}');
        debugPrint('      - isActive: ${data['isActive']}');
        debugPrint('      - periode: ${data['periode']}');
      }

      // Check for inactive tagihan
      final inactiveCount = allTagihan.docs.where((doc) => 
        doc.data()['isActive'] == false
      ).length;
      
      if (inactiveCount > 0) {
        debugPrint('\n⚠️  WARNING: Found $inactiveCount inactive tagihan');
        debugPrint('   These will not appear in warga view');
      }
    } catch (e) {
      debugPrint('❌ ERROR reading tagihan: $e');
    }
  }

  /// Step 4: Check query result with user's keluargaId
  static Future<void> _checkQueryResult() async {
    debugPrint('\n📌 STEP 4: Testing Query with User\'s keluargaId...');
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Get user's keluargaId
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final keluargaId = userDoc.data()?['keluargaId'] as String?;
      
      if (keluargaId == null || keluargaId.isEmpty) {
        debugPrint('⏭️  SKIPPED: No keluargaId to query');
        return;
      }

      debugPrint('   Querying tagihan for keluargaId: $keluargaId');

      // Query tagihan by keluargaId (same as app does)
      final tagihanQuery = await _firestore
          .collection('tagihan')
          .where('keluargaId', isEqualTo: keluargaId)
          .where('isActive', isEqualTo: true)
          .get();

      debugPrint('   Query result: ${tagihanQuery.docs.length} documents');

      if (tagihanQuery.docs.isEmpty) {
        debugPrint('❌ PROBLEM: No tagihan found for this keluargaId!');
        debugPrint('   - User\'s keluargaId: $keluargaId');
        debugPrint('   - Query: tagihan where keluargaId == "$keluargaId" AND isActive == true');
        debugPrint('\n   🔍 DIAGNOSIS:');
        debugPrint('   1. Check if admin created tagihan with correct keluargaId');
        debugPrint('   2. Check if tagihan.keluargaId matches user.keluargaId exactly');
        debugPrint('   3. Check if tagihan.isActive = true');
        
        debugPrint('\n   💡 SOLUTION:');
        debugPrint('   Option A: Update tagihan.keluargaId to match "$keluargaId"');
        debugPrint('   Option B: Update user.keluargaId to match tagihan.keluargaId');
      } else {
        debugPrint('✅ Found ${tagihanQuery.docs.length} tagihan for this user!');
        
        for (var doc in tagihanQuery.docs) {
          final data = doc.data();
          debugPrint('\n   📄 ${data['jenisIuranName']}');
          debugPrint('      Status: ${data['status']}');
          debugPrint('      Nominal: Rp ${data['nominal']}');
          debugPrint('      Periode: ${data['periode']}');
        }

        debugPrint('\n   ✅ These tagihan SHOULD appear in warga view!');
      }

      // Check by status
      final statusBreakdown = <String, int>{};
      for (var doc in tagihanQuery.docs) {
        final status = doc.data()['status'] as String? ?? 'Unknown';
        statusBreakdown[status] = (statusBreakdown[status] ?? 0) + 1;
      }

      if (statusBreakdown.isNotEmpty) {
        debugPrint('\n   📊 Status breakdown:');
        statusBreakdown.forEach((status, count) {
          debugPrint('      - $status: $count');
        });
      }
    } catch (e) {
      debugPrint('❌ ERROR during query test: $e');
    }
  }

  /// Quick check - untuk dipanggil di initState
  static Future<Map<String, dynamic>> quickCheck() async {
    final result = <String, dynamic>{
      'hasUser': false,
      'hasKeluargaId': false,
      'keluargaId': null,
      'tagihanCount': 0,
      'error': null,
    };

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        result['error'] = 'No user logged in';
        return result;
      }
      result['hasUser'] = true;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        result['error'] = 'User document not found';
        return result;
      }

      final keluargaId = userDoc.data()?['keluargaId'] as String?;
      if (keluargaId != null && keluargaId.isNotEmpty) {
        result['hasKeluargaId'] = true;
        result['keluargaId'] = keluargaId;

        final tagihan = await _firestore
            .collection('tagihan')
            .where('keluargaId', isEqualTo: keluargaId)
            .where('isActive', isEqualTo: true)
            .get();

        result['tagihanCount'] = tagihan.docs.length;
      } else {
        result['error'] = 'User has no keluargaId';
      }
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }

  /// Print summary in UI-friendly format
  static String getSummary(Map<String, dynamic> checkResult) {
    if (checkResult['error'] != null) {
      return '❌ Error: ${checkResult['error']}';
    }

    if (!checkResult['hasKeluargaId']) {
      return '⚠️ User tidak punya keluargaId';
    }

    final count = checkResult['tagihanCount'] as int;
    final keluargaId = checkResult['keluargaId'];
    
    if (count == 0) {
      return '❌ Tidak ada tagihan untuk keluargaId: $keluargaId';
    }

    return '✅ Ditemukan $count tagihan';
  }
}
