import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../../sign_in_screens/OTP_VerifyACC/verifCODE.dart';
import 'new_password.dart';

/// Password-recovery entry point: same "choose SMS or Email" pattern as
/// VerifyAccountScreen, reused here for password reset instead of account
/// verification. Reuses [VerifyCodeScreen] from OTP_VerifyACC directly
/// (rather than duplicating an OTP-entry screen) since that screen is
/// already generic — only what happens *after* verification differs, which
/// is wired below via `onVerified`.
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(
          method: method,
          maskedContact: maskedContact,
          onVerified: () {
            // Password reset needs one more step than account verification:
            // instead of landing on the home screen, the user sets a new
            // password. pushReplacement so they can't back-swipe into the
            // OTP screen once the code's already been consumed.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NewPasswordScreen(),
              ),
            );
          },
          onResend: () {
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