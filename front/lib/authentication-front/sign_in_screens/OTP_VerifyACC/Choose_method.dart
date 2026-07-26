import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../../../services/auth_service.dart';
import '../Mar7aban.dart';
import 'verifCODE.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({
    super.key,
    required this.token,
    required this.maskedPhone,
    required this.maskedEmail,
    required this.realPhone, // full E.164 phone, e.g. +213558852374
    required this.realEmail, // full email address
  });

  final String token;
  final String maskedPhone;
  final String maskedEmail;
  final String realPhone;
  final String realEmail;

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  bool _isLoading = false;

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  void _onSendCode(OtpMethod method) async {
    setState(() => _isLoading = true);

    try {
      final channel = method == OtpMethod.sms ? 'sms' : 'email';

      await AuthService.sendOtp(
        token: widget.token,
        channel: channel,
      );

      final maskedContact = method == OtpMethod.sms ? widget.maskedPhone : widget.maskedEmail;
      final target = method == OtpMethod.sms ? widget.realPhone : widget.realEmail;

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(
            token: widget.token,
            method: method,
            maskedContact: maskedContact,
            target: target,
            onVerified: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const WelcomeHomeScreen(userName: 'Anis'),
                ),
                (route) => false,
              );
            },
            onResend: () async {
              await AuthService.sendOtp(
                token: widget.token,
                channel: channel,
              );
            },
          ),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'Verify your account',
        onBack: _onBack,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                    maskedPhone: widget.maskedPhone,
                    maskedEmail: widget.maskedEmail,
                    validityMinutes: 10,
                    onSendCode: _isLoading ? (_) {} : _onSendCode,
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
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006972)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}