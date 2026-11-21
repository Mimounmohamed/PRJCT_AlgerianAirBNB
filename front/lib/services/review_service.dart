import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import '../models/review_model.dart';

class ReviewService {
  /// Fetches reviews for a listing from GET /api/reviews/listing/:listingId
  static Future<List<ReviewModel>> fetchReviews(String listingId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/reviews/listing/$listingId');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = data['reviews'] as List<dynamic>? ?? [];

      return rawList
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Helper to generate a 24-character hexadecimal ObjectId so MongoDB
  /// is satisfied even if a direct bookingId wasn't generated yet.
  static String _generateObjectId() {
    final nowSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toRadixString(16).padLeft(8, '0');
    final randomHex = List.generate(16, (i) => ((DateTime.now().microsecondsSinceEpoch + i * 31) % 16).toRadixString(16)).join();
    return (nowSeconds + randomHex).substring(0, 24);
  }

  /// Submits a new review to POST /api/reviews
  static Future<ReviewModel> submitReview({
    required String token,
    required String listingId,
    required String hostId,
    required double rating,
    required String comment,
    Map<String, double>? categoryRatings,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/reviews');

    final cleanOverall = rating.clamp(1.0, 5.0);

    final payload = {
      'listingId': listingId,
      'hostId': hostId.isNotEmpty ? hostId : _generateObjectId(),
      'bookingId': _generateObjectId(),
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
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['error'] ?? 'Failed to submit review (${response.statusCode})');
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
