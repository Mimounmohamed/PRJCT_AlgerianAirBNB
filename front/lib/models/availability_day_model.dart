/// Parses one day's entry from GET /api/availability/:listingId
/// (back/src/models/Availability.js).
class AvailabilityDayModel {
  final DateTime date;
  final String status; // 'available' | 'booked' | 'blocked'
  final double? priceOverride;

  AvailabilityDayModel({
    required this.date,
    required this.status,
    required this.priceOverride,
  });

  factory AvailabilityDayModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityDayModel(
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'available',
      priceOverride: (json['priceOverride'] as num?)?.toDouble(),
    );
  }
}