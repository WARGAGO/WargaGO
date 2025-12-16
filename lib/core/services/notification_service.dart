// ============================================================================
// NOTIFICATION SERVICE
// ============================================================================
// Service untuk handle Firebase Cloud Messaging (FCM) dan local notifications
// ============================================================================

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Handler untuk background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message: ${message.messageId}');
  debugPrint('📨 Notification: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  // ============================================================================
  // INITIALIZE NOTIFICATION SERVICE
  // ============================================================================
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup FCM
      await _setupFCM();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      _isInitialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  // ============================================================================
  // REQUEST PERMISSION
  // ============================================================================
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('✅ Notification permission: ${settings.authorizationStatus}');
  }

  // ============================================================================
  // INITIALIZE LOCAL NOTIFICATIONS
  // ============================================================================
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'wargago_channel', // ID
      'WargaGo Notifications', // Name
      description: 'Notifikasi untuk aplikasi WargaGo',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    debugPrint('✅ Local notifications initialized');
  }

  // ============================================================================
  // SETUP FCM
  // ============================================================================
  Future<void> _setupFCM() async {
    // Get FCM token
    _fcmToken = await _messaging.getToken();
    debugPrint('📱 FCM Token: $_fcmToken');

    // Save token to Firestore
    if (_fcmToken != null) {
      await _saveFCMToken(_fcmToken!);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      _saveFCMToken(newToken);
      debugPrint('🔄 FCM Token refreshed: $newToken');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    // Check if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }
  }

  // ============================================================================
  // SAVE FCM TOKEN TO FIRESTORE
  // ============================================================================
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  // ============================================================================
  // HANDLE FOREGROUND MESSAGE
  // ============================================================================
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message: ${message.messageId}');
    debugPrint('📨 Notification: ${message.notification?.title}');
    debugPrint('📨 Data: ${message.data}');

    // Show local notification
    await _showLocalNotification(message);
  }

  // ============================================================================
  // SHOW LOCAL NOTIFICATION
  // ============================================================================
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'wargago_channel',
      'WargaGo Notifications',
      channelDescription: 'Notifikasi untuk aplikasi WargaGo',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // ============================================================================
  // HANDLE NOTIFICATION TAPPED
  // ============================================================================
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _navigateToScreen(data);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  // ============================================================================
  // HANDLE NOTIFICATION OPENED
  // ============================================================================
  void _handleNotificationOpened(RemoteMessage message) {
    debugPrint('📱 Notification opened: ${message.messageId}');
    _navigateToScreen(message.data);
  }

  // ============================================================================
  // NAVIGATE TO SCREEN
  // ============================================================================
  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'];
    debugPrint('🔗 Navigating to: $type');

    // TODO: Implement navigation based on notification type
    // Example:
    // if (type == 'new_order') {
    //   navigatorKey.currentState?.pushNamed('/order-detail', arguments: data['orderId']);
    // } else if (type == 'new_product') {
    //   navigatorKey.currentState?.pushNamed('/product-detail', arguments: data['productId']);
    // }
  }

  // ============================================================================
  // SEND NOTIFICATION TO SPECIFIC USER
  // ============================================================================
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final fcmToken = userDoc.data()?['fcmToken'];
      if (fcmToken == null) {
        debugPrint('❌ User $userId has no FCM token');
        return;
      }

      // Save notification to Firestore (for notification history)
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Notification saved to Firestore for user $userId');

      // Note: To actually send push notification, you need to use Cloud Functions
      // or a backend service to call FCM API with the token
      // Example Cloud Function:
      // await admin.messaging().sendToDevice(fcmToken, {
      //   notification: { title, body },
      //   data: data ?? {},
      // });

    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  // ============================================================================
  // SUBSCRIBE TO TOPIC
  // ============================================================================
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  // ============================================================================
  // UNSUBSCRIBE FROM TOPIC
  // ============================================================================
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  // ============================================================================
  // GET NOTIFICATION HISTORY
  // ============================================================================
  Stream<QuerySnapshot> getNotificationHistory(String userId) {
    // ⚠️ OPTIMIZED: Remove orderBy to avoid composite index requirement
    // Sorting will be done client-side in NotificationProvider
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .limit(50)
        .snapshots();
  }

  // ============================================================================
  // MARK NOTIFICATION AS READ
  // ============================================================================
  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      debugPrint('✅ Notification marked as read');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  // ============================================================================
  // GET UNREAD COUNT
  // ============================================================================
  Stream<int> getUnreadCount(String userId) {
    // ⚠️ OPTIMIZED: Remove second where to avoid composite index
    // Filter isRead=false on client-side instead
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Client-side filter for isRead = false
          return snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['isRead'] == false;
          }).length;
        });
  }
}

