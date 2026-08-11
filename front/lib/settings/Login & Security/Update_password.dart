import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
class UpdatePasswordScreen extends StatefulWidget {
  final String token;
  const UpdatePasswordScreen({super.key, required this.token});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _isLoading = false;

  bool get _hasMinLength => _newController.text.length >= 8;
  bool get _hasSpecialChar =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_newController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newController.text);

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasSpecialChar) score++;
    if (_hasNumber) score++;
    if (_newController.text.length >= 12) score++;
    return score;
  }

  String get _strengthLabel {
    if (_newController.text.isEmpty) return '';
    if (_strengthScore <= 1) return 'WEAK';
    if (_strengthScore <= 2) return 'MEDIUM';
    if (_strengthScore == 3) return 'STRONG';
    return 'VERY STRONG';
  }

  Color get _strengthColor {
    if (_strengthScore <= 1) return const Color(0xFFB5451B);
    if (_strengthScore <= 2) return const Color(0xFFD4A017);
    return const Color(0xFF006972);
  }

  @override
  void initState() {
    super.initState();
    _newController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AKRILI',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006972),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Update Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF23130A),
                fontSize: 24,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ensure your account stays secure by\nchoosing a strong, unique password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 15,
                fontFamily: 'HankenGrotesk',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // CURRENT PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: _FieldLabel('CURRENT PASSWORD'),
            ),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _currentController,
              hintText: '',
              obscureText: _obscureCurrent,
              onToggleObscure: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 24),

            // NEW PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: _FieldLabel('NEW PASSWORD'),
            ),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _newController,
              hintText: 'Enter new password',
              obscureText: _obscureNew,
              onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: List.generate(4, (index) {
                      final filled = index < _strengthScore;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: filled
                                ? _strengthColor
                                : const Color(0xFFE7DCCB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (_strengthLabel.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    _strengthLabel,
                    style: TextStyle(
                      color: _strengthColor,
                      fontSize: 11,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // CONFIRM NEW PASSWORD
            Align(
              alignment: Alignment.centerLeft,
              child: _FieldLabel('CONFIRM NEW PASSWORD'),
            ),
            const SizedBox(height: 8),
            _PlainPasswordField(
              controller: _confirmController,
              hintText: 'Repeat new password',
            ),
            const SizedBox(height: 24),

            // REQUIREMENTS
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REQUIREMENTS',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 11,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.54,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _RequirementRow(
                    label: 'Minimum 8 characters',
                    satisfied: _hasMinLength,
                  ),
                  const SizedBox(height: 12),
                  _RequirementRow(
                    label: 'Include a special character (!@#)',
                    satisfied: _hasSpecialChar,
                  ),
                  const SizedBox(height: 12),
                  _RequirementRow(
                    label: 'At least one number',
                    satisfied: _hasNumber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (_currentController.text.isEmpty) {
      _showMessage('Please enter your current password.');
      return;
    }
    if (!_hasMinLength || !_hasSpecialChar || !_hasNumber) {
      _showMessage('Your new password doesn\'t meet all requirements.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      _showMessage('New password and confirmation do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
          setState(() => _isLoading = true);
    try {
      await AuthService.updatePassword(
        token: widget.token,
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        confirmPassword: _confirmController.text,
      );
      if (!mounted) return;
      _showMessage('Password updated successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _showMessage('Password updated successfully.');
      Navigator.of(context).pop();
    } catch (e) {
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF4F4540),
        fontSize: 11,
        fontFamily: 'HankenGrotesk',
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggleObscure;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3C3BD), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Color(0xFF23130A),
          fontSize: 15,
          fontFamily: 'HankenGrotesk',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9B8C7E),
            fontSize: 15,
            fontFamily: 'HankenGrotesk',
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: const Color(0xFF9B8C7E),
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
        ),
      ),
    );
  }
}

class _PlainPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _PlainPasswordField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD3C3BD), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(
          color: Color(0xFF23130A),
          fontSize: 15,
          fontFamily: 'HankenGrotesk',
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF9B8C7E),
            fontSize: 15,
            fontFamily: 'HankenGrotesk',
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool satisfied;

  const _RequirementRow({required this.label, required this.satisfied});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: satisfied ? const Color(0xFF006972) : Colors.transparent,
            border: Border.all(
              color: satisfied ? const Color(0xFF006972) : const Color(0xFFD3C3BD),
              width: 1.5,
            ),
          ),
          child: satisfied
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: satisfied ? const Color(0xFF23130A) : const Color(0xFF4F4540),
            fontSize: 14,
            fontFamily: 'HankenGrotesk',
          ),
        ),
      ],
    );
  }
}