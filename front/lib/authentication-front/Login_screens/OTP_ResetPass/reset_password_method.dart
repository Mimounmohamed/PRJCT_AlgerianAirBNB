import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../../sign_in_screens/OTP_VerifyACC/verifCODE.dart';
import 'new_password.dart';

class ResetPasswordMethodScreen extends StatelessWidget {
  const ResetPasswordMethodScreen({
    super.key,
    required this.maskedPhone,
    required this.maskedEmail,
  });

  final String maskedPhone;
  final String maskedEmail;

  void _onBack(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  void _onSendCode(BuildContext context, OtpMethod method) {
    final maskedContact = method == OtpMethod.sms ? maskedPhone : maskedEmail;
    // For password reset, target can be the unmasked or masked contact 
    // depending on what your backend expects for password reset lookup.
    final target = maskedContact; 

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(
          method: method,
          maskedContact: maskedContact,
          target: target,
          purpose: 'password-reset', // Specifying purpose for password recovery
          onVerified: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NewPasswordScreen(),
              ),
            );
          },
          onResend: () async {
            // TODO: call the resend-code API for `method`.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'Reset password',
        onBack: () => _onBack(context),
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
              const SizedBox(height: 24),
              const Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "No worries. Select one of the methods below and we'll "
                'send you a code to reset it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              OtpMethodSelector(
                maskedPhone: maskedPhone,
                maskedEmail: maskedEmail,
                validityMinutes: 10,
                onSendCode: (method) => _onSendCode(context, method),
              ),
              const SizedBox(height: 28),
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}