import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Where you'll be" map preview for the Listing Detail page.
///
/// Shows the listing's real, exact coordinates (as set by the host in
/// the Create Listing Location step) — no fuzzing. Includes:
///  - an expand (⛶) button that opens a larger, fully interactive map
///    in a dialog (pan/zoom + explicit zoom buttons), same pattern as
///    the Location wizard step's full-map dialog
///  - a "Take me there" button that opens the location in the device's
///    external maps app (Google Maps / Apple Maps) via url_launcher
///
/// NOTE: launching an external https URL on Android 11+ requires a
/// <queries> block in android/app/src/main/AndroidManifest.xml declaring
/// the https VIEW intent, or the launch fails/throws due to package
/// visibility restrictions — see the app's AndroidManifest.xml.
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

  Future<void> _openExternalMaps(BuildContext context) async {
    if (latitude == null || longitude == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open a maps app on this device.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open a maps app on this device.")),
        );
      }
    }
  }

  Future<void> _openFullMap(BuildContext context) async {
    if (latitude == null || longitude == null) return;
    final center = LatLng(latitude!, longitude!);
    final mapController = MapController();
    double zoom = 15;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            void zoomBy(double delta) {
              zoom = (zoom + delta).clamp(3, 18);
              mapController.move(mapController.camera.center, zoom);
              setDialogState(() {});
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: MediaQuery.of(dialogContext).size.height * 0.7,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: zoom,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.akrili.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: center,
                                width: 44,
                                height: 44,
                                child: const Icon(Icons.location_pin, color: _teal, size: 44),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 20, color: _dark),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 14,
                        bottom: 84,
                        child: Column(
                          children: [
                            _mapButton(icon: Icons.add, onTap: () => zoomBy(1)),
                            const SizedBox(height: 8),
                            _mapButton(icon: Icons.remove, onTap: () => zoomBy(-1)),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 14,
                        bottom: 14,
                        right: 14,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openExternalMaps(dialogContext),
                            icon: const Icon(Icons.directions, size: 18, color: Colors.white),
                            label: const Text('Take me there', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _mapButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Icon(icon, size: 18, color: _dark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = latitude != null && longitude != null;
    final center = hasCoordinates ? LatLng(latitude!, longitude!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
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
                    style: const TextStyle(color: _muted, fontSize: 14, fontFamily: 'HenkenGrotesk'),
                  ),
                ],
              ),
            ),
            if (hasCoordinates)
              IconButton(
                onPressed: () => _openFullMap(context),
                icon: const Icon(Icons.fullscreen, color: _teal),
                tooltip: 'Expand map',
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap ?? (hasCoordinates ? () => _openFullMap(context) : null),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: hasCoordinates
                  ? IgnorePointer(
                      // Preview tile is tap-through — the GestureDetector
                      // above handles opening the full map; this keeps
                      // the small preview from fighting map gestures.
                      child: FlutterMap(
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
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: center,
                                width: 34,
                                height: 34,
                                child: const Icon(Icons.location_pin, color: _teal, size: 34),
                              ),
                            ],
                          ),
                        ],
                      ),
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
        if (hasCoordinates) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openExternalMaps(context),
              icon: const Icon(Icons.directions, size: 18, color: _teal),
              label: const Text('Take me there', style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _teal),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }
}