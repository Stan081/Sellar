import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sellar/src/constants/app_constants.dart';

/// Storage service for persisting data
class StorageService {
  late final SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== Shared Preferences ==========

  /// Save string value
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save int value
  Future<bool> setInt(String key, int value) async {
    return _prefs.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save bool value
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save double value
  Future<bool> setDouble(String key, double value) async {
    return _prefs.setDouble(key, value);
  }

  /// Get double value
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Save list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    return _prefs.setStringList(key, value);
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Remove a key
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  /// Clear all data
  Future<bool> clear() async {
    return _prefs.clear();
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ========== Secure Storage ==========

  /// Save secure string
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get secure string
  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  /// Remove secure key
  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clear all secure data
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // ========== Convenience Methods ==========

  /// Save user token (secure)
  Future<void> saveUserToken(String token) async {
    await setSecureString(AppConstants.userTokenKey, token);
  }

  /// Get user token (secure)
  Future<String?> getUserToken() async {
    return await getSecureString(AppConstants.userTokenKey);
  }

  /// Clear user token
  Future<void> clearUserToken() async {
    await removeSecure(AppConstants.userTokenKey);
  }

  /// Save user ID
  Future<bool> saveUserId(String userId) async {
    return setString(AppConstants.userIdKey, userId);
  }

  /// Get user ID
  String? getUserId() {
    return getString(AppConstants.userIdKey);
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    await clearUserToken();
    await remove(AppConstants.userIdKey);
  }
}
