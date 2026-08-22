import 'package:flutter/material.dart';
import '../../models/listing_model.dart'; // adjust path to match your project structure

/// A single listing card for the Explore feed — hero photo with a favorite
/// heart overlay, title, location, and rating/price row below.
///
/// Favoriting is local UI state only for now (no backend call yet) —
/// [onFavoriteToggle] fires so that logic can be wired in later.
class ListingCard extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.listing.isGuestFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image with favorite overlay ──────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    listing.coverPhotoUrl != null
                        ? Image.network(
                            listing.coverPhotoUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(color: const Color(0xFFE7DCCB));
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: const Color(0xFFE7DCCB)),
                          )
                        : Container(color: const Color(0xFFE7DCCB)),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isFavorite = !_isFavorite);
                          widget.onFavoriteToggle?.call(_isFavorite);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: _isFavorite ? const Color(0xFFE8543E) : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Title + rating row ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 28,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (listing.ratingOverall > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 18, color: Color(0xFFB8860B)),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: listing.ratingOverall.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Color(0xFF2A1B12),
                                  fontSize: 16,
                                  fontFamily: 'HenkenGrotesk',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: ' (${listing.reviewCount})',
                                style: const TextStyle(
                                  color: Color(0xFF9A8C7F),
                                  fontSize: 16,
                                  fontFamily: 'HenkenGrotesk',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Location ────────────────────────────────────────────────
            Text(
              '${listing.city}, Algeria',
              style: const TextStyle(
                color: Color.fromARGB(255, 97, 86, 77),
                fontSize: 18,
                fontFamily: 'HenkenGrotesk',
              ),
            ),
            const SizedBox(height: 4),

            // ── Date range ──────────────────────────────────────────────
            // TODO: replace with a real "next available" range once the
            // Availability collection is queried for this listing.
            const Text(
              'Flexible dates',
              style: TextStyle(
                color: Color(0xFF8A7B6E),
                fontSize: 18,
                fontFamily: 'HenkenGrotesk',
              ),
            ),
            const SizedBox(height: 6),

            // ── Price ───────────────────────────────────────────────────
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: listing.formattedPrice,
                    style: const TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'HenkenGrotesk',
                    ),
                  ),
                  const TextSpan(
                    text: ' night',
                    style: TextStyle(
                      color: Color(0xFF8A7B6E),
                      fontSize: 15,
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
    );
  }
}