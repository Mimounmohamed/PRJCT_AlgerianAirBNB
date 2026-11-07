import 'package:flutter/material.dart';
import '../../services/listing_service.dart';
import '../../models/listing_detail_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
import '../../chat/conversation.dart';
import '../widgets/detail_image_carousel.dart';
import '../widgets/host_section.dart';
import 'host_profile_page.dart';
import 'booking_page.dart';
import 'reviews_page.dart';
import '../../services/review_service.dart';
import '../../models/review_model.dart';
import '../widgets/add_review_sheet.dart';
import '../widgets/share_sheet.dart';
import '../widgets/amenities_section.dart';
import 'amenities_page.dart';
import '../widgets/location_map_preview.dart';
import '../widgets/booking_bottom_bar.dart';

/// Listing Detail page — fetches the full listing by id and renders the
/// photo carousel, title/rating, host row, description, amenities preview,
/// location preview, and a sticky booking bar.
class ListingDetailPage extends StatefulWidget {
  final String listingId;

  const ListingDetailPage({super.key, required this.listingId});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {

  void _refreshListing() {
    setState(() {
      _future = ListingService.fetchListingById(widget.listingId);
    });
  }

  Future<void> _openWriteReview(ListingDetailModel listing) async {
    final currentUserId = UserSession.instance.currentUser?.id;
    if (currentUserId != null && currentUserId == listing.hostId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hosts cannot write a review on their own listing.'),
          backgroundColor: Color(0xFF2A1B12),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to write a review.'),
          backgroundColor: Color(0xFF2A1B12),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newReview = await AddReviewSheet.show(
      context,
      listingId: listing.id,
      hostId: listing.hostId,
      listingTitle: listing.title,
    );

    if (newReview != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted! Thank you for your feedback.'),
          backgroundColor: Color(0xFF006972),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refreshListing();
    }
  }

  Widget _buildReviewsSection(ListingDetailModel listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    color: Color(0xFF2A1B12),
                    fontSize: 22,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE5A93C)),
                    const SizedBox(width: 4),
                    Text(
                      listing.ratingOverall > 0
                          ? '${listing.ratingOverall.toStringAsFixed(2)} (${listing.reviewCount})'
                          : 'No reviews yet',
                      style: const TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (UserSession.instance.currentUser?.id != listing.hostId)
              OutlinedButton.icon(
              onPressed: () => _openWriteReview(listing),
              icon: const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF006972)),
              label: const Text(
                'Write a review',
                style: TextStyle(
                  color: Color(0xFF006972),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HankenGrotesk',
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF006972)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<ReviewModel>>(
          future: ReviewService.fetchReviews(listing.id),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF3E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE7DCCB)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'No reviews for this listing yet',
                      style: TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Have you stayed here? Share your thoughts to help future travelers!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 13,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                  ],
                ),
              );
            }

            final previewReviews = reviews.take(3).toList();
            return Column(
              children: [
                ...previewReviews.map((r) => _inlineReviewCard(r)),
                if (reviews.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewsPage(
                              listingId: listing.id,
                              hostId: listing.hostId,
                              listingTitle: listing.title,
                              ratingOverall: listing.ratingOverall,
                              reviewCount: listing.reviewCount,
                            ),
                          ),
                        ).then((_) => _refreshListing()),
                        child: Text(
                          'Show all ${reviews.length} reviews',
                          style: const TextStyle(
                            color: Color(0xFF006972),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'HankenGrotesk',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _inlineReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE7DCCB),
                backgroundImage: review.reviewerPhotoUrl != null
                    ? NetworkImage(review.reviewerPhotoUrl!)
                    : null,
                child: review.reviewerPhotoUrl == null
                    ? Text(
                        review.reviewerInitials,
                        style: const TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'HankenGrotesk',
                      ),
                    ),
                    if (review.formattedDate.isNotEmpty)
                      Text(
                        review.formattedDate,
                        style: const TextStyle(
                          color: Color(0xFF8A7B6E),
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE5A93C)),
                  const SizedBox(width: 2),
                  Text(
                    review.ratingOverall.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 13,
                height: 1.4,
                fontFamily: 'HankenGrotesk',
              ),
            ),
          ],
          if (review.hasHostReply) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE7DCCB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply_rounded, size: 14, color: Color(0xFF006972)),
                      const SizedBox(width: 4),
                      const Text(
                        'Response from host',
                        style: TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                      if (review.formattedHostReplyDate.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          ' • ${review.formattedHostReplyDate}',
                          style: const TextStyle(
                            color: Color(0xFF8A7B6E),
                            fontSize: 11,
                            fontFamily: 'HankenGrotesk',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.hostReplyComment!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 12,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  late Future<ListingDetailModel> _future;
  bool _descriptionExpanded = false;
  bool _openingChat = false;

  @override
  void initState() {
    super.initState();
    _future = ListingService.fetchListingById(widget.listingId);
  }

  Future<void> _openChat(ListingDetailModel listing) async {
    // Don't allow messaging yourself
    final myId = UserSession.instance.currentUser?.id ?? '';
    if (listing.hostId.isEmpty || listing.hostId == myId) return;

    setState(() => _openingChat = true);
    try {
      final token = UserSession.instance.token ?? '';
      final result = await AuthService.startConversation(
        token: token,
        recipientId: listing.hostId,
        listingId: listing.id,
        content: 'Hi, I\'m interested in your listing "${listing.title}".',
      );

      final conv = result['conversation'] as Map<String, dynamic>? ?? result;
      final conversationId = (conv['_id'] ?? conv['id'] ?? '').toString();

      if (!mounted) return;

      // Build initials from host name
      final nameParts = listing.hostName.trim().split(' ');
      final initials = nameParts.length >= 2
          ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
          : listing.hostName.isNotEmpty
              ? listing.hostName[0].toUpperCase()
              : '?';

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            otherUserName: listing.hostName,
            otherUserInitials: initials,
            listingName: listing.title,
            listingLocation: '${listing.city}, Algeria',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<ListingDetailModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF006972)));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Couldn't load this listing.",
                      style: TextStyle(color: Color(0xFF2A1B12), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go back', style: TextStyle(color: Color(0xFF006972))),
                    ),
                  ],
                ),
              ),
            );
          }

          final listing = snapshot.data!;
          final locationLabel = [listing.wilaya, 'Algeria'].join(', ');

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailImageCarousel(
                      photoUrls: listing.photoUrls,
                      onBackTap: () => Navigator.of(context).pop(),
                      onShareTap: () => showShareSheet(context, listing),
                      onFavoriteToggle: (isFav) {
                        // TODO: wire favorite persistence
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            style: const TextStyle(
                              color: Color(0xFF2A1B12),
                              fontSize: 28,
                              fontFamily: 'CormorantGaramond',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF61564D)),
                              const SizedBox(width: 4),
                              Text(
                                '${listing.city}, Algeria',
                                style: const TextStyle(
                                  color: Color(0xFF61564D),
                                  fontSize: 16,
                                  fontFamily: 'HenkenGrotesk',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReviewsPage(
                                  listingId: listing.id,
                                  hostId: listing.hostId,
                                  listingTitle: listing.title,
                                  ratingOverall: listing.ratingOverall,
                                  reviewCount: listing.reviewCount,
                                ),
                              ),
                            ).then((_) => _refreshListing()),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 22, color: Color(0xFFE5A93C)),
                                const SizedBox(width: 6),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: listing.ratingOverall > 0
                                            ? listing.ratingOverall.toStringAsFixed(2)
                                            : 'New',
                                        style: const TextStyle(
                                          color: Color(0xFF2A1B12),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'HankenGrotesk',
                                        ),
                                      ),
                                      TextSpan(
                                        text: listing.reviewCount > 0
                                            ? ' · ${listing.reviewCount} review${listing.reviewCount == 1 ? '' : 's'}'
                                            : ' · No reviews yet',
                                        style: const TextStyle(
                                          color: Color(0xFF61564D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'HankenGrotesk',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 20),

                          HostSection(
                            hostName: listing.hostName,
                            hostProfilePhotoUrl: listing.hostProfilePhotoUrl,
                            hostSinceLabel: listing.hostSinceLabel,
                            onMessageTap: _openingChat
                                ? null
                                : () => _openChat(listing),
                            isChatLoading: _openingChat,
                            onHostTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HostProfilePage(
                                  hostName: listing.hostName,
                                  hostProfilePhotoUrl: listing.hostProfilePhotoUrl,
                                  hostSinceLabel: listing.hostSinceLabel,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 20),

                          if (listing.description.isNotEmpty) ...[
                            // Optional description title
                            if (listing.descriptionTitle.isNotEmpty) ...[
                              Text(
                                listing.descriptionTitle,
                                style: const TextStyle(
                                  color: Color(0xFF2A1B12),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CormorantGaramond',
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Description body
                            Text(
                              listing.description,
                              maxLines: _descriptionExpanded ? null : 3,
                              overflow: _descriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2A1B12),
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: 'HenkenGrotesk',
                              ),
                            ),

                            // "Read more >" / "See less"
                            GestureDetector(
                              onTap: () => setState(
                                () => _descriptionExpanded = !_descriptionExpanded,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _descriptionExpanded ? 'See less' : 'Read more >',
                                      style: const TextStyle(
                                        color: Color(0xFF2A1B12),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'HenkenGrotesk',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: _descriptionExpanded ? 60 : 80,
                                      height: 2,
                                      color: const Color(0xFF006972),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (listing.amenities.isNotEmpty) ...[
                            AmenitiesSection(
                              amenities: listing.amenities,
                              onShowAllTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AmenitiesPage(
                                    listingTitle: listing.title,
                                    amenities: listing.amenities,
                                    footerPhotoUrl: listing.photoUrls.isNotEmpty
                                        ? listing.photoUrls.first
                                        : null,
                                    footerBlurb: listing.description,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 24),

                          // ── Check-in & Check-out schedule ──
                          const Text(
                            'Check-in & Check-out',
                            style: TextStyle(
                              color: Color(0xFF2A1B12),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CormorantGaramond',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Check-in window
                          const Text(
                            'CHECK-IN WINDOW',
                            style: TextStyle(
                              color: Color(0xFF006972),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _scheduleTimeCard(
                                  label: 'From',
                                  time: listing.checkInTimeFrom,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _scheduleTimeCard(
                                  label: 'To',
                                  time: listing.checkInTimeTo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Check-out window
                          const Text(
                            'CHECK-OUT WINDOW',
                            style: TextStyle(
                              color: Color(0xFF006972),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _scheduleTimeCard(
                                  label: 'From',
                                  time: listing.checkOutTimeFrom,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _scheduleTimeCard(
                                  label: 'To',
                                  time: listing.checkOutTimeTo,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 24),

                          LocationMapPreview(
                            locationLabel: locationLabel,
                            latitude: listing.latitude,
                            longitude: listing.longitude,
                            onTap: () {
                              // TODO: push real full-screen map view once implemented
                            },
                          ),
                          const SizedBox(height: 24),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 24),

                          // ── Reviews Section ──────────────────────────────────
                          _buildReviewsSection(listing),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BookingBottomBar(
                  formattedPrice: listing.formattedPrice,
                  onBookNowTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        listingId: listing.id,
                        hostId: listing.hostId,
                        hostName: listing.hostName,
                        title: listing.title,
                        coverPhotoUrl: listing.photoUrls.isNotEmpty ? listing.photoUrls.first : null,
                        locationLabel: listing.neighborhood != null && listing.neighborhood!.isNotEmpty
                            ? '${listing.city}, ${listing.neighborhood}'
                            : listing.city,
                        ratingOverall: listing.ratingOverall,
                        reviewCount: listing.reviewCount,
                        pricePerNight: listing.pricePerNight,
                        currency: listing.currency,
                        serviceFeePercent: listing.serviceFeePercent,
                        touristTaxPercent: listing.touristTaxPercent,
                        maxGuests: listing.guests,
                        hostPhoneCountryCode: listing.hostPhoneCountryCode,
                        hostPhoneNumber: listing.hostPhoneNumber,
                        checkInTimeFrom: listing.checkInTimeFrom,
                        checkInTimeTo: listing.checkInTimeTo,
                        checkOutTimeFrom: listing.checkOutTimeFrom,
                        checkOutTimeTo: listing.checkOutTimeTo,
                        checkOutTime: listing.checkOutTimeFrom,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _scheduleTimeCard({required String label, required String time}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF3E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7DCCB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF61564D),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'HenkenGrotesk',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'HenkenGrotesk',
            ),
          ),
        ],
      ),
    );
  }
}