import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/listing_model.dart'; // adjust path to match your project structure

/// Standalone fetch for GET /api/listings — no shared HTTP client yet,
/// swap in base_client.dart later if you want auth headers / interceptors
/// applied consistently across services.
class ListingService {
  static Future<List<ListingModel>> fetchListings({
    String? category,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category != 'All') queryParams['category'] = category;
    if (search != null && search.trim().isNotEmpty) queryParams['search'] = search.trim();

    final uri = Uri.parse('${ApiConfig.baseUrl}/listings')
        .replace(queryParameters: queryParams.isEmpty ? null : queryParams);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load listings (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final listingsJson = body['listings'] as List<dynamic>? ?? [];

    return listingsJson
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}