/// Parses a single listing document as returned by GET /api/listings
/// (see back/src/routes/listing.routes.js and models/Listing.js).
class ListingModel {
  final String id;
  final String title;
  final String city;
  final String wilaya;
  final double pricePerNight;
  final String currency;
  final double ratingOverall;
  final int reviewCount;
  final String? coverPhotoUrl;
  final bool isGuestFavorite;

  ListingModel({
    required this.id,
    required this.title,
    required this.city,
    required this.wilaya,
    required this.pricePerNight,
    required this.currency,
    required this.ratingOverall,
    required this.reviewCount,
    required this.coverPhotoUrl,
    required this.isGuestFavorite,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final price = json['price'] as Map<String, dynamic>? ?? {};
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    final photos = json['photos'] as List<dynamic>? ?? [];
    final coverIndex = (json['coverPhotoIndex'] as num?)?.toInt() ?? 0;

    String? coverUrl;
    if (photos.isNotEmpty) {
      final index = coverIndex < photos.length ? coverIndex : 0;
      coverUrl = (photos[index] as Map<String, dynamic>)['url'] as String?;
    }

    return ListingModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      city: location['city'] as String? ?? '',
      wilaya: location['wilaya'] as String? ?? '',
      pricePerNight: (price['perNight'] as num?)?.toDouble() ?? 0,
      currency: price['currency'] as String? ?? 'DZD',
      ratingOverall: (rating['overall'] as num?)?.toDouble() ?? 0,
      reviewCount: (rating['totalReviews'] as num?)?.toInt() ?? 0,
      coverPhotoUrl: coverUrl,
      isGuestFavorite: json['isGuestFavorite'] as bool? ?? false,
    );
  }

  /// "9 200 DA" — thousands separated with a space, DZD shown as "DA".
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