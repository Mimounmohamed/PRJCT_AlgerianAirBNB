import 'package:flutter/material.dart';
import 'dart:async';
import '../onboarding_screens/discover.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3a271d),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                'assets/images/logo for main.png',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'AKRILI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontFamily: 'CormorantGaramond',
                letterSpacing: 6.4,
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
                  child: Icon(Icons.star, color: Color(0xFF006972), size: 19),
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
                fontSize: 24,
                fontFamily: 'CormorantGaramond',
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