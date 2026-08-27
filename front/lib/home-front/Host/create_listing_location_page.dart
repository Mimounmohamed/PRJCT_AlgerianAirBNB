import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import '../../../models/listing_draft_model.dart'; // adjust path to match your project structure

/// Step 3 of the Create Listing wizard — location. Uses flutter_map with
/// OpenStreetMap tiles (free, no API key) instead of Google Maps. The pin
/// stays fixed at the map's center; panning the map moves the pin. On
/// pan-end we reverse-geocode the center via Nominatim (OSM's free
/// geocoding API — no key, but requires a descriptive User-Agent per
/// their usage policy) to prefill City/Neighborhood, which the host can
/// still edit by hand.
class CreateListingLocationPage extends StatefulWidget {
  final ListingDraft draft;

  const CreateListingLocationPage({super.key, required this.draft});

  @override
  State<CreateListingLocationPage> createState() => _CreateListingLocationPageState();
}

class _CreateListingLocationPageState extends State<CreateListingLocationPage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  late final TextEditingController _cityController =
      TextEditingController(text: widget.draft.city);
  late final TextEditingController _neighborhoodController =
      TextEditingController(text: widget.draft.neighborhood);

  final MapController _mapController = MapController();

  // Default center: Algiers — used until the host pans/has a saved pin.
  static const LatLng _defaultCenter = LatLng(36.7538, 3.0588);

  late LatLng _center = (widget.draft.lat != null && widget.draft.lng != null)
      ? LatLng(widget.draft.lat!, widget.draft.lng!)
      : _defaultCenter;

  double _zoom = 13;
  bool _isGeocoding = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
      final center = _mapController.camera.center;
      setState(() {
        _center = center;
        widget.draft.lat = center.latitude;
        widget.draft.lng = center.longitude;
      });
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () => _reverseGeocode(center));
    }
  }

  /// GET https://nominatim.openstreetmap.org/reverse — free, no API key.
  /// Per Nominatim's usage policy, requests must include a real
  /// identifying User-Agent (replace with your actual app name/contact).
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&accept-language=en',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Akrili/1.0 (contact: om_mimoun@esi.dz)'},
      );
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final address = body['address'] as Map<String, dynamic>? ?? {};

      final city = (address['city'] ?? address['town'] ?? address['municipality'] ?? '') as String;
      final neighborhood = (address['suburb'] ?? address['neighbourhood'] ?? '') as String;
      final wilaya = (address['state'] ?? address['county'] ?? '') as String;

      if (!mounted) return;
      setState(() {
        if (city.isNotEmpty) {
          _cityController.text = city;
          widget.draft.city = city;
        }
        if (neighborhood.isNotEmpty) {
          _neighborhoodController.text = neighborhood;
          widget.draft.neighborhood = neighborhood;
        }
        if (wilaya.isNotEmpty) widget.draft.wilaya = wilaya;
      });
    } catch (_) {
      // Silent fail — host can still type City/Neighborhood manually.
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  void _zoomBy(double delta) {
    _zoom = (_zoom + delta).clamp(3, 18);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  Widget _fieldContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBF3E7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AkriliAppBar(
            title: 'AKRILI',
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: CreateListingPatternBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Where's your place located?",
                      style: TextStyle(
                        color: _dark,
                        fontSize: 26,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your address is only shared with guests after they book.',
                      style: TextStyle(color: _muted, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    _fieldContainer(
                      child: TextField(
                        controller: _cityController,
                        onChanged: (value) => widget.draft.city = value,
                        style: const TextStyle(color: _dark, fontSize: 15),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          hintText: 'City',
                          hintStyle: TextStyle(color: _muted),
                          prefixIcon: Icon(Icons.location_on_outlined, color: _muted, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _fieldContainer(
                      child: TextField(
                        controller: _neighborhoodController,
                        onChanged: (value) => widget.draft.neighborhood = value,
                        style: const TextStyle(color: _dark, fontSize: 15),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          hintText: 'Neighborhood',
                          hintStyle: TextStyle(color: _muted),
                          prefixIcon: Icon(Icons.explore_outlined, color: _muted, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 220,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _center,
                                initialZoom: _zoom,
                                onMapEvent: _onMapEvent,
                              ),
                              children: [
                                TileLayer(
                                  // Free OSM tile server. For production
                                  // scale, consider a paid/self-hosted tile
                                  // provider per OSM's tile usage policy.
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.akrili.app',
                                ),
                              ],
                            ),
                            // Fixed center pin — the map moves under it.
                            const IgnorePointer(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 28),
                                  child: Icon(Icons.location_pin, color: _teal, size: 40),
                                ),
                              ),
                            ),
                            if (_isGeocoding)
                              const Positioned(
                                top: 10,
                                left: 10,
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: _teal),
                                ),
                              ),
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: Column(
                                children: [
                                  _mapButton(icon: Icons.add, onTap: () => _zoomBy(1)),
                                  const SizedBox(height: 8),
                                  _mapButton(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Pan the map to adjust pin location',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF3E7),
                border: Border(top: BorderSide(color: _border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Back', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: push the Photos step, passing widget.draft
                      // forward (city/neighborhood/lat/lng are already
                      // written into it above).
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}