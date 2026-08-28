import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// One commune (baladiya) row from assets/data/algeria_communes.json,
/// sourced from the ihahachi/Algeria-Cities open dataset. Field names
/// below map to that dataset's columns: wilaya_code, wilaya_name_fr,
/// commune_name_fr, Lat, Long.
class AlgeriaCommune {
  final String communeNameFr;
  final String wilayaNameFr;
  final int wilayaCode;
  final double lat;
  final double lng;

  const AlgeriaCommune({
    required this.communeNameFr,
    required this.wilayaNameFr,
    required this.wilayaCode,
    required this.lat,
    required this.lng,
  });

  factory AlgeriaCommune.fromJson(Map<String, dynamic> json) {
    return AlgeriaCommune(
      communeNameFr: json['commune_name_fr'] as String,
      wilayaNameFr: json['wilaya_name_fr'] as String,
      wilayaCode: json['wilaya_code'] is int
          ? json['wilaya_code'] as int
          : int.parse('${json['wilaya_code']}'),
      lat: (json['Lat'] as num).toDouble(),
      lng: (json['Long'] as num).toDouble(),
    );
  }
}

/// Loads assets/data/algeria_communes.json once and exposes convenience
/// lookups used by the Location step's Wilaya/Baladiya pickers.
class AlgeriaLocationData {
  static List<AlgeriaCommune>? _communes;

  static Future<List<AlgeriaCommune>> load() async {
    if (_communes != null) return _communes!;
    final raw = await rootBundle.loadString('assets/data/algeria_communes.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    _communes = decoded
        .map((item) => AlgeriaCommune.fromJson(item as Map<String, dynamic>))
        .toList();
    return _communes!;
  }

  /// Sorted, de-duplicated wilaya names.
  static List<String> wilayaNames(List<AlgeriaCommune> communes) {
    final names = communes.map((c) => c.wilayaNameFr).toSet().toList();
    names.sort();
    return names;
  }

  /// Commune names for a given wilaya (or all communes if wilaya is null),
  /// sorted alphabetically.
  static List<String> communeNames(List<AlgeriaCommune> communes, {String? wilayaNameFr}) {
    final filtered = wilayaNameFr == null
        ? communes
        : communes.where((c) => c.wilayaNameFr == wilayaNameFr);
    final names = filtered.map((c) => c.communeNameFr).toSet().toList();
    names.sort();
    return names;
  }

  /// Communes belonging to a single wilaya, as full objects (not just
  /// names) — used when resolving a picked name back to its coordinates,
  /// so cross-wilaya name collisions (several wilayas can share a commune
  /// name) never resolve to the wrong one.
  static List<AlgeriaCommune> communesForWilaya(List<AlgeriaCommune> communes, String wilayaNameFr) {
    return communes.where((c) => c.wilayaNameFr == wilayaNameFr).toList();
  }

  static AlgeriaCommune? findByCommuneName(List<AlgeriaCommune> communes, String communeNameFr) {
    for (final c in communes) {
      if (c.communeNameFr == communeNameFr) return c;
    }
    return null;
  }

  /// Case-insensitive match — used to reconcile Nominatim's reverse-geocode
  /// result (free text) against the dataset's commune names.
  static AlgeriaCommune? findByCommuneNameLoose(List<AlgeriaCommune> communes, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final c in communes) {
      if (c.communeNameFr.toLowerCase() == normalized) return c;
    }
    return null;
  }
}