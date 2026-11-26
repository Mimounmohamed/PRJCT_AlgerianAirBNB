import 'package:flutter/material.dart';
import '../../models/listing_model.dart';
import '../../services/saved_service.dart';
import '../../services/user_session.dart';
import '../../widgets/app_toast.dart';
import '../explore_page/listing_detail_page.dart';
import '../widgets/property_types.dart';

enum _SavedSort { recent, priceLow, priceHigh, rating }

extension on _SavedSort {
  String get label => switch (this) {
        _SavedSort.recent => 'Recently saved',
        _SavedSort.priceLow => 'Price: low to high',
        _SavedSort.priceHigh => 'Price: high to low',
        _SavedSort.rating => 'Top rated',
      };
}

/// Saved tab: the stays the guest ❤️'d, as a 2-column grid. Search by
/// name or place, filter by the same stay groups as Explore (Apartments,
/// Houses, Hotels, Cabins), sort, and tap the heart to remove one.
///
/// Follows SavedService.ids, so saving or unsaving anywhere else in the
/// app updates this list.
class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _chip = Color(0xFFF1E7DA);
  static const Color _heart = Color(0xFFC0583E);
  static const Color _star = Color(0xFFE5A93C);

  final TextEditingController _search = TextEditingController();
  List<SavedListing> _saved = [];
  bool _loading = true;
  String? _error;
  StayGroup? _group;
  _SavedSort _sort = _SavedSort.recent;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    SavedService.instance.ids.addListener(_onIdsChanged);
    _load();
  }

  @override
  void dispose() {
    SavedService.instance.ids.removeListener(_onIdsChanged);
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _saved.isEmpty;
      _error = null;
    });
    try {
      final saved = await SavedService.instance.fetchSaved();
      if (!mounted) return;
      setState(() {
        _saved = saved;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  /// Unsaved elsewhere → drop it here. Saved elsewhere → reload to get it.
  void _onIdsChanged() {
    if (!mounted) return;
    final ids = SavedService.instance.ids.value;
    final shown = _saved.map((s) => s.listing.id).toSet();
    if (ids.difference(shown).isNotEmpty) {
      _load();
    } else if (shown.difference(ids).isNotEmpty) {
      setState(() => _saved = _saved.where((s) => ids.contains(s.listing.id)).toList());
    }
  }

  Future<void> _unsave(ListingModel listing) async {
    try {
      await SavedService.instance.setSaved(listing.id, false);
      if (mounted) AppToast.show(context, 'Removed from Saved.', type: AppToastType.success);
    } catch (e) {
      if (mounted) AppToast.show(context, e.toString(), type: AppToastType.error);
    }
  }

  List<SavedListing> get _visible {
    final q = _search.text.trim().toLowerCase();
    final list = _saved.where((s) {
      final l = s.listing;
      final matchesGroup = _group == null || _group!.types.contains(l.propertyType);
      final matchesQuery = q.isEmpty ||
          l.title.toLowerCase().contains(q) ||
          l.city.toLowerCase().contains(q) ||
          l.wilaya.toLowerCase().contains(q);
      return matchesGroup && matchesQuery;
    }).toList();
    switch (_sort) {
      case _SavedSort.recent:
        list.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      case _SavedSort.priceLow:
        list.sort((a, b) => a.listing.pricePerNight.compareTo(b.listing.pricePerNight));
      case _SavedSort.priceHigh:
        list.sort((a, b) => b.listing.pricePerNight.compareTo(a.listing.pricePerNight));
      case _SavedSort.rating:
        list.sort((a, b) => b.listing.ratingOverall.compareTo(a.listing.ratingOverall));
    }
    return list;
  }

  Future<void> _pickSort() async {
    final picked = await showModalBottomSheet<_SavedSort>(
      context: context,
      backgroundColor: const Color(0xFFFBF3E7),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Sort by', style: TextStyle(color: _dark, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
              ),
              for (final s in _SavedSort.values)
                ListTile(
                  onTap: () => Navigator.of(context).pop(s),
                  title: Text(s.label, style: TextStyle(color: _dark, fontWeight: s == _sort ? FontWeight.w700 : FontWeight.w500)),
                  trailing: s == _sort ? const Icon(Icons.check, color: _teal) : null,
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  // ── Pieces ──────────────────────────────────────────────

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved', style: TextStyle(color: _dark, fontSize: 40, height: 1.1, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        const Text(
          'Your handpicked collection of stays across Algeria.',
          style: TextStyle(color: _dark, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: _teal, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _search,
                  cursorColor: _teal,
                  style: const TextStyle(color: _dark, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    hintText: 'Search your saved stays',
                    hintStyle: TextStyle(color: _muted, fontSize: 14),
                  ),
                ),
              ),
              if (_search.text.isNotEmpty)
                GestureDetector(onTap: _search.clear, child: const Icon(Icons.close, size: 18, color: _muted)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _groupChip('All stays', null),
              for (final g in kStayGroups) _groupChip(g.label, g),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickSort,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sort: ${_sort.label}', style: const TextStyle(color: _dark, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: _dark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _groupChip(String label, StayGroup? group) {
    final on = _group == group;
    return GestureDetector(
      onTap: () => setState(() => _group = group),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(color: on ? _dark : _chip, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: on ? Colors.white : _dark, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
        color: const Color(0xFFE3EEEF),
        child: const Center(child: Icon(Icons.grid_view_outlined, size: 44, color: Color(0xFF9FC3C7))),
      );

  Widget _card(ListingModel l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingDetailPage(listingId: l.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.82,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  l.coverPhotoUrl != null
                      ? Image.network(
                          l.coverPhotoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: _border),
                          errorBuilder: (_, _, _) => _photoPlaceholder(),
                        )
                      : _photoPlaceholder(),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _unsave(l),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, size: 18, color: _heart),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _dark, fontSize: 17, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: _muted),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  (l.city.isNotEmpty ? l.city : l.wilaya).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 15, color: _star),
              const SizedBox(width: 3),
              Text(
                l.reviewCount > 0 ? '${l.ratingOverall.toStringAsFixed(2)} (${l.reviewCount})' : 'New',
                style: const TextStyle(color: _dark, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l.formattedPrice, style: const TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
                const TextSpan(text: ' / night', style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _message({required IconData icon, required String title, required String body, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: _chip, shape: BoxShape.circle),
            child: Icon(icon, color: _heart, size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _dark, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 14, height: 1.4)),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(color: _teal)),
      );
    }
    if (_error != null) {
      return _message(
        icon: Icons.cloud_off_outlined,
        title: "Couldn't load your saved stays",
        body: _error!,
        action: TextButton(onPressed: _load, child: const Text('Retry', style: TextStyle(color: _teal, fontWeight: FontWeight.w700))),
      );
    }
    if (_saved.isEmpty) {
      return _message(
        icon: Icons.favorite_border,
        title: 'Nothing saved yet',
        body: 'Tap the heart on any stay in Explore\nto keep it here for later.',
      );
    }
    final visible = _visible;
    if (visible.isEmpty) {
      return _message(icon: Icons.search_off, title: 'No matches', body: 'No saved stay matches this search or filter.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visible.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 20,
        mainAxisExtent: 290,
      ),
      itemBuilder: (context, i) => _card(visible[i].listing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = UserSession.instance.token;
    if (token == null || token.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _message(icon: Icons.favorite_border, title: 'Log in to see your saved stays', body: 'Your saved stays follow your account.'),
      );
    }
    return RefreshIndicator(
      color: _teal,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _header(),
          _content(),
        ],
      ),
    );
  }
}
