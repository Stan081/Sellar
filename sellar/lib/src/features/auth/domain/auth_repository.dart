import 'package:sellar/src/constants/app_constants.dart';
import 'package:sellar/src/features/auth/data/models/vendor.dart';
import 'package:sellar/src/services/api_service.dart';
import 'package:sellar/src/services/storage_service.dart';

/// Repository for authentication operations
class AuthRepository {
  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  final ApiService _apiService;
  final StorageService _storageService;

  /// Register a new vendor account
  Future<Vendor> register({
    required String email,
    String? phone,
    required String password,
    required String businessName,
    required String firstName,
    required String lastName,
    required String country,
    String? currency,
  }) async {
    final response = await _apiService.post(
      AppConstants.authRegisterPath,
      data: {
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
        'businessName': businessName,
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
      },
    );

    if (response.statusCode == 201 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final vendorData = data['vendor'] as Map<String, dynamic>;

      // Save token and vendor ID
      await _storageService.saveUserToken(token);
      await _storageService.saveUserId(vendorData['id'] as String);

      // Set auth token in API service
      _apiService.setAuthToken(token);

      return Vendor.fromJson(vendorData);
    }

    throw Exception(response.data?['error'] ?? 'Registration failed');
  }

  /// Login with email/phone and password
  Future<Vendor> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.authLoginPath,
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final vendorData = data['vendor'] as Map<String, dynamic>;

        // Save token and vendor ID
        await _storageService.saveUserToken(token);
        await _storageService.saveUserId(vendorData['id'] as String);

        // Set auth token in API service
        _apiService.setAuthToken(token);

        return Vendor.fromJson(vendorData);
      }

      throw Exception(response.data?['error'] ?? 'Login failed');
    } catch (e) {
      // Re-throw API exceptions directly, otherwise wrap in generic exception
      if (e.toString().contains('ApiException')) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Get current vendor profile
  Future<Vendor> getProfile() async {
    final response = await _apiService.get(AppConstants.authProfilePath);

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>;
      return Vendor.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to fetch profile');
  }

  /// Update vendor profile
  Future<Vendor> updateProfile({
    String? businessName,
    String? firstName,
    String? lastName,
    String? phone,
    String? country,
    String? currency,
  }) async {
    final data = <String, dynamic>{};
    if (businessName != null) data['businessName'] = businessName;
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (country != null) data['country'] = country;
    if (currency != null) data['currency'] = currency;

    final response = await _apiService.put(
      AppConstants.authProfilePath,
      data: data,
    );

    if (response.statusCode == 200 && response.data != null) {
      final responseData = response.data['data'] as Map<String, dynamic>;
      return Vendor.fromJson(responseData);
    }

    throw Exception(response.data?['error'] ?? 'Failed to update profile');
  }

  /// Logout current user
  Future<void> logout() async {
    await _storageService.clearUserData();
    _apiService.clearAuthToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getUserToken();
    return token != null && token.isNotEmpty;
  }
}
