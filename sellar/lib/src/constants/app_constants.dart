/// Application constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // API endpoints
  static const String apiVersion = 'v1';
  static const String authRegisterPath = '/api/auth/register';
  static const String authLoginPath = '/api/auth/login';
  static const String authProfilePath = '/api/auth/profile';
  static const String productsPath = '/api/products';
  static const String linksPath = '/api/links';
  static const String uploadImagePath = '/api/upload/image';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // Regular expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );
}
