import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import 'user_session.dart';

/// Handles FCM token registration and foreground message listening.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Call once after login / Firebase.initializeApp().
  Future<void> initialize() async {
    // Request permission (iOS and Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the current FCM token and register it with our backend
    final token = await _fcm.getToken();
    if (token != null) await _registerToken(token);

    // Listen for token refresh and re-register
    _fcm.onTokenRefresh.listen((newToken) => _registerToken(newToken));
  }

  Future<void> _registerToken(String token) async {
    final userToken = UserSession.instance.token;
    if (userToken == null) return;
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );
    } catch (_) {
      // Silently fail — push is best-effort
    }
  }

  /// Call on logout to avoid stale pushes.
  Future<void> clearToken() async {
    await _fcm.deleteToken();
  }
}
