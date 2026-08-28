import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)
import '../models/host_dashboard_model.dart';
import '../models/host_listing_summary_model.dart';

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
}