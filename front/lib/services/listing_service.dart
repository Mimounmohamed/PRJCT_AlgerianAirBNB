import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/listing_model.dart'; // adjust path to match your project structure
import '../models/listing_detail_model.dart'; // adjust path to match your project structure

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

  /// GET /api/listings/:id — used by the Listing Detail page.
  /// Note: unlike fetchListings, this route returns the listing object
  /// directly (not wrapped in { listings: [...] }) — see listing.routes.js.
  static Future<ListingDetailModel> fetchListingById(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings/$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load listing (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return ListingDetailModel.fromJson(body);
  }

  /// POST /api/listings — creates a new listing from a Create Listing
  /// wizard draft (see listing_draft_model.dart's toJson()). Requires
  /// a host auth token — the backend's requireHost middleware rejects
  /// non-host accounts with a 403.
  ///
  /// Pass status: 'draft' to save without submitting for review; omit
  /// it (or pass null) to submit normally — the backend forces
  /// 'pending_review' server-side for anything other than 'draft', so
  /// a host can never self-publish straight to 'active' from the client.
  ///
  /// Returns the new listing's _id on success.
  static Future<String> createListing({
    required String authToken,
    required Map<String, dynamic> draftJson,
    String? status,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings');
    final body = {
      ...draftJson,
      if (status != null) 'status': status,
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save listing (${response.statusCode}): ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['_id'] as String;
  }
}