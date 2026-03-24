/// Base API exception class
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

/// Exception for network connectivity issues
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// Exception for server errors (5xx)
class ServerException extends ApiException {
  const ServerException(super.message, [super.statusCode]);
}

/// Exception for client errors (4xx)
class ClientException extends ApiException {
  const ClientException(super.message, [super.statusCode]);
}

/// Exception for authentication errors
class AuthException extends ApiException {
  const AuthException(String message) : super(message, 401);
}

/// Exception for validation errors
class ValidationException extends ApiException {
  final Map<String, String>? fieldErrors;

  const ValidationException(String message, [this.fieldErrors])
      : super(message, 400);

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      final errors =
          fieldErrors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return 'ValidationException: $message. Errors: $errors';
    }
    return 'ValidationException: $message';
  }
}

/// Exception for timeout errors
class TimeoutException extends ApiException {
  const TimeoutException(String message) : super(message, 408);
}

/// Exception for unexpected API responses
class UnexpectedResponseException extends ApiException {
  const UnexpectedResponseException(super.message, [super.statusCode]);
}
