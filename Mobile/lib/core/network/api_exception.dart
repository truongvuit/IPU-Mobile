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

  
  factory ApiException.timeout({required String message}) {
    return ApiException(
      message: message,
      statusCode: 408,
      errorCode: 'TIMEOUT',
    );
  }

  
  factory ApiException.badRequest({required String message, dynamic data}) {
    return ApiException(
      message: message,
      statusCode: 400,
      errorCode: 'BAD_REQUEST',
      data: data,
    );
  }

  
  factory ApiException.unauthorized({required String message}) {
    return ApiException(
      message: message,
      statusCode: 401,
      errorCode: 'UNAUTHORIZED',
    );
  }

  
  factory ApiException.forbidden({required String message}) {
    return ApiException(
      message: message,
      statusCode: 403,
      errorCode: 'FORBIDDEN',
    );
  }

  
  factory ApiException.notFound({required String message}) {
    return ApiException(
      message: message,
      statusCode: 404,
      errorCode: 'NOT_FOUND',
    );
  }

  
  factory ApiException.serverError({required String message}) {
    return ApiException(
      message: message,
      statusCode: 500,
      errorCode: 'SERVER_ERROR',
    );
  }

  
  factory ApiException.noInternetConnection({required String message}) {
    return ApiException(message: message, errorCode: 'NO_INTERNET');
  }

  
  factory ApiException.requestCancelled({required String message}) {
    return ApiException(message: message, errorCode: 'REQUEST_CANCELLED');
  }

  
  factory ApiException.unknown({required String message}) {
    return ApiException(message: message, errorCode: 'UNKNOWN');
  }

  @override
  String toString() => 'ApiException: $message (${errorCode ?? 'UNKNOWN'})';
}
