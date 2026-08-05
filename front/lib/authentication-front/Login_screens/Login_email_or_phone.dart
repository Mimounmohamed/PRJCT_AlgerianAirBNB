import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/app_bar.dart';
import '../sign_in_screens/signUP_step1.dart';
import 'OTP_ResetPass/reset_password_method.dart';
import '../../services/auth_service.dart';
import '../sign_in_screens/Mar7aban.dart';

class LoginEmailOrPhoneScreen extends StatefulWidget {
  const LoginEmailOrPhoneScreen({super.key});

  @override
  State<LoginEmailOrPhoneScreen> createState() =>
      _LoginEmailOrPhoneScreenState();
}

class _LoginEmailOrPhoneScreenState extends State<LoginEmailOrPhoneScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  bool _isLoading = false;

void _onLogin() async {
  final identifier = _identifierController.text.trim();
  final password = _passwordController.text.trim();

  if (identifier.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final data = await AuthService.loginWithEmail(
      email: identifier,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => WelcomeHomeScreen(
          userName: data['user']?['fullName'] ?? 'there',
          token: data['token'] ?? '',
        ),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  }
}

    void _onForgotPassword() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResetPasswordMethodScreen(
          maskedPhone: '+213 XXX XX XX XX',
          maskedEmail: identifier.replaceRange(1, identifier.indexOf('@'), '***'),
          realEmail: identifier,
        ),
      ),
    );
  }

  void _onSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignUpStep1()),
    );
  }

  Widget _labeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixOverride,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
            suffixIcon: suffixOverride,
            filled: true,
            fillColor: const Color(0xFFFBF3E7),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD9CDB5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F4C4C)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF3E7),
      appBar: AkriliAppBar(
        title: 'AKRILI',
        onBack: _onBack,
      ),
      body: Stack(
        children: [
          // Decorative star, bottom-left, sitting behind the content, slightly smaller and 10px higher than the right one.
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
                        Color(0xFF0F4C4C),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Log in',
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _labeledField(
                    label: 'Email or phone number',
                    hint: 'e.g. malek@andalus.com',
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _labeledField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixOverride: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFFB0A48C),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006972),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _onForgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Color(0xFF006972),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF6B6B6B),
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
                            style: const TextStyle(
                              color: Color(0xFFB5652B),
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _onSignUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}