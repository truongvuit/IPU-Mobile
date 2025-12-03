import 'package:dartz/dartz.dart';
import '../../domain/entities/teacher_class.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/student_score.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/entities/teacher_profile.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_api_datasource.dart';
import '../../../../core/errors/exceptions.dart';

class TeacherRepositoryWithApi implements TeacherRepository {
  final TeacherApiDataSource apiDataSource;

  TeacherRepositoryWithApi({required this.apiDataSource});

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
    return Left('Not implemented');
  }

  @override
  Future<Either<String, List<TeacherClass>>> getMyClasses() async {
    try {
      final result = await apiDataSource.getMyClasses();
      return Right(result);
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
    return Left('Not implemented');
  }

  @override
  Future<Either<String, List<AttendanceSession>>> getClassSessions(
    String classId,
  ) async {
    // Not needed - we use session-based attendance
    return const Left('Use getAttendanceSession with sessionId instead');
  }

  @override
  Future<Either<String, AttendanceSession>> getAttendanceSession(
    String classId,
    DateTime date,
  ) async {
    // Note: This method expects classId but API uses sessionId
    // The screen should pass sessionId, not classId
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
    // Single record - will be batched in UI
    return const Left('Use batchRecordAttendance instead');
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
  Future<Either<String, void>> submitAttendance(String sessionId) async {
    // Attendance is submitted via batchRecordAttendance
    return const Right(null);
  }

  @override
  Future<Either<String, List<StudentScore>>> getClassScores(
    String classId,
  ) async {
    return Left('Not implemented');
  }

  @override
  Future<Either<String, List<StudentScore>>> getStudentScores(
    String studentId,
    String classId,
  ) async {
    return Left('Not implemented');
  }

  @override
  Future<Either<String, void>> submitScore(StudentScore score) async {
    return Left('Not implemented');
  }

  @override
  Future<Either<String, void>> updateScore(StudentScore score) async {
    return Left('Not implemented');
  }

  @override
  Future<Either<String, void>> batchSubmitScores(
    String classId,
    String examType,
    String examName,
    DateTime examDate,
    List<Map<String, dynamic>> scores,
  ) async {
    return Left('Not implemented');
  }

  @override
  Future<Either<String, List<TeacherSchedule>>> getWeekSchedule(
    DateTime date,
  ) async {
    try {
      final result = await apiDataSource.getWeekSchedule(date);
      return Right(result);
    } on ServerException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<TeacherSchedule>>> getTodaySchedule() async {
    return getWeekSchedule(DateTime.now());
  }
}
