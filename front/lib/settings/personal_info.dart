import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../authentication-front/Login_screens/courtyard.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String token;
  const PersonalInfoScreen({super.key, required this.token});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isLoading = true;
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  bool _identityVerified = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService.getProfile(token: widget.token);
      if (!mounted) return;
      setState(() {
        _fullName = data['fullName'] ?? '';
        _email = data['email'] ?? '';
        _phone = data['phone'] != null
            ? '${data['phone']['countryCode'] ?? '+213'} ${data['phone']['number'] ?? ''}'
            : '';
        _address = data['fullAddress'] ?? '';
        _identityVerified = data['identityVerified'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _saveField(String fieldName, String value) async {
    try {
      await AuthService.updateProfile(
        token: widget.token,
        fields: {fieldName: value},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _deactivateAccount() async {
    try {
      await AuthService.deactivateAccount(token: widget.token);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9EE),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Personal info',
            style: TextStyle(
              color: Color(0xFF23130A),
              fontSize: 28,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF006972)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Personal info',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro text
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Color(0xFF4F4540),
                  fontSize: 16,
                  fontFamily: 'HankenGrotesk',
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text:
                        'Update your details and how we can reach you. This information is kept private as per our \n',
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Color(0xFF006972),
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF006972),
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Legal Name
            _InfoField(
              label: 'LEGAL NAME',
              initialValue: _fullName,
              onChanged: (newValue) => _saveField('fullName', newValue),
            ),
            const SizedBox(height: 16),

            // Email Address
            _InfoField(
              label: 'EMAIL ADDRESS',
              initialValue: _email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (newValue) => _saveField('email', newValue),
            ),
            const SizedBox(height: 16),

            // Phone Number
            _InfoField(
            label: 'PHONE NUMBER',
            initialValue: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (newValue) => _savePhone(newValue),
          ),
            const SizedBox(height: 16),

            // Emergency Contact
            _InfoFieldWithBadge(
              label: 'EMERGENCY CONTACT',
              actionLabel: 'Add',
              onAction: () {},
              badge: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF7EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD3C3BD)),
                ),
                child: const Text(
                  'Not provided',
                  style: TextStyle(
                    color: Color(0xFFB5A89E),
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            _InfoField(
              label: 'ADDRESS',
              initialValue: _address,
              maxLines: 2,
              onChanged: (newValue) => _saveField('fullAddress', newValue),
            ),
            const SizedBox(height: 24),

            // Identity verified card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCDE6E8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _identityVerified
                          ? const Color(0xFF006972).withOpacity(0.1)
                          : const Color(0xFFB5451B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _identityVerified ? Icons.shield_outlined : Icons.warning_amber_rounded,
                      color: _identityVerified ? const Color(0xFF006972) : const Color(0xFFB5451B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _identityVerified ? 'Identity verified' : 'Identity not verified',
                          style: const TextStyle(
                            color: Color(0xFF23130A),
                            fontSize: 20,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _identityVerified
                              ? 'Your identity has been verified through \nyour government-issued ID. This helps \nbuild trust within the AKRILI\ncommunity.'
                              : 'Verify your identity to build trust\nwithin the AKRILI community.',
                          style: const TextStyle(
                            color: Color(0xFF4F4540),
                            fontSize: 14,
                            fontFamily: 'HankenGrotesk',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Divider(
              color: Color(0xFFD3C3BD),
              thickness: 0.7,
              height: 20,
            ),

            // Deactivate account
            TextButton.icon(
              onPressed: () => _showDeactivateSheet(context),
              icon: const Icon(
                Icons.person_off_outlined,
                color: Color(0xFFB5451B),
                size: 18,
              ),
              label: const Text(
                'Deactivate account',
                style: TextStyle(
                  color: Color(0xFFB23A3A),
                  fontSize: 16,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeactivateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFCF6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD3C3BD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBE4E4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  color: Color(0xFFB23A3A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Deactivate your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF23130A),
                  fontSize: 28,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This will hide your profile and listings.\nYou can reactivate at any time by logging back in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4F4540),
                  fontSize: 17,
                  fontFamily: 'HankenGrotesk',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deactivateAccount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB23A3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Deactivate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD3C3BD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Keep my account',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 20,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ACTION CANNOT BE UNDONE AUTOMATICALLY',
                style: TextStyle(
                  color: Color(0xFF81756F),
                  fontSize: 11,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePhone(String value) async {
  try {
    final cleaned = value.replaceAll(' ', '').replaceAll('+213', '');
    await AuthService.updateProfile(
      token: widget.token,
      fields: {
        'phone': {
          'countryCode': '+213',
          'number': cleaned,
        }
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone updated successfully')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  }
}
}

/// A labeled field that toggles between read-only and editable.
class _InfoField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;

  const _InfoField({
    required this.label,
    required this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  State<_InfoField> createState() => _InfoFieldState();
}

class _InfoFieldState extends State<_InfoField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _InfoField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && !_isEditing) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    if (widget.readOnly) return;
    setState(() {
      if (_isEditing) {
        _isEditing = false;
        widget.onChanged?.call(_controller.text);
        _focusNode.unfocus();
      } else {
        _isEditing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 1.54,
              ),
            ),
            if (!widget.readOnly)
              GestureDetector(
                onTap: _toggleEditing,
                child: Text(
                  _isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF7EF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isEditing ? const Color(0xFF006972) : const Color(0xFFD3C3BD),
              width: _isEditing ? 1.4 : 1,
            ),
          ),
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  onSubmitted: (_) => _toggleEditing(),
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    color: Color(0xFF2A1B12),
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                )
              : Text(
                  _controller.text.isEmpty ? 'Not provided' : _controller.text,
                  style: TextStyle(
                    color: _controller.text.isEmpty
                        ? const Color(0xFFB5A89E)
                        : const Color(0xFF2A1B12),
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                  ),
                ),
        ),
      ],
    );
  }
}

class _InfoFieldWithBadge extends StatelessWidget {
  final String label;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget badge;

  const _InfoFieldWithBadge({
    required this.label,
    required this.actionLabel,
    required this.onAction,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 1.54,
              ),
            ),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFF006972),
                  fontSize: 14,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w500,
                  height: 20 / 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        badge,
      ],
    );
  }
}