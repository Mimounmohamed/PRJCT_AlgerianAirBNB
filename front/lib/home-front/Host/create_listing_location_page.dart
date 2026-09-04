import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import '../../../models/listing_draft_model.dart'; // adjust path to match your project structure
import '../../../data/algeria_location_data.dart'; // adjust path to match your project structure
import '../widgets/app_search_sheet_picker.dart'; // adjust path if you placed this elsewhere
import 'create_listing_amenities_page.dart'; // adjust path if you placed this elsewhere

/// Step 3 of the Create Listing wizard — location. Wilaya and Baladiya
/// (commune) are searchable dropdowns sourced from the bundled
/// assets/data/algeria_communes.json dataset (58/69 wilayas, 1,541
/// communes, each with coordinates). The map uses flutter_map with
/// CartoDB Voyager tiles (free, no API key, CDN-backed).
///
/// Two-way sync:
///  - Picking a Wilaya filters the Baladiya list to that wilaya.
///  - Picking a Baladiya sets its Wilaya automatically, and moves the
///    map to that commune's coordinates.
///  - Panning the map reverse-geocodes the new center via Nominatim
///    (free, no key) and tries to match the result against the local
///    commune dataset to update the Wilaya/Baladiya dropdowns.
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

  final MapController _mapController = MapController();
  final MapController _expandedMapController = MapController();

  static const LatLng _defaultCenter = LatLng(36.7538, 3.0588); // Algiers

  late LatLng _center = (widget.draft.lat != null && widget.draft.lng != null)
      ? LatLng(widget.draft.lat!, widget.draft.lng!)
      : _defaultCenter;

  double _zoom = 13;
  bool _isGeocoding = false;
  Timer? _debounce;

  List<AlgeriaCommune> _communes = [];
  bool _isLoadingDataset = true;

  late final TextEditingController _streetController =
      TextEditingController(text: widget.draft.fullAddress);
  String? _lastAutoFilledStreet;

  String? get _selectedWilaya => widget.draft.wilaya;
  String? get _selectedCommune => widget.draft.city;

  @override
  void initState() {
    super.initState();
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    final communes = await AlgeriaLocationData.load();
    if (!mounted) return;
    setState(() {
      _communes = communes;
      _isLoadingDataset = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _streetController.dispose();
    super.dispose();
  }

  void _moveMapTo(LatLng point, {double? zoom}) {
    _zoom = zoom ?? _zoom;
    _mapController.move(point, _zoom);
    setState(() {
      _center = point;
      widget.draft.lat = point.latitude;
      widget.draft.lng = point.longitude;
    });
  }

  Future<void> _pickWilaya() async {
    final options = AlgeriaLocationData.wilayaNames(_communes);
    final result = await AppSearchSheetPicker.show(
      context: context,
      title: 'Select Wilaya',
      options: options,
      selected: _selectedWilaya,
    );
    if (result == null) return;

    setState(() {
      widget.draft.wilaya = result;
      // Changing the wilaya invalidates whatever baladiya was picked
      // under the previous wilaya.
      widget.draft.city = null;
    });
  }

  Future<void> _pickBaladiya() async {
    final options = AlgeriaLocationData.communeNames(_communes, wilayaNameFr: _selectedWilaya);
    final result = await AppSearchSheetPicker.show(
      context: context,
      title: 'Select Baladiya',
      options: options,
      selected: _selectedCommune,
      emptyMessage: _selectedWilaya == null
          ? 'No results found.'
          : 'No results found in $_selectedWilaya.',
    );
    if (result == null) return;

    // Resolve within the currently selected wilaya only — several wilayas
    // can share a commune name (e.g. more than one "Aïn Turck"-style
    // name across the country), so searching the full dataset by name
    // alone can silently return a commune in the wrong wilaya.
    AlgeriaCommune? commune;
    if (_selectedWilaya != null) {
      final scoped = AlgeriaLocationData.communesForWilaya(_communes, _selectedWilaya!);
      commune = AlgeriaLocationData.findByCommuneName(scoped, result);
    }
    // Fallback: no wilaya was picked yet (baladiya picked first) — search
    // globally, which also fills in the wilaya from whichever commune matched.
    commune ??= AlgeriaLocationData.findByCommuneName(_communes, result);

    setState(() {
      widget.draft.city = result;
      if (commune != null) widget.draft.wilaya = commune.wilayaNameFr;
    });
    if (commune != null) {
      _moveMapTo(LatLng(commune.lat, commune.lng), zoom: 13);
    }
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
  /// Result is matched against the local commune dataset (case-insensitive
  /// exact match on commune name) to keep the Wilaya/Baladiya dropdowns in
  /// sync with wherever the pin lands. If no exact match is found, the
  /// dropdowns are left as-is — only the pin/coordinates move.
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&accept-language=fr',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Akrili/1.0 (contact: om_mimoun@esi.dz)'},
      );
      if (response.statusCode != 200) return;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final address = body['address'] as Map<String, dynamic>? ?? {};

      final candidates = [
        address['city'],
        address['town'],
        address['municipality'],
        address['village'],
        address['suburb'],
      ].whereType<String>();

      AlgeriaCommune? match;
      for (final candidate in candidates) {
        match = AlgeriaLocationData.findByCommuneNameLoose(_communes, candidate);
        if (match != null) break;
      }

      // Street — Nominatim's 'road' field, with the house number prefixed
      // when available (e.g. "12 Rue Larbi Ben M'hidi"). Refreshes on
      // every pan UNLESS the host has typed something themselves — that
      // is detected by comparing the field's current text against the
      // last value *we* auto-filled: if they match, nothing was typed by
      // hand, so it's safe to refresh; if they differ, the host edited it
      // and we leave it alone.
      final road = address['road'] as String?;
      final houseNumber = address['house_number'] as String?;
      final streetGuess = road == null
          ? null
          : (houseNumber != null ? '$houseNumber $road' : road);

      if (!mounted) return;
      final currentText = _streetController.text.trim();
      final isUntouchedByHost = currentText.isEmpty || currentText == _lastAutoFilledStreet;
      setState(() {
        if (match != null) {
          widget.draft.city = match.communeNameFr;
          widget.draft.wilaya = match.wilayaNameFr;
        }
        if (streetGuess != null && isUntouchedByHost) {
          _streetController.text = streetGuess;
          widget.draft.fullAddress = streetGuess;
          _lastAutoFilledStreet = streetGuess;
        }
      });
    } catch (_) {
      // Silent fail — host can still pick Wilaya/Baladiya manually.
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  void _zoomBy(double delta) {
    _zoom = (_zoom + delta).clamp(3, 18);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  /// Opens the map larger (not literally full-screen) as a rounded dialog
  /// over a dimmed background. Uses its own MapController so it doesn't
  /// fight the inline preview's controller while both are mounted; on
  /// close, whatever position the dialog ended up at is synced back to
  /// the page's real state (and re-triggers the reverse-geocode).
  Future<void> _openFullMap() async {
    double expandedZoom = _zoom;
    LatLng expandedCenter = _center;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) {
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
                    mapController: _expandedMapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: _zoom,
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
                          expandedCenter = _expandedMapController.camera.center;
                          expandedZoom = _expandedMapController.camera.zoom;
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.akrili.app',
                      ),
                    ],
                  ),
                  const IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 32),
                        child: Icon(Icons.location_pin, color: _teal, size: 48),
                      ),
                    ),
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
                    bottom: 14,
                    child: Column(
                      children: [
                        _mapButton(
                          icon: Icons.add,
                          onTap: () {
                            expandedZoom = (expandedZoom + 1).clamp(3, 18);
                            _expandedMapController.move(_expandedMapController.camera.center, expandedZoom);
                          },
                        ),
                        const SizedBox(height: 8),
                        _mapButton(
                          icon: Icons.remove,
                          onTap: () {
                            expandedZoom = (expandedZoom - 1).clamp(3, 18);
                            _expandedMapController.move(_expandedMapController.camera.center, expandedZoom);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Sync whatever the dialog ended up centered on back into the page.
    _moveMapTo(expandedCenter, zoom: expandedZoom);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _reverseGeocode(expandedCenter));
  }

  Widget _dropdownField({
    required IconData icon,
    required String hint,
    required String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(icon, color: _muted, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value == null ? _muted : _dark,
                  fontSize: 15,
                  fontWeight: value == null ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: _muted, size: 20),
          ],
        ),
      ),
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
                    if (_isLoadingDataset)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(color: _teal)),
                      )
                    else ...[
                      _dropdownField(
                        icon: Icons.location_on_outlined,
                        hint: 'Wilaya',
                        value: _selectedWilaya,
                        onTap: _pickWilaya,
                      ),
                      const SizedBox(height: 12),
                      _dropdownField(
                        icon: Icons.explore_outlined,
                        hint: 'Baladiya',
                        value: _selectedCommune,
                        onTap: _pickBaladiya,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.signpost_outlined, color: _muted, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _streetController,
                                onChanged: (value) => widget.draft.fullAddress = value,
                                style: const TextStyle(color: _dark, fontSize: 15),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  hintText: 'Street',
                                  hintStyle: TextStyle(color: _muted),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Try to auto-fill from the map',
                                icon: _isGeocoding
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: _teal),
                                      )
                                    : const Icon(Icons.refresh, color: _teal, size: 20),
                                onPressed: _isGeocoding ? null : () => _reverseGeocode(_center),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "We'll try to fill this in from the map, but you can always type or edit it yourself — or leave it blank.",
                          style: TextStyle(color: _muted, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
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
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.akrili.app',
                                ),
                              ],
                            ),
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
                            Positioned(
                              left: 10,
                              top: 10,
                              child: _mapButton(icon: Icons.fullscreen, onTap: _openFullMap),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Pan the map, or pick your Wilaya/Baladiya above',
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
                    // Matches property-type/basics pages: exits the whole
                    // wizard back to the Host dashboard (tab shell root).
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Exit flow', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateListingAmenitiesPage(draft: widget.draft),
                        ),
                      );
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