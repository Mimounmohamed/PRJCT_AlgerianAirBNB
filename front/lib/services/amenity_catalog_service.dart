import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart'; // ApiConfig — same folder (lib/services/)

/// One predefined amenity from the catalog (a category's entry in the
/// GET /api/amenities-catalog response). Distinct from AmenityModel,
/// which represents an amenity already attached to a listing (selected +
/// possibly customized) — this is just the pickable catalog source.
class AmenityCatalogItem {
  final String key;
  final String name;
  final String iconName;

  const AmenityCatalogItem({required this.key, required this.name, required this.iconName});

  factory AmenityCatalogItem.fromJson(Map<String, dynamic> json) {
    return AmenityCatalogItem(
      key: json['key'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? '',
    );
  }
}

/// Fixed category order — mirrors AMENITY_CATEGORIES in
/// back/src/models/AmenityCatalog.js. The backend's grouped response is a
/// plain JS object (Mongo-sorted alphabetically), so we re-order client
/// side to this canonical order for a stable, predictable UI.
const List<String> amenityCategoryOrder = [
  'Scenic views',
  'Bedroom and laundry',
  'Bathroom',
  'Internet and office',
  'Entertainment',
  'Kitchen and dining',
  'Heating and cooling',
  'Home safety',
  'Outdoor',
  'Parking and facilities',
  'Accessibility',
  'Other',
];

class AmenityCatalogService {
  /// GET /api/amenities-catalog — returns { "categories": { catName: [...] } }.
  /// Result is re-ordered to [amenityCategoryOrder]; any category present
  /// in the response but not in that fixed list (future additions) is
  /// appended at the end so nothing silently disappears.
  static Future<Map<String, List<AmenityCatalogItem>>> fetchCatalog() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/amenities-catalog');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load amenities (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rawCategories = body['categories'] as Map<String, dynamic>? ?? {};

    final parsed = <String, List<AmenityCatalogItem>>{};
    rawCategories.forEach((category, items) {
      parsed[category] = (items as List<dynamic>)
          .map((item) => AmenityCatalogItem.fromJson(item as Map<String, dynamic>))
          .toList();
    });

    final ordered = <String, List<AmenityCatalogItem>>{};
    for (final category in amenityCategoryOrder) {
      if (parsed.containsKey(category)) ordered[category] = parsed[category]!;
    }
    for (final entry in parsed.entries) {
      if (!ordered.containsKey(entry.key)) ordered[entry.key] = entry.value;
    }

    return ordered;
  }
}