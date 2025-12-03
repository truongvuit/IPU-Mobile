import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';

class StudentLocalDataSource {
  final SharedPreferences sharedPreferences;

  StudentLocalDataSource({required this.sharedPreferences});

  static const String _schedulesCacheKey = 'cached_schedules';
  static const String _schedulesTimestampKey = 'cached_schedules_timestamp';

  Future<void> cacheSchedules(List<ScheduleModel> schedules) async {
    try {
      final jsonList = schedules.map((schedule) => schedule.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await sharedPreferences.setString(_schedulesCacheKey, jsonString);
      await sharedPreferences.setString(
        _schedulesTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache schedules: $e');
    }
  }

  Future<List<ScheduleModel>?> getCachedSchedules() async {
    try {
      final jsonString = sharedPreferences.getString(_schedulesCacheKey);

      if (jsonString == null) {
        return null;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await clearScheduleCache();
      return null;
    }
  }

  DateTime? getCacheTimestamp() {
    final timestampString = sharedPreferences.getString(_schedulesTimestampKey);
    if (timestampString == null) {
      return null;
    }

    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  bool hasCachedSchedules() {
    return sharedPreferences.containsKey(_schedulesCacheKey);
  }

  Future<void> clearScheduleCache() async {
    await sharedPreferences.remove(_schedulesCacheKey);
    await sharedPreferences.remove(_schedulesTimestampKey);
  }

  bool isCacheValid() {
    final timestamp = getCacheTimestamp();
    if (timestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    return difference.inDays < 7;
  }
}
