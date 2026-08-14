import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF23130A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Andalus',
          style: TextStyle(
            color: Color(0xFF23130A),
            fontSize: 28,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HOW IT WORKS label
            const Center(
              child: Text(
                'HOW IT WORKS',
                style: TextStyle(
                  color: Color(0xFF006972),
                  fontSize: 11,
                  fontFamily: 'HankenGrotesk',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.54,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Your Journey to the Heart of Algeria',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF3A271D),
                    fontSize: 28,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Discover a seamless way to explore\n authentic stays and local culture across\n the Maghreb.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4F4540),
                    fontSize: 15,
                    fontFamily: 'HankenGrotesk',
                    height: 1.6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Step 1
            _StepSection(
              stepNumber: 'STEP #1',
              title: '\t\t\t\t1. Discover',
              image: 'assets/images/discoverAlgeria.png',
              description:
                  'Browse our hand-picked collection of Riads, desert camps, and heritage homes. Filter by region, experience, or host expertise to find your perfect sanctuary.',
              svgIcon: 'assets/icons/discover.svg',
              iconColor: const Color(0xFF006972),
            ),

            // Step 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF006972).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/confidence.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF006972),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'STEP #2',
                        style: TextStyle(
                          color: Color(0xFF006972),
                          fontSize: 10,
                          fontFamily: 'IBMPlexSans',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2. Book with Confidence',
                    style: TextStyle(
                      color: Color(0xFF23130A),
                      fontSize: 26,
                      fontFamily: 'CormorantGaramond',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Authenticity Guaranteed card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: Color(0xFF006972), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Authenticity Guaranteed',
                                style: TextStyle(
                                  color: Color(0xFF006972),
                                  fontSize: 14,
                                  fontFamily: 'HankenGrotesk',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Every stay and guide is verified by our local curation team to ensure a premium, respectful cultural experience.',
                                style: TextStyle(
                                  color: Color(0xFF4F4540),
                                  fontSize: 13,
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
                  const SizedBox(height: 16),
                  const Text(
                    'Secure your dates with our protected payment system. Message hosts directly to customize your itinerary or request traditional meals.',
                    style: TextStyle(
                      color: Color(0xFF4F4540),
                      fontSize: 14,
                      fontFamily: 'HankenGrotesk',
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Step 3
            _StepSection(
              stepNumber: 'STEP #3',
              title: '3. Experience Algeria',
              image: 'assets/images/authentically.png',
              description:
                  'Arrive at your destination and immerse yourself in Algerian hospitality. From guided Casbah tours to Saharan stargazing, your host is your gateway to local life.',
              svgIcon: 'assets/icons/experience.svg',
              iconColor: Colors.white,
              showWatchFilm: true,
            ),

            const SizedBox(height: 40),

            // Ready to start section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EBDE),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  children: [
                    const Text(
                      'Ready to start your adventure?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF23130A),
                        fontSize: 28,
                        fontFamily: 'CormorantGaramond',
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Join thousands of travelers discovering the hidden gems of North Africa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4F4540),
                        fontSize: 14,
                        fontFamily: 'HankenGrotesk',
                        height: 1.6,
                      ),
                    ),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'EXPLORE STAYS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'ANDALUS EXPERIENCE © 2024',
                    style: TextStyle(
                      color: Color(0xFF9B8C7E),
                      fontSize: 10,
                      fontFamily: 'HankenGrotesk',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.help_outline, color: Color(0xFF4F4540), size: 20),
                      SizedBox(width: 20),
                      Icon(Icons.mail_outline, color: Color(0xFF4F4540), size: 20),
                      SizedBox(width: 20),
                      Icon(Icons.share_outlined, color: Color(0xFF4F4540), size: 20),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepSection extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String image;
  final String description;
  final IconData? icon;
  final String? svgIcon;
  final Color iconColor;
  final bool showWatchFilm;

  const _StepSection({
    required this.stepNumber,
    required this.title,
    required this.image,
    required this.description,
    this.icon,
    this.svgIcon,
    required this.iconColor,
    this.showWatchFilm = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF006972).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: svgIcon != null
                    ? Center(
                        child: SvgPicture.asset(
                          svgIcon!,
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF006972),
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : Icon(icon, color: const Color(0xFF006972), size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                stepNumber,
                style: const TextStyle(
                  color: Color(0xFF006972),
                  fontSize: 10,
                  fontFamily: 'IBMPlexSans',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF23130A),
              fontSize: 26,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                if (showWatchFilm)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'WATCH FILM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontFamily: 'HankenGrotesk',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF4F4540),
              fontSize: 14,
              fontFamily: 'HankenGrotesk',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}