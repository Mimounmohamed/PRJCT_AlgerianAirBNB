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
