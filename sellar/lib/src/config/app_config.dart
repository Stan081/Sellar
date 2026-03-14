import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration
class AppConfig {
  static String get appName => dotenv.env['APP_NAME'] ?? 'Sellar';
  static String get apiBaseUrl => dotenv.env['ENVIRONMENT'] == 'production'
      ? dotenv.env['API_BASE_URL'] ?? 'https://sellar-chi.vercel.app'
      : 'http://192.168.0.43:3001';
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
