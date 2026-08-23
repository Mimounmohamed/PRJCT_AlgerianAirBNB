import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A1B12)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated
            const Text(
              'LAST UPDATED: OCTOBER 2025',
              style: TextStyle(
                color: Color(0xFF006972),
                fontSize: 11,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.14,
              ),
            ),
            const SizedBox(height: 12),
            // Title
            const Text(
              'Commitment to Your Privacy',
              style: TextStyle(
                color: Color(0xFF23130A),
                fontSize: 48,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Intro text
            const Text(
              'At Andalus, we believe that your journey\nacross Algeria should be as secure as it is\nbreathtaking. This Privacy Policy outlines our\ntransparent approach to handling your\npersonal data, ensuring that your heritage\n-rich experience remains private and\nprotected.',
              style: TextStyle(
                color: Color(0xFF4F4540),
                fontSize: 17,
                fontFamily: 'HankenGrotesk',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Section 1 - white card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SectionHeader(
                    icon: Icons.grid_view_rounded,
                    iconColor: Color(0xFF006972),
                    title: 'Data we collect',
                  ),
                  SizedBox(height: 20),
                  _DataItem(
                    title: 'Account Information',
                    description:
                        'We collect your name, email address, and phone number when you register for an account to facilitate authentic hospitality connections.',
                  ),
                  SizedBox(height: 16),
                  _DataItem(
                    title: 'Travel Preferences',
                    description:
                        'Information about your interest in specific Algerian regions, cultural guides, and stay types to personalize your editorial travel recommendations.',
                  ),
                  SizedBox(height: 16),
                  _DataItem(
                    title: 'Payment Details',
                    description:
                        'Transaction data is processed through secure, encrypted gateways. We do not store full credit card numbers on our local servers.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section 2
            const _SectionHeader(
              icon: Icons.location_on_outlined,
              iconColor: Color(0xFFB5451B),
              title: 'How we use your info',
            ),
            const SizedBox(height: 20),
            const _CheckItem(
              text:
                  'To process your bookings and provide seamless communication between guests and hosts.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text:
                  'To improve the Andalus platform experience based on user interactions and journey patterns.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text:
                  'To send cultural updates, curated guides, and important security notifications regarding your account.',
            ),
            const SizedBox(height: 32),

            // Section 3 - dark card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF3a271d),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.balance_outlined,
                          color: Colors.white70, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Your rights',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You maintain full sovereignty over your\npersonal digital footprint. Under our\nglobal data protection standards, you\nhave the right to:',
                    style: TextStyle(
                      color: Color(0xFFA98D7F),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _RightItem(
                      text: 'Access and download a copy of your personal data.'),
                  const SizedBox(height: 10),
                  const _RightItem(
                      text:
                          'Correct any inaccuracies in your profile information.'),
                  const SizedBox(height: 10),
                  const _RightItem(
                      text:
                          'Request the permanent deletion of your account and data.'),
                  const SizedBox(height: 10),
                  const _RightItem(
                      text:
                          'Opt out of non-essential marketing communications.'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006972),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 11, 24, 12.19),
                      ),
                      child: const Text(
                        'CONTACT PRIVACY OFFICER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: const [
                  Text(
                    'Have questions about our privacy practices?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF81756F),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'privacy@andalus.travel',
                    style: TextStyle(
                      color: Color(0xFF006972),
                      fontSize: 20,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF006972),
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
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 22,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DataItem extends StatelessWidget {
  final String title;
  final String description;

  const _DataItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF006972),
            fontSize: 15,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF4F4540),
            fontSize: 13,
            fontFamily: 'HankenGrotesk',
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline,
            color: Color(0xFF006972), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4F4540),
              fontSize: 13,
              fontFamily: 'HankenGrotesk',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _RightItem extends StatelessWidget {
  final String text;

  const _RightItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ',
            style: TextStyle(color: Color(0xFF98F0FB), fontSize:24)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFA98D7F),
              fontSize: 15,
              fontFamily: 'HankenGrotesk',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}