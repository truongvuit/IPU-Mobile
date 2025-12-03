import 'package:equatable/equatable.dart';

/// Base class cho tất cả các lỗi trong ứng dụng
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Lỗi từ server/API
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Lỗi kết nối mạng
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không có kết nối mạng'});
}

/// Lỗi xác thực (authentication)
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Xác thực thất bại',
    super.code,
  });
}

/// Lỗi cache/local storage
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi cache'});
}

/// Lỗi validation
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
