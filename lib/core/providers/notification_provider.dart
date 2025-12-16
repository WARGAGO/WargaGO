// ============================================================================
// NOTIFICATION PROVIDER
// ============================================================================
// Provider untuk manage notifikasi di aplikasi (IN-APP ONLY)
// GRATIS - Tidak perlu Cloud Functions atau push notification
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  int _unreadCount = 0;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  int get unreadCount => _unreadCount;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================================
  // INITIALIZE - Listen to Firestore for real-time updates
  // ============================================================================
  Future<void> initialize(String userId) async {
    debugPrint('🔵 [NotificationProvider] Initializing for user: $userId');
    
    // Listen to unread count
    _notificationService.getUnreadCount(userId).listen((count) {
      debugPrint('🔔 [NotificationProvider] Unread count updated: $count');
      _unreadCount = count;
      notifyListeners();
    });

    // Listen to notification history
    _notificationService.getNotificationHistory(userId).listen((snapshot) {
      debugPrint('📬 [NotificationProvider] Received ${snapshot.docs.length} notifications');
      _notifications = snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();

      // ⚠️ IMPORTANT: Sort by createdAt descending (client-side)
      // This avoids the need for composite index in Firestore
      _notifications.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      debugPrint('✅ [NotificationProvider] Sorted ${_notifications.length} notifications');
      notifyListeners();
    });

    debugPrint('✅ [NotificationProvider] Successfully initialized for user: $userId');
  }

  // ============================================================================
  // MARK AS READ
  // ============================================================================
  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  // ============================================================================
  // SEND NOTIFICATION FOR NEW ORDER
  // ============================================================================
  Future<void> sendNewOrderNotification({
    required String sellerId,
    required String orderId,
    required String productName,
    required String buyerName,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: sellerId,
      title: '🛒 Pesanan Baru!',
      body: '$buyerName memesan $productName',
      data: {
        'type': 'new_order',
        'orderId': orderId,
      },
    );
  }

  // ============================================================================
  // SEND NOTIFICATION FOR ORDER STATUS UPDATE
  // ============================================================================
  Future<void> sendOrderStatusNotification({
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

    await _notificationService.sendNotificationToUser(
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
  // SEND NOTIFICATION FOR NEW PRODUCT
  // ============================================================================
  Future<void> sendNewProductNotification({
    required String productId,
    required String productName,
    required String category,
  }) async {
    // Send to topic subscribers (e.g., users interested in this category)
    // Note: You'll need to implement topic subscription in your app
    // For now, we'll just log it
    debugPrint('📢 New product notification: $productName in $category');
  }

  // ============================================================================
  // SEND NOTIFICATION FOR LOW STOCK
  // ============================================================================
  Future<void> sendLowStockNotification({
    required String sellerId,
    required String productId,
    required String productName,
    required int stock,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: sellerId,
      title: '⚠️ Stok Menipis',
      body: '$productName tinggal $stock item',
      data: {
        'type': 'low_stock',
        'productId': productId,
      },
    );
  }

  // ============================================================================
  // SEND NOTIFICATION FOR PAYMENT RECEIVED
  // ============================================================================
  Future<void> sendPaymentReceivedNotification({
    required String sellerId,
    required String orderId,
    required String productName,
    required double amount,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: sellerId,
      title: '💰 Pembayaran Diterima',
      body: 'Pembayaran untuk $productName sebesar Rp ${amount.toStringAsFixed(0)} telah diterima',
      data: {
        'type': 'payment_received',
        'orderId': orderId,
      },
    );
  }

  // ============================================================================
  // 🗳️ SEND NOTIFICATION FOR NEW POLL
  // ============================================================================
  Future<void> sendNewPollNotification({
    required String pollId,
    required String pollTitle,
    required String pollType, // 'official' or 'community'
    required List<String> targetUserIds, // List of users to notify
  }) async {
    final icon = pollType == 'official' ? '🗳️' : '💬';
    final typeText = pollType == 'official' ? 'Polling Resmi' : 'Polling Komunitas';

    for (final userId in targetUserIds) {
      await _notificationService.sendNotificationToUser(
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
  }

  // ============================================================================
  // 🗳️ SEND NOTIFICATION FOR POLL RESULT
  // ============================================================================
  Future<void> sendPollResultNotification({
    required String pollId,
    required String pollTitle,
    required List<String> participantIds,
  }) async {
    for (final userId in participantIds) {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: '📊 Hasil Polling',
        body: 'Hasil polling "$pollTitle" sudah tersedia',
        data: {
          'type': 'poll_result',
          'pollId': pollId,
        },
      );
    }
  }

  // ============================================================================
  // 📅 SEND NOTIFICATION FOR NEW AGENDA/EVENT
  // ============================================================================
  Future<void> sendNewAgendaNotification({
    required String agendaId,
    required String agendaTitle,
    required String agendaDate,
    required String agendaLocation,
    required List<String> targetUserIds,
  }) async {
    for (final userId in targetUserIds) {
      await _notificationService.sendNotificationToUser(
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
  }

  // ============================================================================
  // 📅 SEND NOTIFICATION FOR AGENDA REMINDER
  // ============================================================================
  Future<void> sendAgendaReminderNotification({
    required String agendaId,
    required String agendaTitle,
    required String reminderTime, // e.g., "1 hari lagi", "1 jam lagi"
    required List<String> targetUserIds,
  }) async {
    for (final userId in targetUserIds) {
      await _notificationService.sendNotificationToUser(
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
  // 👤 SEND NOTIFICATION FOR NEW USER REGISTRATION (TO ADMIN)
  // ============================================================================
  Future<void> sendNewUserRegistrationNotification({
    required String newUserId,
    required String userName,
    required String userEmail,
    required List<String> adminUserIds, // List of admin IDs
  }) async {
    for (final adminId in adminUserIds) {
      await _notificationService.sendNotificationToUser(
        userId: adminId,
        title: '👤 Pendaftaran User Baru',
        body: '$userName ($userEmail) mendaftar dan memerlukan verifikasi',
        data: {
          'type': 'new_user_registration',
          'newUserId': newUserId,
        },
      );
    }
  }

  // ============================================================================
  // 📝 SEND NOTIFICATION FOR KYC STATUS UPDATE
  // ============================================================================
  Future<void> sendKYCStatusNotification({
    required String userId,
    required String documentType, // 'KTP' or 'KK'
    required String status, // 'approved', 'rejected', 'pending_review'
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

    await _notificationService.sendNotificationToUser(
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
  // 📢 SEND ANNOUNCEMENT NOTIFICATION (BROADCAST)
  // ============================================================================
  Future<void> sendAnnouncementNotification({
    required String announcementId,
    required String title,
    required String message,
    required List<String> targetUserIds, // All users or filtered list
    String? category, // 'urgent', 'info', 'event', etc.
  }) async {
    final icon = category == 'urgent' ? '🚨' : '📢';

    for (final userId in targetUserIds) {
      await _notificationService.sendNotificationToUser(
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
  }

  // ============================================================================
  // 💰 SEND NOTIFICATION FOR NEW TAGIHAN/IURAN
  // ============================================================================
  Future<void> sendNewTagihanNotification({
    required String tagihanId,
    required String userId,
    required String jenisIuran,
    required double nominal,
    required String periode,
    required String dueDate,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '💰 Tagihan Baru',
      body: 'Iuran $jenisIuran sebesar Rp ${nominal.toStringAsFixed(0)} - Jatuh tempo: $dueDate',
      data: {
        'type': 'new_tagihan',
        'tagihanId': tagihanId,
        'periode': periode,
      },
    );
  }

  // ============================================================================
  // 💰 SEND NOTIFICATION FOR TAGIHAN REMINDER
  // ============================================================================
  Future<void> sendTagihanReminderNotification({
    required String tagihanId,
    required String userId,
    required String jenisIuran,
    required double nominal,
    required String daysRemaining, // e.g., "3 hari lagi"
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '⏰ Pengingat Tagihan',
      body: 'Iuran $jenisIuran (Rp ${nominal.toStringAsFixed(0)}) jatuh tempo $daysRemaining',
      data: {
        'type': 'tagihan_reminder',
        'tagihanId': tagihanId,
      },
    );
  }

  // ============================================================================
  // ✅ SEND NOTIFICATION FOR PAYMENT CONFIRMATION
  // ============================================================================
  Future<void> sendPaymentConfirmationNotification({
    required String userId,
    required String jenisIuran,
    required double nominal,
    required String paymentDate,
  }) async {
    await _notificationService.sendNotificationToUser(
      userId: userId,
      title: '✅ Pembayaran Berhasil',
      body: 'Pembayaran iuran $jenisIuran sebesar Rp ${nominal.toStringAsFixed(0)} telah dikonfirmasi',
      data: {
        'type': 'payment_confirmation',
        'jenisIuran': jenisIuran,
        'paymentDate': paymentDate,
      },
    );
  }

  // ============================================================================
  // 🏠 SEND NOTIFICATION FOR HOUSEHOLD UPDATE (TO FAMILY MEMBERS)
  // ============================================================================
  Future<void> sendHouseholdUpdateNotification({
    required String updateType, // 'member_added', 'member_removed', 'data_updated'
    required String message,
    required List<String> familyMemberIds,
  }) async {
    for (final userId in familyMemberIds) {
      await _notificationService.sendNotificationToUser(
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
  // 📊 SEND NOTIFICATION FOR FINANCIAL REPORT
  // ============================================================================
  Future<void> sendFinancialReportNotification({
    required String periode,
    required List<String> targetUserIds,
  }) async {
    for (final userId in targetUserIds) {
      await _notificationService.sendNotificationToUser(
        userId: userId,
        title: '📊 Laporan Keuangan Tersedia',
        body: 'Laporan keuangan periode $periode telah dipublikasikan',
        data: {
          'type': 'financial_report',
          'periode': periode,
        },
      );
    }
  }

  // ============================================================================
  // BROADCAST NOTIFICATION TO ALL USERS
  // ============================================================================
  Future<void> broadcastNotificationToAllUsers({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'verified') // Only verified users
          .get();

      final userIds = usersSnapshot.docs.map((doc) => doc.id).toList();

      // Send to all users
      for (final userId in userIds) {
        await _notificationService.sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          data: {
            'type': type,
            ...?additionalData,
          },
        );
      }

      debugPrint('✅ Broadcast notification sent to ${userIds.length} users');
    } catch (e) {
      debugPrint('❌ Error broadcasting notification: $e');
    }
  }
}

// ============================================================================
// NOTIFICATION MODEL
// ============================================================================
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: data['data'] ?? {},
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

