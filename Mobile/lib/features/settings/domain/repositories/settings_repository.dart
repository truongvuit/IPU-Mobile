import 'package:dartz/dartz.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Either<String, AppSettings>> getSettings();

  Future<Either<String, AppSettings>> updateSettings(AppSettings settings);

  Future<Either<String, AppSettings>> resetToDefaults();
}
