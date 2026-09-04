import 'package:flutter/material.dart';
import '../../models/host_listing_summary_model.dart'; // adjust path to match your project structure

/// Single row in the "Your listings" section — thumbnail, title, subtitle,
/// and a status badge (ACTIVE / IN REVIEW / PAUSED / etc).
class HostListingRow extends StatelessWidget {
  final HostListingSummaryModel listing;
  final VoidCallback? onTap;

  const HostListingRow({super.key, required this.listing, this.onTap});

  Color get _statusColor {
    switch (listing.status) {
      case 'active': return const Color(0xFF006972);
      case 'pending_review': return const Color(0xFFB8860B);
      case 'inactive': return const Color(0xFF9A8C7F);
      case 'rejected': return const Color(0xFFB3261E);
      default: return const Color(0xFF8A7B6E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72,
                height: 72,
                child: listing.coverPhotoUrl != null
                    ? Image.network(listing.coverPhotoUrl!, fit: BoxFit.cover)
                    : Container(color: const Color(0xFFE7DCCB)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: const TextStyle(color: Color(0xFF2A1B12), fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          listing.statusLabel,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${listing.propertyType} • ${listing.city}',
                    style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        listing.status == 'active' ? Icons.calendar_today_outlined : Icons.info_outline,
                        size: 13,
                        color: const Color(0xFF8A7B6E),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        listing.statusSubtitle,
                        style: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 13),
                      ),
                    ],
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