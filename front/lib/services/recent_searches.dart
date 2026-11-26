import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// One past search on the search screen: free text, a wilaya, or a region.
class RecentSearch {
  final String label;
  final String kind; // 'text' | 'place'
  final List<String> wilayas; // for 'place'

  const RecentSearch({required this.label, required this.kind, this.wilayas = const []});

  Map<String, dynamic> toJson() => {'label': label, 'kind': kind, 'wilayas': wilayas};

  factory RecentSearch.fromJson(Map<String, dynamic> json) => RecentSearch(
        label: json['label'] as String? ?? '',
        kind: json['kind'] as String? ?? 'text',
        wilayas: (json['wilayas'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      );
}

/// Recent searches, saved on this phone (newest first, at most 6).
class RecentSearches {
  static const _key = 'recent_searches_v1';
  static const _max = 6;

  static Future<List<RecentSearch>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => RecentSearch.fromJson(e as Map<String, dynamic>))
          .where((r) => r.label.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(RecentSearch search) async {
    final list = await load();
    list.removeWhere((r) => r.label.toLowerCase() == search.label.toLowerCase());
    list.insert(0, search);
    await _save(list.take(_max).toList());
  }

  static Future<void> clear() => _save([]);

  static Future<void> _save(List<RecentSearch> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(list.map((r) => r.toJson()).toList()));
    } catch (_) {}
  }
}
