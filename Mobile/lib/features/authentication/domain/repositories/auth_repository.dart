import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({required String emailOrPhone});

  Future<Either<Failure, void>> verifyCode({
    required String code,
    required String emailOrPhone,
  });

  Future<Either<Failure, void>> resendCode({required String emailOrPhone});

  Future<Either<Failure, void>> resetPassword({
    required String newPassword,
    required String verificationCode,
    required String emailOrPhone,
  });

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> refreshToken();

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
