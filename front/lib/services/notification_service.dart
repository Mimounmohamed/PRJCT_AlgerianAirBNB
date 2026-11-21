import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';

/// One in-app notification (back/src/models/Notification.js).
class AppNotification {
  final String id;
  final String type; // booking_requested, booking_confirmed, booking_cancelled, ...
  final String title;
  final String body;
  final String? relatedId;
  final String? relatedType; // 'booking' | 'listing' | 'message' | ...
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.relatedId,
    required this.relatedType,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['_id']?.toString() ?? '',
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        relatedId: json['relatedId']?.toString(),
        relatedType: json['relatedType'] as String?,
        read: json['read'] == true,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );

  AppNotification copyRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        relatedId: relatedId,
        relatedType: relatedType,
        read: true,
        createdAt: createdAt,
      );
}

class NotificationPage {
  final List<AppNotification> notifications;
  final int unreadCount;
  NotificationPage(this.notifications, this.unreadCount);
}

class NotificationService {
  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  /// GET /api/notifications — newest first, with the unread count.
  static Future<NotificationPage> fetch({required String token, int page = 1, int limit = 30}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/notifications')
        .replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications (${response.statusCode}).');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (body['notifications'] as List<dynamic>? ?? [])
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
    return NotificationPage(list, (body['unreadCount'] as num?)?.toInt() ?? 0);
  }

  /// Just the unread count (for the bell badge). Never throws — 0 on error.
  static Future<int> unreadCount({required String token}) async {
    try {
      return (await fetch(token: token, limit: 1)).unreadCount;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> markRead({required String token, required String id}) async {
    await http.put(Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read'), headers: _headers(token));
  }

  static Future<void> markAllRead({required String token}) async {
    await http.put(Uri.parse('${ApiConfig.baseUrl}/notifications/read-all'), headers: _headers(token));
  }
}
