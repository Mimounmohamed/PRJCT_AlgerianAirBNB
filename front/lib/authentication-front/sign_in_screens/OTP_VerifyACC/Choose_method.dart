import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_phone_auth_service.dart';
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

  void _goToVerifyCodeScreen(OtpMethod method) {
    final maskedContact = method == OtpMethod.sms ? widget.maskedPhone : widget.maskedEmail;
    final target = method == OtpMethod.sms ? widget.realPhone : widget.realEmail;
    final channel = method == OtpMethod.sms ? 'sms' : 'email';

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
            if (method == OtpMethod.sms) {
              await FirebasePhoneAuthService.sendCode(
                phoneNumber: widget.realPhone,
                onCodeSent: () {},
                onError: (error) {
                  throw Exception(error);
                },
              );
            } else {
              await AuthService.sendOtp(
                token: widget.token,
                channel: channel,
              );
            }
          },
        ),
      ),
    );
  }

  void _onSendCode(OtpMethod method) async {
    setState(() => _isLoading = true);

    try {
      if (method == OtpMethod.sms) {
        // Firebase sends the SMS itself — no backend call needed here
        await FirebasePhoneAuthService.sendCode(
          phoneNumber: widget.realPhone,
          onCodeSent: () {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _goToVerifyCodeScreen(method);
          },
          onError: (error) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
        );
      } else {
        // Email — unchanged, uses existing backend OTP flow
        await AuthService.sendOtp(
          token: widget.token,
          channel: 'email',
        );

        if (!mounted) return;
        setState(() => _isLoading = false);
        _goToVerifyCodeScreen(method);
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      setState(() => _isLoading = false);
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