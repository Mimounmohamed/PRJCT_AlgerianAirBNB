import 'package:flutter/material.dart';
import 'signin_google.dart';
import 'package:flutter/gestures.dart';
import '../sign_in_screens/signUP_step1.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/courtyard.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF2A1B12).withOpacity(0.98),
                    const Color(0xFF2A1B12).withOpacity(0.75),
                    const Color(0xFF2A1B12).withOpacity(0.15),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'AKRILI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontFamily: 'CormorantGaramond',
                    letterSpacing: 3.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const Text(
                        'Find your Algerian\nhome.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'CormorantGaramond',
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Discover the warmth of local \n hospitality in stays that tell a story.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                          fontFamily: 'HenkenGrotesk',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue with phone
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                          label: const Text(
                            'Continue with phone',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'HenkenGrotesk',
                              fontWeight: FontWeight.w400,
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
                      const SizedBox(height: 14),

                      // OR divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 0.7,
                              color: Colors.white24,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                letterSpacing: 1.54,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 0.7,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 350),
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const GoogleSignInScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  final offsetAnimation = Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ));

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.g_mobiledata, size: 20, color: Colors.white),
                          label: const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'HenkenGrotesk',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Log in
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.login, size: 20, color: Colors.white),
                          label: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'HenkenGrotesk',
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Sign up
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: 'HenkenGrotesk',
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign up',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'HenkenGrotesk',
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration:
                                          const Duration(milliseconds: 350),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const SignUpStep1(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        final offsetAnimation = Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOutCubic,
                                        ));
                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Browse as guest
                      const Text(
                        'Browse as guest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'HenkenGrotesk',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Terms text
                      const Text(
                        "By continuing, you agree to Akrili's Terms of Service and \n Privacy Policy. Experience Algeria responsibly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
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