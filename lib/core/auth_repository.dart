import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/auth_user.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final http.Client _client;
  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 8);

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    final response = await _post(uri, {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    });

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ?? 'Registration failed',
      );
    }
  }

  Future<({String token, AuthUser user})> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final response = await _post(uri, {'email': email, 'password': password});
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        (body['error']?['message'] as String?) ?? 'Login failed',
      );
    }

    return (
      token: body['accessToken'] as String,
      user: AuthUser.fromJson(body['user'] as Map<String, dynamic>),
    );
  }

  Future<http.Response> _post(Uri uri, Map<String, dynamic> body) {
    return _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw ApiException(
            0,
            'Could not reach the server. Try again later.',
          ),
        );
  }
}
