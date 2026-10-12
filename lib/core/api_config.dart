import 'dart:io' show Platform;

class ApiConfig {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_baseUrl.isNotEmpty) return _baseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
    return 'http://localhost:3000/api/v1'; // iOS simulator, desktop
  }
}
