import 'package:flutter/material.dart';

/// Host Profile page — shown when tapping the host row on Listing Detail.
///
/// STATIC SKELETON: only the host's name and photo (already available from
/// the listing) are real. Everything else — bio, verified info, rating
/// breakdown, other listings by this host — is a placeholder section to be
/// wired up once a real host-profile endpoint / model exists. Each gap is
/// marked with a "TODO" comment and a visibly placeholder-styled block so
/// it's obvious what still needs real data.
class HostProfilePage extends StatelessWidget {
  final String hostName;
  final String? hostProfilePhotoUrl;
  final String? hostSinceLabel;

  const HostProfilePage({
    super.key,
    required this.hostName,
    required this.hostProfilePhotoUrl,
    required this.hostSinceLabel,
  });

  String get _initials {
    final parts = hostName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }

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
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header: avatar, name, since label (REAL DATA) ────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: const Color(0xFFE7DCCB),
                  backgroundImage:
                      hostProfilePhotoUrl != null ? NetworkImage(hostProfilePhotoUrl!) : null,
                  child: hostProfilePhotoUrl == null
                      ? Text(
                          _initials,
                          style: const TextStyle(
                            color: Color(0xFF2A1B12),
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  hostName,
                  style: const TextStyle(
                    color: Color(0xFF2A1B12),
                    fontSize: 22,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hostSinceLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hostSinceLabel!,
                    style: const TextStyle(
                      color: Color(0xFF8A7B6E),
                      fontSize: 14,
                      fontFamily: 'HenkenGrotesk',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Stats row (PLACEHOLDER — reviews/rating/listings count) ──
          // TODO: wire to real host stats once a host-profile endpoint exists.
          const _PlaceholderStatsRow(),
          const SizedBox(height: 28),
          const Divider(height: 1, color: Color(0xFFE7DCCB)),
          const SizedBox(height: 24),

          // ── About (PLACEHOLDER — host bio) ───────────────────────────
          // TODO: wire to a real host bio field once hosts can write one.
          _PlaceholderSection(
            title: 'About $hostName',
            child: const _PlaceholderBlock(lines: 3),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE7DCCB)),
          const SizedBox(height: 24),

          // ── Verified information (PLACEHOLDER) ───────────────────────
          // TODO: wire to real identityVerification fields from User model.
          _PlaceholderSection(
            title: 'Verified information',
            child: const _PlaceholderBlock(lines: 2),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE7DCCB)),
          const SizedBox(height: 24),

          // ── Other listings by this host (PLACEHOLDER) ────────────────
          // TODO: wire to GET /api/listings?hostId=... once that filter exists.
          _PlaceholderSection(
            title: '$hostName\'s other listings',
            child: const _PlaceholderCardRow(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PlaceholderStatsRow extends StatelessWidget {
  const _PlaceholderStatsRow();

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF2A1B12),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'HenkenGrotesk',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8A7B6E),
                  fontSize: 12,
                  fontFamily: 'HenkenGrotesk',
                ),
              ),
            ],
          ),
        );

    // TODO: replace '—' placeholders with real values (reviews, rating, listings count).
    return Row(
      children: [
        stat('—', 'Reviews'),
        stat('—', 'Rating'),
        stat('—', 'Listings'),
      ],
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _PlaceholderSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 18,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Visibly placeholder-styled block — grey bars standing in for real text,
/// so it's obvious this section still needs real content wired in.
class _PlaceholderBlock extends StatelessWidget {
  final int lines;

  const _PlaceholderBlock({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FractionallySizedBox(
            widthFactor: isLast ? 0.5 : 1.0,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE7DCCB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Placeholder row standing in for a horizontal list of the host's other
/// listings — TODO: replace with real ListingCard-style items once the
/// backend supports filtering listings by hostId.
class _PlaceholderCardRow extends StatelessWidget {
  const _PlaceholderCardRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFE7DCCB),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}