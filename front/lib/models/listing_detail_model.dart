import 'amenity_model.dart'; // adjust path to match your project structure

/// Fuller listing model for the Listing Detail page — parses the full
/// document returned by GET /api/listings/:id (see listing.routes.js),
/// including description, all photos, amenities, capacity, and the
/// populated host info. Kept separate from ListingModel (used for the
/// Explore cards) since the card only needs a handful of summary fields
/// and shouldn't carry this much data on every list fetch.
class ListingDetailModel {
  final String id;
  final String title;
  final String description;
  final String descriptionTitle;
  final String propertyType;
  final List<String> categories;

  final String city;
  final String wilaya;
  final String? neighborhood;
  final double? latitude;
  final double? longitude;

  final double pricePerNight;
  final String currency;

  final int guests;
  final int bedrooms;
  final int bathrooms;

  final List<String> photoUrls;
  final int coverPhotoIndex;

  final List<AmenityModel> amenities;

  final double ratingOverall;
  final int reviewCount;

  final String hostName;
  final String? hostProfilePhotoUrl;
  final bool hostIsSuperhost;
  final String? hostSince;
  final String? hostCreatedAt; // fallback source for hostSinceLabel below

  ListingDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.descriptionTitle,
    required this.propertyType,
    required this.categories,
    required this.city,
    required this.wilaya,
    required this.neighborhood,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.currency,
    required this.guests,
    required this.bedrooms,
    required this.bathrooms,
    required this.photoUrls,
    required this.coverPhotoIndex,
    required this.amenities,
    required this.ratingOverall,
    required this.reviewCount,
    required this.hostName,
    required this.hostProfilePhotoUrl,
    required this.hostIsSuperhost,
    required this.hostSince,
    required this.hostCreatedAt,
  });

  factory ListingDetailModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final coordinates = location['coordinates'] as Map<String, dynamic>? ?? {};
    final coordsList = coordinates['coordinates'] as List<dynamic>? ?? [];

    final price = json['price'] as Map<String, dynamic>? ?? {};
    final capacity = json['capacity'] as Map<String, dynamic>? ?? {};
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    final photos = json['photos'] as List<dynamic>? ?? [];
    final amenitiesRaw = json['amenities'] as List<dynamic>? ?? [];
    final categoriesRaw = json['categories'] as List<dynamic>? ?? [];

    // hostId is populated by the backend with a subset of User fields
    // (see listing.routes.js: .populate('hostId', 'fullName profilePhoto isSuperhost hostSince'))
    final host = json['hostId'] as Map<String, dynamic>? ?? {};

    return ListingDetailModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionTitle: json['descriptionTitle'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      categories: categoriesRaw.map((c) => c.toString()).toList(),
      city: location['city'] as String? ?? '',
      wilaya: location['wilaya'] as String? ?? '',
      neighborhood: location['neighborhood'] as String?,
      latitude: coordsList.length > 1 ? (coordsList[1] as num?)?.toDouble() : null,
      longitude: coordsList.isNotEmpty ? (coordsList[0] as num?)?.toDouble() : null,
      pricePerNight: (price['perNight'] as num?)?.toDouble() ?? 0,
      currency: price['currency'] as String? ?? 'DZD',
      guests: (capacity['guests'] as num?)?.toInt() ?? 1,
      bedrooms: (capacity['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (capacity['bathrooms'] as num?)?.toInt() ?? 0,
      photoUrls: photos
          .map((p) => (p as Map<String, dynamic>)['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      coverPhotoIndex: (json['coverPhotoIndex'] as num?)?.toInt() ?? 0,
      amenities: amenitiesRaw
          .map((a) => AmenityModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      ratingOverall: (rating['overall'] as num?)?.toDouble() ?? 0,
      reviewCount: (rating['totalReviews'] as num?)?.toInt() ?? 0,
      hostName: host['fullName'] as String? ?? 'Host',
      hostProfilePhotoUrl: host['profilePhoto'] as String?,
      hostIsSuperhost: host['isSuperhost'] as bool? ?? false,
      hostSince: host['hostSince'] as String?,
      // Requires listing.routes.js to also populate 'createdAt' on hostId
      // (currently selects 'fullName profilePhoto isSuperhost hostSince') —
      // add createdAt to that populate() call for this fallback to work.
      hostCreatedAt: host['createdAt'] as String?,
    );
  }

  /// "Superhost since 2019" when the real hostSince date exists, falling
  /// back to "Member since 2026" using the host's account creation date
  /// otherwise. Returns null if neither is available.
  String? get hostSinceLabel {
    final source = hostSince ?? hostCreatedAt;
    if (source == null) return null;

    final year = DateTime.tryParse(source)?.year;
    if (year == null) return null;

    return hostSince != null ? 'Superhost since $year' : 'Member since $year';
  }

  /// "12 500 DA" — thousands separated with a space, DZD shown as "DA".
  String get formattedPrice {
    final rounded = pricePerNight.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      final posFromEnd = rounded.length - i;
      buffer.write(rounded[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    final currencyLabel = currency == 'DZD' ? 'DA' : currency;
    return '${buffer.toString()} $currencyLabel';
  }
}