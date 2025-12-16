// ============================================================================
// TEST NOTIFICATION WIDGET
// ============================================================================
// Floating button untuk test notifikasi (DEBUG MODE ONLY)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/helpers/notification_helper.dart';

class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () async {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        
        if (userId == null) {
          debugPrint('❌ No user logged in');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error: User not logged in'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        debugPrint('\n🧪 ===== TESTING NOTIFICATION =====');
        debugPrint('🧪 Current User ID: $userId');
        
        try {
          // Test broadcast to all users
          await NotificationHelper.broadcastToAll(
            title: '🧪 Test Notifikasi',
            body: 'Ini adalah test notifikasi manual. Jika muncul, sistem bekerja!',
            type: 'test',
          );
          
          debugPrint('✅ Test notification sent successfully!');
          debugPrint('✅ Check:');
          debugPrint('   1. Firebase Console > Firestore > notifications');
          debugPrint('   2. Badge di icon bell: 🔔(1)');
          debugPrint('   3. NotificationsPage');
          debugPrint('🧪 ===== TEST COMPLETE =====\n');
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Test notification sent! Check badge 🔔'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint('❌ Error sending test notification: $e');
          debugPrint('🧪 ===== TEST FAILED =====\n');
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.bug_report),
      label: const Text('Test Notif'),
      backgroundColor: Colors.orange,
    );
  }
}

