import 'package:flutter/material.dart';

/// Sticky bottom bar on the Listing Detail page — price, a short
/// availability hint, and a "Book now" button.
///
/// The booking flow behind [onBookNowTap] doesn't exist yet — this only
/// renders the bar and exposes the tap callback.
class BookingBottomBar extends StatelessWidget {
  final String formattedPrice;
  final String? dateRangeLabel;
  final VoidCallback? onBookNowTap;

  static const Color _teal = Color(0xFF006972);

  const BookingBottomBar({
    super.key,
    required this.formattedPrice,
    this.dateRangeLabel,
    this.onBookNowTap,
  });

  @override
  Widget build(BuildContext context) {
    // Falls back to "Flexible dates" — same wording used on the listing
    // cards — when this specific listing has no fixed availability window.
    final hasDates = dateRangeLabel != null && dateRangeLabel!.trim().isNotEmpty;
    final displayLabel = hasDates ? dateRangeLabel! : 'Flexible dates';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: formattedPrice,
                          style: const TextStyle(
                            color: Color(0xFF2A1B12),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'HenkenGrotesk',
                          ),
                        ),
                        const TextSpan(
                          text: ' night',
                          style: TextStyle(
                            color: Color(0xFF8A7B6E),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'HenkenGrotesk',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // IntrinsicWidth so the underline below matches the text's
                  // own width, same treatment as the "Read more" underline
                  // in the description section — not a fixed guessed size,
                  // since "Oct 12 – 17" and "Flexible dates" differ in length.
                  IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayLabel,
                          style: const TextStyle(
                            color: Color(0xFF2A1B12),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'HenkenGrotesk',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: double.infinity,
                          height: 2,
                          color: _teal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onBookNowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text(
                'Book now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HenkenGrotesk',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}