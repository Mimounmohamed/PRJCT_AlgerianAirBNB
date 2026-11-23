import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/firebase_options.dart';
import 'services/push_notification_service.dart';
import 'authentication-front/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Must register background handler before any other Firebase Messaging call
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Set up the local notification channel (Android) before runApp
  await initLocalNotifications();

  // Push tokens: starts once and follows the login session from here on,
  // so whichever account logs in (any login method) gets this phone's pushes.
  PushNotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algerian AirBNB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // AKRILI teal — also what default widgets (date/time pickers,
        // dialogs, chips without explicit colors) pick up.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006972)),
        // App body font. Titles set CormorantGaramond explicitly; every
        // other text (including widgets that don't set a font at all) uses
        // Hanken Grotesk instead of falling back to Roboto.
        fontFamily: 'HankenGrotesk',
        scaffoldBackgroundColor: const Color(0xFFFBF3E7),
        // Default dialogs match the app's cream popups.
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFBF3E7),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(color: Color(0xFF2A1B12), fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'HankenGrotesk'),
          contentTextStyle: const TextStyle(color: Color(0xFF8A7B6E), fontSize: 14, height: 1.4, fontFamily: 'HankenGrotesk'),
        ),
        // Any snackbar not created through AppToast still looks close to it.
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFBF3E7),
          contentTextStyle: const TextStyle(color: Color(0xFF2A1B12), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'HankenGrotesk'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE7DCCB)),
          ),
        ),
        // Material 3 tints and shades an app bar once content scrolls under
        // it, which turned every cream app bar a muddy grey/purple. Keep
        // app bars exactly the color each screen sets.
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
