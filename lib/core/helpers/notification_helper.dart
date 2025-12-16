// ============================================================================
// NOTIFICATION HELPER
// ============================================================================
// Helper untuk trigger notifikasi tanpa Cloud Functions
// IN-APP NOTIFICATIONS ONLY - 100% GRATIS!
// User lihat notifikasi dengan tap icon bell di app
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================================
  // SEND NOTIFICATION (Save to Firestore - User sees in app)
  // ============================================================================
  static Future<void> _sendNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      debugPrint('🔵 [NotificationHelper] Sending notification...');
      debugPrint('   User ID: $userId');
      debugPrint('   Title: $title');
      debugPrint('   Body: $body');
      debugPrint('   Type: ${data['type']}');
      
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Notification sent successfully to user $userId');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
    }
  }

  // ============================================================================
  // GET ALL ADMIN USER IDs
  // ============================================================================
  static Future<List<String>> _getAdminUserIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('❌ Error getting admin users: $e');
      return [];
    }
  }

  // ============================================================================
  // GET ALL VERIFIED USER IDs
  // ============================================================================
  static Future<List<String>> _getAllVerifiedUserIds() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'verified')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('❌ Error getting verified users: $e');
      return [];
    }
  }

  // ============================================================================
  // 🗳️ POLLING NOTIFICATIONS
  // ============================================================================

  /// Send notification when new poll is created
  static Future<void> notifyNewPoll({
    required String pollId,
    required String pollTitle,
    required String pollType,
  }) async {
    final icon = pollType == 'official' ? '🗳️' : '💬';
    final typeText = pollType == 'official' ? 'Polling Resmi' : 'Polling Komunitas';

    final userIds = await _getAllVerifiedUserIds();

    for (final userId in userIds) {
      await _sendNotification(
        userId: userId,
        title: '$icon $typeText Baru!',
        body: pollTitle,
        data: {
          'type': 'new_poll',
          'pollId': pollId,
          'pollType': pollType,
        },
      );
    }

    debugPrint('✅ Poll notification sent to ${userIds.length} users');
  }

  /// Send notification when poll ends (to participants)
  static Future<void> notifyPollResult({
    required String pollId,
    required String pollTitle,
    required List<String> participantIds,
  }) async {
    for (final userId in participantIds) {
      await _sendNotification(
        userId: userId,
        title: '📊 Hasil Polling',
        body: 'Hasil polling "$pollTitle" sudah tersedia',
        data: {
          'type': 'poll_result',
          'pollId': pollId,
        },
      );
    }

    debugPrint('✅ Poll result notification sent to ${participantIds.length} participants');
  }

  // ============================================================================
  // 📅 AGENDA/EVENT NOTIFICATIONS
  // ============================================================================

  /// Send notification when new agenda is created
  static Future<void> notifyNewAgenda({
    required String agendaId,
    required String agendaTitle,
    required String agendaDate,
    required String agendaLocation,
  }) async {
    final userIds = await _getAllVerifiedUserIds();

    for (final userId in userIds) {
      await _sendNotification(
        userId: userId,
        title: '📅 Kegiatan Baru!',
        body: '$agendaTitle - $agendaDate',
        data: {
          'type': 'new_agenda',
          'agendaId': agendaId,
          'location': agendaLocation,
        },
      );
    }

    debugPrint('✅ Agenda notification sent to ${userIds.length} users');
  }

  /// Send agenda reminder (call this from UI when needed)
  static Future<void> notifyAgendaReminder({
    required String agendaId,
    required String agendaTitle,
    required String reminderTime,
    required List<String> targetUserIds,
  }) async {
    for (final userId in targetUserIds) {
      await _sendNotification(
        userId: userId,
        title: '⏰ Pengingat Kegiatan',
        body: '$agendaTitle - $reminderTime',
        data: {
          'type': 'agenda_reminder',
          'agendaId': agendaId,
        },
      );
    }
  }

  // ============================================================================
  // 👤 USER REGISTRATION NOTIFICATIONS
  // ============================================================================

  /// Send notification to admins when new user registers
  static Future<void> notifyNewUserRegistration({
    required String newUserId,
    required String userName,
    required String userEmail,
  }) async {
    final adminIds = await _getAdminUserIds();

    for (final adminId in adminIds) {
      await _sendNotification(
        userId: adminId,
        title: '👤 Pendaftaran User Baru',
        body: '$userName ($userEmail) mendaftar dan memerlukan verifikasi',
        data: {
          'type': 'new_user_registration',
          'newUserId': newUserId,
        },
      );
    }

    debugPrint('✅ New user notification sent to ${adminIds.length} admins');
  }

  // ============================================================================
  // 📝 KYC STATUS NOTIFICATIONS
  // ============================================================================

  /// Send notification when KYC status changes
  static Future<void> notifyKYCStatus({
    required String userId,
    required String documentType,
    required String status,
    String? rejectionReason,
  }) async {
    String title;
    String body;

    switch (status) {
      case 'approved':
        title = '✅ KYC Disetujui';
        body = 'Dokumen $documentType Anda telah diverifikasi';
        break;
      case 'rejected':
        title = '❌ KYC Ditolak';
        body = 'Dokumen $documentType ditolak. ${rejectionReason ?? "Silakan upload ulang"}';
        break;
      case 'pending_review':
        title = '⏳ KYC Dalam Review';
        body = 'Dokumen $documentType Anda sedang ditinjau';
        break;
      default:
        title = '📝 Update KYC';
        body = 'Status dokumen $documentType: $status';
    }

    await _sendNotification(
      userId: userId,
      title: title,
      body: body,
      data: {
        'type': 'kyc_status',
        'documentType': documentType,
        'status': status,
      },
    );
  }

  // ============================================================================
  // 📢 ANNOUNCEMENT NOTIFICATIONS
  // ============================================================================

  /// Send announcement to all users or specific group
  static Future<void> notifyAnnouncement({
    required String announcementId,
    required String title,
    required String message,
    String? category,
    List<String>? targetUserIds, // If null, send to all verified users
  }) async {
    final icon = category == 'urgent' ? '🚨' : '📢';
    final userIds = targetUserIds ?? await _getAllVerifiedUserIds();

    for (final userId in userIds) {
      await _sendNotification(
        userId: userId,
        title: '$icon $title',
        body: message,
        data: {
          'type': 'announcement',
          'announcementId': announcementId,
          'category': category ?? 'info',
        },
      );
    }

    debugPrint('✅ Announcement sent to ${userIds.length} users');
  }

  // ============================================================================
  // 💰 TAGIHAN/IURAN NOTIFICATIONS
  // ============================================================================

  /// Send notification for new tagihan
  static Future<void> notifyNewTagihan({
    required String tagihanId,
    required String userId,
    required String jenisIuran,
    required double nominal,
    required String periode,
    String? dueDate,
  }) async {
    await _sendNotification(
      userId: userId,
      title: '💰 Tagihan Baru',
      body: 'Iuran $jenisIuran sebesar Rp ${nominal.toStringAsFixed(0)}${dueDate != null ? " - Jatuh tempo: $dueDate" : ""}',
      data: {
        'type': 'new_tagihan',
        'tagihanId': tagihanId,
        'periode': periode,
      },
    );
  }

  /// Send tagihan reminder
  static Future<void> notifyTagihanReminder({
    required String tagihanId,
    required String userId,
    required String jenisIuran,
    required double nominal,
    required String daysRemaining,
  }) async {
    await _sendNotification(
      userId: userId,
      title: '⏰ Pengingat Tagihan',
      body: 'Iuran $jenisIuran (Rp ${nominal.toStringAsFixed(0)}) jatuh tempo $daysRemaining',
      data: {
        'type': 'tagihan_reminder',
        'tagihanId': tagihanId,
      },
    );
  }

  /// Send payment confirmation
  static Future<void> notifyPaymentConfirmation({
    required String userId,
    required String jenisIuran,
    required double nominal,
  }) async {
    await _sendNotification(
      userId: userId,
      title: '✅ Pembayaran Berhasil',
      body: 'Pembayaran iuran $jenisIuran sebesar Rp ${nominal.toStringAsFixed(0)} telah dikonfirmasi',
      data: {
        'type': 'payment_confirmation',
        'jenisIuran': jenisIuran,
      },
    );
  }

  // ============================================================================
  // 📦 ORDER STATUS UPDATE (Already handled by NotificationProvider)
  // ============================================================================

  /// Send order status update notification
  static Future<void> notifyOrderStatus({
    required String buyerId,
    required String orderId,
    required String status,
    required String productName,
  }) async {
    String statusText;
    switch (status) {
      case 'confirmed':
        statusText = 'dikonfirmasi';
        break;
      case 'preparing':
        statusText = 'sedang disiapkan';
        break;
      case 'ready':
        statusText = 'siap diambil';
        break;
      case 'completed':
        statusText = 'selesai';
        break;
      case 'cancelled':
        statusText = 'dibatalkan';
        break;
      default:
        statusText = status;
    }

    await _sendNotification(
      userId: buyerId,
      title: '📦 Update Pesanan',
      body: 'Pesanan $productName telah $statusText',
      data: {
        'type': 'order_status',
        'orderId': orderId,
        'status': status,
      },
    );
  }

  // ============================================================================
  // 🏠 HOUSEHOLD UPDATE
  // ============================================================================

  /// Send notification for household/family data update
  static Future<void> notifyHouseholdUpdate({
    required String updateType,
    required String message,
    required List<String> familyMemberIds,
  }) async {
    for (final userId in familyMemberIds) {
      await _sendNotification(
        userId: userId,
        title: '🏠 Update Data Keluarga',
        body: message,
        data: {
          'type': 'household_update',
          'updateType': updateType,
        },
      );
    }
  }

  // ============================================================================
  // 📊 FINANCIAL REPORT
  // ============================================================================

  /// Send financial report notification
  static Future<void> notifyFinancialReport({
    required String periode,
  }) async {
    final userIds = await _getAllVerifiedUserIds();

    for (final userId in userIds) {
      await _sendNotification(
        userId: userId,
        title: '📊 Laporan Keuangan Tersedia',
        body: 'Laporan keuangan periode $periode telah dipublikasikan',
        data: {
          'type': 'financial_report',
          'periode': periode,
        },
      );
    }

    debugPrint('✅ Financial report notification sent to ${userIds.length} users');
  }

  // ============================================================================
  // BROADCAST TO ALL
  // ============================================================================

  /// Broadcast custom notification to all verified users
  static Future<void> broadcastToAll({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    final userIds = await _getAllVerifiedUserIds();

    for (final userId in userIds) {
      await _sendNotification(
        userId: userId,
        title: title,
        body: body,
        data: {
          'type': type,
          ...?additionalData,
        },
      );
    }

    debugPrint('✅ Broadcast sent to ${userIds.length} users');
  }
}

