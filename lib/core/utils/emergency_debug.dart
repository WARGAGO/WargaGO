// ============================================================================
// EMERGENCY DEBUG SCRIPT - CHECK DATA ACTUAL
// ============================================================================
// Run this to check actual data in Firestore and find the mismatch
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class EmergencyDebug {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emergency check - print EVERYTHING
  static Future<void> checkEverything() async {
    debugPrint('\n' + '=' * 80);
    debugPrint('🚨 EMERGENCY DEBUG - CHECKING ACTUAL DATA');
    debugPrint('=' * 80);

    // 1. Check current user
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('❌ NO USER LOGGED IN!');
      return;
    }

    debugPrint('\n📱 CURRENT USER:');
    debugPrint('   UID: ${currentUser.uid}');
    debugPrint('   Email: ${currentUser.email}');

    // 2. Get user document
    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

    if (!userDoc.exists) {
      debugPrint('❌ USER DOCUMENT NOT FOUND!');
      return;
    }

    final userData = userDoc.data()!;
    debugPrint('\n👤 USER DATA:');
    userData.forEach((key, value) {
      if (key != 'password') {
        debugPrint('   $key: $value');
      }
    });

    final userKeluargaId = userData['keluargaId'] as String?;
    debugPrint('\n⭐ USER KELUARGA ID: "$userKeluargaId"');

    if (userKeluargaId == null || userKeluargaId.isEmpty) {
      debugPrint('❌ USER HAS NO KELUARGA ID!');
      return;
    }

    // 3. Check ALL tagihan in collection
    debugPrint('\n📋 ALL TAGIHAN IN FIRESTORE:');
    final allTagihan = await _firestore.collection('tagihan').get();
    debugPrint('   Total: ${allTagihan.docs.length} documents');

    for (var doc in allTagihan.docs) {
      final data = doc.data();
      debugPrint('\n   📄 ${doc.id}');
      debugPrint('      keluargaId: "${data['keluargaId']}"');
      debugPrint('      jenisIuranName: ${data['jenisIuranName']}');
      debugPrint('      status: ${data['status']}');
      debugPrint('      isActive: ${data['isActive']}');
      debugPrint('      nominal: ${data['nominal']}');

      // Check if matches user
      final tagihanKeluargaId = data['keluargaId'] as String?;
      if (tagihanKeluargaId == userKeluargaId) {
        debugPrint('      ✅ MATCHES USER KELUARGA ID!');
      } else {
        debugPrint('      ❌ DOES NOT MATCH (user: "$userKeluargaId" vs tagihan: "$tagihanKeluargaId")');
      }
    }

    // 4. Query tagihan with user's keluargaId
    debugPrint('\n🔍 QUERYING TAGIHAN WITH USER KELUARGA ID:');
    debugPrint('   Query: where keluargaId == "$userKeluargaId"');

    final matchingTagihan = await _firestore
        .collection('tagihan')
        .where('keluargaId', isEqualTo: userKeluargaId)
        .get();

    debugPrint('   Result: ${matchingTagihan.docs.length} documents');

    if (matchingTagihan.docs.isEmpty) {
      debugPrint('\n❌ NO MATCHING TAGIHAN FOUND!');
      debugPrint('   POSSIBLE REASONS:');
      debugPrint('   1. Admin belum buat tagihan untuk keluargaId: "$userKeluargaId"');
      debugPrint('   2. Typo di keluargaId (check exact string, spaces, case)');
      debugPrint('   3. Tagihan.keluargaId berbeda dengan user.keluargaId');
    } else {
      debugPrint('\n✅ FOUND MATCHING TAGIHAN:');
      for (var doc in matchingTagihan.docs) {
        final data = doc.data();
        debugPrint('\n   📄 ${data['jenisIuranName']}');
        debugPrint('      Status: ${data['status']}');
        debugPrint('      Active: ${data['isActive']}');
        debugPrint('      Nominal: Rp ${data['nominal']}');
      }
    }

    // 5. Check with isActive filter
    debugPrint('\n🔍 QUERYING WITH isActive = true:');
    final activeTagihan = await _firestore
        .collection('tagihan')
        .where('keluargaId', isEqualTo: userKeluargaId)
        .where('isActive', isEqualTo: true)
        .get();

    debugPrint('   Result: ${activeTagihan.docs.length} documents');

    if (activeTagihan.docs.isEmpty && matchingTagihan.docs.isNotEmpty) {
      debugPrint('   ⚠️ WARNING: Tagihan exists but all are INACTIVE!');
      debugPrint('   Solution: Set isActive = true in Firebase Console');
    }

    // 6. Compare exact bytes
    debugPrint('\n🔬 EXACT STRING COMPARISON:');
    debugPrint('   User keluargaId bytes: ${userKeluargaId.codeUnits}');
    debugPrint('   User keluargaId length: ${userKeluargaId.length}');

    for (var doc in allTagihan.docs) {
      final tagihanKeluargaId = doc.data()['keluargaId'] as String?;
      if (tagihanKeluargaId != null) {
        final matches = tagihanKeluargaId == userKeluargaId;
        debugPrint('\n   Tagihan ${doc.id}:');
        debugPrint('      Value: "$tagihanKeluargaId"');
        debugPrint('      Bytes: ${tagihanKeluargaId.codeUnits}');
        debugPrint('      Length: ${tagihanKeluargaId.length}');
        debugPrint('      Matches: $matches');

        if (!matches) {
          // Find differences
          debugPrint('      DIFFERENCES:');
          if (userKeluargaId.length != tagihanKeluargaId.length) {
            debugPrint('         - Length: user=${userKeluargaId.length} vs tagihan=${tagihanKeluargaId.length}');
          }
          if (userKeluargaId.trim() == tagihanKeluargaId.trim()) {
            debugPrint('         - Has extra SPACES!');
          }
          if (userKeluargaId.toLowerCase() == tagihanKeluargaId.toLowerCase()) {
            debugPrint('         - CASE MISMATCH!');
          }
        }
      }
    }

    debugPrint('\n' + '=' * 80);
    debugPrint('🚨 EMERGENCY DEBUG COMPLETE');
    debugPrint('=' * 80 + '\n');
  }

  /// Quick fix - show exact match/mismatch
  static Future<String> getDiagnosticMessage() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return '❌ Not logged in';

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return '❌ User document not found';

      final userKeluargaId = userDoc.data()?['keluargaId'] as String?;
      if (userKeluargaId == null) return '❌ User has no keluargaId';

      final tagihan = await _firestore
          .collection('tagihan')
          .where('keluargaId', isEqualTo: userKeluargaId)
          .where('isActive', isEqualTo: true)
          .get();

      if (tagihan.docs.isEmpty) {
        final allTagihan = await _firestore.collection('tagihan').limit(5).get();
        final tagihanIds = allTagihan.docs
            .map((d) => d.data()['keluargaId'] as String?)
            .where((id) => id != null)
            .toList();

        return '❌ No matching tagihan!\n'
            'User keluargaId: "$userKeluargaId"\n'
            'Available keluargaIds: $tagihanIds\n'
            'Possible typo or mismatch!';
      }

      return '✅ Found ${tagihan.docs.length} tagihan';
    } catch (e) {
      return '❌ Error: $e';
    }
  }
}

