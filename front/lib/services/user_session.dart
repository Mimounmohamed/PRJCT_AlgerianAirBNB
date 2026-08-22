import 'package:flutter/foundation.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profilePhotoUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] as String? ?? '',
      name: json['fullName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePhotoUrl: json['profilePhoto'] as String?,
    );
  }

  AppUser copyWith({String? profilePhotoUrl}) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}

/// App-wide session store. No external package needed —
/// widgets react to it via ListenableBuilder.
class UserSession extends ChangeNotifier {
  UserSession._();
  static final UserSession instance = UserSession._();

  AppUser? _currentUser;
  String? _token;
  Map<String, dynamic>? _rawUser; // full JSON from backend

  AppUser? get currentUser => _currentUser;
  String? get token => _token;
  Map<String, dynamic>? get rawUser => _rawUser;

  void setUser(AppUser user, {String? token, Map<String, dynamic>? raw}) {
    _currentUser = user;
    if (token != null) _token = token;
    if (raw != null) _rawUser = raw;
    notifyListeners();
  }

  void updateProfilePhoto(String? url) {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      profilePhotoUrl: url,
    );
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _token = null;
    _rawUser = null;
    notifyListeners();
  }
}