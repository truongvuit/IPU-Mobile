import 'package:dartz/dartz.dart';
import '../../domain/entities/teacher_class.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_api_datasource.dart';
import '../datasources/teacher_local_datasource.dart';
import '../models/teacher_profile_model.dart';
import '../../../../core/errors/exceptions.dart';

class TeacherRepositoryWithApi implements TeacherRepository {
  final TeacherApiDataSource apiDataSource;
  final TeacherLocalDataSource? localDataSource;

  TeacherRepositoryWithApi({required this.apiDataSource, this.localDataSource});

  @override
  Future<Either<String, TeacherProfile>> getProfile() async {
    try {
      final result = await apiDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateProfile(TeacherProfile profile) async {
    try {
      await apiDataSource.updateProfile(
        TeacherProfileModel.fromEntity(profile),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Không thể cập nhật hồ sơ: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<TeacherClass>>> getMyClasses() async {
    try {
      final result = await apiDataSource.getMyClasses();
      
      final activeClasses = result.where((cls) {
        final statusLower = (cls.status ?? '').toLowerCase();
        return statusLower == 'active' ||
            statusLower == 'ongoing' ||
            statusLower == 'inprogress' ||
            statusLower == 'in_progress' ||
            statusLower == 'đang học';
      }).toList();
      return Right(activeClasses);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, TeacherClass>> getClassDetail(String classId) async {
    try {
      final result = await apiDataSource.getClassDetail(int.parse(classId));
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ClassStudent>>> getClassStudents(
    String classId,
  ) async {
    try {
      final result = await apiDataSource.getClassStudents(int.parse(classId));
      return Right(result.cast<ClassStudent>());
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ClassStudent>> getStudentDetail(
    String studentId,
  ) async {
    try {
      final result = await apiDataSource.getStudentDetail(int.parse(studentId));
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Không thể tải thông tin học viên: $e');
    }
  }

  @override
  Future<Either<String, List<AttendanceSession>>> getClassSessions(
    String classId,
  ) async {
    
    return const Left('Vui lòng chọn buổi học cụ thể từ lịch dạy');
  }

  @override
  Future<Either<String, AttendanceSession>> getAttendanceSession(
    String classId,
    DateTime date,
  ) async {
    try {
      final sessionId = int.tryParse(classId);
      if (sessionId == null) {
        return const Left('Invalid session ID');
      }
      final result = await apiDataSource.getAttendanceForSession(sessionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, AttendanceSession>> getAttendanceBySessionId(
    String sessionId,
  ) async {
    try {
      final id = int.tryParse(sessionId);
      if (id == null) {
        return const Left('Invalid session ID');
      }
      final result = await apiDataSource.getAttendanceForSession(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> recordAttendance(
    String classId,
    String studentId,
    String status,
    String? note,
  ) async {
    
    return const Left(
      'Chức năng này đã được thay thế. Vui lòng sử dụng điểm danh hàng loạt.',
    );
  }

  @override
  Future<Either<String, void>> batchRecordAttendance(
    String sessionId,
    List<Map<String, dynamic>> records,
  ) async {
    try {
      final id = int.tryParse(sessionId);
      if (id == null) {
        return const Left('Invalid session ID');
      }
      await apiDataSource.submitAttendance(id, records);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TeacherSchedule>>> getWeekSchedule(
    DateTime date,
  ) async {
    try {
      
      if (localDataSource != null && localDataSource!.isCacheValid()) {
        final cachedSchedules = await localDataSource!.getCachedSchedules();
        if (cachedSchedules != null && cachedSchedules.isNotEmpty) {
          
          final weekStart = date.subtract(Duration(days: date.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          final filteredSchedules = cachedSchedules.where((s) {
            return s.startTime.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                s.startTime.isBefore(weekEnd);
          }).toList();

          if (filteredSchedules.isNotEmpty) {
            return Right(filteredSchedules.cast<TeacherSchedule>());
          }
        }
      }

      
      final result = await apiDataSource.getWeekSchedule(date);

      
      if (localDataSource != null && result.isNotEmpty) {
        await localDataSource!.cacheSchedules(result);
      }

      return Right(result);
    } on ServerException catch (e) {
      
      if (localDataSource != null) {
        final cachedSchedules = await localDataSource!.getCachedSchedules();
        if (cachedSchedules != null && cachedSchedules.isNotEmpty) {
          return Right(cachedSchedules.cast<TeacherSchedule>());
        }
      }
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TeacherSchedule>>> getTodaySchedule() async {
    final result = await getWeekSchedule(DateTime.now());
    return result.map((schedules) {
      final now = DateTime.now();

      return schedules.where((s) {
        return s.startTime.year == now.year &&
            s.startTime.month == now.month &&
            s.startTime.day == now.day;
      }).toList();
    });
  }
}
