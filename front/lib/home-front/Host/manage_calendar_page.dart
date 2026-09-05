import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/availability_service.dart'; // adjust path to match your project structure
import '../../models/availability_day_model.dart';

/// "Manage Calendar" — shown from the Manage Listing page's "Manage
/// calendar" quick action. Lets the host browse month-by-month, select
/// one or more dates, and mark them available/blocked with an optional
/// per-day price override, via the existing GET/PUT
/// /api/availability/:listingId contract.
class ManageCalendarPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final double basePricePerNight;

  const ManageCalendarPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.basePricePerNight,
  });

  @override
  State<ManageCalendarPage> createState() => _ManageCalendarPageState();
}

class _ManageCalendarPageState extends State<ManageCalendarPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _bookedBg = Color(0xFFF0DCC9);
  static const Color _blockedBg = Color(0xFFE3E0DA);

  late DateTime _visibleMonth; // always the 1st of the month
  Map<String, AvailabilityDayModel> _byDate = {}; // key: yyyy-mm-dd
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  final Set<DateTime> _selected = {};
  bool _markAvailable = true; // toggle: Available vs Blocked for the pending update
  late final TextEditingController _priceController;

  static const List<String> _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month, 1);
    _priceController = TextEditingController(text: widget.basePricePerNight.round().toString());
    _loadMonth();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String _key(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadMonth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final days = await AvailabilityService.fetchMonth(
        listingId: widget.listingId,
        month: _visibleMonth.month,
        year: _visibleMonth.year,
      );
      if (!mounted) return;
      setState(() {
        _byDate = {for (final d in days) _key(d.date): d};
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
      _selected.clear();
    });
    _loadMonth();
  }

  void _toggleDay(DateTime day) {
    setState(() {
      if (_selected.contains(day)) {
        _selected.remove(day);
      } else {
        _selected.add(day);
      }
    });
  }

  void _clearSelection() => setState(_selected.clear);

  String get _selectionLabel {
    if (_selected.isEmpty) return 'No dates selected';
    final sorted = _selected.toList()..sort();
    final first = sorted.first;
    final last = sorted.last;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final firstLabel = '${months[first.month - 1]} ${first.day}';
    if (sorted.length == 1) return firstLabel;
    final lastLabel = '${months[last.month - 1]} ${last.day}';
    final nights = sorted.length;
    return '$firstLabel - $lastLabel ($nights ${nights == 1 ? 'night' : 'nights'})';
  }

  Future<void> _applyUpdate() async {
    if (_selected.isEmpty) return;
    final price = double.tryParse(_priceController.text);

    setState(() => _isSaving = true);
    try {
      await AvailabilityService.updateDates(
        authToken: widget.authToken,
        listingId: widget.listingId,
        dates: _selected.toList(),
        status: _markAvailable ? 'available' : 'blocked',
        priceOverride: _markAvailable ? price : null,
      );
      if (!mounted) return;
      setState(() {
        _selected.clear();
        _isSaving = false;
      });
      await _loadMonth();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calendar updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  /// "6.5k" for thousands, plain otherwise — small price label per cell.
  String _shortPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}k';
    }
    return price.round().toString();
  }

  List<DateTime?> _daysGrid() {
    final firstOfMonth = _visibleMonth;
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday-first grid

    final grid = <DateTime?>[];
    for (int i = 0; i < leadingBlanks; i++) {
      grid.add(null);
    }
    for (int day = 1; day <= daysInMonth; day++) {
      grid.add(DateTime(_visibleMonth.year, _visibleMonth.month, day));
    }
    return grid;
  }

  Widget _legendSwatch(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Calendar',
              style: TextStyle(color: _dark, fontSize: 26, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // ── Month nav ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isLoading ? null : () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left, color: _teal),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right, color: _teal),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Calendar grid ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: _teal)),
                    )
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Text(_error!, style: const TextStyle(color: _muted, fontSize: 12), textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _loadMonth, child: const Text('Retry', style: TextStyle(color: _teal))),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              children: _weekdayLabels
                                  .map((l) => Expanded(
                                        child: Center(
                                          child: Text(l, style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _daysGrid().length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (context, index) {
                                final day = _daysGrid()[index];
                                if (day == null) return const SizedBox.shrink();

                                final entry = _byDate[_key(day)];
                                final status = entry?.status ?? 'available';
                                final isSelected = _selected.contains(day);
                                final isPast = day.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

                                Color bg = Colors.transparent;
                                if (status == 'booked') bg = _bookedBg;
                                if (status == 'blocked') bg = _blockedBg;

                                final price = entry?.priceOverride ?? widget.basePricePerNight;

                                return GestureDetector(
                                  onTap: (isPast || status == 'booked') ? null : () => _toggleDay(day),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? _teal : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: isPast ? _muted.withValues(alpha: 0.5) : _dark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (status == 'booked')
                                          const Text('Booked', style: TextStyle(color: _muted, fontSize: 8))
                                        else if (status == 'blocked')
                                          const Text('Blocked', style: TextStyle(color: _muted, fontSize: 8))
                                        else if (!isPast)
                                          Text(_shortPrice(price), style: const TextStyle(color: _teal, fontSize: 9)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _legendSwatch(Colors.white, 'Available'),
                                _legendSwatch(_bookedBg, 'Booked'),
                                _legendSwatch(_blockedBg, 'Blocked'),
                              ],
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 20),

            // ── Selection details ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Selection details', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                      if (_selected.isNotEmpty)
                        TextButton(
                          onPressed: _clearSelection,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: const Text('Clear', style: TextStyle(color: _teal, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_selectionLabel, style: const TextStyle(color: _muted, fontSize: 13)),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Availability', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Switch(
                            value: _markAvailable,
                            onChanged: (v) => setState(() => _markAvailable = v),
                            activeColor: Colors.white,
                            activeTrackColor: _teal,
                            inactiveTrackColor: _border,
                          ),
                          Text(
                            _markAvailable ? 'Available' : 'Blocked',
                            style: TextStyle(color: _markAvailable ? _teal : _muted, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (_markAvailable) ...[
                    Text('Nightly Price (${widget.basePricePerNight > 0 ? 'DZD' : 'DZD'})', style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _cream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const Text('/night', style: TextStyle(color: _muted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selected.isEmpty || _isSaving) ? null : _applyUpdate,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync, color: Colors.white, size: 18),
                label: Text(
                  _isSaving ? 'Updating...' : 'Update Calendar',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}