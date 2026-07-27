import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;

  static Future<void> sendCode({
    required String phoneNumber,
    required void Function() onCodeSent,
    required void Function(String error) onError,
  }) async {
    print('[FIREBASE] Starting phone verification for: $phoneNumber');

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('[FIREBASE] Auto-verification completed (Android instant verify)');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('[FIREBASE ERROR] Code: ${e.code} | Message: ${e.message}');
        onError(e.message ?? 'Verification failed (${e.code})');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('[FIREBASE] Code sent successfully. verificationId: $verificationId');
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('[FIREBASE] Auto-retrieval timeout. verificationId: $verificationId');
        _verificationId = verificationId;
      },
    );
  }

  static Future<String> verifyCode(String smsCode) async {
    print('[FIREBASE] Verifying code: $smsCode');

    if (_verificationId == null) {
      print('[FIREBASE ERROR] No verificationId in memory — cannot verify.');
      throw Exception('No verification in progress. Please request a new code.');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      print('[FIREBASE] Sign-in successful. UID: ${userCredential.user?.uid}');

      final idToken = await userCredential.user!.getIdToken();
      if (idToken == null) {
        print('[FIREBASE ERROR] getIdToken() returned null.');
        throw Exception('Failed to retrieve verification token.');
      }
      print('[FIREBASE] ID token retrieved (length: ${idToken.length})');
      return idToken;
    } on FirebaseAuthException catch (e) {
      print('[FIREBASE ERROR] Code: ${e.code} | Message: ${e.message}');
      throw Exception(e.message ?? 'Invalid code (${e.code})');
    }
  }
}