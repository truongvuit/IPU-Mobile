/// Custom exceptions for the application
library;

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? " (code: $code)" : ""}';
}

/// Server/Backend exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
  
  @override
  String toString() => 'ServerException: $message${code != null ? " (code: $code)" : ""}';
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
  
  @override
  String toString() => 'CacheException: $message${code != null ? " (code: $code)" : ""}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
  
  @override
  String toString() => 'NetworkException: $message${code != null ? " (code: $code)" : ""}';
}

/// API-related exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(
    super.message, {
    this.statusCode,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? " (status: $statusCode)" : ""}${code != null ? " (code: $code)" : ""}';
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});

  @override
  String toString() => 'AuthException: $message${code != null ? " (code: $code)" : ""}';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.details,
  });

  @override
  String toString() =>
      'ValidationException: $message${fieldErrors != null ? " (fields: ${fieldErrors!.keys.join(", ")})" : ""}';
}

/// Data parsing exceptions
class ParsingException extends AppException {
  const ParsingException(super.message, {super.code, super.details});

  @override
  String toString() => 'ParsingException: $message${code != null ? " (code: $code)" : ""}';
}

/// Not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.details});

  @override
  String toString() => 'NotFoundException: $message${code != null ? " (code: $code)" : ""}';
}

/// Permission exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});

  @override
  String toString() => 'PermissionException: $message${code != null ? " (code: $code)" : ""}';
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.details});

  @override
  String toString() => 'TimeoutException: $message${code != null ? " (code: $code)" : ""}';
}
