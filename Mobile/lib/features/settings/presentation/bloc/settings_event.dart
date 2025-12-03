import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ToggleDarkMode extends SettingsEvent {
  final bool isDarkMode;

  const ToggleDarkMode(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class UpdateTextScale extends SettingsEvent {
  final double textScale;

  const UpdateTextScale(this.textScale);

  @override
  List<Object?> get props => [textScale];
}

class ChangeLanguage extends SettingsEvent {
  final String language;

  const ChangeLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class TogglePushNotifications extends SettingsEvent {
  final bool enabled;

  const TogglePushNotifications(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSettings extends SettingsEvent {
  final AppSettings settings;

  const UpdateSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ResetSettings extends SettingsEvent {
  const ResetSettings();
}
