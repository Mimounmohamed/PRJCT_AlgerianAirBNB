import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/app_bar.dart';
import '../sign_in_screens/signUP_step1.dart';
import 'OTP_ResetPass/reset_password_method.dart';
import '../../services/auth_service.dart';
import '../../services/user_session.dart';
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
  bool _isLoading = false;

  String? _identifierError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onBack() {
    Navigator.of(context).maybePop();
  }

  void _onLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _identifierError =
          identifier.isEmpty ? 'Email or phone number is required' : null;
      _passwordError = password.isEmpty ? 'Password is required' : null;
      _generalError = null;
    });

    if (_identifierError != null || _passwordError != null) {
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

      // Populate the app-wide session with the logged-in user
      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        UserSession.instance.setUser(AppUser.fromJson(userJson));
      }

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
      setState(() {
        _isLoading = false;
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _onForgotPassword() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      setState(() {
        _identifierError = 'Please enter your email or phone number first';
        _generalError = null;
      });
      return;
    }

    setState(() {
      _identifierError = null;
      _generalError = null;
      _isLoading = true;
    });

    try {
      // Calls the database to lookup user data and fetch the exact masked elements
      final data = await AuthService.lookupRecovery(identifier);

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordMethodScreen(
            maskedPhone: data['maskedPhone'] ?? '',
            maskedEmail: data['maskedEmail'] ?? '',
            realPhone: data['realPhone'] ?? '',
            realEmail: data['realEmail'] ?? '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generalError = e.toString().replaceAll('Exception: ', '');
      });
    }
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
    String? errorText,
    VoidCallback? onChanged,
  }) {
    final hasError = errorText != null;
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
          onChanged: (_) => onChanged?.call(),
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
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFD9CDB5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFFD9CDB5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF0F4C4C),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
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
                  if (_generalError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _generalError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _labeledField(
                    label: 'Email or phone number',
                    hint: 'e.g. malek@andalus.com',
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _identifierError,
                    onChanged: () => setState(() => _identifierError = null),
                  ),
                  const SizedBox(height: 16),
                  _labeledField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    errorText: _passwordError,
                    onChanged: () => setState(() => _passwordError = null),
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
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF006972)),
              ),
            ),
        ],
      ),
    );
  }
}