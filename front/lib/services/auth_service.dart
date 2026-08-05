import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';
import 'dart:io';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['error'] ?? 'Registration failed');
    }
    return data;
  }

  static Future<Map<String, dynamic>> completeProfile({
    required String token,
    required String gender,
    required String birthday,
    required String wilaya,
    required String baladiya,
    required String fullAddress,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/complete-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'gender': gender,
        'birthday': birthday,
        'wilaya': wilaya,
        'baladiya': baladiya,
        'fullAddress': fullAddress,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Profile update failed');
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfilePhoto({
    required String token,
    required String profilePhotoUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/auth/profile-photo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'profilePhoto': profilePhotoUrl}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Photo update failed');
    }
    return data;
  }

  static Future<String> uploadToCloudinary(File imageFile) async {
    const cloudName = 'bcaeahkm';
    const uploadPreset = 'akrili_unsigned';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'];
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error']['message'] ?? 'Image upload failed');
    }
  }

  // ── OTP: Send code (requires auth token — used during signup) ──
  static Future<void> sendOtp({
    required String token,
    required String channel,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/send-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'channel': channel}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to send OTP');
    }
  }

  // ── OTP: Verify code ──
  static Future<Map<String, dynamic>> verifyOtp({
    String token = '',
    required String target,
    required String code,
    String purpose = 'signup',
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp'),
      headers: headers,
      body: jsonEncode({
        'target': target,
        'code': code,
        'purpose': purpose,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Invalid OTP code');
    }
    return data;
  }

  // ── Phone Login: Step 1 — send OTP to phone (no auth needed) ──
  static Future<void> loginWithPhone({
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to send login OTP');
    }
  }

  // ── Password Reset: Send OTP (no auth needed) ──
  static Future<void> sendResetOtp({
    String phone = '',
    String email = '',
    required String channel,
  }) async {
    final body = <String, String>{'channel': channel};
    if (channel == 'sms' && phone.isNotEmpty) {
      body['phone'] = phone;
    } else if (channel == 'email' && email.isNotEmpty) {
      body['email'] = email;
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/send-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Failed to send reset code');
    }
  }

  // ── Firebase Phone Verify (kept for backwards compat) ──
  static Future<Map<String, dynamic>> verifyFirebasePhone({
    required String token,
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-firebase-phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'idToken': idToken}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Phone verification failed');
    }
    return data;
  }

  // ── Email + Password Login ──
  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Login failed');
    }
    return data;
  }

  // ── Google Login ──
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String googleId,
    required String email,
    required String fullName,
    required String? profilePhoto,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'googleId': googleId,
        'email': email,
        'fullName': fullName,
        'profilePhoto': profilePhoto,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Google login failed');
    }
    return data;
  }

    static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['error'] ?? 'Password reset failed');
    }
  }

  static Future<Map<String, dynamic>> lookupRecovery(String identifier) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/lookup-recovery'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to look up account.');
    }
    return data;
  }
}