class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  /// Timeout exception
  factory ApiException.timeout({required String message}) {
    return ApiException(
      message: message,
      statusCode: 408,
      errorCode: 'TIMEOUT',
    );
  }

  /// Bad request (400)
  factory ApiException.badRequest({required String message, dynamic data}) {
    return ApiException(
      message: message,
      statusCode: 400,
      errorCode: 'BAD_REQUEST',
      data: data,
    );
  }

  /// Unauthorized (401)
  factory ApiException.unauthorized({required String message}) {
    return ApiException(
      message: message,
      statusCode: 401,
      errorCode: 'UNAUTHORIZED',
    );
  }

  /// Forbidden (403)
  factory ApiException.forbidden({required String message}) {
    return ApiException(
      message: message,
      statusCode: 403,
      errorCode: 'FORBIDDEN',
    );
  }

  /// Not found (404)
  factory ApiException.notFound({required String message}) {
    return ApiException(
      message: message,
      statusCode: 404,
      errorCode: 'NOT_FOUND',
    );
  }

  /// Server error (500+)
  factory ApiException.serverError({required String message}) {
    return ApiException(
      message: message,
      statusCode: 500,
      errorCode: 'SERVER_ERROR',
    );
  }

  /// No internet connection
  factory ApiException.noInternetConnection({required String message}) {
    return ApiException(message: message, errorCode: 'NO_INTERNET');
  }

  /// Request cancelled
  factory ApiException.requestCancelled({required String message}) {
    return ApiException(message: message, errorCode: 'REQUEST_CANCELLED');
  }

  /// Unknown error
  factory ApiException.unknown({required String message}) {
    return ApiException(message: message, errorCode: 'UNKNOWN');
  }

  @override
  String toString() => 'ApiException: $message (${errorCode ?? 'UNKNOWN'})';
}
