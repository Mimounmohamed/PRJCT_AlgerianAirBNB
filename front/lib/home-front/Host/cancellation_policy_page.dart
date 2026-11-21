import 'package:flutter/material.dart';
import '../../authentication-front/widgets/app_bar.dart'; // adjust path to match your project structure
import '../../services/host_service.dart'; // adjust path to match your project structure

/// One cancellation policy as shown to hosts. [refundShare] is how much of
/// the timeline bar is green (refundable) — purely visual.
class CancellationPolicyOption {
  final String value; // matches Listing.cancellationPolicy enum
  final String badge;
  final String title;
  final String deadline; // the bold part of the description
  final String timelineLabel;
  final double refundShare;

  const CancellationPolicyOption({
    required this.value,
    required this.badge,
    required this.title,
    required this.deadline,
    required this.timelineLabel,
    required this.refundShare,
  });

  static const List<CancellationPolicyOption> all = [
    CancellationPolicyOption(
      value: 'Flexible',
      badge: 'MOST POPULAR',
      title: 'Flexible',
      deadline: '24 hours',
      timelineLabel: '24H BEFORE',
      refundShare: 0.72,
    ),
    CancellationPolicyOption(
      value: 'Moderate',
      badge: 'BALANCED',
      title: 'Moderate',
      deadline: '5 days',
      timelineLabel: '5 DAYS BEFORE',
      refundShare: 0.5,
    ),
    CancellationPolicyOption(
      value: 'Firm',
      badge: 'STRICT PROTECTION',
      title: 'Firm',
      deadline: '30 days',
      timelineLabel: '30 DAYS BEFORE',
      refundShare: 0.3,
    ),
  ];

  /// "Full refund if cancelled at least 5 days before check-in."
  String get description => 'Full refund if cancelled at least $deadline before check-in.';
}

/// "Cancellation policy" — its own full page (pushed from Listing
/// Settings). Picks one of the three policies and saves just
/// `cancellationPolicy` via PUT /api/listings/:id. Pops with the saved
/// value, or null if the host backed out.
class CancellationPolicyPage extends StatefulWidget {
  final String authToken;
  final String listingId;
  final String cancellationPolicy;

  const CancellationPolicyPage({
    super.key,
    required this.authToken,
    required this.listingId,
    required this.cancellationPolicy,
  });

  @override
  State<CancellationPolicyPage> createState() => _CancellationPolicyPageState();
}

class _CancellationPolicyPageState extends State<CancellationPolicyPage> {
  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _card = Color(0xFFFFFBF5);
  static const Color _dark = Color(0xFF2A1B12);
  static const Color _teal = Color(0xFF006972);
  static const Color _tealTint = Color(0xFFE3F0F1);
  static const Color _muted = Color(0xFF4F4540);
  static const Color _border = Color(0xFFE7DCCB);
  static const Color _refund = Color(0xFF2E7D4F);
  static const Color _noRefund = Color(0xFFB3261E);

  late String _selected;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.cancellationPolicy;
  }

  Future<void> _save() async {
    if (_selected == widget.cancellationPolicy) {
      Navigator.of(context).pop(); // nothing changed
      return;
    }
    setState(() => _isSaving = true);
    try {
      await HostService.updateListingDetails(
        authToken: widget.authToken,
        listingId: widget.listingId,
        updates: {'cancellationPolicy': _selected},
      );
      if (!mounted) return;
      await _showSavedPopup();
      if (!mounted) return;
      Navigator.of(context).pop(_selected);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSavedPopup() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop();
        });
        return Dialog(
          backgroundColor: _cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Policy saved', style: TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _timeline(CancellationPolicyOption option) {
    const labelStyle = TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.3);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final splitX = constraints.maxWidth * option.refundShare;
            // Keep the middle label clear of the two end labels.
            const minLeft = 60.0;
            final maxLeft = (constraints.maxWidth - 120).clamp(minLeft, double.infinity);
            return SizedBox(
              height: 12,
              child: Stack(
                children: [
                  const Positioned(left: 0, top: 0, child: Text('RESERVATION', style: labelStyle)),
                  Positioned(
                    left: (splitX - 40).clamp(minLeft, maxLeft),
                    width: 80,
                    top: 0,
                    child: Text(option.timelineLabel, textAlign: TextAlign.center, style: labelStyle),
                  ),
                  const Positioned(right: 0, top: 0, child: Text('CHECK-IN', style: labelStyle)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(flex: (option.refundShare * 100).round(), child: Container(color: _refund)),
                Expanded(flex: 100 - (option.refundShare * 100).round(), child: Container(color: _noRefund)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('100% REFUND', style: TextStyle(color: _refund, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
            Text('NO REFUND', style: TextStyle(color: _noRefund, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ],
        ),
      ],
    );
  }

  Widget _policyCard(CancellationPolicyOption option) {
    final selected = _selected == option.value;
    return GestureDetector(
      onTap: () => setState(() => _selected = option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _teal : _border, width: selected ? 1.6 : 1),
          boxShadow: selected
              ? [BoxShadow(color: _teal.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.badge,
                        style: TextStyle(
                          color: selected ? _teal : _dark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.title,
                        style: const TextStyle(color: _dark, fontSize: 22, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? _teal : _border,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: _dark, fontSize: 13, height: 1.4),
                children: [
                  const TextSpan(text: 'Full refund if cancelled at least '),
                  TextSpan(text: option.deadline, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: ' before check-in.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _timeline(option),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: _cream,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: AkriliAppBar(title: 'AKRILI', onBack: () => Navigator.of(context).maybePop()),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cancellation policy',
                    style: TextStyle(color: _dark, fontSize: 28, fontFamily: 'CormorantGaramond', fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose a policy that protects your earnings while offering the flexibility your guests need.',
                    style: TextStyle(color: _muted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  for (final option in CancellationPolicyOption.all) _policyCard(option),
                  const SizedBox(height: 10),

                  // Host guarantee
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _tealTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _teal.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: _teal, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Host Guarantee', style: TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text(
                                'AKRILI protection overrides policy settings in cases of documented emergencies or extenuating circumstances.',
                                style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            color: _cream,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  disabledBackgroundColor: _teal.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
