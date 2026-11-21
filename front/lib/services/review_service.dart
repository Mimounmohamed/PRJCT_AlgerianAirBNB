import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import '../models/review_model.dart';

/// Result of "can I review this listing?" (GET /api/reviews/eligible).
class ReviewEligibility {
  /// The completed, not-yet-reviewed stay to review — null if none.
  final String? bookingId;
  /// Why the user can't review (shown to them) when [bookingId] is null.
  final String reason;
  const ReviewEligibility({this.bookingId, this.reason = ''});
  bool get canReview => bookingId != null;
}

class ReviewService {
  static const int _pageSize = 50;
  static const int _maxPages = 20; // 1000 reviews — plenty for one listing

  /// All reviews for a listing (GET /api/reviews/listing/:listingId), every
  /// page — the server returns at most 50 per request. Returns [] on error.
  static Future<List<ReviewModel>> fetchReviews(String listingId) async {
    final all = <ReviewModel>[];
    try {
      for (var page = 1; page <= _maxPages; page++) {
        final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/listing/$listingId')
            .replace(queryParameters: {'page': '$page', 'limit': '$_pageSize'});
        final response = await http.get(uri);
        if (response.statusCode != 200) break;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawList = data['reviews'] as List<dynamic>? ?? [];
        all.addAll(rawList.map((item) => ReviewModel.fromJson(item as Map<String, dynamic>)));

        final total = (data['total'] as num?)?.toInt() ?? all.length;
        if (rawList.length < _pageSize || all.length >= total) break;
      }
    } catch (_) {
      // Keep whatever loaded.
    }
    return all;
  }

  /// Can the logged-in user review this listing? Only guests with a
  /// completed stay there they haven't reviewed yet can.
  static Future<ReviewEligibility> checkEligibility({required String token, required String listingId}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/eligible').replace(queryParameters: {'listingId': listingId});
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode != 200) {
        return const ReviewEligibility(reason: "Couldn't check whether you can review this place. Try again.");
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ReviewEligibility(
        bookingId: data['bookingId']?.toString(),
        reason: data['reason'] as String? ?? '',
      );
    } catch (_) {
      return const ReviewEligibility(reason: "Couldn't check whether you can review this place. Try again.");
    }
  }

  /// Submits a review for a completed stay (POST /api/reviews). The server
  /// takes the listing and host from the booking.
  static Future<ReviewModel> submitReview({
    required String token,
    required String bookingId,
    required double rating,
    required String comment,
    Map<String, double>? categoryRatings,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews');

    final cleanOverall = rating.clamp(1.0, 5.0);

    final payload = {
      'bookingId': bookingId,
      'ratings': {
        'overall': cleanOverall,
        'cleanliness': (categoryRatings?['cleanliness'] ?? cleanOverall).clamp(1.0, 5.0),
        'communication': (categoryRatings?['communication'] ?? cleanOverall).clamp(1.0, 5.0),
        'checkIn': (categoryRatings?['checkIn'] ?? cleanOverall).clamp(1.0, 5.0),
        'location': (categoryRatings?['location'] ?? cleanOverall).clamp(1.0, 5.0),
        'value': (categoryRatings?['value'] ?? cleanOverall).clamp(1.0, 5.0),
      },
      'comment': comment.trim(),
      'photos': <String>[],
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      String message = 'Failed to submit review (${response.statusCode})';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody['error'] != null) message = errorBody['error'].toString();
      } catch (_) {}
      throw Exception(message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }

  /// Submits a host response to a review: POST /api/reviews/:id/reply
  static Future<ReviewModel> replyToReview({
    required String token,
    required String reviewId,
    required String comment,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/$reviewId/reply');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': comment.trim()}),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to post reply (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ReviewModel.fromJson(data);
  }
}
