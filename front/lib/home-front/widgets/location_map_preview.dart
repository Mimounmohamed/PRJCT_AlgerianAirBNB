import 'package:flutter/material.dart';

/// Static "Where you'll be" map placeholder for the Listing Detail page.
///
/// This is a visual placeholder only — no real map SDK wired up yet
/// (matches the earlier decision to defer real map integration).
/// [onTap] is exposed for when a real map screen exists to push to.
class LocationMapPreview extends StatelessWidget {
  final String locationLabel;
  final VoidCallback? onTap;

  const LocationMapPreview({
    super.key,
    required this.locationLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Where you'll be",
          style: TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 24,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          locationLabel,
          style: const TextStyle(
            color: Color(0xFF8A7B6E),
            fontSize: 14,
            fontFamily: 'HenkenGrotesk',
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFE7DCCB),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 40, color: const Color(0xFF9A8C7F).withOpacity(0.6)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A1B12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}