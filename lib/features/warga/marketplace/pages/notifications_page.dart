// ============================================================================
// NOTIFICATIONS PAGE
// ============================================================================
// Halaman untuk melihat semua notifikasi
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/notification_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    Provider.of<NotificationProvider>(context, listen: false)
        .markAsRead(notification.id);

    // Navigate based on type
    final type = notification.data['type'];
    switch (type) {
      // Marketplace
      case 'new_order':
      case 'order_status':
      case 'payment_received':
        final orderId = notification.data['orderId'];
        // TODO: Navigate to order detail
        // Navigator.pushNamed(context, '/order-detail', arguments: orderId);
        break;

      case 'new_product':
      case 'low_stock':
        final productId = notification.data['productId'];
        // TODO: Navigate to product detail
        // Navigator.pushNamed(context, '/product-detail', arguments: productId);
        break;

      // Polling
      case 'new_poll':
      case 'poll_result':
        final pollId = notification.data['pollId'];
        // TODO: Navigate to poll detail
        // Navigator.pushNamed(context, '/poll-detail', arguments: pollId);
        break;

      // Agenda
      case 'new_agenda':
      case 'agenda_reminder':
        final agendaId = notification.data['agendaId'];
        // TODO: Navigate to agenda detail
        // Navigator.pushNamed(context, '/agenda-detail', arguments: agendaId);
        break;

      // Admin - New User
      case 'new_user_registration':
        final newUserId = notification.data['newUserId'];
        // TODO: Navigate to user verification page
        // Navigator.pushNamed(context, '/admin/verify-user', arguments: newUserId);
        break;

      // KYC
      case 'kyc_status':
        // TODO: Navigate to KYC page
        // Navigator.pushNamed(context, '/kyc');
        break;

      // Announcement
      case 'announcement':
        final announcementId = notification.data['announcementId'];
        // TODO: Navigate to announcement detail
        // Navigator.pushNamed(context, '/announcement', arguments: announcementId);
        break;

      // Financial
      case 'new_tagihan':
      case 'tagihan_reminder':
        final tagihanId = notification.data['tagihanId'];
        // TODO: Navigate to tagihan detail
        // Navigator.pushNamed(context, '/tagihan-detail', arguments: tagihanId);
        break;

      case 'payment_confirmation':
        // TODO: Navigate to payment history
        // Navigator.pushNamed(context, '/payment-history');
        break;

      case 'financial_report':
        final periode = notification.data['periode'];
        // TODO: Navigate to financial report
        // Navigator.pushNamed(context, '/financial-report', arguments: periode);
        break;

      // Household
      case 'household_update':
        // TODO: Navigate to family data
        // Navigator.pushNamed(context, '/family-data');
        break;

      default:
        // No specific navigation
        break;
    }
  }
}

// ============================================================================
// NOTIFICATION CARD
// ============================================================================
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F80ED),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    final type = notification.data['type'];
    switch (type) {
      // Marketplace notifications
      case 'new_order':
        return Icons.shopping_bag;
      case 'order_status':
        return Icons.local_shipping;
      case 'new_product':
        return Icons.new_releases;
      case 'low_stock':
        return Icons.warning_amber;
      case 'payment_received':
        return Icons.payments;

      // Polling notifications
      case 'new_poll':
        return Icons.poll;
      case 'poll_result':
        return Icons.bar_chart;

      // Agenda/Event notifications
      case 'new_agenda':
        return Icons.event;
      case 'agenda_reminder':
        return Icons.alarm;

      // User & Admin notifications
      case 'new_user_registration':
        return Icons.person_add;
      case 'kyc_status':
        return Icons.verified_user;

      // Announcement notifications
      case 'announcement':
        return Icons.campaign;

      // Financial notifications
      case 'new_tagihan':
        return Icons.receipt_long;
      case 'tagihan_reminder':
        return Icons.notifications_active;
      case 'payment_confirmation':
        return Icons.check_circle;
      case 'financial_report':
        return Icons.assessment;

      // Household notifications
      case 'household_update':
        return Icons.home;

      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    final type = notification.data['type'];
    switch (type) {
      // Marketplace notifications
      case 'new_order':
        return Colors.green;
      case 'order_status':
        return Colors.blue;
      case 'new_product':
        return Colors.purple;
      case 'low_stock':
        return Colors.orange;
      case 'payment_received':
        return Colors.teal;

      // Polling notifications
      case 'new_poll':
        return Colors.indigo;
      case 'poll_result':
        return Colors.deepPurple;

      // Agenda/Event notifications
      case 'new_agenda':
        return Colors.cyan;
      case 'agenda_reminder':
        return Colors.amber;

      // User & Admin notifications
      case 'new_user_registration':
        return Colors.lightBlue;
      case 'kyc_status':
        return Colors.green;

      // Announcement notifications
      case 'announcement':
        return Colors.red;

      // Financial notifications
      case 'new_tagihan':
        return Colors.deepOrange;
      case 'tagihan_reminder':
        return Colors.orange;
      case 'payment_confirmation':
        return Colors.green;
      case 'financial_report':
        return Colors.blueGrey;

      // Household notifications
      case 'household_update':
        return Colors.brown;

      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    }
  }
}

