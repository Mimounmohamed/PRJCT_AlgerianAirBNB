import 'package:flutter/material.dart';

/// Reviews & Ratings page — shown when tapping the rating row on Listing
/// Detail.
///
/// STATIC SKELETON: only [listingTitle], [ratingOverall], and [reviewCount]
/// are real (already available from ListingDetailModel). The rating
/// breakdown (cleanliness, communication, etc.) and the individual written
/// reviews are placeholders — wire them up once a real reviews fetch
/// exists (GET /api/reviews?listingId=...). Note: the breakdown sub-scores
/// actually already exist on the backend Listing.rating object
/// (cleanliness/communication/checkIn/location/value) — that part could be
/// made real quickly without touching the reviews system at all, if wanted.
class ReviewsPage extends StatelessWidget {
  final String listingTitle;
  final double ratingOverall;
  final int reviewCount;

  const ReviewsPage({
    super.key,
    required this.listingTitle,
    required this.ratingOverall,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF3E7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          listingTitle,
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'HenkenGrotesk',
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header: overall rating + review count (REAL DATA) ────────
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 26, color: Color(0xFFB8860B)),
                    const SizedBox(width: 8),
                    Text(
                      ratingOverall.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Color(0xFF2A1B12),
                        fontSize: 32,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                  style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Divider(height: 1, color: Color(0xFFE7DCCB)),
          const SizedBox(height: 24),

          // ── Rating breakdown (PLACEHOLDER) ────────────────────────────
          // TODO: wire to listing.rating.{cleanliness,communication,checkIn,
          // location,value} — this data already exists on the backend
          // Listing document, no reviews system needed for this part.
          const Text(
            'Rating breakdown',
            style: TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 18,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const _PlaceholderBreakdownRow(label: 'Cleanliness'),
          const _PlaceholderBreakdownRow(label: 'Communication'),
          const _PlaceholderBreakdownRow(label: 'Check-in'),
          const _PlaceholderBreakdownRow(label: 'Location'),
          const _PlaceholderBreakdownRow(label: 'Value'),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE7DCCB)),
          const SizedBox(height: 24),

          // ── Individual reviews (PLACEHOLDER) ──────────────────────────
          // TODO: wire to GET /api/reviews?listingId=... once that route
          // is confirmed / built.
          const Text(
            'What guests are saying',
            style: TextStyle(
              color: Color(0xFF2A1B12),
              fontSize: 18,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const _PlaceholderReviewCard(),
          const SizedBox(height: 20),
          const _PlaceholderReviewCard(),
          const SizedBox(height: 20),
          const _PlaceholderReviewCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PlaceholderBreakdownRow extends StatelessWidget {
  final String label;

  const _PlaceholderBreakdownRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE7DCCB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Visibly placeholder-styled review card — grey bars/blocks standing in
/// for a real reviewer avatar, name, date, and comment text.
class _PlaceholderReviewCard extends StatelessWidget {
  const _PlaceholderReviewCard();

  Widget _bar({double width = double.infinity, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7DCCB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFE7DCCB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(width: 100, height: 12),
              const SizedBox(height: 6),
              _bar(width: 70, height: 10),
              const SizedBox(height: 10),
              _bar(height: 10),
              const SizedBox(height: 6),
              _bar(width: 200, height: 10),
            ],
          ),
        ),
      ],
    );
  }
}