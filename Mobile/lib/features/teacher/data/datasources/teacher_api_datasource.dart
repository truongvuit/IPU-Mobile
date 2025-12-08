import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/teacher_profile_model.dart';
import '../models/teacher_class_model.dart';
import '../models/teacher_schedule_model.dart';
import '../models/teacher_student_model.dart';
import '../../domain/entities/attendance.dart';

abstract class TeacherApiDataSource {
  Future<TeacherProfileModel> getProfile();
  Future<void> updateProfile(TeacherProfileModel profile);
  Future<List<TeacherClassModel>> getMyClasses();
  Future<List<TeacherScheduleModel>> getWeekSchedule(DateTime date);
  Future<List<TeacherStudentModel>> getClassStudents(int classId);
  Future<TeacherClassModel> getClassDetail(int classId);
  Future<AttendanceSession> getAttendanceForSession(int sessionId);
  Future<AttendanceSession> submitAttendance(
    int sessionId,
    List<Map<String, dynamic>> entries,
  );
  Future<TeacherStudentModel> getStudentDetail(int studentId);
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
  Future<void> updateProfile(TeacherProfileModel profile) async {
    try {
      // Chuyển đổi gender từ string sang boolean
      bool? genderBoolean;
      if (profile.gender != null) {
        if (profile.gender == 'Nam') {
          genderBoolean = true;
        } else if (profile.gender == 'Nữ') {
          genderBoolean = false;
        }
      }

      // Sử dụng endpoint PUT /lecturers/me để giảng viên tự cập nhật
      final response = await dioClient.put(
        '/lecturers/me',
        data: {
          if (profile.fullName.isNotEmpty) 'fullName': profile.fullName,
          if (profile.email != null && profile.email!.isNotEmpty)
            'email': profile.email,
          if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
            'phoneNumber': profile.phoneNumber,
          if (profile.address != null && profile.address!.isNotEmpty)
            'address': profile.address,
          if (profile.dateOfBirth != null)
            'dateOfBirth': profile.dateOfBirth!.toIso8601String().split('T')[0],
          if (genderBoolean != null) 'gender': genderBoolean,
          if (profile.specialization != null &&
              profile.specialization!.isNotEmpty)
            'specialization': profile.specialization,
          if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
            'imagePath': profile.avatarUrl,
        },
      );
      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Cập nhật hồ sơ thất bại',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Lỗi kết nối mạng');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Cập nhật hồ sơ thất bại: $e');
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

        final List<dynamic> days = data['days'] ?? [];
        for (final day in days) {
          final sessionDate = day['date'] as String?;
          final List<dynamic> periods = day['periods'] ?? [];

          for (final period in periods) {
            final List<dynamic> sessions = period['sessions'] ?? [];

            for (final session in sessions) {
              final classId = session['classId']?.toString() ?? '';

              DateTime startTime = DateTime.now();
              DateTime endTime = DateTime.now().add(const Duration(hours: 1));

              if (sessionDate != null) {
                final dateOnly = DateTime.parse(sessionDate);

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

                final durationMinutes =
                    session['durationMinutes'] as int? ?? 60;
                endTime = startTime.add(Duration(minutes: durationMinutes));
              }

              schedules.add(
                TeacherScheduleModel(
                  id: session['sessionId']?.toString() ?? '',
                  classId: classId,
                  className: session['className'] ?? '',
                  startTime: startTime,
                  endTime: endTime,
                  room: session['roomName'] ?? 'N/A',
                  note: session['note'],
                ),
              );
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
  Future<AttendanceSession> getAttendanceForSession(int sessionId) async {
    try {
      final response = await dioClient.get(
        '/courseclasses/sessions/$sessionId/attendance',
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        return _parseAttendanceSession(data, sessionId);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get attendance failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  @override
  Future<AttendanceSession> submitAttendance(
    int sessionId,
    List<Map<String, dynamic>> entries,
  ) async {
    try {
      final response = await dioClient.post(
        '${ApiEndpoints.teacherAttendance}/$sessionId/attendance',
        data: {'sessionId': sessionId, 'entries': entries},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        return _parseAttendanceSession(data, sessionId);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Submit attendance failed',
        );
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network error');
    }
  }

  AttendanceSession _parseAttendanceSession(
    Map<String, dynamic> data,
    int sessionId,
  ) {
    final entries = data['entries'] as List<dynamic>? ?? [];

    final serverClassId = data['classId']?.toString() ?? '';
    final serverDate = data['sessionDate'] != null
        ? DateTime.tryParse(data['sessionDate'].toString())
        : (data['date'] != null
              ? DateTime.tryParse(data['date'].toString())
              : null);
    final serverIsCompleted =
        data['isCompleted'] as bool? ?? data['completed'] as bool? ?? false;
    final serverCreatedAt = data['createdAt'] != null
        ? DateTime.tryParse(data['createdAt'].toString())
        : null;

    final records = entries.map((e) {
      final entryDate = e['date'] != null
          ? DateTime.tryParse(e['date'].toString())
          : (e['createdAt'] != null
                ? DateTime.tryParse(e['createdAt'].toString())
                : null);
      final entryCreatedAt = e['createdAt'] != null
          ? DateTime.tryParse(e['createdAt'].toString())
          : null;

      return AttendanceRecord(
        id: '${sessionId}_${e['studentId']}',
        studentId: e['studentId']?.toString() ?? '',
        classId: e['classId']?.toString() ?? serverClassId,
        date: entryDate ?? serverDate ?? DateTime.now(),
        status: (e['absent'] == true) ? 'absent' : 'present',
        note: e['note'] as String?,
        createdAt: entryCreatedAt ?? serverCreatedAt ?? DateTime.now(),
        studentName: e['studentName'] as String? ?? e['fullName'] as String?,
        studentCode: e['studentCode'] as String? ?? e['code'] as String?,
        studentAvatar:
            e['studentAvatar'] as String? ??
            e['avatar'] as String? ??
            e['imagePath'] as String?,
      );
    }).toList();

    return AttendanceSession(
      id: sessionId.toString(),
      classId: serverClassId,
      date: serverDate ?? DateTime.now(),
      records: records,
      isCompleted: serverIsCompleted,
    );
  }

  @override
  Future<TeacherStudentModel> getStudentDetail(int studentId) async {
    try {
      final response = await dioClient.get('/students/$studentId');

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return TeacherStudentModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get student detail failed',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Không thể tải thông tin học viên: $e');
    }
  }
}
