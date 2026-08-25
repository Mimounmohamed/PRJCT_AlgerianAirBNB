/// Parses one listing document as returned by GET /api/host/listings
/// (raw Listing docs, unlike the public /api/listings endpoint's shaped
/// response). Used for the "Your listings" rows on the Host dashboard.
class HostListingSummaryModel {
  final String id;
  final String title;
  final String propertyType;
  final String city;
  final String? coverPhotoUrl;
  final String status; // 'draft' | 'pending_review' | 'active' | 'inactive' | 'rejected'

  HostListingSummaryModel({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.city,
    required this.coverPhotoUrl,
    required this.status,
  });

  factory HostListingSummaryModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final photos = json['photos'] as List<dynamic>? ?? [];
    final coverIndex = (json['coverPhotoIndex'] as num?)?.toInt() ?? 0;

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

  /// Status-derived subtitle. TODO: replace the 'active' case with a real
  /// "Next check-in: <date>" once a per-listing upcoming-booking query
  /// exists — the current dashboard endpoint only returns host-wide
  /// recentBookings, not per-listing next-checkin dates.
  String get statusSubtitle {
    switch (status) {
      case 'active': return 'Active listing';
      case 'pending_review': return 'Pending approval';
      case 'inactive': return 'Paused by host';
      case 'rejected': return 'Rejected — needs changes';
      default: return 'Draft — not yet published';
    }
  }
}