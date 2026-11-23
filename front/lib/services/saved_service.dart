import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import 'user_session.dart';

/// The guest's saved listings (the ❤️ on Discover cards and the listing
/// page). Every heart listens to [ids], so saving on the listing page
/// also fills the heart on its Discover card.
///
/// Backend: GET /api/saved/ids, POST/DELETE /api/saved/:listingId — the
/// backend also counts the saves per listing (stats.totalFavorites).
class SavedService {
  SavedService._();
  static final SavedService instance = SavedService._();

  /// Listing ids the logged-in user saved.
  final ValueNotifier<Set<String>> ids = ValueNotifier<Set<String>>({});

  // Token the current [ids] belong to — a different login reloads them.
  String? _loadedFor;

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  bool isSaved(String listingId) => ids.value.contains(listingId);

  /// Loads the saved ids once per login. Never throws.
  Future<void> ensureLoaded() async {
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) {
      _loadedFor = null;
      ids.value = {};
      return;
    }
    if (_loadedFor == token) return;
    _loadedFor = token;
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/saved/ids'), headers: _headers(token));
      if (response.statusCode == 200) {
        ids.value = (jsonDecode(response.body) as List<dynamic>).map((e) => e.toString()).toSet();
      } else {
        _loadedFor = null;
      }
    } catch (_) {
      _loadedFor = null;
    }
  }

  /// Saves or unsaves. The heart changes right away and goes back if the
  /// request fails. Throws with a message the UI can show.
  Future<void> setSaved(String listingId, bool saved) async {
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) throw Exception('Log in to save places you like.');

    final before = ids.value;
    ids.value = saved ? {...before, listingId} : ({...before}..remove(listingId));

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/saved/$listingId');
      final response = saved
          ? await http.post(uri, headers: _headers(token))
          : await http.delete(uri, headers: _headers(token));
      if (response.statusCode >= 300) {
        throw Exception(saved ? 'Could not save this place.' : 'Could not remove this place.');
      }
    } catch (e) {
      ids.value = before;
      rethrow;
    }
  }
}
