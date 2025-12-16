// ============================================================================
// ANNOUNCEMENT HELPER
// ============================================================================
// Helper untuk broadcast pengumuman ke semua user
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../helpers/notification_helper.dart';

class AnnouncementHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Buat pengumuman dan kirim notifikasi ke semua user
  static Future<String?> createAnnouncement({
    required String title,
    required String message,
    required String category, // 'urgent', 'info', 'event', dll
    String? adminId,
  }) async {
    try {
      // Save to Firestore
      final announcementDoc = await _firestore.collection('announcements').add({
        'title': title,
        'message': message,
        'category': category,
        'createdBy': adminId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Announcement created: ${announcementDoc.id}');

      // 🔔 KIRIM NOTIFIKASI ke semua user
      await NotificationHelper.notifyAnnouncement(
        announcementId: announcementDoc.id,
        title: title,
        message: message,
        category: category,
      );
      debugPrint('✅ Announcement notification sent to all users');

      return announcementDoc.id;
    } catch (e) {
      debugPrint('❌ Error creating announcement: $e');
      return null;
    }
  }

  /// Broadcast message langsung ke semua user (tanpa save ke announcements)
  static Future<bool> broadcastMessage({
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await NotificationHelper.broadcastToAll(
        title: title,
        body: message,
        type: type,
      );

      debugPrint('✅ Broadcast message sent to all users');
      return true;
    } catch (e) {
      debugPrint('❌ Error broadcasting message: $e');
      return false;
    }
  }
}

