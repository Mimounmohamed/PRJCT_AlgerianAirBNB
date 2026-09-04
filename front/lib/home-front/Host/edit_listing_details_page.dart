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
import '../../services/amenity_catalog_service.dart'; // adjust path — exposes AmenityCatalogService + AmenityCatalogItem
import '../../models/host_listing_detail_model.dart'; // adjust path to match your project structure
import '../../models/amenity_model.dart'; // adjust path — for AmenityModel.iconFor()

class _PropertyTypeOption {
  final String label;
  final IconData icon;
  const _PropertyTypeOption({required this.label, required this.icon});
}

/// "Edit Listing Details" — reached from Manage Listing's Quick Actions.
/// Edits title, description, photos, property type ("stay category" —
/// mirrors the exact enum from create_listing_property_type_page.dart,
/// single-select), amenities (full add/remove/edit — mirrors
/// create_listing_amenities_page.dart's interaction pattern, but
/// operating on an existing listing's amenities instead of a fresh
/// draft), and location (tap the map preview to open a bigger draggable
/// map — pin fixed at center, map pans underneath, same technique as
/// the Create Listing wizard's location step's expanded dialog).
///
/// Saves via PUT /api/listings/:id. Because that route does a shallow
/// merge (see host_service.dart), every save sends COMPLETE `photos`,
/// `amenities`, and `location` objects/arrays, not partial diffs — and
/// only sends keys this screen actually edits (no `categories`, since
/// that's a separate field this screen doesn't touch — omitting it
/// leaves whatever was there untouched on the backend).
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
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _gold = Color(0xFFE8A33D);

  /// Matches the backend's Listing.propertyType enum exactly (see
  /// Listing.js) — same list/icons as create_listing_property_type_page.dart.
  static const List<_PropertyTypeOption> _propertyTypeOptions = [
    _PropertyTypeOption(label: 'Apartment', icon: Icons.apartment),
    _PropertyTypeOption(label: 'Hotel', icon: Icons.hotel),
    _PropertyTypeOption(label: 'Touristic Complex', icon: Icons.holiday_village),
    _PropertyTypeOption(label: 'Beach Cabin', icon: Icons.beach_access),
    _PropertyTypeOption(label: 'House', icon: Icons.house),
    _PropertyTypeOption(label: 'Villa', icon: Icons.villa),
    _PropertyTypeOption(label: 'Duplex', icon: Icons.other_houses),
    _PropertyTypeOption(label: 'Desert Cabin', icon: Icons.terrain),
  ];

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
  String? _selectedPropertyType;

  // Location — carried through untouched unless the host repositions the
  // pin. wilaya/city/neighborhood/fullAddress are preserved as-is so a
  // save never wipes fields this screen doesn't expose UI for.
  double? _lat;
  double? _lng;
  String? _wilaya;
  String? _city;
  String? _neighborhood;
  String? _fullAddress;

  static const LatLng _fallbackCenter = LatLng(36.7538, 3.0588); // Algiers
  double _zoom = 13;

  // ── Amenities state ─────────────────────────────────────
  late List<Map<String, dynamic>> _amenities;
  Map<String, List<AmenityCatalogItem>> _amenityCatalog = {};
  bool _isLoadingCatalog = true;
  String? _catalogError;
  final TextEditingController _amenitySearchController = TextEditingController();
  String _amenityQuery = '';
  final Set<String> _expandedAmenityCategories = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _photos = [];
    _coverPhotoIndex = 0;
    _amenities = [];
    _future = _load();
    _fetchAmenityCatalog();
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
      _selectedPropertyType = listing.propertyType;
      _amenities = listing.amenities.map((a) => Map<String, dynamic>.from(a)).toList();
      _lat = listing.latitude;
      _lng = listing.longitude;
      _wilaya = listing.wilaya;
      _city = listing.city;
      _neighborhood = listing.neighborhood;
      _fullAddress = listing.fullAddress;
      _isLoaded = true;
    }
    return listing;
  }

  Future<void> _fetchAmenityCatalog() async {
    setState(() {
      _isLoadingCatalog = true;
      _catalogError = null;
    });
    try {
      final catalog = await AmenityCatalogService.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _amenityCatalog = catalog;
        _isLoadingCatalog = false;
        if (catalog.isNotEmpty) _expandedAmenityCategories.add(catalog.keys.first);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogError = e.toString();
        _isLoadingCatalog = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amenitySearchController.dispose();
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

  /// Fills whatever cell size the GridView gives it — no fixed
  /// dimensions here on purpose, so this matches the dashed "Add Photo"
  /// tile's size exactly instead of being smaller than it.
  Widget _photoThumbnail(int index) {
    final photo = _photos[index];
    final isCover = _coverPhotoIndex == index;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            photo['url'] as String,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: _border),
          ),
          if (isCover)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: _teal, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          // Star — hollow when this photo isn't the cover, filled gold
          // when it is. Tapping it sets this photo as the cover photo.
          Positioned(
            left: 6,
            top: 6,
            child: GestureDetector(
              onTap: () => setState(() => _coverPhotoIndex = index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCover ? Icons.star : Icons.star_border,
                  size: 14,
                  color: isCover ? _gold : Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: GestureDetector(
              onTap: () => _removePhotoAt(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoTile() {
    final atLimit = _photos.length >= _maxPhotos;
    return GestureDetector(
      onTap: (_isUploadingPhoto || atLimit) ? null : _addPhoto,
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
    );
  }

  // ── Property type (single-select "stay category") ─────

  Widget _propertyTypeCard(_PropertyTypeOption option) {
    final isSelected = _selectedPropertyType == option.label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPropertyType = option.label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? _teal : _border, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(option.icon, size: 26, color: isSelected ? _teal : _dark),
            const SizedBox(height: 10),
            Text(
              option.label,
              style: TextStyle(
                color: isSelected ? _teal : _dark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Amenities ────────────────────────────────────────────

  bool _isCatalogAmenitySelected(String catalogKey) => _amenities.any((a) => a['catalogKey'] == catalogKey);

  void _toggleCatalogAmenity({
    required String catalogKey,
    required String name,
    required String category,
    required String iconName,
  }) {
    setState(() {
      final idx = _amenities.indexWhere((a) => a['catalogKey'] == catalogKey);
      if (idx >= 0) {
        _amenities.removeAt(idx);
      } else {
        _amenities.add({
          'catalogKey': catalogKey,
          'name': name,
          'category': category,
          'iconName': iconName,
          'description': '',
          'isCustom': false,
        });
      }
    });
  }

  void _removeAmenity({String? catalogKey, String? customName}) {
    setState(() {
      _amenities.removeWhere((a) {
        if (catalogKey != null) return a['catalogKey'] == catalogKey;
        return a['isCustom'] == true && a['name'] == customName;
      });
    });
  }

  void _updateAmenityDescription({String? catalogKey, String? customName, required String description}) {
    final idx = _amenities.indexWhere((a) {
      if (catalogKey != null) return a['catalogKey'] == catalogKey;
      return a['isCustom'] == true && a['name'] == customName;
    });
    if (idx >= 0) _amenities[idx]['description'] = description;
  }

  Future<void> _openAddCustomAmenityDialog(String category) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: _cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add a custom amenity', style: TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Category: $category', style: const TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 16),
                _dialogField(controller: nameController, hint: 'Amenity name'),
                const SizedBox(height: 10),
                _dialogField(controller: descController, hint: 'Description (optional)', maxLines: 2),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (added == true && nameController.text.trim().isNotEmpty) {
      setState(() {
        _amenities.add({
          'catalogKey': null,
          'name': nameController.text.trim(),
          'category': category,
          // No icon picker in this dialog (matches the create-listing
          // flow's version) — 'other' is a safe fallback bucket for
          // AmenityModel.iconFor() when there's no catalog icon to copy.
          'iconName': 'other',
          'description': descController.text.trim(),
          'isCustom': true,
        });
      });
    }
  }

  Widget _dialogField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: _dark, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hint,
          hintStyle: const TextStyle(color: _muted),
        ),
      ),
    );
  }

  Widget _amenityChip({
    required String name,
    required String iconName,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _tealTint : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _teal : _border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AmenityModel.iconFor(iconName), size: 16, color: selected ? _teal : _dark),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                color: selected ? _teal : _dark,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addCustomAmenityChip(String category) {
    return GestureDetector(
      onTap: () => _openAddCustomAmenityDialog(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: _teal),
            SizedBox(width: 6),
            Text('Add custom', style: TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _amenityCategorySection(String category, List<AmenityCatalogItem> items) {
    final isExpanded = _expandedAmenityCategories.contains(category);
    final selectedCount = items.where((i) => _isCatalogAmenitySelected(i.key)).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedAmenityCategories.remove(category);
              } else {
                _expandedAmenityCategories.add(category);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(child: Text(category, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700))),
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(12)),
                      child: Text('$selectedCount selected', style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: _muted),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    _amenityChip(
                      name: item.name,
                      iconName: item.iconName,
                      selected: _isCatalogAmenitySelected(item.key),
                      onTap: () => _toggleCatalogAmenity(
                        catalogKey: item.key,
                        name: item.name,
                        category: category,
                        iconName: item.iconName,
                      ),
                    ),
                  _addCustomAmenityChip(category),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _selectedAmenitiesPanel() {
    if (_amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected amenities (${_amenities.length})', style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final amenity in _amenities) _selectedAmenityRow(amenity),
        ],
      ),
    );
  }

  Widget _selectedAmenityRow(Map<String, dynamic> amenity) {
    final String? catalogKey = amenity['catalogKey'] as String?;
    final String name = amenity['name'] as String;
    final bool isCustom = amenity['isCustom'] as bool? ?? false;
    final String iconName = amenity['iconName'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AmenityModel.iconFor(iconName), size: 18, color: _teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextFormField(
                    initialValue: amenity['description'] as String? ?? '',
                    onChanged: (value) => _updateAmenityDescription(
                      catalogKey: catalogKey,
                      customName: isCustom ? name : null,
                      description: value,
                    ),
                    style: const TextStyle(color: _dark, fontSize: 13),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      hintText: 'Optional note for guests',
                      hintStyle: TextStyle(color: _muted, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 18, color: _muted),
            onPressed: () => _removeAmenity(catalogKey: catalogKey, customName: isCustom ? name : null),
          ),
        ],
      ),
    );
  }

  bool get _isSearchingAmenities => _amenityQuery.trim().isNotEmpty;

  List<MapEntry<String, AmenityCatalogItem>> get _amenitySearchResults {
    final normalized = _amenityQuery.trim().toLowerCase();
    final results = <MapEntry<String, AmenityCatalogItem>>[];
    _amenityCatalog.forEach((category, items) {
      for (final item in items) {
        if (item.name.toLowerCase().contains(normalized)) results.add(MapEntry(category, item));
      }
    });
    return results;
  }

  Widget _amenitiesSection() {
    if (_isLoadingCatalog) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: _teal)),
      );
    }
    if (_catalogError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Couldn't load amenities: $_catalogError", style: const TextStyle(color: _muted, fontSize: 12)),
          TextButton(onPressed: _fetchAmenityCatalog, child: const Text('Retry', style: TextStyle(color: _teal))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: _amenitySearchController,
            onChanged: (v) => setState(() => _amenityQuery = v),
            style: const TextStyle(color: _dark, fontSize: 15),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: 'Search amenities...',
              hintStyle: const TextStyle(color: _muted),
              prefixIcon: const Icon(Icons.search, color: _muted, size: 20),
              suffixIcon: _isSearchingAmenities
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18, color: _muted),
                      onPressed: () => setState(() {
                        _amenitySearchController.clear();
                        _amenityQuery = '';
                      }),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _selectedAmenitiesPanel(),
        if (_isSearchingAmenities)
          _amenitySearchResults.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No matching amenities.', style: TextStyle(color: _muted)),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _amenitySearchResults)
                      _amenityChip(
                        name: entry.value.name,
                        iconName: entry.value.iconName,
                        selected: _isCatalogAmenitySelected(entry.value.key),
                        onTap: () => _toggleCatalogAmenity(
                          catalogKey: entry.value.key,
                          name: entry.value.name,
                          category: entry.key,
                          iconName: entry.value.iconName,
                        ),
                      ),
                  ],
                )
        else
          for (final category in _amenityCatalog.keys) _amenityCategorySection(category, _amenityCatalog[category]!),
      ],
    );
  }

  // ── Location ────────────────────────────────────────────

  Future<void> _reverseGeocodeLabel(LatLng point) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&accept-language=fr',
      );
      final response = await http.get(uri, headers: {'User-Agent': 'Akrili/1.0 (contact: om_mimoun@esi.dz)'});
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Icon(icon, size: 18, color: _dark),
      ),
    );
  }

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
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(10)),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please give your place a title.')));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a description.')));
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one photo.')));
      return;
    }
    if (_selectedPropertyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose a stay category.')));
      return;
    }

    final effectiveWilaya = (_wilaya != null && _wilaya!.trim().isNotEmpty) ? _wilaya! : (_city ?? 'Algiers');
    final effectiveCity = (_city != null && _city!.trim().isNotEmpty) ? _city! : effectiveWilaya;

    setState(() => _isSaving = true);
    try {
      final normalizedPhotos = [
        for (int i = 0; i < _photos.length; i++)
          {'url': _photos[i]['url'], 'caption': _photos[i]['caption'] ?? '', 'order': i},
      ];
      final normalizedAmenities = [
        for (final a in _amenities)
          {
            'catalogKey': a['catalogKey'],
            'name': a['name'],
            'category': a['category'],
            'iconName': a['iconName'],
            'description': a['description'] ?? '',
            'isCustom': a['isCustom'] ?? false,
          },
      ];

      final safeCoverIndex = _coverPhotoIndex.clamp(0, normalizedPhotos.length - 1);

      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'propertyType': _selectedPropertyType,
          'photos': normalizedPhotos,
          'coverPhotoIndex': safeCoverIndex,
          'amenities': normalizedAmenities,
          'location': {
            'wilaya': effectiveWilaya,
            'city': effectiveCity,
            if (_neighborhood != null && _neighborhood!.isNotEmpty) 'neighborhood': _neighborhood,
            if (_fullAddress != null && _fullAddress!.isNotEmpty) 'fullAddress': _fullAddress,
            'coordinates': {
              'type': 'Point',
              'coordinates': [_lng ?? _fallbackCenter.longitude, _lat ?? _fallbackCenter.latitude],
            },
          },
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved.')));
      Navigator.of(context).pop(true); // true = caller should refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
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
                    TextButton(onPressed: () => setState(() => _future = _load()), child: const Text('Retry', style: TextStyle(color: _teal))),
                  ],
                ),
              ),
            );
          }

          return Column(
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
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
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

                      _sectionLabel('Description'),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          minLines: 3,
                          style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),

                      _sectionLabel('Stay category'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _propertyTypeOptions.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.7,
                        ),
                        itemBuilder: (context, index) => _propertyTypeCard(_propertyTypeOptions[index]),
                      ),

                      _sectionLabel('Amenities'),
                      _amenitiesSection(),

                      _sectionLabel('Location'),
                      _locationPreview(),
                      const Padding(
                        padding: EdgeInsets.only(top: 6, left: 2),
                        child: Text('Tap the map to reposition the pin.', style: TextStyle(color: _muted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(color: _cream, border: Border(top: BorderSide(color: _border))),
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
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                      label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Draws a dashed rounded-rect border — used for the "Add photo" tile.
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
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) => false;
}