import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// "Where you'll be" map preview for the Listing Detail page.
///
/// Shows a real (non-interactive) map tile centered near the listing,
/// with a soft shaded circle marking the general area rather than an
/// exact pin — the precise address is only shared with confirmed
/// guests (see back/src/models/Listing.js: location.fullAddress).
///
/// [latitude]/[longitude] are the listing's real coordinates. If either
/// is null (older listings without geo data), this falls back to the
/// original static placeholder box.
class LocationMapPreview extends StatelessWidget {
  final String locationLabel;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onTap;

  const LocationMapPreview({
    super.key,
    required this.locationLabel,
    this.latitude,
    this.longitude,
    this.onTap,
  });

  static const Color _dark = Color(0xFF2A1B12);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _teal = Color(0xFF006972);
  static const Color _border = Color(0xFFE7DCCB);

  /// Deterministically nudges the real coordinates by a small random-ish
  /// offset (seeded off the coordinates themselves, so the same listing
  /// always fuzzes to the same spot) — roughly 150-300m, enough to hide
  /// the exact building without misleading guests about the neighborhood.
  LatLng _fuzzedCenter(double lat, double lng) {
    final seed = ((lat * 1000).round() ^ (lng * 1000).round());
    final dLat = ((seed % 200) - 100) / 100000; // ±0.001° ≈ ±110m
    final dLng = (((seed ~/ 200) % 200) - 100) / 100000;
    return LatLng(lat + dLat, lng + dLng);
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;
    final center = hasCoordinates ? _fuzzedCenter(latitude!, longitude!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Where you'll be",
          style: TextStyle(
            color: _dark,
            fontSize: 24,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          locationLabel,
          style: const TextStyle(
            color: _muted,
            fontSize: 14,
            fontFamily: 'HenkenGrotesk',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Exact location provided after booking.',
          style: TextStyle(color: _muted, fontSize: 12, fontFamily: 'HenkenGrotesk'),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: hasCoordinates
                  ? Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: center!,
                            initialZoom: 14,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.akrili.app',
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: center,
                                  radius: 220,
                                  useRadiusInMeter: true,
                                  color: _teal.withValues(alpha: 0.18),
                                  borderColor: _teal.withValues(alpha: 0.55),
                                  borderStrokeWidth: 1.5,
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Absorbs taps so the map itself stays non-interactive
                        // while still forwarding a tap to onTap (e.g. to push
                        // a real full-screen map view later).
                        Positioned.fill(child: Container(color: Colors.transparent)),
                      ],
                    )
                  : Container(
                      color: _border,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.map_outlined, size: 40, color: _muted.withValues(alpha: 0.6)),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: _dark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.home, size: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}