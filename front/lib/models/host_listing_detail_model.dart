/// Parses one listing document as returned by GET /api/host/listings/:id
/// (raw Listing doc, host-scoped/ownership-checked) — used for the
/// Manage Listing page's performance highlights and header.
class HostListingDetailModel {
  final String id;
  final String title;
  final String propertyType;
  final String status; // 'draft' | 'pending_review' | 'active' | 'inactive' | 'rejected'
  final String? coverPhotoUrl;

  final double totalEarnings;
  final int totalViews;
  final int totalBookings;

  final double ratingOverall;
  final int reviewCount;
  final bool isGuestFavorite;

  HostListingDetailModel({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.status,
    required this.coverPhotoUrl,
    required this.totalEarnings,
    required this.totalViews,
    required this.totalBookings,
    required this.ratingOverall,
    required this.reviewCount,
    required this.isGuestFavorite,
  });

  factory HostListingDetailModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>? ?? [];
    final coverIndex = (json['coverPhotoIndex'] as num?)?.toInt() ?? 0;
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final rating = json['rating'] as Map<String, dynamic>? ?? {};

    String? coverUrl;
    if (photos.isNotEmpty) {
      final index = coverIndex < photos.length ? coverIndex : 0;
      coverUrl = (photos[index] as Map<String, dynamic>)['url'] as String?;
    }

    return HostListingDetailModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      coverPhotoUrl: coverUrl,
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
}