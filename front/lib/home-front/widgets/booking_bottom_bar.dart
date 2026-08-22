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

  const BookingBottomBar({
    super.key,
    required this.formattedPrice,
    this.dateRangeLabel,
    this.onBookNowTap,
  });

  @override
  Widget build(BuildContext context) {
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
                            fontSize: 16,
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
                  if (dateRangeLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateRangeLabel!,
                      style: const TextStyle(
                        color: Color(0xFF8A7B6E),
                        fontSize: 12,
                        fontFamily: 'HenkenGrotesk',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onBookNowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006972),
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