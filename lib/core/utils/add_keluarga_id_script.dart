// ============================================================================
// SCRIPT: ADD keluargaId TO EXISTING USERS
// ============================================================================
// Script untuk menambahkan field keluargaId ke semua user yang sudah ada
// di Firestore
//
// CARA PAKAI:
// 1. Import script ini di main.dart atau file lain
// 2. Panggil AddKeluargaIdScript.run() saat app start (one-time)
// 3. Script akan update semua user dengan keluargaId default
// 4. Setelah selesai, hapus/comment script ini
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddKeluargaIdScript {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run script to add keluargaId to all existing users
  static Future<void> run() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('🔧 SCRIPT: Adding keluargaId to existing users');
    debugPrint('=' * 70);

    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      debugPrint('📊 Found ${usersSnapshot.docs.length} users');

      int updated = 0;
      int skipped = 0;

      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final userId = userDoc.id;
        final keluargaId = data['keluargaId'] as String?;

        // Skip if already has keluargaId
        if (keluargaId != null && keluargaId.isNotEmpty) {
          debugPrint('⏭️  User ${userDoc.id} already has keluargaId: $keluargaId');
          skipped++;
          continue;
        }

        // Generate keluargaId based on userId
        // Format: keluarga_[first_8_chars_of_userId]
        final newKeluargaId = 'keluarga_${userId.substring(0, userId.length > 8 ? 8 : userId.length)}';

        debugPrint('📝 Updating user: ${data['email']}');
        debugPrint('   Adding keluargaId: $newKeluargaId');

        // Update user document
        await userDoc.reference.update({
          'keluargaId': newKeluargaId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        updated++;
      }

      debugPrint('\n✅ Script completed!');
      debugPrint('   - Updated: $updated users');
      debugPrint('   - Skipped: $skipped users (already have keluargaId)');
      debugPrint('=' * 70 + '\n');

    } catch (e, stackTrace) {
      debugPrint('\n❌ Script failed!');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('=' * 70 + '\n');
    }
  }

  /// Alternative: Update specific user with specific keluargaId
  static Future<void> updateUser({
    required String userId,
    required String keluargaId,
  }) async {
    try {
      debugPrint('🔧 Updating user: $userId');
      debugPrint('   keluargaId: $keluargaId');

      await _firestore.collection('users').doc(userId).update({
        'keluargaId': keluargaId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ User updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update user: $e');
      rethrow;
    }
  }

  /// Check all users and their keluargaId status
  static Future<void> checkStatus() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('📊 CHECKING keluargaId STATUS');
    debugPrint('=' * 70);

    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int hasKeluargaId = 0;
      int noKeluargaId = 0;

      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final keluargaId = data['keluargaId'] as String?;
        final email = data['email'] ?? 'No email';

        if (keluargaId != null && keluargaId.isNotEmpty) {
          debugPrint('✅ ${email.padRight(30)} → keluargaId: $keluargaId');
          hasKeluargaId++;
        } else {
          debugPrint('❌ ${email.padRight(30)} → NO keluargaId');
          noKeluargaId++;
        }
      }

      debugPrint('\n📊 Summary:');
      debugPrint('   - Has keluargaId: $hasKeluargaId');
      debugPrint('   - Missing keluargaId: $noKeluargaId');
      debugPrint('=' * 70 + '\n');

    } catch (e) {
      debugPrint('❌ Error checking status: $e');
    }
  }
}

