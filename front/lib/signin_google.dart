import 'package:flutter/material.dart';

class GoogleSignInScreen extends StatelessWidget {
  const GoogleSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/google.png',
              fit: BoxFit.cover,
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'AKRILI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: 'CormorantGaramond',
                        letterSpacing: 3.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          // Bottom card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448,maxHeight: 395,),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF6EF),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3F4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          color: Color(0xFF006972),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Color(0xFF2A1B12),
                          fontSize: 28,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      const Text(
                        'Use your Google account to securely\n access your AKRILI journeys and\n authentic stays.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B5D52),
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Continue with Google button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'G',
                              style: TextStyle(
                                color: Color(0xFF006972),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006972),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Terms
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: Color(0xFF81756F),
                            fontSize: 11,
                            height: 1.5,
                            fontFamily: 'HenkenGothic',
                            letterSpacing: 2,
                            decorationStyle: TextDecorationStyle.solid,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(text: "By continuing, you agree to Akrili's\n "),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Color(0xFF006972),
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' and Privacy Policy.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}