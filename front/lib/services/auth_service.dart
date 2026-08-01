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

  // CHANGED: now returns Map<String, dynamic> instead of void
  static Future<Map<String, dynamic>> verifyOtp({
    required String token,
    required String target,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'target': target,
        'code': code,
        'purpose': 'signup',
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Invalid OTP code');
    }
    return data;
  }

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
<<<<<<< HEAD

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


=======
>>>>>>> origin/yacien-loginjdida
}