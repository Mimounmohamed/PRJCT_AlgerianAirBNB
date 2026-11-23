/// Parses one listing document as returned by GET /api/host/listings
/// (raw Listing docs plus `nextCheckIn`, unlike the public /api/listings
/// endpoint's shaped response). Used for the "Your listings" rows on the
/// Host dashboard and the All listings page.
class HostListingSummaryModel {
  final String id;
  final String title;
  final String propertyType;
  final String city;
  final String? coverPhotoUrl;
  final String status; // 'draft' | 'pending_review' | 'active' | 'inactive' | 'rejected'
  final double pricePerNight;
  final String currency;
  final String visibility; // 'listed' | 'unlisted' | 'snoozed'
  final DateTime? snoozedUntil;
  // Earliest confirmed stay that hasn't started yet, or null.
  final DateTime? nextCheckIn;

  HostListingSummaryModel({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.city,
    required this.coverPhotoUrl,
    required this.status,
    required this.pricePerNight,
    required this.currency,
    this.visibility = 'listed',
    this.snoozedUntil,
    this.nextCheckIn,
  });

  factory HostListingSummaryModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final photos = json['photos'] as List<dynamic>? ?? [];
    final coverIndex = (json['coverPhotoIndex'] as num?)?.toInt() ?? 0;
    final price = json['price'] as Map<String, dynamic>? ?? {};

    String? coverUrl;
    if (photos.isNotEmpty) {
      final index = coverIndex < photos.length ? coverIndex : 0;
      coverUrl = (photos[index] as Map<String, dynamic>)['url'] as String?;
    }

    return HostListingSummaryModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      propertyType: json['propertyType'] as String? ?? '',
      city: location['city'] as String? ?? '',
      coverPhotoUrl: coverUrl,
      status: json['status'] as String? ?? 'draft',
      pricePerNight: (price['perNight'] as num?)?.toDouble() ?? 0,
      currency: price['currency'] as String? ?? 'DZD',
      visibility: json['visibility'] as String? ?? 'listed',
      snoozedUntil: DateTime.tryParse(json['snoozedUntil']?.toString() ?? '')?.toLocal(),
      // Booking days are stored as UTC midnight — keep the UTC calendar day.
      nextCheckIn: DateTime.tryParse(json['nextCheckIn']?.toString() ?? '')?.toUtc(),
    );
  }

  /// An active listing the host snoozed (hidden from guests until a date).
  bool get isSnoozed =>
      status == 'active' && visibility == 'snoozed' && snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  /// An active listing the host hid from search (Listing visibility → Unlisted).
  bool get isUnlisted => status == 'active' && visibility == 'unlisted';

  /// What the row shows: the status, except that an active listing hidden
  /// from guests shows 'snoozed' / 'unlisted' instead of 'active'.
  String get displayStatus => isSnoozed ? 'snoozed' : (isUnlisted ? 'unlisted' : status);

  /// "ACTIVE" / "SNOOZED" / "UNLISTED" / "IN REVIEW" / "PAUSED" / "DRAFT" / "REJECTED"
  String get statusLabel {
    switch (displayStatus) {
      case 'active': return 'ACTIVE';
      case 'snoozed': return 'SNOOZED';
      case 'unlisted': return 'UNLISTED';
      case 'pending_review': return 'IN REVIEW';
      case 'inactive': return 'PAUSED';
      case 'rejected': return 'REJECTED';
      default: return 'DRAFT';
    }
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String _shortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

  /// "Next check-in: Nov 28" / "No upcoming stays" for a live listing,
  /// "Snoozed until Dec 3" for a snoozed one, otherwise status-derived.
  String get statusSubtitle {
    switch (displayStatus) {
      case 'active':
      case 'unlisted':
        final next = nextCheckIn;
        final stays = next == null ? 'No upcoming stays' : 'Next check-in: ${_shortDate(next)}';
        return displayStatus == 'unlisted' ? 'Hidden from search · $stays' : stays;
      case 'snoozed':
        return 'Snoozed until ${_shortDate(snoozedUntil!)}';
      case 'pending_review': return 'Pending approval';
      case 'inactive': return 'Paused by host';
      case 'rejected': return 'Rejected — needs changes';
      default: return 'Draft — not yet published';
    }
  }

  /// "12 500 DA/night" — thousands separated with a space, DZD shown as "DA".
  String get formattedPricePerNight {
    final rounded = pricePerNight.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      final posFromEnd = rounded.length - i;
      buffer.write(rounded[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    final currencyLabel = currency == 'DZD' ? 'DA' : currency;
    return '${buffer.toString()} $currencyLabel/night';
  }
}
