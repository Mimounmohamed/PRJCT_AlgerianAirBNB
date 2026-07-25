import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_client.dart';

class AuthService {
  // Step 1: Register
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

  // Step 2: Complete Profile
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

  // Step 3: Update Profile Photo
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
}