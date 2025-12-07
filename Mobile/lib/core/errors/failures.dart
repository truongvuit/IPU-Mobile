import 'package:equatable/equatable.dart';


abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}


class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}


class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Không có kết nối mạng'});
}


class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Xác thực thất bại',
    super.code,
  });
}


class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Lỗi cache'});
}


class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
