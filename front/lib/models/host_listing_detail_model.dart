/// Parses one listing document as returned by GET /api/host/listings/:id
/// (raw Listing doc, host-scoped/ownership-checked) — used by Manage
/// Listing, Edit Listing Details, Manage Calendar, and Listing Settings.
class HostListingDetailModel {
  final String id;
  final String title;
  final String description;
  final String propertyType;
  final String? styleType;
  final List<String> categories;
  final List<Map<String, dynamic>> amenities; // raw {catalogKey, name, category, iconName, description, isCustom}
  final String status; // 'draft' | 'pending_review' | 'active' | 'inactive' | 'rejected'
  final String visibility; // 'listed' | 'unlisted'

  final List<Map<String, dynamic>> photos; // raw {url, caption, order} maps
  final int coverPhotoIndex;
  final String? coverPhotoUrl;

  final String? wilaya;
  final String? city;
  final String? neighborhood;
  final String? fullAddress;
  final double? latitude;
  final double? longitude;

  final double pricePerNight;

  // ── House rules ──────────────────────────────────────
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool adultOnly;
  final bool curfew;
  final String? curfewTime; // "HH:mm - HH:mm"
  final String? additionalRules;
  final bool familyBookletRequired;

  // ── Booking preferences ──────────────────────────────
  final bool instantBook;
  final int advanceNoticeHours;
  final int minStayNights;
  final int maxStayNights;
  final String checkInTimeFrom;
  final String checkInTimeTo;
  final String checkOutTime;

  final String cancellationPolicy; // 'Flexible' | 'Moderate' | 'Firm'
  final String? checkInInstructions;

  final double totalEarnings;
  final int totalViews;
  final int totalBookings;

  final double ratingOverall;
  final int reviewCount;
  final bool isGuestFavorite;

  HostListingDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.styleType,
    required this.categories,
    required this.amenities,
    required this.status,
    required this.visibility,
    required this.photos,
    required this.coverPhotoIndex,
    required this.coverPhotoUrl,
    required this.wilaya,
    required this.city,
    required this.neighborhood,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    required this.pricePerNight,
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.eventsAllowed,
    required this.adultOnly,
    required this.curfew,
    required this.curfewTime,
    required this.additionalRules,
    required this.familyBookletRequired,
    required this.instantBook,
    required this.advanceNoticeHours,
    required this.minStayNights,
    required this.maxStayNights,
    required this.checkInTimeFrom,
    required this.checkInTimeTo,
    required this.checkOutTime,
    required this.cancellationPolicy,
    required this.checkInInstructions,
    required this.totalEarnings,
    required this.totalViews,
    required this.totalBookings,
    required this.ratingOverall,
    required this.reviewCount,
    required this.isGuestFavorite,
  });

  factory HostListingDetailModel.fromJson(Map<String, dynamic> json) {
    final photosJson = (json['photos'] as List<dynamic>? ?? [])
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
    final amenitiesJson = (json['amenities'] as List<dynamic>? ?? [])
        .map((a) => Map<String, dynamic>.from(a as Map))
        .toList();
    final coverIndex = (json['coverPhotoIndex'] as num?)?.toInt() ?? 0;
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final coordinates = location['coordinates'] as Map<String, dynamic>?;
    final coordsList = coordinates?['coordinates'] as List<dynamic>?; // [lng, lat]
    final price = json['price'] as Map<String, dynamic>? ?? {};
    final houseRules = json['houseRules'] as Map<String, dynamic>? ?? {};
    final bookingPreferences = json['bookingPreferences'] as Map<String, dynamic>? ?? {};

    String? coverUrl;
    if (photosJson.isNotEmpty) {
      final index = coverIndex < photosJson.length ? coverIndex : 0;
      coverUrl = photosJson[index]['url'] as String?;
    }

    return HostListingDetailModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      styleType: json['styleType'] as String?,
      categories: (json['categories'] as List<dynamic>? ?? []).map((c) => c.toString()).toList(),
      amenities: amenitiesJson,
      status: json['status'] as String? ?? 'draft',
      visibility: json['visibility'] as String? ?? 'unlisted',
      photos: photosJson,
      coverPhotoIndex: coverIndex,
      coverPhotoUrl: coverUrl,
      wilaya: location['wilaya'] as String?,
      city: location['city'] as String?,
      neighborhood: location['neighborhood'] as String?,
      fullAddress: location['fullAddress'] as String?,
      latitude: coordsList != null && coordsList.length == 2 ? (coordsList[1] as num).toDouble() : null,
      longitude: coordsList != null && coordsList.length == 2 ? (coordsList[0] as num).toDouble() : null,
      pricePerNight: (price['perNight'] as num?)?.toDouble() ?? 0,
      petsAllowed: houseRules['petsAllowed'] as bool? ?? false,
      smokingAllowed: houseRules['smokingAllowed'] as bool? ?? false,
      eventsAllowed: houseRules['eventsAllowed'] as bool? ?? false,
      adultOnly: houseRules['adultOnly'] as bool? ?? false,
      curfew: houseRules['curfew'] as bool? ?? false,
      curfewTime: houseRules['curfewTime'] as String?,
      additionalRules: houseRules['additionalRules'] as String?,
      familyBookletRequired: houseRules['familyBookletRequired'] as bool? ?? false,
      instantBook: bookingPreferences['instantBook'] as bool? ?? false,
      advanceNoticeHours: (bookingPreferences['advanceNoticeHours'] as num?)?.toInt() ?? 24,
      minStayNights: (bookingPreferences['minStayNights'] as num?)?.toInt() ?? 1,
      maxStayNights: (bookingPreferences['maxStayNights'] as num?)?.toInt() ?? 365,
      checkInTimeFrom: bookingPreferences['checkInTimeFrom'] as String? ?? '14:00',
      checkInTimeTo: bookingPreferences['checkInTimeTo'] as String? ?? '22:00',
      checkOutTime: bookingPreferences['checkOutTime'] as String? ?? '11:00',
      cancellationPolicy: json['cancellationPolicy'] as String? ?? 'Moderate',
      checkInInstructions: json['checkInInstructions'] as String?,
      totalEarnings: (stats['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalViews: (stats['totalViews'] as num?)?.toInt() ?? 0,
      totalBookings: (stats['totalBookings'] as num?)?.toInt() ?? 0,
      ratingOverall: (rating['overall'] as num?)?.toDouble() ?? 0,
      reviewCount: (rating['totalReviews'] as num?)?.toInt() ?? 0,
      isGuestFavorite: json['isGuestFavorite'] as bool? ?? false,
    );
  }

  /// "ACTIVE" / "IN REVIEW" / "PAUSED" / "DRAFT" / "REJECTED"
  String get statusLabel {
    switch (status) {
      case 'active': return 'ACTIVE';
      case 'pending_review': return 'IN REVIEW';
      case 'inactive': return 'PAUSED';
      case 'rejected': return 'REJECTED';
      default: return 'DRAFT';
    }
  }

  /// "142 500 DZD" — thousands separated with a space.
  String get formattedEarnings {
    final rounded = totalEarnings.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      final posFromEnd = rounded.length - i;
      buffer.write(rounded[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return '${buffer.toString()} DZD';
  }

  /// "1,248" — comma-grouped for the views/bookings counters.
  String _grouped(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final posFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  String get formattedViews => _grouped(totalViews);
  String get formattedBookings => _grouped(totalBookings);

  /// "Casbah, Algiers, Algeria"-style caption for the location preview.
  String get locationLabel {
    final parts = [city, wilaya].where((p) => p != null && p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Location not set';
    return '${parts.join(', ')}, Algeria';
  }

  /// "Casbah, Algiers" — no country suffix, used by Listing Settings'
  /// current-listing card, matching the mockup.
  String get shortLocationLabel {
    final parts = [city, wilaya].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? 'Location not set' : parts.join(', ');
  }
}