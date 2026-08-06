import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../Login_email_or_phone.dart';
import '../../../services/auth_service.dart';


class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorText;
  bool _isLoading = false;
  bool _rateLimited = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _onBack() {
    Navigator.of(context).maybePop();
  }

    void _onResetPassword() async {
    if (_newPasswordController.text.isEmpty ||
        _newPasswordController.text.length < 8) {
      setState(() => _errorText = 'Password must be at least 8 characters.');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorText = "Passwords don't match.");
      return;
    }
    setState(() { _errorText = null; _isLoading = true; });

    try {
      await AuthService.resetPassword(
        email: widget.email,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginEmailOrPhoneScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');

      if (msg.contains('too many times')) {
        setState(() {
          _rateLimited = true;
          _errorText = 'You cannot change your password more than 2 times in 24 hours.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorText = msg;
          _isLoading = false;
        });
      }
    }
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
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
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB8AE9C)),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFFB0A48C),
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
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
              borderSide: const BorderSide(color: Color(0xFF006972)),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Set a new password',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your new password must be different from previously '
                'used passwords.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6B6B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _passwordField(
                label: 'New password',
                hint: '••••••••',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleObscure: () =>
                    setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 16),
              _passwordField(
                label: 'Confirm new password',
                hint: '••••••••',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Color(0xFFB3261E),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _rateLimited
                          ? () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginEmailOrPhoneScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          : _onResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rateLimited
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF006972),
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
                      : Text(
                          _rateLimited ? 'Back to login' : 'Reset password',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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