import 'package:flutter/material.dart';
import '../../services/listing_service.dart'; // adjust path to match your project structure
import '../../models/listing_detail_model.dart'; // adjust path to match your project structure
import '../widgets/detail_image_carousel.dart';
import '../widgets/host_section.dart';
import '../widgets/amenities_section.dart';
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
                            Row(
                              children: [
                                const Icon(Icons.star, size: 22, color: Color.fromARGB(255, 29, 28, 21)),
                                const SizedBox(width: 6),
                                Text(
                                  '${listing.ratingOverall.toStringAsFixed(2)} · ${listing.reviewCount} reviews',
                                  style: const TextStyle(
                                    color: Color(0xFF2A1B12),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'HenkenGrotesk',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE7DCCB)),
                            const SizedBox(height: 16),
                          ],

                          HostSection(
                            hostName: listing.hostName,
                            hostProfilePhotoUrl: listing.hostProfilePhotoUrl,
                            hostSinceLabel: listing.hostSinceLabel,
                            onMessageTap: () {
                              // TODO: wire messaging flow
                            },
                          ),
                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFE7DCCB)),
                          const SizedBox(height: 20),

                          if (listing.description.isNotEmpty) ...[
                            Text(
                              listing.description,
                              maxLines: _descriptionExpanded ? null : 3,
                              overflow: _descriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2A1B12),
                                fontSize: 16,
                                height: 1.5,
                                fontFamily: 'HenkenGrotesk',
                              ),
                            ),
                            if (!_descriptionExpanded)
                              GestureDetector(
                                onTap: () => setState(() => _descriptionExpanded = true),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Read more >',
                                    style: TextStyle(
                                      color: Color(0xFF006972),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'HenkenGrotesk',
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],

                          if (listing.amenities.isNotEmpty) ...[
                            AmenitiesSection(
                              amenities: listing.amenities,
                              onShowAllTap: () {
                                // TODO: push full amenities list sheet
                              },
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
                  onBookNowTap: () {
                    // TODO: wire booking flow
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}