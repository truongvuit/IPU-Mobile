import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/teacher_profile_model.dart';
import '../models/teacher_class_model.dart';
import '../models/teacher_schedule_model.dart';
import '../models/teacher_student_model.dart';

abstract class TeacherApiDataSource {
  Future<TeacherProfileModel> getProfile();
  Future<List<TeacherClassModel>> getMyClasses();
  Future<List<TeacherScheduleModel>> getWeekSchedule(DateTime date);
  Future<List<TeacherStudentModel>> getClassStudents(int classId);
  Future<TeacherClassModel> getClassDetail(int classId);
  Future<void> submitAttendance(
    int sessionId,
    List<Map<String, dynamic>> attendances,
  );
}

class TeacherApiDataSourceImpl implements TeacherApiDataSource {
  final DioClient dioClient;
  int? _cachedLecturerId;

  TeacherApiDataSourceImpl({required this.dioClient});

  Future<int> _getLecturerId() async {
    if (_cachedLecturerId != null) return _cachedLecturerId!;

    final profile = await getProfile();
    _cachedLecturerId = int.tryParse(profile.id) ?? 0;
    return _cachedLecturerId!;
  }

  @override
  Future<TeacherProfileModel> getProfile() async {
    try {
      final response = await dioClient.get(ApiEndpoints.teacherProfile);
      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return TeacherProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Get profile failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<List<TeacherClassModel>> getMyClasses() async {
    try {
      final lecturerId = await _getLecturerId();
      final response = await dioClient.get(
        ApiEndpoints.teacherClasses,
        queryParameters: {'lecturerId': lecturerId, 'page': 1, 'size': 100},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> classes = data['classes'] ?? data ?? [];
        return classes.map((json) => TeacherClassModel.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Get classes failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<List<TeacherScheduleModel>> getWeekSchedule(DateTime date) async {
    try {
      final lecturerId = await _getLecturerId();
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await dioClient.get(
        ApiEndpoints.teacherSchedule,
        queryParameters: {'lecturerId': lecturerId, 'date': dateStr},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        final List<TeacherScheduleModel> schedules = [];
        
        // Parse WeeklyScheduleResponse structure: days -> periods -> sessions
        final List<dynamic> days = data['days'] ?? [];
        for (final day in days) {
          final sessionDate = day['date'] as String?;
          final List<dynamic> periods = day['periods'] ?? [];
          
          for (final period in periods) {
            final List<dynamic> sessions = period['sessions'] ?? [];
            
            for (final session in sessions) {
              // Get class details for startTime/endTime from courseClass
              final classId = session['classId']?.toString() ?? '';
              
              // Parse start time from course class startTime + sessionDate
              DateTime startTime = DateTime.now();
              DateTime endTime = DateTime.now().add(const Duration(hours: 1));
              
              if (sessionDate != null) {
                final dateOnly = DateTime.parse(sessionDate);
                // Get time from class startTime if available
                final startTimeStr = session['startTime'] as String?;
                if (startTimeStr != null) {
                  final timeParts = startTimeStr.split(':');
                  if (timeParts.length >= 2) {
                    startTime = DateTime(
                      dateOnly.year,
                      dateOnly.month,
                      dateOnly.day,
                      int.tryParse(timeParts[0]) ?? 0,
                      int.tryParse(timeParts[1]) ?? 0,
                    );
                  }
                } else {
                  startTime = dateOnly;
                }
                
                // Calculate endTime from duration or default 1 hour
                final durationMinutes = session['durationMinutes'] as int? ?? 60;
                endTime = startTime.add(Duration(minutes: durationMinutes));
              }
              
              schedules.add(TeacherScheduleModel(
                id: session['sessionId']?.toString() ?? '',
                classId: classId,
                className: session['className'] ?? '',
                startTime: startTime,
                endTime: endTime,
                room: session['roomName'] ?? 'N/A',
                note: session['note'],
              ));
            }
          }
        }
        
        return schedules;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get schedule failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<List<TeacherStudentModel>> getClassStudents(int classId) async {
    try {
      final response = await dioClient.get(
        '${ApiEndpoints.teacherClassStudents}/$classId',
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        final List<dynamic> students = data['students'] ?? [];
        return students
            .map((json) => TeacherStudentModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get students failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<TeacherClassModel> getClassDetail(int classId) async {
    try {
      final response = await dioClient.get(
        '${ApiEndpoints.teacherClassDetail}/$classId',
      );
      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return TeacherClassModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Get class failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<void> submitAttendance(
    int sessionId,
    List<Map<String, dynamic>> attendances,
  ) async {
    try {
      final response = await dioClient.post(
        '${ApiEndpoints.teacherAttendance}/$sessionId/attendance',
        data: {'sessionId': sessionId, 'attendances': attendances},
      );

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Submit attendance failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }
}
