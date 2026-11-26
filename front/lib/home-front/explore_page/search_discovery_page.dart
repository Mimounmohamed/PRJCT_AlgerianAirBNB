import 'package:flutter/material.dart';
import '../../data/algeria_location_data.dart';
import '../../models/explore_filters.dart';
import '../../services/listing_service.dart';
import '../../services/recent_searches.dart';
import '../widgets/property_types.dart';
import 'filters_page.dart';

/// Search — Discovery: opens when the guest taps the search bar on
/// Explore. Type a place (wilaya suggestions appear as you type), or pick
/// a recent search, a region, or a stay type. The tune icon opens Filters.
///
/// Returns the new [ExploreFilters] for Explore to load, or null when the
/// guest goes back without choosing.
class SearchDiscoveryPage extends StatefulWidget {
  final ExploreFilters initial;

  const SearchDiscoveryPage({super.key, required this.initial});

  static Future<ExploreFilters?> open(BuildContext context, ExploreFilters initial) {
    return Navigator.of(context).push<ExploreFilters>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => SearchDiscoveryPage(initial: initial),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<SearchDiscoveryPage> createState() => _SearchDiscoveryPageState();
}

class _SearchDiscoveryPageState extends State<SearchDiscoveryPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _chip = Color(0xFFF1E7DA);

  late final TextEditingController _controller;
  late ExploreFilters _filters;
  List<RecentSearch> _recent = [];
  List<String> _wilayas = [];
  Map<String, int> _typeCounts = {};
  final Map<String, int> _regionCounts = {};

  @override
  void initState() {
    super.initState();
    _filters = widget.initial;
    _controller = TextEditingController(text: widget.initial.search ?? '');
    _controller.addListener(() => setState(() {}));

    RecentSearches.load().then((r) {
      if (mounted) setState(() => _recent = r);
    });
    AlgeriaLocationData.load().then((communes) {
      if (mounted) setState(() => _wilayas = AlgeriaLocationData.wilayaNames(communes));
    }).catchError((_) {});
    ListingService.fetchTypeCounts().then((c) {
      if (mounted) setState(() => _typeCounts = c);
    });
    for (final region in kDiscoverRegions) {
      ListingService.countListings(ExploreFilters(wilayas: region.wilayas)).then((n) {
        if (mounted) setState(() => _regionCounts[region.name] = n);
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Listings saved before the commune dataset use "Algiers" for Alger.
  static List<String> _wilayaAliases(String wilaya) => wilaya == 'Alger' ? ['Alger', 'Algiers'] : [wilaya];

  // ── Choosing ────────────────────────────────────────────

  void _finish(ExploreFilters filters) => Navigator.of(context).pop(filters);

  void _searchText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      _finish(_filters.clearPlace());
      return;
    }
    RecentSearches.add(RecentSearch(label: text, kind: 'text'));
    _finish(_filters.withPlace(search: text));
  }

  void _pickPlace(String label, List<String> wilayas) {
    RecentSearches.add(RecentSearch(label: label, kind: 'place', wilayas: wilayas));
    _finish(_filters.withPlace(placeLabel: label, wilayas: wilayas));
  }

  void _pickRecent(RecentSearch r) {
    r.kind == 'place' ? _pickPlace(r.label, r.wilayas) : _searchText(r.label);
  }

  void _pickType(String type) => _finish(_filters.withPropertyTypes({type}));

  Future<void> _openFilters() async {
    final result = await FiltersPage.open(context, _filters);
    if (result != null && mounted) _finish(result);
  }

  Future<void> _clearRecent() async {
    await RecentSearches.clear();
    if (mounted) setState(() => _recent = []);
  }

  // ── Pieces ──────────────────────────────────────────────

  Widget _searchField() {
    final hasText = _controller.text.isNotEmpty;
    final guests = _filters.guests;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 24, color: _teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  autofocus: true,
                  cursorColor: _teal,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _searchText,
                  style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: 'Where to?',
                    hintStyle: TextStyle(color: _muted, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  guests > 0 ? 'Anytime · $guests+ guests' : 'Anytime · Add guests',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (hasText)
            IconButton(
              onPressed: _controller.clear,
              icon: const Icon(Icons.close, size: 18, color: _muted),
              splashRadius: 18,
            ),
          _filterButton(),
        ],
      ),
    );
  }

