import 'dart:ui';

import 'package:flutter/material.dart';

class CompleteProfileDialog extends StatefulWidget {
  const CompleteProfileDialog({super.key});

  @override
  State<CompleteProfileDialog> createState() =>
      _CompleteProfileDialogState();
}

class _CompleteProfileDialogState
    extends State<CompleteProfileDialog>
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

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continueProfile() {
    Navigator.pop(context);

    // TODO:
    // Navigator.push(... ProfileCompletionScreen());
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
            filter: ImageFilter.blur(
              sigmaX: 7,
              sigmaY: 7,
            ),
            child: Container(
              color: Colors.black38,
            ),
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
                    color: const Color(0xffFFF9F3),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 30,
                        offset: Offset(0, 10),
                        color: Color(0x22000000),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge(),

                      const SizedBox(height: 18),

                      const Text(
                        "Complete Your Profile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "CormorantGaramond",
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff222222),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Complete your profile to unlock the full AKRILI experience and personalize your stays.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: Color(0xff707070),
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildIllustration(),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _continueProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff006972),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Continue Profile",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
                            side: const BorderSide(
                              color: Color(0xffD7D7D7),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            "Browse the App",
                            style: TextStyle(
                              color: Color(0xff222222),
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

  Widget _buildBadge() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xffF8E5B2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Color(0xffB8860B),
        size: 34,
      ),
    );
  }

  Widget _buildIllustration() {
  return SizedBox(
    height: 185,
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [

        CustomPaint(
          size: const Size(double.infinity, 185),
          painter: _DashedPathPainter(),
        ),

        Positioned(
          top: 20,
          left: 60,
          child: _circle(
            Icons.home_rounded,
            const Color(0xffD8F1F0),
            const Color(0xff006972),
          ),
        ),

        Positioned(
          top: 10,
          right: 55,
          child: _circle(
            Icons.favorite_rounded,
            const Color(0xffFDECC8),
            const Color(0xffC58A2A),
          ),
        ),

        Positioned(
          bottom: 15,
          left: 80,
          child: _circle(
            Icons.location_on_rounded,
            const Color(0xffFBE3E3),
            Colors.red,
          ),
        ),

        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: const Color(0xff006972),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
    ),
  );
}
Widget _circle(
  IconData icon,
  Color background,
  Color iconColor,
) {
  return Container(
    width: 52,
    height: 52,
    decoration: BoxDecoration(
      color: background,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 10,
        ),
      ],
    ),
    child: Icon(
      icon,
      color: iconColor,
      size: 24,
    ),
  );
}
}

class _DashedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffD8D8D8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    path.moveTo(90, 35);

    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width - 80,
      40,
    );

    path.moveTo(90, 35);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width - 80,
      40,
    );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(
      Canvas canvas,
      Path path,
      Paint paint,
      ) {
    const dash = 7.0;
    const gap = 6.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            distance + dash,
          ),
          paint,
        );

        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}