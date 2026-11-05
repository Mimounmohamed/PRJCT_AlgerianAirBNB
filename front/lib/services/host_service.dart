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

  /// POST /api/host/listings/:id/pause — "Pause Listing" on the Manage
  /// Listing page. Reversible (status → 'inactive', unlisted). The backend
  /// only allows this on an active listing.
  static Future<void> pauseListing({
    required String authToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings/$listingId/pause');
    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorFrom(response, 'Failed to pause listing'));
    }
  }

  /// POST /api/host/listings/:id/resume — "Resume Listing" on the Manage
  /// Listing page, shown once a listing is paused. The backend decides the
  /// new status: 'active' straight away if the listing has autoPublish on,
  /// otherwise 'pending_review' (an admin has to approve it again).
  static Future<void> resumeListing({
    required String authToken,
    required String listingId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/host/listings/$listingId/resume');
    final response = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode != 200) {
      throw Exception(_errorFrom(response, 'Failed to resume listing'));
    }
  }

  /// Uses the backend's `{error: "..."}` message when there is one.
  static String _errorFrom(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['error'] != null) return body['error'].toString();
    } catch (_) {}
    return '$fallback (${response.statusCode}).';
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

  /// PUT /api/listings/:id — used by the Edit Listing Details page.
  ///
  /// IMPORTANT: the backend does a shallow `Object.assign(listing, req.body)`
  /// (see listing.routes.js), not a deep merge. That means nested fields
  /// like `location` and array fields like `photos`/`categories` must be
  /// sent as COMPLETE objects/arrays here — sending a partial `location`
  /// object (e.g. just `{wilaya, city}`) will silently wipe out
  /// `fullAddress`/`neighborhood`/`coordinates` if they're omitted, since
  /// the whole `location` key gets replaced wholesale. Always build the
  /// full nested object client-side before calling this.
  static Future<void> updateListingDetails({
    required String authToken,
    required String listingId,
    required Map<String, dynamic> updates,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/listings/$listingId');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode != 200) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] != null) {
          throw Exception(body['error'].toString());
        }
      } catch (e) {
        if (e is! FormatException) rethrow;
      }
      throw Exception('Failed to save changes (${response.statusCode}).');
    }
  }
}