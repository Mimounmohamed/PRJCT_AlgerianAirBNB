import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
            // Legal document badge - centered
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 6),
                    decoration: BoxDecoration(
                      color: const Color(0x80FFFFFF),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: const Color(0xFFD3C3BD), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text(
                      'LEGAL DOCUMENT',
                      style: TextStyle(
                        color: Color(0xFF4F4540),
                        fontSize: 11,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Last Updated: October 24, 2023',
                style: TextStyle(
                  color: Color(0xFF81756F),
                  fontSize: 14,
                  fontFamily: 'HankenGrotesk',
                ),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 2,
                color: const Color(0xFFB5451B),
              ),
            ),
            const SizedBox(height: 8),

            // Section 01: Our Mission
            const _NumberedSectionTitle(number: '01', title: 'Our Mission'),
            const SizedBox(height: 12),
            const Text(
              'Andalus is dedicated to fostering authentic connections between travelers and the rich cultural heritage of Algeria. Our mission is to facilitate respectful, immersive, and sustainable tourism that benefits both the curious explorer and the local communities who serve as guardians of our traditions.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 12),
            const Text(
              'By using our platform, you join a community committed to the preservation of architecture, gastronomy, and the spirit of hospitality that defines the Maghreb.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 32),

            // Section 02: User Responsibilities
            const _NumberedSectionTitle(number: '02', title: 'User Responsibilities'),
            const SizedBox(height: 12),
            const Text(
              'As a guest or host on Andalus, you agree to:',
              style: _bodyStyle,
            ),
            const SizedBox(height: 16),
            const _CheckItem(
              text: 'Provide accurate, truthful information regarding your identity and property listings.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text: 'Respect the local laws, customs, and religious practices of the Algerian regions you visit.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text: 'Maintain the integrity of the heritage sites and private homes listed on our platform.',
            ),
            const SizedBox(height: 32),

            // Section 03: Booking Terms
            const _NumberedSectionTitle(number: '03', title: 'Booking Terms'),
            const SizedBox(height: 16),
            // Quote card
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
              padding: const EdgeInsets.all(20),
              child: const Text(
                '"All bookings made through Andalus are legally binding agreements between the Guest and the Host."',
                style: TextStyle(
                  color: Color(0xFF2A1B12),
                  fontSize: 16,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payments are processed securely through our authorized partners. A service fee is applied to each transaction to maintain the platform and support local heritage preservation initiatives. Hosts are responsible for ensuring their availability calendars are accurate at all times.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 32),

            // Section 04: Cancellations & Refunds
            const _NumberedSectionTitle(number: '04', title: 'Cancellations & Refunds'),
            const SizedBox(height: 20),

            // Standard Policy - teal background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F4),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Standard Policy',
                    style: TextStyle(
                      color: Color(0xFF006972),
                      fontSize: 16,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Full refund for cancellations made within 48 hours of booking, provided the check-in date is at least 14 days away.',
                    style: _bodyStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Late Cancellation
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EBDE),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Late Cancellation',
                    style: TextStyle(
                      color: Color(0xFF2A1B12),
                      fontSize: 16,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '50% refund for cancellations made at least 7 days before check-in. No refunds for cancellations made within 7 days of arrival.',
                    style: _bodyStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Special circumstances
            const Text(
              'Special circumstances, such as documentation of travel restrictions or emergencies, will be reviewed on a case-by-case basis by our support team.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 40),

            // Divider line
            Center(
              child: Container(
                width: 40,
                height: 2,
                color: const Color(0xFFD3C3BD),
              ),
            ),
            const SizedBox(height: 16),

            // Footer icon
            Center(
              child: SvgPicture.asset(
                'assets/icons/terms.svg',
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFB5451B),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Accept bar
            Center(
              child: Container(
              width: 350,
              height: 84,
              padding: const EdgeInsets.fromLTRB(24, 15, 16, 15),
              decoration: BoxDecoration(
                color: const Color(0xFF34251F),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Accept these terms?',
                      style: TextStyle(
                        color: Color(0xFFD3C3BD),
                        fontSize: 15,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006972),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Agree',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'HankenGrotesk',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _NumberedSectionTitle extends StatelessWidget {
  final String number;
  final String title;

  const _NumberedSectionTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Color(0xFFD3C3BD),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2A1B12),
            fontSize: 24,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
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
        const Icon(Icons.check_circle_outline, color: Color(0xFF006972), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: _bodyStyle,
          ),
        ),
      ],
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  color: Color(0xFF4F4540),
  fontSize: 14,
  fontFamily: 'HankenGrotesk',
  height: 1.6,
);