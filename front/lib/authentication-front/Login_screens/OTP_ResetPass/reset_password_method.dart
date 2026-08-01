import 'package:flutter/material.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/app_bar.dart';
import '../../sign_in_screens/OTP_VerifyACC/verifCODE.dart';
import '../../../services/auth_service.dart';
import '../../../services/firebase_phone_auth_service.dart';
import 'new_password.dart';

class ResetPasswordMethodScreen extends StatefulWidget {
  const ResetPasswordMethodScreen({
    super.key,
    required this.maskedPhone,
    required this.maskedEmail,
    this.realPhone = '',
    this.realEmail = '',
  });

  final String maskedPhone;
  final String maskedEmail;
  final String realPhone;
  final String realEmail;

  @override
  State<ResetPasswordMethodScreen> createState() => _ResetPasswordMethodScreenState();
}

class _ResetPasswordMethodScreenState extends State<ResetPasswordMethodScreen> {
  bool _isLoading = false;

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  String get _fullPhoneE164 {
    final stripped = widget.realPhone.replaceFirst(RegExp(r'^0'), '');
    return '+213$stripped';
  }

  void _goToVerifyCodeScreen(OtpMethod method) {
    final maskedContact = method == OtpMethod.sms ? widget.maskedPhone : widget.maskedEmail;
    final target = method == OtpMethod.sms
        ? (_fullPhoneE164.length > 4 ? _fullPhoneE164 : widget.maskedPhone)
        : (widget.realEmail.isNotEmpty ? widget.realEmail : widget.maskedEmail);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VerifyCodeScreen(
          method: method,
          maskedContact: maskedContact,
          target: target,
          purpose: 'password-reset',
          onVerified: (finalToken, userName) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const NewPasswordScreen(),
              ),
            );
          },
          onResend: () async {
            if (method == OtpMethod.sms && _fullPhoneE164.length > 4) {
              await FirebasePhoneAuthService.sendCode(
                phoneNumber: _fullPhoneE164,
                onCodeSent: () {},
                onError: (error) {
                  throw Exception(error);
                },
              );
            } else if (method == OtpMethod.email && widget.realEmail.isNotEmpty) {
              await AuthService.sendOtp(
                token: '',
                channel: 'email',
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
        if (_fullPhoneE164.length > 4) {
          await FirebasePhoneAuthService.sendCode(
            phoneNumber: _fullPhoneE164,
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
          // If real phone wasn't provided, navigate directly to verify code screen
          if (!mounted) return;
          setState(() => _isLoading = false);
          _goToVerifyCodeScreen(method);
        }
      } else {
        if (widget.realEmail.isNotEmpty) {
          await AuthService.sendOtp(
            token: '',
            channel: 'email',
          );
        }
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
        title: 'Reset password',
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