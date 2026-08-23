import 'package:flutter/material.dart';

/// Colors sampled directly (pixel-picked) from the reference design so the
/// palette is consistent with the rest of the app / the Notifications screen.
class _C {
  static const pageBg = Color(0xFFFFF9EE);
  static const cardBg = Color(0xFFFFFCF6);
  static const border = Color(0xFFEFE6D6); // also used for footer bg + divider
  static const teal = Color(0xFF006972);
  static const darkText = Color(0xFF2A1B12);
  static const bodyText = Color(0xFF4F4540);
  static const mutedText = Color(0xFF9B8C7E);
  static const captionText = Color(0xFF81756F);
  static const badgeBg = Color(0xFF9CEEF7);
  static const authBannerBg = Color(0xFFE8F3F4);
  static const darkCardBg = Color(0xFF3A271D);
  static const warningBoxBg = Color(0xFF443229);
  static const warningIcon = Color(0xFFC1633D);
  static const darkCardBodyText = Color(0xFFA89684);
  static const successGreen = Color(0xFF2E9B6F);
  static const appbarIcon = Color(0xFF23130A);
}

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.pageBg,
      appBar: AppBar(
        backgroundColor: _C.pageBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _C.appbarIcon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _YourSafeJourneyCard(),
                  const SizedBox(height: 16),
                  _TwoStepCard(),
                  const SizedBox(height: 16),
                  _PasswordCard(),
                  const SizedBox(height: 16),
                  _DataControlCard(),
                  const SizedBox(height: 16),
                  _PhishingCard(),
                  const SizedBox(height: 16),
                  _QuoteImageCard(),
                  const SizedBox(height: 8),
                  const Divider(height: 33, thickness: 1, color: _C.border),
                  _StillHaveQuestions(),
                ],
              ),
            ),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// Shared card decoration used by the light cards.
BoxDecoration _cardDecoration() => BoxDecoration(
      color: _C.cardBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _C.border),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(58, 39, 29, 0.04),
          offset: Offset(0, 4),
          blurRadius: 20,
        ),
      ],
    );

class _YourSafeJourneyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _C.badgeBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield, color: _C.teal, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Safe Journey',
                      style: TextStyle(
                        color: Color(0xFF23130A),
                        fontSize: 24,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rooted in hospitality, secured by modern tech.',
                      style: TextStyle(
                        color: const Color(0xFF4F4540),
                        fontSize: 16,
                        fontFamily: 'HankenGrotesk',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'We believe your digital security is as important as'
            'your physical comfort. This '
            'guide outlines how we protect your '
            'personal data and how you can keep your '
            'account safe.',
            style: TextStyle(
              color: Color(0xFF1D1C15),
              fontSize: 14,
              fontFamily: 'HankenGrotesk',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoStepCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stylized "AUTHENTICATOR" banner graphic.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _C.authBannerBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'AUTH',
                  style: TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                Icon(Icons.lock, color: _C.teal, size: 20),
                Text(
                  'ICATOR',
                  style: TextStyle(
                    color: Color(0xFF006972),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Two-step verification',
            style: TextStyle(
              color: Color(0xFF23130A),
              fontSize: 20,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Why it matters: Even if someone gets"
            "your password, they can't access your"
            "account without the unique code sent"
            "only to your personal device. It adds an"
            "essential second layer of protection to"
            "your bookings and identity.",
            style: TextStyle(
              color: Color(0xFF4F4540),
              fontSize: 14,
              fontFamily: 'HankenGrotesk',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENABLE SECURITY LAYER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'HankenGrotesk',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: _C.teal, size: 20),
          const SizedBox(height: 10),
          const Text(
            'Protecting your password',
            style: TextStyle(
              color: Color(0xFF23130A),
              fontSize: 20,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use a unique passphrase of at least 12 characters. Avoid '
            'common dates or local landmarks. A strong password is your '
            'first line of defense against intruders.',
            style: TextStyle(
              color: _C.bodyText,
              fontSize: 14,
              fontFamily: 'HankenGrotesk',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.7, color: _C.border),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.check_circle_outline, color: _C.successGreen, size: 16),
              SizedBox(width: 6),
              Text(
                'UPDATED 30 DAYS AGO',
                style: TextStyle(
                  color: _C.captionText,
                  fontSize: 11,
                  fontFamily: 'HankenGrotesk',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataControlCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.people_outline, color: _C.teal, size: 20),
          const SizedBox(height: 10),
          const Text(
            'Data control',
            style: TextStyle(
              color: _C.darkText,
              fontSize: 16,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You own your information. At any time, you can request a '
            'download of your account data or exercise your right to be '
            'forgotten in accordance with regional privacy laws.',
            style: TextStyle(
              color: _C.bodyText,
              fontSize: 14,
              fontFamily: 'HankenGrotesk',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'VIEW PRIVACY RIGHTS',
                  style: TextStyle(
                    color: _C.teal,
                    fontSize: 12,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, color: _C.teal, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhishingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _C.darkCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Faded decorative watermark icon.
          Positioned(
            top: 12,
            right: 8,
            child: Opacity(
              opacity: 0.12,
              child: Icon(Icons.dangerous_outlined,
                  color: Colors.white, size: 64),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recognizing phishing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: _C.darkCardBodyText,
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(text: 'Stay vigilant. We will '),
                      TextSpan(
                        text: 'never',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' ask for your 2FA codes, password, or credit '
                            'card details over email or text. Phishing '
                            'attempts often use a false sense of urgency to '
                            'trick you.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.warningBoxBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: _C.warningIcon, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'If you receive a suspicious link claiming to be '
                          'from us, report it immediately to our security '
                          'team.',
                          style: TextStyle(
                            color: _C.darkCardBodyText.withOpacity(0.95),
                            fontSize: 13,
                            fontFamily: 'HankenGrotesk',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteImageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A8073), Color(0xFF554A40)],
        ),
      ),
      child: const Text(
        '"Hospitality begins with the peace of mind that you are '
        'protected."',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'CormorantGaramond',
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _StillHaveQuestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Still have questions?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _C.darkText,
            fontSize: 16,
            fontFamily: 'HankenGrotesk',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Our security experts are available 24/7 to help you secure '
          'your account or answer privacy concerns.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _C.bodyText,
            fontSize: 14,
            fontFamily: 'HankenGrotesk',
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _C.teal.withOpacity(0.75)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'VISIT HELP CENTER',
              style: TextStyle(
                color: _C.teal,
                fontSize: 13,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.cardBg,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: _C.border),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text(
              'CONTACT SECURITY TEAM',
              style: TextStyle(
                color: _C.darkText,
                fontSize: 13,
                fontFamily: 'HankenGrotesk',
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _C.border,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Container(width: 28, height: 1, color: _C.captionText.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'Last updated October 2023',
            style: TextStyle(
              color: _C.darkText,
              fontSize: 12,
              fontFamily: 'HankenGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2023 Andalus Travel. All rights reserved. Your privacy is '
            'our priority.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _C.captionText,
              fontSize: 11.5,
              fontFamily: 'HankenGrotesk',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}