class ReviewModel {
  final String id;
  final String listingId;
  final String? hostId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerPhotoUrl;
  final String? reviewerCity;
  final double ratingOverall;
  final double cleanliness;
  final double communication;
  final double checkIn;
  final double location;
  final double value;
  final String comment;
  final List<String> photos;
  final DateTime? createdAt;
  final String? hostReplyComment;
  final DateTime? hostRepliedAt;

  ReviewModel({
    required this.id,
    required this.listingId,
    this.hostId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerPhotoUrl,
    this.reviewerCity,
    required this.ratingOverall,
    required this.cleanliness,
    required this.communication,
    required this.checkIn,
    required this.location,
    required this.value,
    required this.comment,
    required this.photos,
    this.createdAt,
    this.hostReplyComment,
    this.hostRepliedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final reviewer = json['reviewerId'] is Map<String, dynamic>
        ? json['reviewerId'] as Map<String, dynamic>
        : (json['reviewerId'] is Map
            ? Map<String, dynamic>.from(json['reviewerId'] as Map)
            : <String, dynamic>{});

    final ratings = json['ratings'] is Map<String, dynamic>
        ? json['ratings'] as Map<String, dynamic>
        : (json['ratings'] is Map
            ? Map<String, dynamic>.from(json['ratings'] as Map)
            : <String, dynamic>{});

    final photosRaw = json['photos'] as List<dynamic>? ?? [];

    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    final hostReply = json['hostReply'] is Map<String, dynamic>
        ? json['hostReply'] as Map<String, dynamic>
        : (json['hostReply'] is Map
            ? Map<String, dynamic>.from(json['hostReply'] as Map)
            : null);

    DateTime? parsedReplyDate;
    if (hostReply?['repliedAt'] != null) {
      try {
        parsedReplyDate = DateTime.parse(hostReply!['repliedAt'].toString());
      } catch (_) {}
    }

    final double overall = (ratings['overall'] as num?)?.toDouble() ?? 5.0;

    String? parsedHostId;
    if (json['hostId'] != null) {
      if (json['hostId'] is Map) {
        parsedHostId = (json['hostId']['_id'] ?? '').toString();
      } else {
        parsedHostId = json['hostId'].toString();
      }
    }

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      listingId: (json['listingId'] ?? '').toString(),
      hostId: parsedHostId,
      reviewerId: (reviewer['_id'] ?? json['reviewerId'] ?? '').toString(),
      reviewerName: reviewer['fullName'] as String? ?? 'Guest',
      reviewerPhotoUrl: reviewer['profilePhoto'] as String?,
      reviewerCity: reviewer['city'] as String?,
      ratingOverall: overall,
      cleanliness: (ratings['cleanliness'] as num?)?.toDouble() ?? overall,
      communication: (ratings['communication'] as num?)?.toDouble() ?? overall,
      checkIn: (ratings['checkIn'] as num?)?.toDouble() ?? overall,
      location: (ratings['location'] as num?)?.toDouble() ?? overall,
      value: (ratings['value'] as num?)?.toDouble() ?? overall,
      comment: json['comment'] as String? ?? '',
      photos: photosRaw.map((e) => e.toString()).toList(),
      createdAt: parsedDate,
      hostReplyComment: hostReply?['comment'] as String?,
      hostRepliedAt: parsedReplyDate,
    );
  }

  bool get hasHostReply => hostReplyComment != null && hostReplyComment!.trim().isNotEmpty;

  ReviewModel copyWith({
    String? hostReplyComment,
    DateTime? hostRepliedAt,
  }) {
    return ReviewModel(
      id: id,
      listingId: listingId,
      hostId: hostId,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerPhotoUrl: reviewerPhotoUrl,
      reviewerCity: reviewerCity,
      ratingOverall: ratingOverall,
      cleanliness: cleanliness,
      communication: communication,
      checkIn: checkIn,
      location: location,
      value: value,
      comment: comment,
      photos: photos,
      createdAt: createdAt,
      hostReplyComment: hostReplyComment ?? this.hostReplyComment,
      hostRepliedAt: hostRepliedAt ?? this.hostRepliedAt,
    );
  }

  String get formattedDate {
    if (createdAt == null) return '';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  String get formattedHostReplyDate {
    if (hostRepliedAt == null) return '';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[hostRepliedAt!.month - 1]} ${hostRepliedAt!.year}';
  }

  String get reviewerInitials {
    final parts = reviewerName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'G';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}
