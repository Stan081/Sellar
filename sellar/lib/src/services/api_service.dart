import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:sellar/src/config/app_config.dart';
import 'package:sellar/src/constants/app_constants.dart';

/// API service for making HTTP requests
class ApiService {
  late final Dio _dio;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_loggingInterceptor());
  }

  /// Logging interceptor
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (AppConfig.isDebugMode) {
          _logger.i('REQUEST[${options.method}] => ${options.uri}');
          _logger.d('Headers: ${options.headers}');
          _logger.d('Data: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (AppConfig.isDebugMode) {
          _logger.i(
              'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          _logger.d('Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (AppConfig.isDebugMode) {
          _logger.e(
              'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          _logger.e('Message: ${error.message}');
        }
        return handler.next(error);
      },
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get the current raw JWT (without "Bearer " prefix), or null if not set.
  String? getAuthToken() {
    final header = _dio.options.headers['Authorization'] as String?;
    if (header == null || !header.startsWith('Bearer ')) return null;
    return header.substring(7);
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
