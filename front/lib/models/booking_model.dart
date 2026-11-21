/// One booking, as returned by the /api/bookings routes (listing, guest
/// and host populated). The backend strips the exact address, check-in
/// instructions and phone numbers until the stay is confirmed.
class BookingModel {
  final String id;
  final String status; // pending | confirmed | completed | cancelled_by_guest | cancelled_by_host | rejected | expired
  final String viewerRole; // 'guest' | 'host' — who is looking at it

  final DateTime checkIn; // calendar day (UTC midnight from the server)
  final DateTime checkOut;
  final int nights;
  final int guestsCount;

  final double nightlyRate;
  final double subtotal;
  final double discount;
  final double serviceFee;
  final double touristTax;
  final double total;
  final double hostPayout;
  final String currency;

  final bool instantBook;
  final String cancellationPolicy;
  final DateTime? freeCancellationUntil;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final String declineReason;
  final String cancellationReason;
  final double? refundAmount;
  /// Set once the guest reviewed this stay.
  final String? guestReviewId;

  // Listing
  final String listingId;
  final String listingTitle;
  final String? listingPhotoUrl;
  final String? listingCity;
  final String? listingWilaya;
  final String? fullAddress; // confirmed stays only
  final String? checkInInstructions; // confirmed stays only
  final String checkInTimeFrom;
  final String checkInTimeTo;
  final String checkOutTimeFrom;
  final String checkOutTimeTo;

  // People
  final String guestId;
  final String guestName;
  final String? guestPhoto;
  final String? guestPhone;
  final String hostId;
  final String hostName;
  final String? hostPhoto;
  final String? hostPhone;

  BookingModel({
    required this.id,
    required this.status,
    required this.viewerRole,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.guestsCount,
    required this.nightlyRate,
    required this.subtotal,
    required this.discount,
    required this.serviceFee,
    required this.touristTax,
    required this.total,
    required this.hostPayout,
    required this.currency,
    required this.instantBook,
    required this.cancellationPolicy,
    required this.freeCancellationUntil,
    required this.expiresAt,
    required this.createdAt,
    required this.declineReason,
    required this.cancellationReason,
    required this.refundAmount,
    this.guestReviewId,
    required this.listingId,
    required this.listingTitle,
    required this.listingPhotoUrl,
    required this.listingCity,
    required this.listingWilaya,
    required this.fullAddress,
    required this.checkInInstructions,
    required this.checkInTimeFrom,
    required this.checkInTimeTo,
    required this.checkOutTimeFrom,
    required this.checkOutTimeTo,
    required this.guestId,
    required this.guestName,
    required this.guestPhoto,
    required this.guestPhone,
    required this.hostId,
    required this.hostName,
    required this.hostPhoto,
    required this.hostPhone,
  });

  static Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  /// Server days are UTC midnight — keep them as plain calendar dates.
  static DateTime _day(dynamic v) {
    final d = DateTime.parse(v.toString()).toUtc();
    return DateTime(d.year, d.month, d.day);
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final listing = _map(json['listingId']);
    final guest = _map(json['guestId']);
    final host = _map(json['hostId']);
    final pricing = _map(json['pricing']);
    final location = _map(listing['location']);
    final prefs = _map(listing['bookingPreferences']);

    String? photo;
    final photos = listing['photos'] as List<dynamic>? ?? [];
    if (photos.isNotEmpty) {
      final cover = (listing['coverPhotoIndex'] as num?)?.toInt() ?? 0;
      photo = _map(photos[cover < photos.length ? cover : 0])['url'] as String?;
    }

    return BookingModel(
      id: json['_id']?.toString() ?? '',
      status: json['status'] as String? ?? 'pending',
      viewerRole: json['viewerRole'] as String? ?? 'guest',
      checkIn: _day(json['checkIn']),
      checkOut: _day(json['checkOut']),
      nights: (json['nights'] as num?)?.toInt() ?? 0,
      guestsCount: (json['guestsCount'] as num?)?.toInt() ?? 1,
      nightlyRate: _num(pricing['nightlyRate']),
      subtotal: _num(pricing['subtotal']),
      discount: _num(pricing['discount']),
      serviceFee: _num(pricing['serviceFee']),
      touristTax: _num(pricing['touristTax']),
      total: _num(pricing['totalDZD']),
      hostPayout: _num(pricing['hostPayout']),
      currency: pricing['currency'] as String? ?? 'DZD',
      instantBook: json['instantBook'] == true,
      cancellationPolicy: json['cancellationPolicy'] as String? ?? 'Moderate',
      freeCancellationUntil: _date(json['freeCancellationUntil'])?.toLocal(),
      expiresAt: _date(json['expiresAt'])?.toLocal(),
      createdAt: _date(json['createdAt'])?.toLocal(),
      declineReason: json['declineReason'] as String? ?? '',
      cancellationReason: json['cancellationReason'] as String? ?? '',
      refundAmount: (json['refundAmount'] as num?)?.toDouble(),
      guestReviewId: json['guestReviewId']?.toString(),
      listingId: listing['_id']?.toString() ?? json['listingId']?.toString() ?? '',
      listingTitle: listing['title'] as String? ?? 'Listing',
      listingPhotoUrl: photo,
      listingCity: location['city'] as String?,
      listingWilaya: location['wilaya'] as String?,
      fullAddress: location['fullAddress'] as String?,
      checkInInstructions: listing['checkInInstructions'] as String?,
      checkInTimeFrom: prefs['checkInTimeFrom'] as String? ?? '14:00',
      checkInTimeTo: prefs['checkInTimeTo'] as String? ?? '22:00',
      checkOutTimeFrom: prefs['checkOutTimeFrom'] as String? ?? '11:00',
      checkOutTimeTo: prefs['checkOutTimeTo'] as String? ?? '12:00',
      guestId: guest['_id']?.toString() ?? '',
      guestName: guest['fullName'] as String? ?? 'Guest',
      guestPhoto: guest['profilePhoto'] as String?,
      guestPhone: guest['phone']?.toString(),
      hostId: host['_id']?.toString() ?? '',
      hostName: host['fullName'] as String? ?? 'Host',
      hostPhoto: host['profilePhoto'] as String?,
      hostPhone: host['phone']?.toString(),
    );
  }

  bool get isHostView => viewerRole == 'host';
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';

  /// Stay has started (check-in day reached) — can't be cancelled anymore.
  bool get hasStarted {
    final now = DateTime.now();
    return !DateTime(now.year, now.month, now.day).isBefore(checkIn);
  }

  /// Currently checked in.
  bool get isCurrent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return isConfirmed && !today.isBefore(checkIn) && today.isBefore(checkOut);
  }

  /// Guest's completed stay that hasn't been reviewed yet.
  bool get canReview => !isHostView && status == 'completed' && (guestReviewId == null || guestReviewId!.isEmpty);

  bool get canHostRespond => isHostView && isPending && (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
  bool get canCancel => (isPending && !isHostView || isConfirmed) && !hasStarted;

  String get location => [listingCity, listingWilaya].where((p) => p != null && p.isNotEmpty).join(', ');

  /// The other person in this booking, from the viewer's side.
  String get otherPersonName => isHostView ? guestName : hostName;
  String? get otherPersonPhoto => isHostView ? guestPhoto : hostPhoto;
  String get otherPersonId => isHostView ? guestId : hostId;
}
