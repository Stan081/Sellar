import 'package:dio/dio.dart';
import '../exceptions/api_exceptions.dart';

/// Utility class to handle API errors and convert them to appropriate exceptions
class ErrorHandler {
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ApiException) {
      return error;
    } else {
      return UnexpectedResponseException(error.toString());
    }
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException(
            'Request timed out. Please check your connection and try again.');

      case DioExceptionType.connectionError:
        return const NetworkException(
            'No internet connection. Please check your network settings.');

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return const UnexpectedResponseException('Request was cancelled.');

      case DioExceptionType.unknown:
        return const UnexpectedResponseException(
            'An unexpected error occurred. Please try again.');

      default:
        return UnexpectedResponseException(
            error.message ?? 'Unknown error occurred.');
    }
  }

  static ApiException _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Something went wrong';
    Map<String, String>? fieldErrors;

    // Extract error message from response data
    if (responseData is Map<String, dynamic>) {
      message = responseData['error'] ?? responseData['message'] ?? message;

      // Handle validation errors with field-specific messages
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        fieldErrors = Map<String, String>.from(
          (responseData['errors'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        );
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message, fieldErrors);
      case 401:
        return AuthException(message);
      case 403:
        return const ClientException(
            'Access forbidden. You don\'t have permission to perform this action.');
      case 404:
        return const ClientException('The requested resource was not found.');
      case 422:
        return ValidationException(message, fieldErrors);
      case 429:
        return const ClientException(
            'Too many requests. Please try again later.');
      case 500:
        return const ServerException(
            'Internal server error. Please try again later.');
      case 502:
        return const ServerException(
            'Server is temporarily unavailable. Please try again later.');
      case 503:
        return const ServerException(
            'Service unavailable. Please try again later.');
      default:
        return UnexpectedResponseException(message, statusCode);
    }
  }

  /// Get user-friendly error message for display
  static String getUserMessage(ApiException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return '📶 No internet connection. Please check your network and try again.';
      case TimeoutException:
        return '⏰ Request timed out. Please try again.';
      case ServerException:
        return '🔧 Server error. Please try again in a few moments.';
      case AuthException:
        return '🔐 Authentication failed. Please check your credentials.';
      case ValidationException:
        final validationException = exception as ValidationException;
        if (validationException.fieldErrors != null &&
            validationException.fieldErrors!.isNotEmpty) {
          return '⚠️ ${validationException.fieldErrors!.values.first}';
        }
        return '⚠️ ${exception.message}';
      case ClientException:
        return '⚠️ ${exception.message}';
      default:
        return '❌ ${exception.message}';
    }
  }
}
