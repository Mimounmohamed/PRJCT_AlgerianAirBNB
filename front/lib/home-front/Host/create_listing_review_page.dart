import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../widgets/create_listing_pattern_background.dart'; // adjust path if you placed this elsewhere
import '../../../models/listing_draft_model.dart'; // adjust path to match your project structure
import '../../../services/auth_service.dart'; // adjust path — exposes AuthService.uploadToCloudinary()
import '../../../services/listing_service.dart'; // adjust path — exposes ListingService.createListing()
import '../../../services/user_session.dart'; // adjust path to match your project structure — exposes UserSession.instance.token

/// Final step of the Create Listing wizard — Review & Submit. Pulls
/// together photos, title, house rules, booking preferences, rental
/// period, cancellation policy, and pricing, then POSTs the whole
/// draft to `POST /api/listings` (status: 'pending_review', forced
/// server-side — see listing.routes.js).
class CreateListingReviewPage extends StatefulWidget {
  final ListingDraft draft;

  const CreateListingReviewPage({super.key, required this.draft});

  @override
  State<CreateListingReviewPage> createState() => _CreateListingReviewPageState();
}

class _CreateListingReviewPageState extends State<CreateListingReviewPage> {
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _gold = Color(0xFFE8A33D);
  static const Color _cream = Color(0xFFFBF7EF); // price-card text color

  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhotos = false;

