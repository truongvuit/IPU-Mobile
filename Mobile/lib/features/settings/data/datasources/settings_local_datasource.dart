import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/settings_model.dart';

class SettingsLocalDataSource {
  final SharedPreferences _sharedPreferences;
  SettingsModel? _cachedSettings;

  static const SettingsModel _defaultSettings = SettingsModel(
    isDarkMode: false,
    textScale: 1.0,
    language: 'vi',
    pushNotificationsEnabled: true,
  );

  SettingsLocalDataSource({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  Future<SettingsModel> getSettings() async {
    
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    
    final settingsJson = _sharedPreferences.getString(AppConstants.keySettings);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _cachedSettings = SettingsModel.fromJson(json);
        return _cachedSettings!;
      } catch (e) {
        
        _cachedSettings = _defaultSettings;
        return _defaultSettings;
      }
    }

    
    _cachedSettings = _defaultSettings;
    return _defaultSettings;
  }

  Future<void> saveSettings(SettingsModel settings) async {
    _cachedSettings = settings;
    final settingsJson = jsonEncode(settings.toJson());
    await _sharedPreferences.setString(AppConstants.keySettings, settingsJson);
  }

  Future<void> clearSettings() async {
    _cachedSettings = null;
    await _sharedPreferences.remove(AppConstants.keySettings);
  }
}
