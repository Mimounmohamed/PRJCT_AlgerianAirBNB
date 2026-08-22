import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/otp_method_selector.dart';
import '../../widgets/otp_code_input.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_session.dart'; // NEW — adjust path if needed

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    this.token,
    required this.method,
    required this.maskedContact,
    this.target = '',
    this.purpose = 'signup',
    required this.onVerified,
    this.onResend,
  });

  final String? token;
  final OtpMethod method;
  final String maskedContact;
  final String target;
  final String purpose;
  final void Function(String finalToken, String userName) onVerified;
  final Future<void> Function()? onResend;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _code = '';
  bool _isLoading = false;

  String? _otpError;
  bool _markAllRed = false;
  String? _resendMessage;
  bool _resendFailed = false;

  bool get _isEmail => widget.method == OtpMethod.email;

  void _onVerifyAndContinue() async {
    if (_code.length != 6) {
      setState(() {
        _otpError = 'Please enter the complete 6-digit code';
        _markAllRed = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (widget.purpose == 'two_factor') {
        // 2FA login verification — uses its own endpoint
        result = await AuthService.verify2FA(
          email: widget.target,
          code: _code,
        );
      } else {
        // Signup / other OTP purposes
        result = await AuthService.verifyOtp(
          token: widget.token ?? '',
          target: widget.target,
          code: _code,
          purpose: widget.purpose,
        );
      }

      if (!mounted) return;

      final finalToken = result['token'] as String? ?? '';
      final userJson = result['user'] as Map<String, dynamic>?;
      final userName = userJson?['fullName'] as String? ?? '';

      if (userJson != null) {
        UserSession.instance.setUser(
          AppUser.fromJson(userJson),
          token: finalToken,
          raw: userJson,
        );
      }

      widget.onVerified(finalToken, userName);
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (!mounted) return;
      setState(() {
        _otpError = msg;
        _markAllRed = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleResend() async {
    if (widget.onResend != null) {
      try {
        await widget.onResend!();
        if (!mounted) return;
        setState(() {
          _resendMessage = 'Code resent successfully';
          _resendFailed = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _resendMessage = 'Failed to resend code';
          _resendFailed = true;
        });
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
                errorText: _otpError,
                markAllRed: _markAllRed,
                onChanged: (code) => setState(() {
                  _code = code;
                  _otpError = null;
                  _markAllRed = false;
                }),
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
              if (_resendMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _resendMessage!,
                  style: TextStyle(
                    color: _resendFailed ? Colors.red : const Color(0xFF006972),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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