import 'dart:ui';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Terms of Service',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Divider with icon
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD3C3BD),
                      thickness: 0.7,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.handyman_outlined,
                      color: const Color(0xFFB5451B),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      color: Color(0xFFD3C3BD),
                      thickness: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Dark pill container
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1B12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Accept these terms?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'HankenGrotesk',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006972),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
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
            ],
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
                      border: Border.all(
                          color: const Color(0xFFD3C3BD), width: 1),
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
                        color: const Color(0xFF4F4540),
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
                  color: const Color(0xFF81756F),
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
            const SizedBox(height: 16),

            // Section 01: Our Mission
            const _SectionTitle(number: '1', title: 'Our Mission'),
            const SizedBox(height: 16),
            const Text(
              'Andalus is dedicated to fostering authentic\nconnections between travelers and the rich\ncultural heritage of Algeria. Our mission is to\nfacilitate respectful, immersive, and\nsustainable tourism that benefits both the\ncurious explorer and the local communities\nwho serve as guardians of our traditions.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 12),
            const Text(
              'By using our platform, you join a community\ncommitted to the preservation of\narchitecture, gastronomy, and the spirit of\nhospitality that defines the Maghreb.',
              style: _bodyStyle,
            ),
            const SizedBox(height: 40),


            // Section 02: User Responsibilities
            const _SectionTitle(number: '2', title: 'User Responsibilities'),
            const SizedBox(height: 16),
            const Text(
              'As a guest or host on Andalus, you agree to:',
              style: _bodyStyle,
            ),
            const SizedBox(height: 16),
            const _CheckItem(
              text:
                  'Provide accurate, truthful information regarding your identity and property listings.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text:
                  'Respect the local laws, customs, and religious practices of the Algerian regions you visit.',
            ),
            const SizedBox(height: 12),
            const _CheckItem(
              text:
                  'Maintain the integrity of the heritage sites and private homes listed on our platform.',
            ),
            const SizedBox(height: 40),



            // Section 03: Booking Terms
            const _SectionTitle(number: '3', title: 'Booking Terms'),
            const SizedBox(height: 20),
            // Quote card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD3C3BD)),
              ),
              padding: const EdgeInsets.all(20),
              child: const Text(
                '"All bookings made through Andalus\nare legally binding agreements\nbetween the Guest and the Host."',
                style: TextStyle(
                  color: Color(0xFF4F4540),
                  fontSize: 17,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w400,
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
            const SizedBox(height: 40),


            // Section 04: Cancellations & Refunds
            const _SectionTitle(number: '4', title: 'Cancellations & Refunds'),
            const SizedBox(height: 20),

            // Standard Policy - teal background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Standard Policy',
                    style: TextStyle(
                      color: Color(0xFF006972),
                      fontSize: 20,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Full refund for cancellations made within 48\nhours of booking, provided the check-in date is at least 14 days away.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w400,
                      height: 1.625,
                    ),
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
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Late Cancellation',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 20,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '50% refund for cancellations made at least 7\ndays before check-in. No refunds for\ncancellations made within 7 days of arrival.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 15,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w400,
                      height: 1.625,
                    ),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String number;
  final String title;

  const _SectionTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            color: const Color(0xFFF3DDCD).withOpacity(0.5),
            fontSize: 48,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w500,
            height: 1.05,
            letterSpacing: -0.96,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2A1B12),
                fontSize: 28,
                fontFamily: 'CormorantGaramond',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 9.8),
            Container(
              height: 1,
              width: 120,
              color: const Color(0xFFF3DDCD),
            ),
          ],
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
          child: Text(text, style: _bodyStyle),
        ),
      ],
    );
  }
}

const TextStyle _bodyStyle = TextStyle(
  color: Color(0xFF4F4540),
  fontSize: 17,
  fontFamily: 'HankenGrotesk',
  fontWeight: FontWeight.w400,
  height: 1.625, // 27.63 / 17 = 1.625
);