import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B2A22),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Logo
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF4A382E),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            // Title
            const Text(
              'AKRILI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontFamily: 'PlayfairDisplay', // serif font, add to pubspec
                letterSpacing: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            // Divider with star
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 0.7,
                  color: Colors.white24,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.star, color: Color(0xFF2E8B8B), size: 14),
                ),
                Container(
                  width: 60,
                  height: 0.7,
                  color: Colors.white24,
                ),
              ],
            ),
            const Spacer(flex: 4),
            // Tagline
            const Text(
              '"Stay where Algeria lives"',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'PlayfairDisplay',
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E8B8B),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}