  Widget _filterButton() {
    final count = _filters.refinementCount;
    return IconButton(
      onPressed: _openFilters,
      splashRadius: 20,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: _teal,
        child: const Icon(Icons.tune, size: 24, color: _dark),
      ),
    );
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: _dark, fontSize: 21, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600)),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _recentSection() {
    if (_recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          'Recent searches',
          trailing: GestureDetector(
            onTap: _clearRecent,
            child: const Text('CLEAR ALL', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent.map((r) {
              return GestureDetector(
                onTap: () => _pickRecent(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 16, color: _muted),
                      const SizedBox(width: 6),
                      Text(r.label, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _regionCard(DiscoverRegion region) {
    final count = _regionCounts[region.name];
    return GestureDetector(
      onTap: () => _pickPlace(region.name, region.wilayas),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: _border),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(region.imageAsset, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: _border)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xB3000000)],
                  stops: [0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(region.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
                  Text(
                    count == null ? region.subtitle : '$count ${count == 1 ? 'stay' : 'stays'}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _propertiesLabel(String type) {
    final n = _typeCounts[type];
    if (n == null) return '';
    if (n == 0) return 'NO STAYS YET';
    return '$n ${n == 1 ? 'PROPERTY' : 'PROPERTIES'}';
  }

  Widget _typeIcon(PropertyType t) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: _teal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
        child: Icon(t.icon, color: _teal, size: 22),
      );

  Widget _typeCard(PropertyType t) {
    return GestureDetector(
      onTap: () => _pickType(t.label),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeIcon(t),
            const SizedBox(height: 18),
            Text(t.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(_propertiesLabel(t.label), style: const TextStyle(color: _muted, fontSize: 10, letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  Widget _typeRow(PropertyType t) {
    return GestureDetector(
      onTap: () => _pickType(t.label),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
        child: Row(
          children: [
            _typeIcon(t),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.label, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(t.blurb, style: const TextStyle(color: _muted, fontSize: 12)),
                ],
              ),
            ),
            Text(_propertiesLabel(t.label), style: const TextStyle(color: _muted, fontSize: 10, letterSpacing: 0.8)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: _muted),
          ],
        ),
      ),
    );
  }

  /// Most-listed types first: the top two as cards, the rest as rows.
  Widget _typesSection() {
    final types = [...kPropertyTypes]..sort((a, b) => (_typeCounts[b.label] ?? 0).compareTo(_typeCounts[a.label] ?? 0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _typeCard(types[0])),
              const SizedBox(width: 12),
              Expanded(child: _typeCard(types[1])),
            ],
          ),
          for (final t in types.skip(2)) _typeRow(t),
        ],
      ),
    );
  }

  Widget _discovery() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _recentSection(),
        _sectionHeader('Discover by region'),
        SizedBox(
          height: 190,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: kDiscoverRegions.map(_regionCard).toList(),
          ),
        ),
        _sectionHeader('Popular stay types'),
        _typesSection(),
      ],
    );
  }

  /// While typing: "Search for …" plus matching regions and wilayas.
  Widget _suggestions() {
    final q = _controller.text.trim().toLowerCase();
    final regions = kDiscoverRegions.where((r) => r.name.toLowerCase().contains(q)).toList();
    final wilayas = _wilayas.where((w) => w.toLowerCase().contains(q)).take(8).toList();

    Widget row(IconData icon, String title, String? subtitle, VoidCallback onTap) => ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _chip, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _dark, size: 20),
          ),
          title: Text(title, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
        );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        row(Icons.search, 'Search for "${_controller.text.trim()}"', 'Titles, cities and wilayas', () => _searchText(_controller.text)),
        for (final r in regions) row(Icons.landscape_outlined, r.name, r.subtitle, () => _pickPlace(r.name, r.wilayas)),
        for (final w in wilayas) row(Icons.location_on_outlined, w, 'Wilaya · Algeria', () => _pickPlace(w, _wilayaAliases(w))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final typing = _controller.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: _teal),
                  ),
                  Expanded(child: _searchField()),
                ],
              ),
            ),
            Expanded(child: typing ? _suggestions() : _discovery()),
          ],
        ),
      ),
    );
  }
}
