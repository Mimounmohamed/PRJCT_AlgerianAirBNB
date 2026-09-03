import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/host_dashboard_model.dart';
import '../models/host_listing_summary_model.dart';
import '../models/host_listing_detail_model.dart';

class HostService {
  /// POST /api/host/become
  static Future<void> becomeHost({required String authToken}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/become');
    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to become a host (${response.statusCode}).');
    }
  }

  /// GET /api/host/dashboard — returns null if the user isn't a host yet
  /// (403 from requireHost middleware), throws on any other error.
  static Future<HostDashboardModel?> fetchDashboard({required String authToken}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/dashboard');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 403) return null;

    if (response.statusCode != 200) {
      throw Exception('Failed to load host dashboard (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return HostDashboardModel.fromJson(body);
  }

  /// GET /api/host/listings
  static Future<List<HostListingSummaryModel>> fetchHostListings({required String authToken}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load your listings (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => HostListingSummaryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/host/listings/:id — single listing, ownership-checked, for
  /// the Manage Listing page.
  static Future<HostListingDetailModel> fetchListingDetail({
    required String authToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings/$listingId');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load this listing (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return HostListingDetailModel.fromJson(body);
  }

  /// PUT /api/listings/:id — "Pause Listing" on the Manage Listing page.
  /// Reversible: sets status back to 'inactive'/'unlisted' rather than
  /// deleting anything. Uses the general (non-host-prefixed) listings
  /// route since that's where update already lives.
  static Future<void> pauseListing({
    required String authToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings/$listingId');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': 'inactive', 'visibility': 'unlisted'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to pause listing (${response.statusCode}).');
    }
  }

  /// DELETE /api/host/listings/:id — "Delete" on the Manage Listing
  /// page's advanced controls. Permanent (soft delete via isDeleted) —
  /// distinct from pauseListing above.
  static Future<void> deleteListing({
    required String authToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings/$listingId');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete listing (${response.statusCode}).');
    }
  }
}