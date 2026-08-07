import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../authentication-front/Login_screens/courtyard.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String token;
  final String userName;
  final String memberSince;

  const DeleteAccountScreen({
    super.key,
    required this.token,
    this.userName = '',
    this.memberSince = '',
  });

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isConfirmed = false;
  bool _isDeleting = false;
  String _userName = '';
  String _memberSince = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isConfirmed = _controller.text.toUpperCase() == 'DELETE';
      });
    });
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    if (widget.userName.isNotEmpty) {
      setState(() {
        _userName = widget.userName;
        _memberSince = widget.memberSince;
      });
      return;
    }
    try {
      final data = await AuthService.getProfile(token: widget.token);
      if (!mounted) return;
      final createdAt = data['createdAt'] ?? '';
      String memberText = '';
      if (createdAt.isNotEmpty) {
        final date = DateTime.tryParse(createdAt);
        if (date != null) {
          const months = [
            '', 'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          memberText = 'Member since ${months[date.month]} ${date.year}';
        }
      }
      setState(() {
        _userName = data['fullName'] ?? 'User';
        _memberSince = memberText;
      });
    } catch (_) {}
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      await AuthService.deleteAccountPermanently(token: widget.token);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9EE),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'AKRILI',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF23130A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Main card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(20),
                border: const Border(
                  top: BorderSide(color: Color(0xFFB85C3A), width: 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Warning icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDAD6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFB23A3A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Delete your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 26,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  const Text(
                    'This action is permanent. All your bookings, travel history, and profile data will be permanently erased. This cannot be \nundone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // User card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF7EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD2C2BD)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFD2C2BD),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.isNotEmpty ? _userName : 'Loading...',
                              style: const TextStyle(
                                color: Color(0xFF23130A),
                                fontSize: 15,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _memberSince.isNotEmpty ? _memberSince : '',
                              style: const TextStyle(
                                color: Color(0xFF4F4540),
                                fontSize: 12,
                                fontFamily: 'HankenGrotesk',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Type DELETE label
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TYPE DELETE TO CONFIRM',
                      style: TextStyle(
                        color: Color(0xFF4F4540),
                        fontSize: 11,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.54,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Text field
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(
                        color: Color(0xFFD8CAC3),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                        letterSpacing: 2,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFBF7EF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD8CAC3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD8CAC3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFB85C3A)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delete Permanently button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isConfirmed && !_isDeleting
                          ? _deleteAccount
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isConfirmed
                            ? const Color(0xFFB85C3A)
                            : const Color(0xFFD99B98),
                        disabledBackgroundColor: const Color(0xFFD99B98),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Delete Permanently',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'HankenGrotesk',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Keep Account button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFA09690)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Keep Account',
                        style: TextStyle(
                          color: Color(0xFF23130A),
                          fontSize: 15,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3DDCD),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFB85C3A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3DDCD),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}