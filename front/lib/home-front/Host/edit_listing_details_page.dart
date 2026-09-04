import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure
import '../../services/auth_service.dart'; // adjust path — exposes AuthService.uploadToCloudinary()
import '../../models/host_listing_detail_model.dart'; // adjust path to match your project structure

/// "Edit Listing Details" — reached from Manage Listing's Quick Actions.
/// Edits title, description, photos, "stay category" chips (maps to the
/// backend's `categories[]` — see note on _categoryOptions below), and
/// location (tap the map preview to open a bigger draggable map; the pin
/// stays fixed at the center and the map pans underneath it, same
/// technique as the Create Listing wizard's location step's expanded
/// dialog — closing the dialog commits whatever the pin landed on).
///
/// Saves via PUT /api/listings/:id. Because that route does a shallow
/// merge (see host_service.dart), every save sends COMPLETE `photos` and
/// `location` objects, not partial diffs, so nothing the host didn't
/// touch gets silently dropped.
class EditListingDetailsPage extends StatefulWidget {
  final String authToken;
  final String listingId;

  const EditListingDetailsPage({
    super.key,
    required this.authToken,
    required this.listingId,
  });

  @override
  State<EditListingDetailsPage> createState() => _EditListingDetailsPageState();
}

class _EditListingDetailsPageState extends State<EditListingDetailsPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  /// Fixed chip set for the "Stay category" picker — the backend's
  /// `categories[]` has NO enum constraint (see Listing.js), so this is
  /// purely a frontend convention. It mirrors the example list already
  /// in the schema's own comment (['Riads', 'Casbah', 'Sea view',
  /// 'Desert']), trimmed to match the Figma reference. Nothing
  /// server-side depends on this exact wording — change freely.
  static const List<String> _categoryOptions = ['Riad', 'Heritage', 'Desert', 'Modern'];

  static const int _maxPhotos = 10;

  final MapController _mapController = MapController();
  final MapController _expandedMapController = MapController();

  Future<HostListingDetailModel>? _future;
  bool _isLoaded = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  final ImagePicker _picker = ImagePicker();

  late List<Map<String, dynamic>> _photos;
  late int _coverPhotoIndex;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Set<String> _selectedCategories;

  // Location — carried through untouched unless the host repositions the
  // pin. wilaya/city/neighborhood/fullAddress are preserved as-is so a
  // save never wipes fields this screen doesn't expose UI for.
  double? _lat;
  double? _lng;
  String? _wilaya;
  String? _city;
  String? _neighborhood;
  String? _fullAddress;
  String? _styleType; // preserved untouched, not editable here

  static const LatLng _fallbackCenter = LatLng(36.7538, 3.0588); // Algiers
  double _zoom = 13;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _photos = [];
    _coverPhotoIndex = 0;
    _selectedCategories = {};
    _future = _load();
  }

  Future<HostListingDetailModel> _load() async {
    final listing = await HostService.fetchListingDetail(
      authToken: widget.authToken,
      listingId: widget.listingId,
    );
    if (!_isLoaded) {
      _titleController.text = listing.title;
      _descriptionController.text = listing.description;
      _photos = listing.photos.map((p) => Map<String, dynamic>.from(p)).toList();
      _coverPhotoIndex = listing.coverPhotoIndex;
      _selectedCategories = listing.categories.toSet();
      _lat = listing.latitude;
      _lng = listing.longitude;
      _wilaya = listing.wilaya;
      _city = listing.city;
      _neighborhood = listing.neighborhood;
      _fullAddress = listing.fullAddress;
      _styleType = listing.styleType;
      _isLoaded = true;
    }
    return listing;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  LatLng get _center => LatLng(_lat ?? _fallbackCenter.latitude, _lng ?? _fallbackCenter.longitude);

  String get _locationLabel {
    final parts = [_city, _wilaya].where((p) => p != null && p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Tap to set location';
    return '${parts.join(', ')}, Algeria';
  }

  // ── Photos ──────────────────────────────────────────────

  Future<void> _addPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      setState(() => _isUploadingPhoto = true);
      final url = await AuthService.uploadToCloudinary(File(picked.path));
      if (!mounted) return;
      setState(() {
        _photos.add({'url': url, 'caption': '', 'order': _photos.length});
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _removePhotoAt(int index) {
    setState(() {
      _photos.removeAt(index);
      if (_photos.isEmpty) {
        _coverPhotoIndex = 0;
      } else if (_coverPhotoIndex >= _photos.length) {
        _coverPhotoIndex = _photos.length - 1;
      } else if (_coverPhotoIndex > index) {
        _coverPhotoIndex--;
      }
    });
  }

  static const double _photoTileSize = 100;

  Widget _photoThumbnail(int index) {
    final photo = _photos[index];
    final isCover = _coverPhotoIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _coverPhotoIndex = index),
      child: SizedBox(
        width: _photoTileSize,
        height: _photoTileSize,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: _photoTileSize,
                height: _photoTileSize,
                decoration: BoxDecoration(
                  border: Border.all(color: isCover ? _teal : Colors.transparent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.network(
                  photo['url'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: _border),
                ),
              ),
            ),
            if (isCover)
              Positioned(
                left: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                ),
              ),
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _removePhotoAt(index),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addPhotoTile() {
    final atLimit = _photos.length >= _maxPhotos;
    return GestureDetector(
      onTap: (_isUploadingPhoto || atLimit) ? null : _addPhoto,
      child: SizedBox(
        width: _photoTileSize,
        height: _photoTileSize,
        child: CustomPaint(
          foregroundPainter: _DashedRectPainter(color: atLimit ? _muted : _teal, radius: 16),
          child: Container(
            alignment: Alignment.center,
            child: _isUploadingPhoto
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _teal),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: atLimit ? _muted : _teal, size: 22),
                      const SizedBox(height: 6),
                      Text(
                        'ADD PHOTO',
                        style: TextStyle(
                          color: atLimit ? _muted : _teal,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────

  Widget _categoryChip(String label) {
    final selected = _selectedCategories.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedCategories.remove(label);
        } else {
          _selectedCategories.add(label);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _teal : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _dark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Location ────────────────────────────────────────────

  /// Best-effort reverse geocode via Nominatim (free, no key) — updates
  /// only the display label (_city/_wilaya), not fullAddress/neighborhood,
  /// so it never overwrites host-entered address detail with a guess.
  /// Silent on failure — the pin/coordinates already moved regardless.
  Future<void> _reverseGeocodeLabel(LatLng point) async {
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
      final cityGuess = (address['city'] ??
          address['town'] ??
          address['municipality'] ??
          address['village'] ??
          address['suburb'] ??
          address['county']) as String?;
      final wilayaGuess = (address['state'] ?? address['province'] ?? address['region']) as String?;
      if (!mounted) return;
      setState(() {
        if (cityGuess != null && cityGuess.isNotEmpty) _city = cityGuess;
        if (wilayaGuess != null && wilayaGuess.isNotEmpty) _wilaya = wilayaGuess;
      });
    } catch (_) {
      // Keep the moved pin even if the label lookup fails.
    }
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

  /// Opens the map larger over a dimmed background — pin fixed at
  /// center, map pans underneath. On close, whatever the dialog ended up
  /// centered on is committed as the new location + a label refresh is
  /// attempted. Same technique as the Create Listing wizard's expanded
  /// map dialog, minus the wilaya/baladiya dropdown sync.
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
                            try {
                              expandedZoom = (expandedZoom + 1).clamp(3.0, 18.0);
                              _expandedMapController.move(_expandedMapController.camera.center, expandedZoom);
                            } catch (_) {}
                          },
                        ),
                        const SizedBox(height: 8),
                        _mapButton(
                          icon: Icons.remove,
                          onTap: () {
                            try {
                              expandedZoom = (expandedZoom - 1).clamp(3.0, 18.0);
                              _expandedMapController.move(_expandedMapController.camera.center, expandedZoom);
                            } catch (_) {}
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

    _zoom = expandedZoom;
    setState(() {
      _lat = expandedCenter.latitude;
      _lng = expandedCenter.longitude;
    });
    try {
      _mapController.move(expandedCenter, expandedZoom);
    } catch (_) {}
    unawaited(_reverseGeocodeLabel(expandedCenter));
  }

  Widget _locationPreview() {
    return GestureDetector(
      onTap: _openFullMap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: _zoom,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
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
                    padding: EdgeInsets.only(bottom: 20),
                    child: Icon(Icons.location_pin, color: _teal, size: 32),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, size: 13, color: Colors.white),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _locationLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save ─────────────────────────────────────────────────

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your place a title.')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description.')),
      );
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo.')),
      );
      return;
    }

    final effectiveWilaya = (_wilaya != null && _wilaya!.trim().isNotEmpty) ? _wilaya! : (_city ?? 'Algiers');
    final effectiveCity = (_city != null && _city!.trim().isNotEmpty) ? _city! : effectiveWilaya;

    setState(() => _isSaving = true);
    try {
      final normalizedPhotos = [
        for (int i = 0; i < _photos.length; i++)
          {
            'url': _photos[i]['url'],
            'caption': _photos[i]['caption'] ?? '',
            'order': i,
          },
      ];

      final safeCoverIndex = _coverPhotoIndex.clamp(0, normalizedPhotos.length - 1);

      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categories': _selectedCategories.toList(),
          if (_styleType != null) 'styleType': _styleType,
          'photos': normalizedPhotos,
          'coverPhotoIndex': safeCoverIndex,
          'location': {
            'wilaya': effectiveWilaya,
            'city': effectiveCity,
            if (_neighborhood != null && _neighborhood!.isNotEmpty) 'neighborhood': _neighborhood,
            if (_fullAddress != null && _fullAddress!.isNotEmpty) 'fullAddress': _fullAddress,
            'coordinates': {
              'type': 'Point',
              'coordinates': [
                _lng ?? _fallbackCenter.longitude,
                _lat ?? _fallbackCenter.latitude,
              ],
            },
          },
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved.')),
      );
      Navigator.of(context).pop(true); // true = caller should refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _discard() => Navigator.of(context).maybePop();

  // ── Build ────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 20),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: AkriliAppBar(title: 'Edit Details', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: FutureBuilder<HostListingDetailModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Couldn't load this listing.", style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _future = _load()),
                      child: const Text('Retry', style: TextStyle(color: _teal)),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Photos', style: TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
                              Text('${_photos.length} / $_maxPhotos photos', style: const TextStyle(color: _muted, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _photos.length + 1,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              if (index == _photos.length) return _addPhotoTile();
                              return _photoThumbnail(index);
                            },
                          ),

                          _sectionLabel('Listing title'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: _titleController,
                              maxLength: 50,
                              style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                                counterStyle: TextStyle(color: _muted, fontSize: 11),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 2),
                            child: Text(
                              'Titles should be descriptive but concise.',
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                          ),

                          _sectionLabel('Description'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _border),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              minLines: 3,
                              style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),

                          _sectionLabel('Stay category'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [for (final option in _categoryOptions) _categoryChip(option)],
                          ),

                          _sectionLabel('Location'),
                          _locationPreview(),
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 2),
                            child: Text(
                              'Tap the map to reposition the pin.',
                              style: TextStyle(color: _muted, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: const BoxDecoration(
                      color: _cream,
                      border: Border(top: BorderSide(color: _border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _isSaving ? null : _discard,
                          child: const Text('Discard', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                          label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Draws a dashed rounded-rect border — used for the "Add photo" tile.
/// Same technique as create_listing_review_page.dart / manage_listing_page.dart.
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  static const double dashWidth = 5;
  static const double dashSpace = 4;
  static const double strokeWidth = 1.6;

  const _DashedRectPainter({required this.color, this.radius = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => false;
}