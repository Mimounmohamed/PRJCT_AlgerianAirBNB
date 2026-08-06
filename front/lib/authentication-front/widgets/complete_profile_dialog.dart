import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CompleteProfileDialog extends StatefulWidget {
  const CompleteProfileDialog({super.key});

  @override
  State<CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

class _CompleteProfileDialogState extends State<CompleteProfileDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continueProfile() {
    Navigator.pop(context);
    // TODO: Navigate to your profile completion screen.
  }

  void _browseApp() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black38),
          ),
          Center(
            child: FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 360,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F3),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 25,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8E7B5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome,
                            color: Color(0xFFC58A2A), size: 34),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Complete Your Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Complete your profile to unlock the full AKRILI experience, personalize your account, and make booking or hosting easier.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SvgPicture.asset(
                        'assets/icons/Decorative_orbit.svg',
                        width: 220,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _continueProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006972),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'CONTINUE PROFILE',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _browseApp,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD8C9BC), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'BROWSE THE APP',
                            style: TextStyle(
                              color: Color(0xFF444444),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
