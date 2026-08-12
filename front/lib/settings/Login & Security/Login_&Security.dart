import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'Two_step_verif.dart';
import 'Delete_acc.dart';
import '../../services/auth_service.dart';
import 'Update_password.dart';

class LoginSecurityScreen extends StatefulWidget {
  final String token;
  const LoginSecurityScreen({super.key, required this.token});

  @override
  State<LoginSecurityScreen> createState() => _LoginSecurityScreenState();
}

class _LoginSecurityScreenState extends State<LoginSecurityScreen> {
  bool _twoStepEnabled = false;
  bool _isGoogleLinked = false;

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
        final google = data['socialAccounts']?['google'];
        _isGoogleLinked = google != null && google['id'] != null;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9EE),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Login & security',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 24,
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
            // Icon + description
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEFE6D6),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/security.svg',
                        width: 26,
                        height: 26,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF006972),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage your account protection and\nsign-in preferences.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 16,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // LOGIN section
            const Text(
              'LOGIN',
              style: TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.54,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Password card
              _SecurityCard(
                icon: Icons.key_outlined,
                iconColor: _isGoogleLinked
                    ? const Color(0xFF9B8C7E)
                    : const Color(0xFF2A1B12),
                title: 'Password',
                subtitle: _isGoogleLinked
                    ? 'Disconnect Google to manage password'
                    : 'Last updated 2 months ago',
                trailing: Icon(
                  Icons.chevron_right,
                  color: _isGoogleLinked
                      ? const Color(0xFF9B8C7E)
                      : const Color(0xFF23130A),
                ),
                onTap: () {
                  if (_isGoogleLinked) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFFFFFCF6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Google account linked',
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF23130A),
                          ),
                        ),
                        content: const Text(
                          'You\'re signed in with Google. To set or change your password, disconnect your Google account first.',
                          style: TextStyle(
                            fontFamily: 'HankenGrotesk',
                            fontSize: 14,
                            color: Color(0xFF4F4540),
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text(
                              'Got it',
                              style: TextStyle(
                                color: Color(0xFF006972),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePasswordScreen(
                          token: widget.token,
                        ),
                      ),
                    );
                  }
                },
              ),
            const SizedBox(height: 12),

            // Social accounts card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(58, 39, 29, 0.04),
                    offset: Offset(0, 4),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Color(0xFF2A1B12),
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Social accounts',
                        style: TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 16,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Google G icon
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Google connected',
                        style: TextStyle(
                          color: Color(0xFF4F4540),
                          fontSize: 14,
                          fontFamily: 'HankenGrotesk',
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showDisconnectGoogleSheet(context),
                        child: const Text(
                          'DISCONNECT',
                          style: TextStyle(
                            color: Color(0xFF006972),
                            fontSize: 11,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // SECURITY section
            const Text(
              'SECURITY',
              style: TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.54,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Two-step verification card
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TwoStepVerificationScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(58, 39, 29, 0.04),
                      offset: Offset(0, 4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Color(0xFF2A1B12),
                      size: 22,
                    ),
                    SizedBox(width: 19),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two-step verification',
                            style: TextStyle(
                              color: Color(0xFF23130A),
                              fontSize: 20,
                              fontFamily: 'HankenGrotesk',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Recommended for your safety',
                            style: TextStyle(
                              color: Color(0xFF4F4540),
                              fontSize: 14,
                              fontFamily: 'HankenGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF9B8C7E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Account deletion card
            _SecurityCard(
              icon: Icons.person_off_outlined,
              iconColor: const Color(0xFFB23A3A),
              title: 'Account deletion',
              titleColor: const Color(0xFFB23A3A),
              subtitle: 'Permanently close your account',
              trailing: const Icon(
                Icons.chevron_right,
                color: Color(0xFF9B8C7E),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeleteAccountScreen(
                      token: widget.token,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Info card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF006972), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Keeping your account secure is our top \npriority. We recommend changing your \npassword every 6 months and ensuring \ntwo-step verification is enabled.',
                      style: TextStyle(
                        color: Color(0xFF004F56),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                        height: 1.5,
                      ),
                    ),
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

  void _showDisconnectGoogleSheet(BuildContext context) {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFCF6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.fromLTRB(
              24, 32, 24,
              24 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3C3BD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Create a password',
                  style: TextStyle(
                    color: Color(0xFF23130A),
                    fontSize: 24,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need a password to log in after\ndisconnecting Google.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4F4540),
                    fontSize: 14,
                    fontFamily: 'HankenGrotesk',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    labelStyle: const TextStyle(color: Color(0xFF9B8C7E)),
                    filled: true,
                    fillColor: const Color(0xFFFBF7EF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006972)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    labelStyle: const TextStyle(color: Color(0xFF9B8C7E)),
                    filled: true,
                    fillColor: const Color(0xFFFBF7EF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD3C3BD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF006972)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setSheetState(() => isLoading = true);
                            try {
                              await AuthService.disconnectGoogle(
                                token: widget.token,
                                password: passwordController.text,
                                confirmPassword: confirmController.text,
                              );
                              if (!mounted) return;
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google disconnected. Use your email and password to log in.'),
                                ),
                              );
                              setState(() {});
                            } catch (e) {
                              setSheetState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString().replaceAll('Exception: ', '')),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB85C3A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Disconnect Google',
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD3C3BD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF23130A),
                        fontSize: 15,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    },
  );
}
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _SecurityCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEFE6D6), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(58, 39, 29, 0.04),
              offset: Offset(0, 4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? const Color(0xFF2A1B12),
                      fontSize: 16,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9B8C7E),
                      fontSize: 13,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}