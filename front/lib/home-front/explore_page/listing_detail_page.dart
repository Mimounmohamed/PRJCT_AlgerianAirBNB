import 'package:flutter/material.dart';
import '../../services/listing_service.dart'; // adjust path to match your project structure
import '../../models/listing_detail_model.dart'; // adjust path to match your project structure
import '../widgets/detail_image_carousel.dart';
import '../widgets/host_section.dart';
import 'host_profile_page.dart'; // adjust path if you placed this elsewhere
import 'booking_page.dart'; // adjust path if you placed this elsewhere
import 'reviews_page.dart'; // adjust path if you placed this elsewhere
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
  late Future<ListingDetailModel> _future;
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _future = ListingService.fetchListingById(widget.listingId);
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
                      onShareTap: () {
                        // TODO: wire share sheet
                      },
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

                          if (listing.ratingOverall > 0) ...[
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReviewsPage(
                                    listingTitle: listing.title,
                                    ratingOverall: listing.ratingOverall,
                                    reviewCount: listing.reviewCount,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 22, color: Color.fromARGB(255, 29, 28, 21)),
                                  const SizedBox(width: 6),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: listing.ratingOverall.toStringAsFixed(2),
                                          style: const TextStyle(
                                            color: Color(0xFF2A1B12),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'HenkenGrotesk',
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' · ${listing.reviewCount} reviews',
                                          style: const TextStyle(
                                            color: Color(0xFF61564D),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'HenkenGrotesk',
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
                          ],

                          HostSection(
                            hostName: listing.hostName,
                            hostProfilePhotoUrl: listing.hostProfilePhotoUrl,
                            hostSinceLabel: listing.hostSinceLabel,
                            onMessageTap: () {
                              // TODO: wire messaging flow
                            },
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

                          LocationMapPreview(
                            locationLabel: locationLabel,
                            onTap: () {
                              // TODO: push real map screen once implemented
                            },
                          ),
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
}