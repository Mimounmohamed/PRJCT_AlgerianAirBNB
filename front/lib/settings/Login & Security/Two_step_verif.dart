import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';

class TwoStepVerificationScreen extends StatefulWidget {
  const TwoStepVerificationScreen({super.key});

  @override
  State<TwoStepVerificationScreen> createState() =>
      _TwoStepVerificationScreenState();
}

class _TwoStepVerificationScreenState
    extends State<TwoStepVerificationScreen> {
  bool _smsEnabled = false;
  bool _emailEnabled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Load current 2FA setting from the logged-in user
    final user = UserSession.instance.currentUser;
    if (user != null) {
      // UserSession stores the raw user map — check security field
      final security = UserSession.instance.rawUser?['security'];
      _emailEnabled = security?['twoFactorEnabled'] == true &&
          security?['twoFactorMethod'] == 'email';
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      final token = UserSession.instance.token ?? '';
      await AuthService.toggle2FA(token: token, enabled: _emailEnabled);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _emailEnabled
                ? '2FA enabled — a code will be sent to your email at each login.'
                : '2FA disabled.',
          ),
          backgroundColor: const Color(0xFF006972),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF2A1B12)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 20),

                    // Shield icon badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006972).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF006972),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Two-step verification',
                      style: TextStyle(
                        color: const Color(0xFF23130A),
                        fontSize: 28,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    const Text(
                      "Add an extra layer of security to your Akrili "
                      "account. After entering your password, you'll be "
                      "asked for a second piece of information to verify "
                      "your identity.",
                      style: TextStyle(
                        color: const Color(0xFF4F4540),
                        fontSize: 15,
                        fontFamily: 'HankenGrotesk',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SMS verification
                    _VerificationTile(
                      icon: Icons.sms_outlined,
                      title: 'SMS verification',
                      subtitle: 'Codes sent via text message.',
                      value: _smsEnabled,
                      onChanged: (val) => setState(() => _smsEnabled = val),
                    ),
                    const SizedBox(height: 14),

                    // Email verification
                    _VerificationTile(
                      icon: Icons.mail_outline,
                      title: 'Email verification',
                      subtitle: 'Codes sent to your inbox.',
                      value: _emailEnabled,
                      onChanged: (val) => setState(() => _emailEnabled = val),
                    ),
                    const SizedBox(height: 20),

                    // Recovery options (dashed border card)
                    _DashedBorderContainer(
                      color: const Color(0xFFD9B99A),
                      radius: 14,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF1E3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.vpn_key_outlined,
                                    color: Color(0xFFB5451B), size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'RECOVERY OPTIONS',
                                  style: TextStyle(
                                    color: Color(0xFFB5451B),
                                    fontSize: 12,
                                    fontFamily: 'HankenGrotesk',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "In case you lose access to your devices, "
                              "one-time backup codes are available to "
                              "ensure you're never locked out of your "
                              "account.",
                              style: TextStyle(
                                color: Color(0xFF4F4540),
                                fontSize: 14,
                                fontFamily: 'HankenGrotesk',
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to backup codes screen
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Manage backup codes',
                                    style: TextStyle(
                                      color: Color(0xFF006972),
                                      fontSize: 14,
                                      fontFamily: 'HankenGrotesk',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Color(0xFF006972), size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Decorative banner image
                    // TODO: replace the gradient below with your actual
                    // image asset, e.g.:
                    // Image.asset('assets/images/leather_texture.jpg',
                    //   height: 150, width: double.infinity, fit: BoxFit.cover)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/khayt.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save Settings button pinned to the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006972),
                    disabledBackgroundColor: const Color(0xFF006972).withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card with an icon, title, subtitle, and a custom toggle switch.
/// Gets a teal border/highlight when its value is true (active).
class _VerificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _VerificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? const Color(0xFF006972) : const Color(0xFFD3C3BD),
          width: value ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF006972).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF006972), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF23130A),
                    fontSize: 15,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7A6F68),
                    fontSize: 13,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// A pill-shaped toggle switch: teal track with a checkmark thumb when on,
/// tan/cream track with a plain thumb when off — matching the design.
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF006972) : const Color(0xFFE7DDD0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: value
                ? const Icon(Icons.check, size: 15, color: Color(0xFF006972))
                : null,
          ),
        ),
      ),
    );
  }
}

/// Wraps [child] with a dashed rounded-rectangle border.
class _DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const _DashedBorderContainer({
    required this.child,
    this.color = const Color(0xFFD9B99A),
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedRRectPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 5.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          dashPaint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}