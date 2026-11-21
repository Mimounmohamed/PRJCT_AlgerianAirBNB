import 'booking_model.dart';

/// Parses GET /api/host/dashboard.
class HostDashboardModel {
  final int totalListings;
  final int activeListings;
  final double totalEarnings; // earned — completed stays only
  /// Host's share of all confirmed + completed bookings (cancelled,
  /// declined and expired ones excluded). Shown as "Projected Earnings".
  final double projectedEarnings;
  final int totalBookings;
  final int totalViews;
  final double avgRating;

  // Booking sections on the dashboard home.
  final int pendingRequestCount;
  final List<BookingModel> requests; // pending, soonest-expiring first (max 3)
  final List<BookingModel> upcoming; // next confirmed stays (max 3)
  final List<BookingModel> history; // latest completed / cancelled / declined / expired (max 5)

  HostDashboardModel({
    required this.totalListings,
    required this.activeListings,
    required this.totalEarnings,
    this.projectedEarnings = 0,
    required this.totalBookings,
    required this.totalViews,
    required this.avgRating,
    this.pendingRequestCount = 0,
    this.requests = const [],
    this.upcoming = const [],
    this.history = const [],
  });

  factory HostDashboardModel.fromJson(Map<String, dynamic> json) {
    final bookings = json['bookings'] is Map ? Map<String, dynamic>.from(json['bookings'] as Map) : <String, dynamic>{};
    // These come straight from the host's dashboard, so the viewer is the host.
    List<BookingModel> parse(String key) => (bookings[key] as List<dynamic>? ?? [])
        .map((b) => BookingModel.fromJson({...Map<String, dynamic>.from(b as Map), 'viewerRole': 'host'}))
        .toList();

    return HostDashboardModel(
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      activeListings: (json['activeListings'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      projectedEarnings: (json['projectedEarnings'] as num?)?.toDouble() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
      pendingRequestCount: (bookings['pendingCount'] as num?)?.toInt() ?? 0,
      requests: parse('requests'),
      upcoming: parse('upcoming'),
      history: parse('history'),
    );
  }

  /// Projected earnings as "420 000 DA" — what the dashboard tile shows.
  String get formattedProjectedEarnings => _formatDa(projectedEarnings);

  /// "420 000 DA" — thousands separated with a space.
  String get formattedEarnings => _formatDa(totalEarnings);

  static String _formatDa(double amount) {
    final rounded = amount.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      final posFromEnd = rounded.length - i;
      buffer.write(rounded[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return '${buffer.toString()} DA';
  }

  /// "1.2k" for large view counts, plain number otherwise.
  String get formattedViews {
    if (totalViews >= 1000) {
      return '${(totalViews / 1000).toStringAsFixed(1)}k';
    }
    return '$totalViews';
  }
}