import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/otp_method_selector.dart';
import '../sign_in_screens/OTP_VerifyACC/verifCODE.dart';
import '../sign_in_screens/Mar7aban.dart';
import '../../services/auth_service.dart';

class LoginUsingPhoneScreen extends StatefulWidget {
  const LoginUsingPhoneScreen({super.key});

  @override
  State<LoginUsingPhoneScreen> createState() => _LoginUsingPhoneScreenState();
}

class _LoginUsingPhoneScreenState extends State<LoginUsingPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  void _onContinue() async {
    final digits = _phoneController.text.trim();
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    final maskedPhone = '+213 ${digits.replaceRange(
      0,
      digits.length > 2 ? digits.length - 2 : 0,
      'X' * (digits.length > 2 ? digits.length - 2 : digits.length),
    )}';

    setState(() => _isLoading = true);

    try {
      // Call backend — it generates OTP and sends SMS via BudgetSMS
      await AuthService.loginWithPhone(phone: digits);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VerifyCodeScreen(
            method: OtpMethod.sms,
            maskedContact: maskedPhone,
            target: digits,
            purpose: 'login',
            onVerified: (finalToken, userName) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => WelcomeHomeScreen(
                    userName: userName.isNotEmpty ? userName : 'there',
                    token: finalToken,
                  ),
                ),
                (route) => false,
              );
            },
            onResend: () async {
              await AuthService.loginWithPhone(phone: digits);
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'AKRILI',
        onBack: _onBack,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative star, bottom-left, sitting behind the content.
            Positioned(
              left: -20,
              bottom: 30,
              child: SizedBox(
                width: 220,
                height: 220,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: 760,
                    maxHeight: 760,
                    alignment: Alignment.bottomLeft,
                    child: Opacity(
                      opacity: 0.5,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF0F4C4C),
                          BlendMode.softLight,
                        ),
                        child: Image.asset(
                          'assets/images/phonenumber.png',
                          width: 760,
                          height: 760,
                          alignment: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Decorative star, anchored bottom-right, sitting behind the content.
            Positioned(
              right: 0,
              bottom: 20,
              child: SizedBox(
                width: 260,
                height: 260,
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: 900,
                    maxHeight: 900,
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.55,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF006972),
                          BlendMode.softLight,
                        ),
                        child: Image.asset(
                          'assets/images/phonenumber.png',
                          width: 900,
                          height: 900,
                          alignment: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your mobile number to access your account.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6B6B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      'PHONE NUMBER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Static country code chip — Algerian flag + +213
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF3E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD9CDB5)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '🇩🇿',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+213',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFFB0A48C),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '5XX XX XX XX',
                            hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
                            filled: true,
                            fillColor: const Color(0xFFFBF3E7),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9CDB5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9CDB5)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF006972)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "We'll send a code via SMS to verify your number. "
                    'Carrier rates may apply.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A9188),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onContinue,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.2),
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