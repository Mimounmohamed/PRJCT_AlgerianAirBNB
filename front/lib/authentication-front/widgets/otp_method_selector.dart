import 'package:flutter/material.dart';

enum OtpMethod { sms, email }

/// Reusable OTP delivery method picker: two selectable cards (SMS / Email),
/// a "code valid for N minutes" note, and a Send code button — all in one
/// widget so it can be dropped into both account verification and
/// password-recovery flows.
///
/// Usage:
/// ```dart
/// OtpMethodSelector(
///   maskedPhone: '+213 XXX XX XX 88',
///   maskedEmail: 'y***@domain.com',
///   validityMinutes: 10,
///   onSendCode: (method) {
///     // navigate to the OTP entry screen for `method`
///   },
/// )
/// ```
class OtpMethodSelector extends StatefulWidget {
  const OtpMethodSelector({
    super.key,
    required this.maskedPhone,
    required this.maskedEmail,
    required this.onSendCode,
    this.validityMinutes = 10,
    this.initialMethod = OtpMethod.sms,
  });

  final String maskedPhone;
  final String maskedEmail;
  final int validityMinutes;
  final OtpMethod initialMethod;
  final ValueChanged<OtpMethod> onSendCode;

  @override
  State<OtpMethodSelector> createState() => _OtpMethodSelectorState();
}

class _OtpMethodSelectorState extends State<OtpMethodSelector> {
  late OtpMethod _selected = widget.initialMethod;

  Widget _methodCard({
    required OtpMethod method,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selected == method;
    return GestureDetector(
      onTap: () => setState(() => _selected = method),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF3E7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF006972) : const Color(0xFFD9CDB5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A9188),
                    ),
                  ),
                ],
              ),
            ),
            Radio<OtpMethod>(
              value: method,
              groupValue: _selected,
              activeColor: const Color(0xFF006972),
              onChanged: (value) {
                if (value != null) setState(() => _selected = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _methodCard(
          method: OtpMethod.sms,
          icon: Icons.sms_outlined,
          iconBackground: const Color(0xFFDCEEF5),
          iconColor: const Color(0xFF2F7BA6),
          title: 'Text Message (SMS)',
          subtitle: widget.maskedPhone,
        ),
        const SizedBox(height: 14),
        _methodCard(
          method: OtpMethod.email,
          icon: Icons.mail_outline,
          iconBackground: const Color(0xFFF7E3D2),
          iconColor: const Color(0xFFC97A3B),
          title: 'Email Address',
          subtitle: widget.maskedEmail,
        ),
        const SizedBox(height: 20),
        Text(
          'The code will be valid for ${widget.validityMinutes} minutes.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 51, 50, 50),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => widget.onSendCode(_selected),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006972),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Send code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}