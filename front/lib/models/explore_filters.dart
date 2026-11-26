/// A group of wilayas guests search as one place ("The Sahara").
class DiscoverRegion {
  final String name;
  final String subtitle;
  final String imageAsset;
  final List<String> wilayas;

  const DiscoverRegion({
    required this.name,
    required this.subtitle,
    required this.imageAsset,
    required this.wilayas,
  });
}

/// Regions on the search screen. Wilaya names are the ones listings are
/// saved with (the app's commune dataset), plus "Algiers" which older
/// listings use for Alger.
const List<DiscoverRegion> kDiscoverRegions = [
  DiscoverRegion(
    name: 'Casbah',
    subtitle: 'Algiers and around',
    imageAsset: 'assets/images/courtyard.png',
    wilayas: ['Alger', 'Algiers', 'Blida', 'Boumerdès', 'Tipaza'],
  ),
  DiscoverRegion(
    name: 'Sahara',
    subtitle: 'Desert towns and dunes',
    imageAsset: 'assets/images/hospitality.png',
    wilayas: [
      'Adrar', 'Tamanrasset', 'Illizi', 'Djanet', 'Ghardaïa', 'Béchar', 'Béni Abbès', 'Timimoun',
      'Ain Salah', 'Ain Guezzam', 'Bordj Badji Mokhtar', 'Tindouf', 'Ouargla', 'Touggourt', 'El Oued',
      'El Menia', 'El Meghaier', 'Biskra', 'Ouled Djellal', 'Laghouat',
    ],
  ),
  DiscoverRegion(
    name: 'The Coast',
    subtitle: 'Mediterranean beaches',
    imageAsset: 'assets/images/discover.png',
    wilayas: [
      'Oran', 'Béjaïa', 'Annaba', 'Jijel', 'Skikda', 'El Tarf', 'Mostaganem', 'Aïn Témouchent',
      'Tlemcen', 'Chlef', 'Tizi Ouzou',
    ],
  ),
  DiscoverRegion(
    name: 'The East',
    subtitle: 'Constantine and the Aurès',
    imageAsset: 'assets/images/authentically.png',
    wilayas: [
      'Constantine', 'Sétif', 'Batna', 'Guelma', 'Mila', 'Oum El Bouaghi', 'Khenchela', 'Tébessa',
      'Souk Ahras', 'Bordj Bou Arreridj',
    ],
  ),
];

/// A popular amenity guests can require in Filters. [keys] are amenity
/// catalogKeys; a listing matches if it has any one of them.
class AmenityFilterOption {
  final String label;
  final List<String> keys;
  const AmenityFilterOption(this.label, this.keys);
  String get param => keys.join('|');
}

const List<AmenityFilterOption> kAmenityFilterOptions = [
  AmenityFilterOption('Wi-Fi', ['fiber_wifi', 'wifi']),
  AmenityFilterOption('Air conditioning', ['air_conditioning']),
  AmenityFilterOption('Kitchen', ['full_kitchen']),
  AmenityFilterOption('Free parking', ['free_parking']),
  AmenityFilterOption('Pool', ['private_pool', 'shared_pool']),
  AmenityFilterOption('Washer', ['in_unit_washer']),
  AmenityFilterOption('Sea view', ['sea_view']),
];

/// Everything that narrows the Discover list: what the guest typed or
/// picked on the search screen (place) plus the Filters page.
class ExploreFilters {
  // ── Where ─────────────────────────────────────────────
  /// Free text ("ora", "riad") — matches title, city, wilaya, type.
  final String? search;
  /// A wilaya or region picked on the search screen.
  final String? placeLabel;
  final List<String> wilayas;

  // ── Filters page ──────────────────────────────────────
  final Set<String> propertyTypes;
  final int? minPrice;
  final int? maxPrice;
  final int guests;
  final int bedrooms;
  final int bathrooms;
  final Set<String> amenities; // AmenityFilterOption.label
  final bool instantBook;

  const ExploreFilters({
    this.search,
    this.placeLabel,
    this.wilayas = const [],
    this.propertyTypes = const {},
    this.minPrice,
    this.maxPrice,
    this.guests = 0,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.amenities = const {},
    this.instantBook = false,
  });

  static const ExploreFilters empty = ExploreFilters();

  /// A new place (text, wilaya or region) replaces the previous one; the
  /// Filters page choices stay.
  ExploreFilters withPlace({String? search, String? placeLabel, List<String> wilayas = const []}) => ExploreFilters(
        search: search,
        placeLabel: placeLabel,
        wilayas: wilayas,
        propertyTypes: propertyTypes,
        minPrice: minPrice,
        maxPrice: maxPrice,
        guests: guests,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        amenities: amenities,
        instantBook: instantBook,
      );

  ExploreFilters clearPlace() => withPlace();

  /// Keeps the place, replaces the Filters page choices.
  ExploreFilters withRefinements(ExploreFilters r) => ExploreFilters(
        search: search,
        placeLabel: placeLabel,
        wilayas: wilayas,
        propertyTypes: r.propertyTypes,
        minPrice: r.minPrice,
        maxPrice: r.maxPrice,
        guests: r.guests,
        bedrooms: r.bedrooms,
        bathrooms: r.bathrooms,
        amenities: r.amenities,
        instantBook: r.instantBook,
      );

  ExploreFilters withPropertyTypes(Set<String> types) => withRefinements(ExploreFilters(
        propertyTypes: types,
        minPrice: minPrice,
        maxPrice: maxPrice,
        guests: guests,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        amenities: amenities,
        instantBook: instantBook,
      ));

  bool get hasPlace => (search != null && search!.isNotEmpty) || wilayas.isNotEmpty;

  /// What the search bar shows as the place.
  String? get placeText => placeLabel ?? search;

  /// Number of Filters page choices in use (badge on the filter icon).
  int get refinementCount =>
      (propertyTypes.isNotEmpty ? 1 : 0) +
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (guests > 0 ? 1 : 0) +
      (bedrooms > 0 ? 1 : 0) +
      (bathrooms > 0 ? 1 : 0) +
      amenities.length +
      (instantBook ? 1 : 0);

  /// Query parameters for GET /api/listings.
  Map<String, String> toQuery() {
    final amenityParams = kAmenityFilterOptions.where((o) => amenities.contains(o.label)).map((o) => o.param);
    return {
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
      if (wilayas.isNotEmpty) 'wilaya': wilayas.join(','),
      if (propertyTypes.isNotEmpty) 'propertyType': propertyTypes.join(','),
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (guests > 0) 'guests': '$guests',
      if (bedrooms > 0) 'bedrooms': '$bedrooms',
      if (bathrooms > 0) 'bathrooms': '$bathrooms',
      if (amenityParams.isNotEmpty) 'amenities': amenityParams.join(','),
      if (instantBook) 'instantBook': 'true',
    };
  }
}
