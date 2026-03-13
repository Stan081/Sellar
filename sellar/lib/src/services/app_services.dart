import 'package:sellar/src/services/api_service.dart';
import 'package:sellar/src/services/storage_service.dart';

/// Simple service registry to initialize and expose core services.
class AppServices {
  AppServices._();

  static late final StorageService storage;
  static late final ApiService api;

  /// Initialize shared services and hydrate any persisted auth state.
  static Future<void> init() async {
    storage = StorageService();
    await storage.init();

    api = ApiService();

    final token = await storage.getUserToken();
    if (token != null && token.isNotEmpty) {
      api.setAuthToken(token);
    }
  }
}
