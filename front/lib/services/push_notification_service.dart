import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import 'user_session.dart';

// ── Background handler (top-level, not a class method) ──────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by the OS on Android.
  debugPrint('[FCM] Background message received: ${message.notification?.title}');
}

// ── Local notifications plugin ───────────────────────────────────────────────
final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _messageChannel = AndroidNotificationChannel(
  'messages',
  'Messages',
  description: 'New message notifications',
  importance: Importance.high,
  playSound: true,
);

/// Call once from main() BEFORE runApp().
Future<void> initLocalNotifications() async {
  await _localNotif
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_messageChannel);

  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  await _localNotif.initialize(initSettings);
  debugPrint('[FCM] Local notifications initialized');
}

/// Shows a local banner for foreground messages.
void showLocalNotification(RemoteMessage message) {
  final title = message.notification?.title ?? message.data['title'] ?? '';
  final body  = message.notification?.body  ?? message.data['body']  ?? '';
  debugPrint('[FCM] Foreground message -> title="$title" body="$body"');
  if (title.isEmpty && body.isEmpty) return;

  _localNotif.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _messageChannel.id,
        _messageChannel.name,
        channelDescription: _messageChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

/// Singleton service for FCM token management.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get and register token
    final token = await _fcm.getToken();
    debugPrint('[FCM] Device token: $token');
    if (token != null) await _registerToken(token);

    // Token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      _registerToken(newToken);
    });

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] onMessage fired: ${message.notification?.title}');
      showLocalNotification(message);
    });
  }

  Future<void> _registerToken(String token) async {
    final userToken = UserSession.instance.token;
    if (userToken == null) {
      debugPrint('[FCM] No auth token — skipping registration');
      return;
    }
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );
      debugPrint('[FCM] Token registered — status ${res.statusCode}: ${res.body}');
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  Future<void> clearToken() async {
    await _fcm.deleteToken();
    debugPrint('[FCM] Token deleted');
  }
}
