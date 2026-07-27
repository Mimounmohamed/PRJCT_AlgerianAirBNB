import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/otp_code_input.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_phone_auth_service.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    this.token, // Optional for login flow
    required this.method,
    required this.maskedContact,
    this.target = '',
    this.purpose = 'signup', // Default fallback
    required this.onVerified,
    this.onResend,
  });

  final String? token;
  final OtpMethod method;
  final String maskedContact;
  final String target;
  final String purpose;
  final VoidCallback onVerified;
  final Future<void> Function()? onResend;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _code = '';
  bool _isLoading = false;

  bool get _isEmail => widget.method == OtpMethod.email;

  void _onVerifyAndContinue() async {
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.method == OtpMethod.sms) {
        // Firebase handles the actual code verification client-side
        final idToken = await FirebasePhoneAuthService.verifyCode(_code);

        // Tell our backend the phone is verified, so it can update the user record
        await AuthService.verifyFirebasePhone(
          token: widget.token ?? '',
          idToken: idToken,
        );
      } else {
        // Email — unchanged, uses existing backend OTP flow
        if (widget.target.isNotEmpty) {
          await AuthService.verifyOtp(
            token: widget.token ?? '',
            target: widget.target,
            code: _code,
          );
        }
      }

      if (!mounted) return;
      widget.onVerified();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResend() async {
    if (widget.onResend != null) {
      try {
        await widget.onResend!();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend code')),
        );
      }
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
                  onPressed: _isLoading ? null : _onVerifyAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006972),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
                onTap: _isLoading ? null : _handleResend,
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