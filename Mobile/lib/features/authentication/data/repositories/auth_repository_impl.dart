import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiDataSource apiDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.apiDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final tokens = await apiDataSource.login(email, password);

      await localDataSource.saveTokens(tokens);

      UserModel userModel;
      try {
        userModel = await apiDataSource.getCurrentUser();
      } catch (_) {
        userModel = UserModel(
          id: tokens.userId ?? '0',
          email: email,
          role: tokens.role ?? 'student',
          isActive: true,
        );
      }

      await localDataSource.saveUser(userModel);
      await localDataSource.setRememberMe(rememberMe);

      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      
      try {
        await apiDataSource.logout();
      } catch (_) {
        
      }

      
      
      
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await localDataSource.setRememberMe(false);

      return const Right(null);
    } catch (e) {
      
      try {
        await localDataSource.clearTokens();
        await localDataSource.clearUser();
        await localDataSource.setRememberMe(false);
      } catch (_) {}
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await apiDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyResetCode({required String code}) async {
    try {
      final result = await apiDataSource.verifyResetCode(code);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode({required String email}) async {
    try {
      await apiDataSource.resendCode(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await apiDataSource.resetPassword(
        code: code,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        try {
          final remoteUser = await apiDataSource.getCurrentUser();
          await localDataSource.saveUser(remoteUser);
          return Right(remoteUser);
        } catch (_) {
          return Right(localUser);
        }
      }

      final tokens = await localDataSource.getTokens();
      if (tokens != null) {
        try {
          final remoteUser = await apiDataSource.getCurrentUser();
          await localDataSource.saveUser(remoteUser);
          return Right(remoteUser);
        } catch (_) {
          await localDataSource.clearTokens();
          await localDataSource.clearUser();
          return const Right(null);
        }
      }

      return const Right(null);
    } catch (e) {
      return const Left(
        CacheFailure(message: 'Lỗi khi lấy thông tin người dùng'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final tokens = await localDataSource.getTokens();
      if (tokens != null) {
        final newTokens = await apiDataSource.refreshToken(tokens.refreshToken);
        await localDataSource.saveTokens(newTokens);
        return const Right(null);
      }
      return const Left(CacheFailure(message: 'Không tìm thấy token'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await apiDataSource.changePassword(currentPassword, newPassword);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