  late final TextEditingController _titleController =
      TextEditingController(text: widget.draft.title);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.draft.description);
  late final TextEditingController _priceController = TextEditingController(
    text: widget.draft.pricePerNight != null
        ? widget.draft.pricePerNight!.toStringAsFixed(0)
        : '',
  );
  late final TextEditingController _minStayController =
      TextEditingController(text: widget.draft.minStayNights.toString());
  late final TextEditingController _maxStayController =
      TextEditingController(text: widget.draft.maxStayNights.toString());

  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minStayController.dispose();
    _maxStayController.dispose();
    super.dispose();
  }

  // ── Formatting helpers ─────────────────────────────────

  String _formatAmount(num value) {
    final rounded = value.round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final posFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  String get _unitLabel => widget.draft.rentalPeriod == 'monthly' ? 'month' : 'night';
  String get _unitLabelPlural => widget.draft.rentalPeriod == 'monthly' ? 'months' : 'nights';

  /// Hard ceiling for maxStayNights based on the current rental period —
  /// 12 months for long-term stays, 365 nights for short-term ones.
  int get _maxStayCap => widget.draft.rentalPeriod == 'monthly' ? 12 : 365;

  // ── Photos ──────────────────────────────────────────────

  Future<void> _pickPhotos() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;

      setState(() => _isUploadingPhotos = true);
      for (final xfile in picked) {
        final url = await AuthService.uploadToCloudinary(File(xfile.path));
        widget.draft.addPhoto(url);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Some photos failed to upload: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhotos = false);
    }
  }

  static const double _photoTileSize = 104;

  Widget _photoThumbnail(int index) {
    final photo = widget.draft.photos[index];
    final isCover = widget.draft.coverPhotoIndex == index;

    return GestureDetector(
      onTap: () => setState(() => widget.draft.setCoverPhoto(index)),
      child: Container(
        width: _photoTileSize,
        height: _photoTileSize,
        margin: const EdgeInsets.only(right: 10),
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
                  errorBuilder: (_, __, ___) => Container(color: _border),
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
                onTap: () => setState(() => widget.draft.removePhotoAt(index)),
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

  Widget _addPhotosTile() {
    return GestureDetector(
      onTap: _isUploadingPhotos ? null : _pickPhotos,
      child: SizedBox(
        width: _photoTileSize,
        height: _photoTileSize,
        child: CustomPaint(
          painter: _DashedRectPainter(color: _teal, radius: 16),
          child: Container(
            alignment: Alignment.center,
            child: _isUploadingPhotos
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _teal))
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, color: _teal, size: 26),
                      SizedBox(height: 8),
                      Text('ADD PHOTOS', style: TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: _teal,
          fontSize: 24,
          fontFamily: 'CormorantGaramond',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── House rules ─────────────────────────────────────────

  Widget _ruleRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: _dark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12, height: 1.3)),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: _teal,
                inactiveTrackColor: _border,
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: _border),
      ],
    );
  }

  String get _quietHoursValueLabel => widget.draft.curfew && widget.draft.curfewTime != null
      ? widget.draft.curfewTime!
      : 'Off';

  Future<void> _openQuietHoursDialog() async {
    bool enabled = widget.draft.curfew;
    TimeOfDay from = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay to = const TimeOfDay(hour: 8, minute: 0);

    final existing = widget.draft.curfewTime;
    if (existing != null && existing.contains(' - ')) {
      final parts = existing.split(' - ');
      from = _parseTime(parts[0]) ?? from;
      to = _parseTime(parts[1]) ?? to;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFFBF3E7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiet hours', style: TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      'Ask guests to keep noise down during these hours.',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Text('Enable quiet hours', style: TextStyle(color: _dark, fontWeight: FontWeight.w600))),
                        Switch(
                          value: enabled,
                          activeColor: Colors.white,
                          activeTrackColor: _teal,
                          inactiveTrackColor: _border,
                          onChanged: (v) => setDialogState(() => enabled = v),
                        ),
                      ],
                    ),
                    if (enabled) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _timePickerField(
                              label: 'From',
                              time: from,
                              onTap: () async {
                                final picked = await showTimePicker(context: dialogContext, initialTime: from);
                                if (picked != null) setDialogState(() => from = picked);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _timePickerField(
                              label: 'To',
                              time: to,
                              onTap: () async {
                                final picked = await showTimePicker(context: dialogContext, initialTime: to);
                                if (picked != null) setDialogState(() => to = picked);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              widget.draft.curfew = enabled;
                              widget.draft.curfewTime = enabled ? '${_fmt(from)} - ${_fmt(to)}' : null;
                            });
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Widget _timePickerField({required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(_fmt(time), style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ── Rental period ───────────────────────────────────────

  /// Switches the rental period and resets the max-stay cap to the new
  /// period's default (12 for monthly, 365 for nightly) — only when the
  /// period is actually changing, so re-tapping the already-selected
  /// pill doesn't clobber a value the host already customized.
  void _setRentalPeriod(String value) {
    if (widget.draft.rentalPeriod == value) return;
    setState(() {
      widget.draft.rentalPeriod = value;
      final defaultMax = value == 'monthly' ? 12 : 365;
      widget.draft.maxStayNights = defaultMax;
      _maxStayController.text = defaultMax.toString();
      if (widget.draft.minStayNights > defaultMax) {
        widget.draft.minStayNights = defaultMax;
        _minStayController.text = defaultMax.toString();
      }
    });
  }

  Widget _rentalPeriodToggle() {
    Widget pill(String label, String value) {
      final selected = widget.draft.rentalPeriod == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => _setRentalPeriod(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? _teal : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: selected ? _teal : _border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _dark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill('By night', 'nightly'),
        const SizedBox(width: 10),
        pill('By month', 'monthly'),
      ],
    );
  }

  // ── Cancellation policy ─────────────────────────────────

  Widget _cancellationCard({required String value, required String title, required String description}) {
    final selected = widget.draft.cancellationPolicy == value;
    return GestureDetector(
      onTap: () => setState(() => widget.draft.cancellationPolicy = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _tealTint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _teal : _border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _teal : _muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(color: _muted, fontSize: 12, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Price ────────────────────────────────────────────────

  Widget _priceCard() {
    final price = num.tryParse(_priceController.text) ?? 0;
    final fee = price * (widget.draft.serviceFeePercent / 100);
    final earn = price - fee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Price per $_unitLabel',
            style: const TextStyle(
              color: _cream,
              fontFamily: 'CormorantGaramond',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IntrinsicWidth(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (v) => setState(() => widget.draft.pricePerNight = num.tryParse(v)),
                  style: const TextStyle(
                    color: _cream,
                    fontFamily: 'CormorantGaramond',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white38, fontFamily: 'CormorantGaramond'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'DA',
                  style: TextStyle(color: Colors.white70, fontFamily: 'CormorantGaramond', fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AKRILI SERVICE FEE (${widget.draft.serviceFeePercent.toStringAsFixed(0)}%)',
                style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.4),
              ),
              Text(
                '${_formatAmount(fee)} DA',
                style: const TextStyle(color: _cream, fontFamily: 'CormorantGaramond', fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('YOU EARN', style: TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              Text(
                '${_formatAmount(earn)} DA',
                style: const TextStyle(color: _gold, fontFamily: 'CormorantGaramond', fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Publish ──────────────────────────────────────────────

  Future<void> _publish() async {
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
    if (widget.draft.pricePerNight == null || widget.draft.pricePerNight! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a price.')),
      );
      return;
    }

    setState(() => _isPublishing = true);
    try {
      final token = UserSession.instance.token;
      await ListingService.createListing(
        authToken: token!,
        draftJson: widget.draft.toJson(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing submitted for review!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.draft.title = _titleController.text;
    widget.draft.description = _descriptionController.text;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'List your place',
                      style: TextStyle(
                        color: _dark,
                        fontSize: 32,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Review the details below you can always change these later.',
                      style: TextStyle(color: _muted, fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // ── Photos ─────────────────────────────
                    _sectionLabel('Photos'),
                    SizedBox(
                      height: _photoTileSize,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (int i = 0; i < widget.draft.photos.length; i++) _photoThumbnail(i),
                          _addPhotosTile(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Title ──────────────────────────────
                    _sectionLabel('Give it a title'),
                    const Text(
                      'TITLE',
                      style: TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 6),
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
                        onChanged: (v) => setState(() => widget.draft.title = v),
                        style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          hintText: 'Dar el-Hawa',
                          hintStyle: TextStyle(color: _muted, fontWeight: FontWeight.normal),
                          counterStyle: TextStyle(color: _muted, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Description ─────────────────────────
                    _sectionLabel('Describe your place'),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 6),
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
                        onChanged: (v) => setState(() => widget.draft.description = v),
                        style: const TextStyle(color: _dark, fontSize: 14, height: 1.4),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          hintText: 'Tell guests what makes your place special — the neighborhood, the view, what\'s nearby...',
                          hintStyle: TextStyle(color: _muted, fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── House rules ────────────────────────
                    _sectionLabel('House rules'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          _ruleRow(
                            icon: Icons.pets_outlined,
                            title: 'Pets allowed',
                            value: widget.draft.petsAllowed,
                            onChanged: (v) => setState(() => widget.draft.petsAllowed = v),
                          ),
                          _ruleRow(
                            icon: Icons.smoking_rooms_outlined,
                            title: 'Smoking allowed',
                            value: widget.draft.smokingAllowed,
                            onChanged: (v) => setState(() => widget.draft.smokingAllowed = v),
                          ),
                          _ruleRow(
                            icon: Icons.celebration_outlined,
                            title: 'Events allowed',
                            value: widget.draft.eventsAllowed,
                            onChanged: (v) => setState(() => widget.draft.eventsAllowed = v),
                          ),
                          _ruleRow(
                            icon: Icons.family_restroom_outlined,
                            title: 'Family booklet required',
                            subtitle: 'Only married couples can book By providing a family booklet.',
                            value: widget.draft.familyBookletRequired,
                            onChanged: (v) => setState(() => widget.draft.familyBookletRequired = v),
                          ),
                          InkWell(
                            onTap: _openQuietHoursDialog,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.nightlight_outlined, size: 20, color: _dark),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text('Quiet hours', style: TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
                                  ),
                                  Text(_quietHoursValueLabel, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right, size: 18, color: _muted),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Booking preferences ────────────────
                    _sectionLabel('Booking preferences'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          _ruleRow(
                            icon: Icons.flash_on_outlined,
                            title: 'Instant Book',
                            subtitle: 'Guests can book without waiting for approval.',
                            value: widget.draft.instantBook,
                            onChanged: (v) => setState(() => widget.draft.instantBook = v),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Rental period ──────────────────────
                    _sectionLabel('Rental period'),
                    _rentalPeriodToggle(),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        widget.draft.rentalPeriod == 'monthly'
                            ? 'Guests book your place for one or more months at a time.'
                            : 'Guests book your place for one or more nights at a time.',
                        style: const TextStyle(color: _muted, fontSize: 12, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Min / Max stay ─────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            label: 'MIN ${_unitLabelPlural.toUpperCase()}',
                            controller: _minStayController,
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed == null) return;
                              final clamped = parsed > _maxStayCap ? _maxStayCap : parsed;
                              widget.draft.minStayNights = clamped;
                              if (clamped != parsed) {
                                _minStayController.value = TextEditingValue(
                                  text: clamped.toString(),
                                  selection: TextSelection.collapsed(offset: clamped.toString().length),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _numberField(
                            label: 'MAX ${_unitLabelPlural.toUpperCase()}',
                            controller: _maxStayController,
                            onChanged: (v) {
                              final parsed = int.tryParse(v);
                              if (parsed == null) return;
                              final clamped = parsed > _maxStayCap ? _maxStayCap : parsed;
                              widget.draft.maxStayNights = clamped;
                              if (clamped != parsed) {
                                _maxStayController.value = TextEditingValue(
                                  text: clamped.toString(),
                                  selection: TextSelection.collapsed(offset: clamped.toString().length),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Cancellation policy ─────────────────
                    _sectionLabel('Cancellation policy'),
                    _cancellationCard(
                      value: 'Flexible',
                      title: 'Flexible',
                      description: 'Full refund 1 day prior to arrival.',
                    ),
                    _cancellationCard(
                      value: 'Moderate',
                      title: 'Moderate',
                      description: 'Full refund 5 days prior to arrival.',
                    ),
                    _cancellationCard(
                      value: 'Firm',
                      title: 'Firm',
                      description: 'Full refund if cancelled within 48 hours of booking.',
                    ),
                    const SizedBox(height: 10),

                    // ── Price ────────────────────────────────
                    _sectionLabel('Set your price'),
                    _priceCard(),
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
                    onPressed: _isPublishing ? null : () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Exit flow', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: _isPublishing ? null : _publish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    child: _isPublishing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Publish listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws a dashed rounded-rect border — used for the "Add photos" tile.
/// No external package needed; Flutter's Path.computeMetrics() lets us
/// walk the rounded-rect outline and stroke it in short segments.
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedRectPainter({
    required this.color,
    this.radius = 16,
    this.dashWidth = 5,
    this.dashSpace = 4,
    this.strokeWidth = 1.6,
  });

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