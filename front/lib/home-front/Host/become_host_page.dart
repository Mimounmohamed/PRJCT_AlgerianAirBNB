import 'package:flutter/material.dart';
import '../../services/host_service.dart'; // adjust path to match your project structure

/// Shown on the Host tab when the user isn't a host yet — a CTA to become
/// one. Calling POST /api/host/become is real; on success, calls
/// [onBecameHost] so the parent can refetch and switch to the dashboard.
class BecomeHostPage extends StatefulWidget {
  final String authToken;
  final VoidCallback onBecameHost;

  const BecomeHostPage({
    super.key,
    required this.authToken,
    required this.onBecameHost,
  });

  @override
  State<BecomeHostPage> createState() => _BecomeHostPageState();
}

class _BecomeHostPageState extends State<BecomeHostPage> {
  bool _isSubmitting = false;
  String? _error;

  static const Color _teal = Color(0xFF006972);
  static const Color _dark = Color(0xFF2A1B12);

  Future<void> _handleBecomeHost() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await HostService.becomeHost(authToken: widget.authToken);
      if (!mounted) return;
      widget.onBecameHost();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_work_outlined, size: 32, color: _teal),
          ),
          const SizedBox(height: 24),
          const Text(
            'Share your place,\nearn on your terms.',
            style: TextStyle(
              color: _dark,
              fontSize: 30,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Turn your riad, apartment, or desert stay into income. '
            'Akrili makes it simple to list your first place and start '
            'welcoming guests from across Algeria.',
            style: TextStyle(color: Color(0xFF8A7B6E), fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          _benefitRow(Icons.verified_outlined, 'Verified guests, secure bookings'),
          const SizedBox(height: 16),
          _benefitRow(Icons.payments_outlined, 'You set the price and availability'),
          const SizedBox(height: 16),
          _benefitRow(Icons.support_agent_outlined, 'Support whenever you need it'),
          const SizedBox(height: 36),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleBecomeHost,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Start hosting',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _teal),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}