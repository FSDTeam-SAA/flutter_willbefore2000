// lib/services/notification_service.dart
import 'dart:io'; // ← Add this import

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutx_core/flutx_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  // Background handler (must be top-level/static)
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    DPrint.log("Background message: ${message.messageId}");
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Firebase already initialized in main.dart → safe to use here
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    await _requestPermissions();

    // Foreground presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _createNotificationChannel();
    await _initializeLocalNotifications();

    // ← THE MOST IMPORTANT PART: Safe token handling for iOS + Android
    _startFcmTokenSync();
  }

  // ──────────────────────────────────────────────────────────────
  // 1. Permission
  // ──────────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    DPrint.log("Permission status: ${settings.authorizationStatus}");
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Android channel
  // ──────────────────────────────────────────────────────────────
  Future<void> _createNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Local notifications (foreground)
  // ──────────────────────────────────────────────────────────────
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        DPrint.log("Notification tapped: ${response.payload}");
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    });
  }

  // ──────────────────────────────────────────────────────────────
  // 4. SAFE FCM TOKEN + AUTO UPDATE TO FIRESTORE (this fixes your crash)
  // ──────────────────────────────────────────────────────────────
  void _startFcmTokenSync() {
    // First attempt – safe for both platforms
    _safeGetAndSaveToken();

    // Listen to future refreshes (tokens change often on iOS!)
    _messaging.onTokenRefresh.listen(_safeGetAndSaveToken);
  }

  Future<String?> _safeGetAndSaveToken([String? _]) async {
    String? token;

    // ── iOS: wait for APNs token first ───────────────────────
    if (Platform.isIOS) {
      for (int i = 0; i < 20; i++) {
        // increased retries
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          DPrint.log("APNs token received");
          token = await _messaging.getToken();
          break;
        }
        DPrint.log("Waiting for APNs token... attempt ${i + 1}");
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    // ── Android: instant ─────────────────────────────────────
    else {
      token = await _messaging.getToken();
    }

    // If we still don’t have a token → give up
    if (token == null) {
      DPrint.error("Failed to retrieve FCM token");
      return null; // ← now returns null (String?)
    }

    DPrint.log("FCM Token obtained: $token");

    // ── Save to Firestore if user is authenticated ───────────
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            'platform': Platform.isIOS ? 'ios' : 'android',
          },
          SetOptions(merge: true),
        ); // use set+merge to avoid overwriting other fields

        DPrint.log("FCM token saved to Firestore for ${user.uid}");
      } catch (e) {
        DPrint.error("Failed to save FCM token: $e");
      }
    }

    return token; // ← correct return type: Future<String?>
  }

  // Public helpers (optional)
  Future<String?> getToken() async => await _safeGetAndSaveToken();
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);
}
