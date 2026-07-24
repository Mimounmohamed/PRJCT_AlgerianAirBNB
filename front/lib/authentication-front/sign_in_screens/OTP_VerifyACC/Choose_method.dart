import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../Mar7aban.dart';
import 'verifCODE.dart';

class VerifyAccountScreen extends StatelessWidget {
  const VerifyAccountScreen({
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    const WelcomeHomeScreen(userName: 'Anis'),
              ),
              (route) => false,
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
        title: 'Verify your account',
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
                'Choose how to receive your code',
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
                'Select one of the methods below to verify your identity '
                'and secure your stay.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 51, 50, 50),
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
                  height: 1.5, // 27px line-height at 18px font size
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