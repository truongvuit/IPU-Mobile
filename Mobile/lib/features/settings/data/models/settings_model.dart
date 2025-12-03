import '../../domain/entities/app_settings.dart';

class SettingsModel extends AppSettings {
  const SettingsModel({
    required super.isDarkMode,
    required super.textScale,
    required super.language,
    required super.pushNotificationsEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String? ?? 'vi',
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'textScale': textScale,
      'language': language,
      'pushNotificationsEnabled': pushNotificationsEnabled,
    };
  }

  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      isDarkMode: settings.isDarkMode,
      textScale: settings.textScale,
      language: settings.language,
      pushNotificationsEnabled: settings.pushNotificationsEnabled,
    );
  }
}
