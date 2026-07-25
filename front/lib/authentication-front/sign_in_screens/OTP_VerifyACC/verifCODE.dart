import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/otp_code_input.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.method,
    required this.maskedContact,
    required this.onVerified,
    this.onResend,
  });

  final OtpMethod method;
  final String maskedContact;
  final VoidCallback onVerified;
  final VoidCallback? onResend;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _code = '';

  bool get _isEmail => widget.method == OtpMethod.email;

  void _onVerifyAndContinue() {
    if (_code.length == 6) {
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEmail ? 'Verify email' : 'Verify phone';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: title,
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/logo.png',
                width: 64,
                height: 64,
              ),
              const SizedBox(height: 36),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "We've sent a 6-digit code to",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.maskedContact,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 28),
              OtpCodeInput(
                length: 6,
                fillColor: const Color(0xFFFFFCF5),
                onChanged: (code) => setState(() => _code = code),
                onCompleted: (code) => setState(() => _code = code),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onVerifyAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006972),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Verify and continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: widget.onResend,
                child: const Text(
                  'RESEND CODE NOW',
                  style: TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'AKRILI',
                style: TextStyle(
                  color: Color(0xFF006972),
                  fontFamily: 'CormorantGaramond',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}