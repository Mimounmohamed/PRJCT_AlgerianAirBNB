import 'package:flutter/material.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import '../../../models/listing_draft_model.dart'; // adjust path to match your project structure
import '../../../models/amenity_model.dart'; // adjust path to match your project structure — for AmenityModel.iconFor()
import '../../../services/amenity_catalog_service.dart'; // adjust path to match your project structure

/// Step 5 of the Create Listing wizard — amenities. With ~90+ catalog
/// items across 11 fixed categories, this uses:
///  - a live search across all items (any category) for fast lookup
///  - collapsible per-category sections with a compact chip grid, for
///    browsing when the host doesn't know exactly what they want
///  - a "Selected amenities" panel where each pick gets an optional
///    free-text description (host can leave it blank)
///  - a "+ Add custom" chip per category for one-off amenities not in
///    the catalog
class CreateListingAmenitiesPage extends StatefulWidget {
  final ListingDraft draft;

  const CreateListingAmenitiesPage({super.key, required this.draft});

  @override
  State<CreateListingAmenitiesPage> createState() => _CreateListingAmenitiesPageState();
}

class _CreateListingAmenitiesPageState extends State<CreateListingAmenitiesPage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  Map<String, List<AmenityCatalogItem>> _catalog = {};
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Which categories are expanded — first one open by default once loaded.
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _fetchCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCatalog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final catalog = await AmenityCatalogService.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _isLoading = false;
        if (catalog.isNotEmpty) _expanded.add(catalog.keys.first);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool get _isSearching => _query.trim().isNotEmpty;

  List<MapEntry<String, AmenityCatalogItem>> get _searchResults {
    final normalized = _query.trim().toLowerCase();
    final results = <MapEntry<String, AmenityCatalogItem>>[];
    _catalog.forEach((category, items) {
      for (final item in items) {
        if (item.name.toLowerCase().contains(normalized)) {
          results.add(MapEntry(category, item));
        }
      }
    });
    return results;
  }

  Future<void> _openAddCustomDialog(String category) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFFFBF3E7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a custom amenity',
                  style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700),
                ),
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
        widget.draft.addCustomAmenity(
          name: nameController.text.trim(),
          category: category,
          description: descController.text.trim(),
        );
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

  Widget _addCustomChip(String category) {
    return GestureDetector(
      onTap: () => _openAddCustomDialog(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border, style: BorderStyle.solid),
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

  Widget _categorySection(String category, List<AmenityCatalogItem> items) {
    final isExpanded = _expanded.contains(category);
    final selectedCount = items.where((i) => widget.draft.isCatalogAmenitySelected(i.key)).length;

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
                _expanded.remove(category);
              } else {
                _expanded.add(category);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(category, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '$selectedCount selected',
                        style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
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
                      selected: widget.draft.isCatalogAmenitySelected(item.key),
                      onTap: () => setState(() {
                        widget.draft.toggleCatalogAmenity(
                          catalogKey: item.key,
                          name: item.name,
                          category: category,
                          iconName: item.iconName,
                        );
                      }),
                    ),
                  _addCustomChip(category),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _selectedAmenitiesPanel() {
    if (widget.draft.amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your selected amenities (${widget.draft.amenities.length})',
            style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            "Add a short note for guests, if you'd like — or leave it blank.",
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final amenity in widget.draft.amenities) _selectedAmenityRow(amenity),
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
                    color: const Color(0xFFFBF3E7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _border),
                  ),
                  child: TextFormField(
                    initialValue: amenity['description'] as String? ?? '',
                    onChanged: (value) => widget.draft.updateAmenityDescription(
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
            onPressed: () => setState(() {
              widget.draft.removeAmenity(catalogKey: catalogKey, customName: isCustom ? name : null);
            }),
          ),
        ],
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
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: CreateListingPatternBackground(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _teal))
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Couldn't load amenities.", style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)),
                                const SizedBox(height: 16),
                                TextButton(onPressed: _fetchCatalog, child: const Text('Retry', style: TextStyle(color: _teal))),
                              ],
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'What does your place have to offer?',
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
                                'Select the amenities available to help guests find exactly what they need.',
                                style: TextStyle(color: _muted, fontSize: 15, height: 1.4),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _border),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) => setState(() => _query = value),
                                  style: const TextStyle(color: _dark, fontSize: 15),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    hintText: 'Search amenities...',
                                    hintStyle: const TextStyle(color: _muted),
                                    prefixIcon: const Icon(Icons.search, color: _muted, size: 20),
                                    suffixIcon: _isSearching
                                        ? IconButton(
                                            icon: const Icon(Icons.close, size: 18, color: _muted),
                                            onPressed: () => setState(() {
                                              _searchController.clear();
                                              _query = '';
                                            }),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _selectedAmenitiesPanel(),
                              if (_isSearching)
                                _searchResults.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24),
                                        child: Center(child: Text('No matching amenities.', style: TextStyle(color: _muted))),
                                      )
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final entry in _searchResults)
                                            _amenityChip(
                                              name: entry.value.name,
                                              iconName: entry.value.iconName,
                                              selected: widget.draft.isCatalogAmenitySelected(entry.value.key),
                                              onTap: () => setState(() {
                                                widget.draft.toggleCatalogAmenity(
                                                  catalogKey: entry.value.key,
                                                  name: entry.value.name,
                                                  category: entry.key,
                                                  iconName: entry.value.iconName,
                                                );
                                              }),
                                            ),
                                        ],
                                      )
                              else
                                for (final category in _catalog.keys) _categorySection(category, _catalog[category]!),
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
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Exit flow', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: push the Review & Submit step, passing
                      // widget.draft forward — amenities are already
                      // written into it above.
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
}