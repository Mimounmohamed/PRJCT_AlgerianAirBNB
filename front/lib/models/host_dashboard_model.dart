/// Parses GET /api/host/dashboard.
class HostDashboardModel {
  final int totalListings;
  final int activeListings;
  final double totalEarnings;
  final int totalBookings;
  final int totalViews;
  final double avgRating;

  HostDashboardModel({
    required this.totalListings,
    required this.activeListings,
    required this.totalEarnings,
    required this.totalBookings,
    required this.totalViews,
    required this.avgRating,
  });

  factory HostDashboardModel.fromJson(Map<String, dynamic> json) {
    return HostDashboardModel(
      totalListings: (json['totalListings'] as num?)?.toInt() ?? 0,
      activeListings: (json['activeListings'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0,
    );
  }

  /// "420 000 DA" — thousands separated with a space.
  String get formattedEarnings {
    final rounded = totalEarnings.round().toString();
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