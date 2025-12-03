import 'package:dartz/dartz.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<String, AppSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      return Left('Không thể tải cài đặt: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(model);
      return Right(settings);
    } catch (e) {
      return Left('Không thể lưu cài đặt: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, AppSettings>> resetToDefaults() async {
    try {
      await localDataSource.clearSettings();
      final defaults = await localDataSource.getSettings();
      return Right(defaults);
    } catch (e) {
      return Left('Không thể đặt lại cài đặt: ${e.toString()}');
    }
  }
}
