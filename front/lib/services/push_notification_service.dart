import 'dart:convert';
import 'dart:async';
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
///
/// This phone's push token must always belong to whoever is logged in
/// RIGHT NOW. So the service:
///  - starts once (main.dart) and listens to [UserSession] — every login
///    path (email, phone, Google, sign-up, …) registers the token for the
///    new user; the backend then removes it from any other account
///  - on logout ([unregisterCurrentUser]) tells the backend to stop
///    sending that user's pushes to this phone
///  - attaches the FCM listeners only once (repeated logins used to add a
///    new onMessage listener each time → duplicate notifications)
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _started = false;
  String? _deviceToken;
  String? _registeredForUserId; // account the token is currently registered to

  /// Fires for every push received while the app is open — e.g. the
  /// notification bell refreshes its unread badge.
  final StreamController<RemoteMessage> _foreground = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage => _foreground.stream;

  /// Safe to call more than once — only the first call does the setup.
  Future<void> initialize() async {
    if (_started) {
      await _syncWithSession();
      return;
    }
    _started = true;

    final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _deviceToken = await _fcm.getToken();
    debugPrint('[FCM] Device token: $_deviceToken');

    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('[FCM] Token refreshed: $newToken');
      _deviceToken = newToken;
      _registeredForUserId = null; // re-register the new token
      _syncWithSession();
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] onMessage fired: ${message.notification?.title}');
      showLocalNotification(message);
      _foreground.add(message);
    });

    UserSession.instance.addListener(_syncWithSession);
    await _syncWithSession();
  }

  /// Registers the token for the logged-in user if it isn't already.
  Future<void> _syncWithSession() async {
    final jwt = UserSession.instance.token;
    final userId = UserSession.instance.currentUser?.id;
    final deviceToken = _deviceToken;
    if (jwt == null || userId == null || deviceToken == null) return;
    if (_registeredForUserId == userId) return;

    _registeredForUserId = userId;
    try {
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $jwt'},
        body: jsonEncode({'fcmToken': deviceToken}),
      );
      debugPrint('[FCM] Token registered for $userId — status ${res.statusCode}');
      if (res.statusCode != 200) _registeredForUserId = null;
    } catch (e) {
      _registeredForUserId = null;
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  /// Call on logout, BEFORE clearing the session: this phone stops
  /// receiving the user's pushes. Never throws, waits at most 4 seconds.
  Future<void> unregisterCurrentUser() async {
    final jwt = UserSession.instance.token;
    _registeredForUserId = null;
    if (jwt == null) return;
    try {
      await http
          .delete(Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'), headers: {'Authorization': 'Bearer $jwt'})
          .timeout(const Duration(seconds: 4));
      debugPrint('[FCM] Token unregistered');
    } catch (e) {
      debugPrint('[FCM] Token unregister failed: $e');
    }
  }

  Future<void> clearToken() async {
    await _fcm.deleteToken();
    _deviceToken = null;
    _registeredForUserId = null;
    debugPrint('[FCM] Token deleted');
  }
}
