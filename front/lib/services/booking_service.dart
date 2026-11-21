import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import '../models/booking_model.dart';

/// Thrown with the backend's own message ("Minimum stay is 2 nights.",
/// "Some of these dates are no longer available…") so screens can show it.
class BookingApiException implements Exception {
  final String message;
  final int statusCode;
  const BookingApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}

/// Server-computed price for a stay (POST /api/bookings/quote).
class StayQuote {
  final int nights;
  final double nightlyRate;
  final double subtotal;
  final double discount;
  final double serviceFee;
  final double touristTax;
  final double total;
  final String currency;
  final bool instantBook;
  final String cancellationPolicy;
  final DateTime? freeCancellationUntil;

  StayQuote.fromJson(Map<String, dynamic> json)
      : nights = (json['nights'] as num?)?.toInt() ?? 0,
        nightlyRate = ((json['pricing']?['nightlyRate']) as num?)?.toDouble() ?? 0,
        subtotal = ((json['pricing']?['subtotal']) as num?)?.toDouble() ?? 0,
        discount = ((json['pricing']?['discount']) as num?)?.toDouble() ?? 0,
        serviceFee = ((json['pricing']?['serviceFee']) as num?)?.toDouble() ?? 0,
        touristTax = ((json['pricing']?['touristTax']) as num?)?.toDouble() ?? 0,
        total = ((json['pricing']?['totalDZD']) as num?)?.toDouble() ?? 0,
        currency = json['pricing']?['currency'] as String? ?? 'DZD',
        instantBook = json['instantBook'] == true,
        cancellationPolicy = json['cancellationPolicy'] as String? ?? 'Moderate',
        freeCancellationUntil = DateTime.tryParse(json['freeCancellationUntil']?.toString() ?? '')?.toLocal();
}

/// Guest-facing calendar (GET /api/listings/:id/availability).
class GuestAvailability {
  final double basePrice;
  final String rentalPeriod;
  final Set<DateTime> unavailable; // nights that can't be booked
  final Map<DateTime, double> prices; // custom per-night prices

  GuestAvailability({required this.basePrice, required this.rentalPeriod, required this.unavailable, required this.prices});
}

class BookingService {
  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  static String day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Never _fail(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) throw BookingApiException(body['error'].toString(), response.statusCode);
    } on FormatException {
      // not JSON
    }
    throw BookingApiException('$fallback (${response.statusCode}).', response.statusCode);
  }

  /// Loads [months] months of availability starting at [from]'s month.
  static Future<GuestAvailability> fetchGuestAvailability({
    required String listingId,
    required DateTime from,
    int months = 12,
  }) async {
    final start = DateTime(from.year, from.month, 1);
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings/$listingId/availability')
        .replace(queryParameters: {'from': day(start), 'months': '$months'});
    final response = await http.get(uri);
    if (response.statusCode != 200) _fail(response, 'Failed to load availability');

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final unavailable = <DateTime>{};
    final prices = <DateTime, double>{};
    for (final raw in body['days'] as List<dynamic>? ?? []) {
      final entry = raw as Map<String, dynamic>;
      final p = (entry['date'] as String).split('-').map(int.parse).toList();
      final date = DateTime(p[0], p[1], p[2]);
      if (entry['available'] == false) unavailable.add(date);
      if (entry['price'] != null) prices[date] = (entry['price'] as num).toDouble();
    }
    return GuestAvailability(
      basePrice: (body['basePrice'] as num?)?.toDouble() ?? 0,
      rentalPeriod: body['rentalPeriod'] as String? ?? 'nightly',
      unavailable: unavailable,
      prices: prices,
    );
  }

  static Future<StayQuote> quote({
    required String token,
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookings/quote'),
      headers: _headers(token),
      body: jsonEncode({'listingId': listingId, 'checkIn': day(checkIn), 'checkOut': day(checkOut), 'guestsCount': guests}),
    );
    if (response.statusCode != 200) _fail(response, 'Could not check these dates');
    return StayQuote.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<BookingModel> create({
    required String token,
    required String listingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/bookings'),
      headers: _headers(token),
      body: jsonEncode({'listingId': listingId, 'checkIn': day(checkIn), 'checkOut': day(checkOut), 'guestsCount': guests}),
    );
    if (response.statusCode != 201) _fail(response, 'Booking failed');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<BookingModel>> _list(String path, String token, Map<String, String> query) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query.isEmpty ? null : query);
    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode != 200) _fail(response, 'Failed to load bookings');
    return (jsonDecode(response.body) as List<dynamic>)
        .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  /// group: 'requests' | 'upcoming' | 'past' | 'cancelled' | null (all)
  static Future<List<BookingModel>> myTrips({required String token, String? group}) =>
      _list('/bookings/my', token, {if (group != null) 'group': group});

  static Future<List<BookingModel>> hostReservations({required String token, String? group, String? listingId}) =>
      _list('/bookings/host', token, {if (group != null) 'group': group, if (listingId != null) 'listingId': listingId});

  static Future<BookingModel> get({required String token, required String bookingId}) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId'), headers: _headers(token));
    if (response.statusCode != 200) _fail(response, 'Failed to load this booking');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<BookingModel> _action(String token, String bookingId, String action, {String? reason}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/$action'),
      headers: _headers(token),
      body: jsonEncode({if (reason != null && reason.isNotEmpty) 'reason': reason}),
    );
    if (response.statusCode != 200) _fail(response, 'Action failed');
    return BookingModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<BookingModel> accept({required String token, required String bookingId}) =>
      _action(token, bookingId, 'accept');

  static Future<BookingModel> decline({required String token, required String bookingId, String? reason}) =>
      _action(token, bookingId, 'decline', reason: reason);

  static Future<BookingModel> cancel({required String token, required String bookingId, String? reason}) =>
      _action(token, bookingId, 'cancel', reason: reason);
}
