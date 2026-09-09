import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/availability_day_model.dart';

class AvailabilityService {
  /// GET /api/availability/:listingId?month=&year= — public, no auth
  /// needed (used by both the guest-facing Booking page and the host's
  /// Manage Calendar page).
  static Future<List<AvailabilityDayModel>> fetchMonth({
    required String listingId,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/availability/$listingId')
        .replace(queryParameters: {'month': '$month', 'year': '$year'});

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load calendar (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => AvailabilityDayModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/availability/:listingId — host-only, ownership-checked.
  /// Bulk-sets status (+ optional per-day price override) for a set of
  /// dates in one call.
  static Future<void> updateDates({
    required String authToken,
    required String listingId,
    required List<DateTime> dates,
    required String status,
    double? priceOverride,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/availability/$listingId');
    final dateStrings = dates.map((d) => d.toIso8601String().split('T').first).toList();

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dates': dateStrings,
        'status': status,
        if (priceOverride != null) 'priceOverride': priceOverride,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update calendar (${response.statusCode}).');
    }
  }
}