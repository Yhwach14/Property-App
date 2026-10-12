import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

class AuthSession {
  final String token;
  final AuthUser user;
  AuthSession({required this.token, required this.user});
}

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<AuthSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return null;
    return AuthSession(
      token: token,
      user: AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>),
    );
  }

  Future<void> save(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, session.token);
    await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
