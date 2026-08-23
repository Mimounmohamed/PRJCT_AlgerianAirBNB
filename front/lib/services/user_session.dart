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

  // Adjust these keys once you confirm your Mongo document's field names.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] as String? ?? '',
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
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
  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  void setUser(AppUser user, {String? token}) {
    _currentUser = user;
    if (token != null) _token = token;
    notifyListeners();
  }

  void updateProfilePhoto(String url) {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = user.copyWith(profilePhotoUrl: url);
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }
}