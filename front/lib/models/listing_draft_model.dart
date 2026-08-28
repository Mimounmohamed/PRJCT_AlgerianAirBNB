/// Mutable draft object carried through the entire Create Listing wizard.
/// Field names/shape mirror back/src/models/Listing.js exactly, so
/// [toJson] can be POSTed straight to `POST /api/listings` once the
/// wizard reaches the Review & Submit step.
///
/// Not every field has a wizard step yet (Location/Photos/Pricing/
/// Amenities/House Rules/Booking Preferences steps don't exist yet) —
/// those fields just sit at their schema defaults until built out.
class ListingDraft {
  // ── Basics ─────────────────────────────────────────────
  String propertyType;
  String title = '';
  String description = '';
  String descriptionTitle = '';
  String? styleType;
  List<String> categories = [];

  // ── Capacity ───────────────────────────────────────────
  int guests;
  int bedrooms;
  double bathrooms;

  // ── Location ───────────────────────────────────────────
  String? wilaya;
  String? city;
  String? neighborhood;
  String? fullAddress;
  double? lat;
  double? lng;

  // ── Pricing ────────────────────────────────────────────
  num? pricePerNight;
  String currency = 'DZD';
  double touristTaxPercent = 5.5;
  double serviceFeePercent = 8;
  double weeklyDiscountPercent = 0;
  double monthlyDiscountPercent = 0;

  // ── Media ──────────────────────────────────────────────
  // Each entry: {url, caption, order}
  List<Map<String, dynamic>> photos = [];
  int coverPhotoIndex = 0;

  // ── Amenities ──────────────────────────────────────────
  // Each entry: {catalogKey, name, category, iconName, description, isCustom}
  List<Map<String, dynamic>> amenities = [];

  // ── House Rules ────────────────────────────────────────
  bool petsAllowed = false;
  bool smokingAllowed = false;
  bool eventsAllowed = false;
  bool adultOnly = false;
  bool curfew = false;
  String? curfewTime;
  String? additionalRules;

  // ── Booking Preferences ────────────────────────────────
  bool instantBook = false;
  int advanceNoticeHours = 24;
  int minStayNights = 1;
  int maxStayNights = 365;
  String checkInTimeFrom = '14:00';
  String checkInTimeTo = '22:00';
  String checkOutTime = '11:00';

  String cancellationPolicy = 'Moderate';
  String? checkInInstructions;

  ListingDraft({
    required this.propertyType,
    required this.guests,
    required this.bedrooms,
    required this.bathrooms,
  });

  /// Builds the POST /api/listings request body. Note: hostId and
  /// status are forced server-side (see listing.routes.js), so they're
  /// intentionally omitted here.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'descriptionTitle': descriptionTitle,
      'propertyType': propertyType,
      if (styleType != null) 'styleType': styleType,
      'categories': categories,
      'location': {
        if (wilaya != null) 'wilaya': wilaya,
        if (city != null) 'city': city,
        if (neighborhood != null) 'neighborhood': neighborhood,
        if (fullAddress != null) 'fullAddress': fullAddress,
        'coordinates': {
          'type': 'Point',
          'coordinates': [lng ?? 0, lat ?? 0],
        },
      },
      'price': {
        'perNight': pricePerNight ?? 0,
        'currency': currency,
        'touristTaxPercent': touristTaxPercent,
        'serviceFeePercent': serviceFeePercent,
        'weeklyDiscountPercent': weeklyDiscountPercent,
        'monthlyDiscountPercent': monthlyDiscountPercent,
      },
      'capacity': {
        'guests': guests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
      },
      'photos': photos,
      'coverPhotoIndex': coverPhotoIndex,
      'amenities': amenities,
      'houseRules': {
        'petsAllowed': petsAllowed,
        'smokingAllowed': smokingAllowed,
        'eventsAllowed': eventsAllowed,
        'adultOnly': adultOnly,
        'curfew': curfew,
        if (curfewTime != null) 'curfewTime': curfewTime,
        if (additionalRules != null) 'additionalRules': additionalRules,
      },
      'bookingPreferences': {
        'instantBook': instantBook,
        'advanceNoticeHours': advanceNoticeHours,
        'minStayNights': minStayNights,
        'maxStayNights': maxStayNights,
        'checkInTimeFrom': checkInTimeFrom,
        'checkInTimeTo': checkInTimeTo,
        'checkOutTime': checkOutTime,
      },
      'cancellationPolicy': cancellationPolicy,
      if (checkInInstructions != null) 'checkInInstructions': checkInInstructions,
    };
  }
}