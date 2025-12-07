import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_model.dart';
import '../models/student_profile_model.dart';
import '../models/student_class_model.dart';
import '../models/course_model.dart';

class StudentLocalDataSource {
  final SharedPreferences sharedPreferences;

  StudentLocalDataSource({required this.sharedPreferences});

  
  static const String _schedulesCacheKey = 'cached_schedules';
  static const String _schedulesTimestampKey = 'cached_schedules_timestamp';
  static const String _profileCacheKey = 'cached_profile';
  static const String _profileTimestampKey = 'cached_profile_timestamp';
  static const String _classesCacheKey = 'cached_classes';
  static const String _classesTimestampKey = 'cached_classes_timestamp';
  static const String _coursesCacheKey = 'cached_courses';
  static const String _coursesTimestampKey = 'cached_courses_timestamp';
  static const String _gradesCacheKey = 'cached_grades';
  static const String _gradesTimestampKey = 'cached_grades_timestamp';

  
  static const int _cacheTTLHours = 24; 
  static const int _scheduleCacheTTLDays = 7; 

  
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

    return difference.inDays < _scheduleCacheTTLDays;
  }

  
  Future<void> cacheProfile(StudentProfileModel profile) async {
    try {
      final jsonString = json.encode(profile.toJson());
      await sharedPreferences.setString(_profileCacheKey, jsonString);
      await sharedPreferences.setString(
        _profileTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache profile: $e');
    }
  }

  Future<StudentProfileModel?> getCachedProfile() async {
    try {
      final jsonString = sharedPreferences.getString(_profileCacheKey);
      if (jsonString == null) {
        return null;
      }
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return StudentProfileModel.fromJson(jsonMap);
    } catch (e) {
      await clearProfileCache();
      return null;
    }
  }

  bool isProfileCacheValid() {
    final timestampString = sharedPreferences.getString(_profileTimestampKey);
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final difference = DateTime.now().difference(timestamp);
      return difference.inHours < _cacheTTLHours;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearProfileCache() async {
    await sharedPreferences.remove(_profileCacheKey);
    await sharedPreferences.remove(_profileTimestampKey);
  }

  
  Future<void> cacheClasses(List<StudentClassModel> classes) async {
    try {
      final jsonList = classes.map((cls) => cls.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_classesCacheKey, jsonString);
      await sharedPreferences.setString(
        _classesTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache classes: $e');
    }
  }

  Future<List<StudentClassModel>?> getCachedClasses() async {
    try {
      final jsonString = sharedPreferences.getString(_classesCacheKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map(
            (json) => StudentClassModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      await clearClassesCache();
      return null;
    }
  }

  bool isClassesCacheValid() {
    final timestampString = sharedPreferences.getString(_classesTimestampKey);
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final difference = DateTime.now().difference(timestamp);
      return difference.inHours < _cacheTTLHours;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearClassesCache() async {
    await sharedPreferences.remove(_classesCacheKey);
    await sharedPreferences.remove(_classesTimestampKey);
  }

  
  Future<void> cacheCourses(List<CourseModel> courses) async {
    try {
      final jsonList = courses.map((course) => course.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_coursesCacheKey, jsonString);
      await sharedPreferences.setString(
        _coursesTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache courses: $e');
    }
  }

  Future<List<CourseModel>?> getCachedCourses() async {
    try {
      final jsonString = sharedPreferences.getString(_coursesCacheKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await clearCoursesCache();
      return null;
    }
  }

  bool isCoursesCacheValid() {
    final timestampString = sharedPreferences.getString(_coursesTimestampKey);
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final difference = DateTime.now().difference(timestamp);
      return difference.inHours < _cacheTTLHours;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCoursesCache() async {
    await sharedPreferences.remove(_coursesCacheKey);
    await sharedPreferences.remove(_coursesTimestampKey);
  }

  
  Future<void> cacheGrades(List<dynamic> grades) async {
    try {
      final jsonString = json.encode(grades);
      await sharedPreferences.setString(_gradesCacheKey, jsonString);
      await sharedPreferences.setString(
        _gradesTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to cache grades: $e');
    }
  }

  Future<List<dynamic>?> getCachedGrades() async {
    try {
      final jsonString = sharedPreferences.getString(_gradesCacheKey);
      if (jsonString == null) return null;
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      await clearGradesCache();
      return null;
    }
  }

  bool isGradesCacheValid() {
    final timestampString = sharedPreferences.getString(_gradesTimestampKey);
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final difference = DateTime.now().difference(timestamp);
      return difference.inHours < _cacheTTLHours;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearGradesCache() async {
    await sharedPreferences.remove(_gradesCacheKey);
    await sharedPreferences.remove(_gradesTimestampKey);
  }

  
  Future<void> clearAllCache() async {
    await clearScheduleCache();
    await clearProfileCache();
    await clearClassesCache();
    await clearCoursesCache();
    await clearGradesCache();
  }
}
