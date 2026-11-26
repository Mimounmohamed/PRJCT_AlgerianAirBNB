import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/explore_filters.dart';
import '../../services/listing_service.dart';
import '../widgets/property_types.dart';

/// "Filters — Refine stays": full screen, opened from the tune icon on
/// the search bar. ✕ closes without changes, CLEAR ALL resets, and the
/// bottom button shows the live number of matching stays and applies.
///
/// Returns the new [ExploreFilters] (place kept as it was), or null when
/// closed with ✕.
class FiltersPage extends StatefulWidget {
  final ExploreFilters initial;

  const FiltersPage({super.key, required this.initial});

  static Future<ExploreFilters?> open(BuildContext context, ExploreFilters initial) {
    return Navigator.of(context).push<ExploreFilters>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => FiltersPage(initial: initial)),
    );
  }

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);

  // Price slider range (DA per night). The top end means "no maximum".
  static const double _priceCap = 50000;
  static const double _priceStep = 500;

  late Set<String> _types;
  late RangeValues _price;
  late int _guests;
  late int _bedrooms;
  late int _bathrooms;
  late Set<String> _amenities;
  late bool _instantBook;

  int? _count;
  bool _counting = false;
  Timer? _countDebounce;
  int _countRequest = 0;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _types = {...f.propertyTypes};
    _price = RangeValues(
      (f.minPrice ?? 0).toDouble().clamp(0, _priceCap),
      (f.maxPrice ?? _priceCap).toDouble().clamp(0, _priceCap),
    );
    _guests = f.guests;
    _bedrooms = f.bedrooms;
    _bathrooms = f.bathrooms;
    _amenities = {...f.amenities};
    _instantBook = f.instantBook;
    _recount();
  }

  @override
  void dispose() {
    _countDebounce?.cancel();
    super.dispose();
  }

  ExploreFilters get _result => widget.initial.withRefinements(ExploreFilters(
        propertyTypes: _types,
        minPrice: _price.start > 0 ? _price.start.round() : null,
        maxPrice: _price.end < _priceCap ? _price.end.round() : null,
        guests: _guests,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        amenities: _amenities,
        instantBook: _instantBook,
      ));

  /// Every change: update, then recount matching stays (debounced).
  void _changed(VoidCallback change) {
    setState(change);
    _countDebounce?.cancel();
    _countDebounce = Timer(const Duration(milliseconds: 350), _recount);
  }

  Future<void> _recount() async {
    final request = ++_countRequest;
    setState(() => _counting = true);
    try {
      final count = await ListingService.countListings(_result);
      if (!mounted || request != _countRequest) return;
      setState(() {
        _count = count;
        _counting = false;
      });
    } catch (_) {
      if (!mounted || request != _countRequest) return;
      setState(() {
        _count = null;
        _counting = false;
      });
    }
  }

  void _clearAll() => _changed(() {
        _types = {};
        _price = const RangeValues(0, _priceCap);
        _guests = 0;
        _bedrooms = 0;
        _bathrooms = 0;
        _amenities = {};
        _instantBook = false;
      });

  static String _money(double v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      b.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) b.write(' ');
    }
    return '$b DA';
  }

  // ── Pieces ──────────────────────────────────────────────

  Widget _sectionTitle(String text, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(color: _dark, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w700)),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(hint, style: const TextStyle(color: _muted, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }

  Widget _priceBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _priceSection() {
    return _card(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              _priceBox('MINIMUM', _money(_price.start)),
              const SizedBox(width: 12),
              _priceBox('MAXIMUM', _price.end >= _priceCap ? '${_money(_priceCap)}+' : _money(_price.end)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _teal,
              inactiveTrackColor: _border,
              thumbColor: Colors.white,
              overlayColor: _teal.withValues(alpha: 0.12),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 11, elevation: 2),
              trackHeight: 3,
            ),
            child: RangeSlider(
              values: _price,
              min: 0,
              max: _priceCap,
              divisions: (_priceCap / _priceStep).round(),
              onChanged: (v) => _changed(() => _price = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeTile(PropertyType t) {
    final on = _types.contains(t.label);
    return GestureDetector(
      onTap: () => _changed(() => on ? _types.remove(t.label) : _types.add(t.label)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: on ? _teal.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: on ? _teal : _border, width: on ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(t.icon, size: 24, color: on ? _teal : _dark),
            Text(
              t.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: on ? _teal : _dark, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperRow(String title, String subtitle, int value, ValueChanged<int> onChanged, {bool divider = true}) {
    Widget button(IconData icon, bool enabled, VoidCallback onTap) => GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: enabled ? _muted : _border),
            ),
            child: Icon(icon, size: 18, color: enabled ? _dark : _border),
          ),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
              button(Icons.remove, value > 0, () => onChanged(value - 1)),
              SizedBox(
                width: 46,
                child: Text(
                  value == 0 ? 'Any' : '$value+',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              button(Icons.add, value < 16, () => onChanged(value + 1)),
            ],
          ),
        ),
        if (divider) const Divider(height: 1, color: _border),
      ],
    );
  }

  Widget _amenityChip(AmenityFilterOption o) {
    final on = _amenities.contains(o.label);
    return GestureDetector(
      onTap: () => _changed(() => on ? _amenities.remove(o.label) : _amenities.add(o.label)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: on ? _teal : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: on ? _teal : _border),
        ),
        child: Text(
          o.label,
          style: TextStyle(color: on ? Colors.white : _dark, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String get _buttonLabel {
    if (_counting && _count == null) return 'Show stays';
    final n = _count;
    if (n == null) return 'Show stays';
    if (n == 0) return 'No stays match';
    return 'Show $n ${n == 1 ? 'stay' : 'stays'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: ✕ · Filters · CLEAR ALL ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _dark, size: 22),
                  ),
                  const Expanded(
                    child: Text(
                      'Filters',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearAll,
                    child: const Text(
                      'CLEAR ALL',
                      style: TextStyle(
                        color: _teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        decoration: TextDecoration.underline,
                        decorationColor: _teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _border),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _sectionTitle('Price per night', hint: 'Before fees and taxes'),
                  _priceSection(),

                  _sectionTitle('Type of place', hint: 'Pick one or several'),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.9,
                    children: kPropertyTypes.map(_typeTile).toList(),
                  ),

                  _sectionTitle('Rooms and guests'),
                  _card(
                    child: Column(
                      children: [
                        _stepperRow('Guests', 'How many people are coming', _guests, (v) => _changed(() => _guests = v)),
                        _stepperRow('Bedrooms', 'At least this many', _bedrooms, (v) => _changed(() => _bedrooms = v)),
                        _stepperRow('Bathrooms', 'At least this many', _bathrooms, (v) => _changed(() => _bathrooms = v), divider: false),
                      ],
                    ),
                  ),

                  _sectionTitle('Amenities'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kAmenityFilterOptions.map(_amenityChip).toList(),
                  ),

                  _sectionTitle('Booking options'),
                  _card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: _dark, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Instant Book', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w600)),
                                Text('Book without waiting for the host to accept', style: TextStyle(color: _muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _instantBook,
                            onChanged: (v) => _changed(() => _instantBook = v),
                            activeThumbColor: Colors.white,
                            activeTrackColor: _teal,
                            inactiveTrackColor: _border,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom: Show N stays ─────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: _cream,
                border: Border(top: BorderSide(color: _border)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _count == 0 ? null : () => Navigator.of(context).pop(_result),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _teal,
                    disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _counting && _count == null
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_buttonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
