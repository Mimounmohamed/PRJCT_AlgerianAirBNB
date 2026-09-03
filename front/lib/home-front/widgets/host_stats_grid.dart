import 'package:flutter/material.dart';

/// 2x2 stats grid on the Host dashboard — Projected Earnings, Active
/// Listings, Overall Rating, Views.
class HostStatsGrid extends StatelessWidget {
  final String formattedEarnings;
  final int activeListings;
  final double avgRating;
  final String formattedViews;

  const HostStatsGrid({
    super.key,
    required this.formattedEarnings,
    required this.activeListings,
    required this.avgRating,
    required this.formattedViews,
  });

  Widget _statBox({required String label, required Widget value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
            ),
            const SizedBox(height: 6),
            value,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(color: Color(0xFF2A1B12), fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'HenkenGrotesk');

    return Column(
      children: [
        Row(
          children: [
            _statBox(
              label: 'Projected Earnings',
              value: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: formattedEarnings.split(' ').sublist(0, formattedEarnings.split(' ').length - 1).join(' '), style: valueStyle),
                    const TextSpan(text: ' DA', style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            _statBox(label: 'Active Listings', value: Text('$activeListings', style: valueStyle)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statBox(
              label: 'Overall Rating',
              value: Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFB8860B)),
                  const SizedBox(width: 4),
                  Text(avgRating.toStringAsFixed(2), style: valueStyle),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _statBox(label: 'Views', value: Text(formattedViews, style: valueStyle)),
          ],
        ),
      ],
    );
  }
}