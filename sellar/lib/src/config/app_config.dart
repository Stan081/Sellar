import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
class AppConfig {
  static String get appName => dotenv.env['APP_NAME'] ?? 'Sellar';
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.sellar.com';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static String get logLevel => dotenv.env['LOG_LEVEL'] ?? 'info';

  // Debug mode
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
