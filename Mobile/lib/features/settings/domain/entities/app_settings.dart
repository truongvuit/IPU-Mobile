import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool isDarkMode;
  final double textScale;
  final String language;
  final bool pushNotificationsEnabled;

  const AppSettings({
    required this.isDarkMode,
    required this.textScale,
    required this.language,
    required this.pushNotificationsEnabled,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    double? textScale,
    String? language,
    bool? pushNotificationsEnabled,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      textScale: textScale ?? this.textScale,
      language: language ?? this.language,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    isDarkMode,
    textScale,
    language,
    pushNotificationsEnabled,
  ];
}
