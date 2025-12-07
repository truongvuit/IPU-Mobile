import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
    on<UpdateTextScale>(_onUpdateTextScale);
    on<ChangeLanguage>(_onChangeLanguage);
    on<TogglePushNotifications>(_onTogglePushNotifications);
    on<UpdateSettings>(_onUpdateSettings);
    on<ResetSettings>(_onResetSettings);
  }

  AppSettings? _getSettings(SettingsState state) {
    if (state is SettingsLoaded) return state.settings;
    if (state is SettingsUpdated) return state.settings;
    return null;
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await repository.getSettings();
    result.fold(
      (error) => emit(SettingsError(error)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getSettings(state);

    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        isDarkMode: event.isDarkMode,
      );

      final result = await repository.updateSettings(updatedSettings);
      result.fold(
        (error) {
          emit(SettingsError(error));
        },
        (settings) {
          emit(SettingsUpdated(settings));
        },
      );
    }
  }

  Future<void> _onUpdateTextScale(
    UpdateTextScale event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getSettings(state);
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        textScale: event.textScale,
      );
      final result = await repository.updateSettings(updatedSettings);
      result.fold(
        (error) => emit(SettingsError(error)),
        (settings) => emit(SettingsUpdated(settings)),
      );
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getSettings(state);
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        language: event.language,
      );
      final result = await repository.updateSettings(updatedSettings);
      result.fold(
        (error) => emit(SettingsError(error)),
        (settings) => emit(SettingsUpdated(settings)),
      );
    }
  }

  Future<void> _onTogglePushNotifications(
    TogglePushNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    final currentSettings = _getSettings(state);
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        pushNotificationsEnabled: event.enabled,
      );
      final result = await repository.updateSettings(updatedSettings);
      result.fold((error) => emit(SettingsError(error)), (settings) {
        emit(SettingsUpdated(settings));
      });
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await repository.updateSettings(event.settings);
    result.fold(
      (error) => emit(SettingsError(error)),
      (settings) => emit(SettingsUpdated(settings)),
    );
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    final result = await repository.resetToDefaults();
    result.fold(
      (error) => emit(SettingsError(error)),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }
}
