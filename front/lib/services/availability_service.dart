import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/availability_day_model.dart';

class AvailabilityService {
  /// GET /api/availability/:listingId?month=&year= — public, no auth
  /// needed. Guest-facing (Booking page): only the host's own marks.
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

  /// GET /api/host/listings/:id/calendar?month=&year= — host-only. Same
  /// days as fetchMonth PLUS every night of a real guest booking (status
  /// 'booked' with a bookingId). Used by Manage Calendar.
  static Future<List<AvailabilityDayModel>> fetchHostMonth({
    required String authToken,
    required String listingId,
    required int month,
    required int year,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings/$listingId/calendar')
        .replace(queryParameters: {'month': '$month', 'year': '$year'});

    final response = await http.get(uri, headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode != 200) {
      throw Exception(_errorFrom(response, 'Failed to load calendar'));
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => AvailabilityDayModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/availability/:listingId — host-only, ownership-checked.
  /// Bulk-sets the status of a set of dates in one call.
  ///
  /// Price override per day:
  ///   - [priceOverride] given       → set it on every date
  ///   - [clearPriceOverride] true   → remove it (dates use the base price)
  ///   - neither                     → each date keeps whatever it had
  ///
  /// The backend refuses (409) any date taken by a guest booking.
  static Future<void> updateDates({
    required String authToken,
    required String listingId,
    required List<DateTime> dates,
    required String status,
    double? priceOverride,
    bool clearPriceOverride = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/availability/$listingId');
    final dateStrings = dates.map(dayString).toList();

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dates': dateStrings,
        'status': status,
        if (priceOverride != null)
          'priceOverride': priceOverride
        else if (clearPriceOverride)
          'priceOverride': null,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorFrom(response, 'Failed to update calendar'));
    }
  }

  /// "2026-11-05" for a local calendar date.
  static String dayString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _errorFrom(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) return body['error'].toString();
    } catch (_) {}
    return '$fallback (${response.statusCode}).';
  }
}
