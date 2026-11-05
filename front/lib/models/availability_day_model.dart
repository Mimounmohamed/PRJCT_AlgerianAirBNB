/// One calendar day, parsed from GET /api/availability/:listingId (guest
/// side) or GET /api/host/listings/:id/calendar (host side — that one also
/// carries real guest bookings).
class AvailabilityDayModel {
  final DateTime date;
  final String status; // 'available' | 'booked' | 'blocked'
  final double? priceOverride;

  /// Set when the day is taken by a real in-app guest booking (host
  /// calendar only). Null for days the host marked "booked" by hand.
  final String? bookingId;
  final String? bookingStatus; // 'pending' | 'confirmed'

  AvailabilityDayModel({
    required this.date,
    required this.status,
    required this.priceOverride,
    this.bookingId,
    this.bookingStatus,
  });

  bool get hasGuestBooking => bookingId != null;

  factory AvailabilityDayModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityDayModel(
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'available',
      priceOverride: (json['priceOverride'] as num?)?.toDouble(),
      bookingId: json['bookingId']?.toString(),
      bookingStatus: json['bookingStatus'] as String?,
    );
  }
}
