import 'package:dartz/dartz.dart';
import '../entities/teacher_class.dart';
import '../entities/class_student.dart';
import '../entities/attendance.dart';
import '../entities/teacher_schedule.dart';
import '../entities/teacher_profile.dart';

abstract class TeacherRepository {
  Future<Either<String, List<TeacherClass>>> getMyClasses();
  Future<Either<String, TeacherClass>> getClassDetail(String classId);

  Future<Either<String, List<ClassStudent>>> getClassStudents(String classId);
  Future<Either<String, ClassStudent>> getStudentDetail(String studentId);

  Future<Either<String, List<AttendanceSession>>> getClassSessions(
    String classId,
  );
  Future<Either<String, AttendanceSession>> getAttendanceSession(
    String classId,
    DateTime date,
  );

  Future<Either<String, AttendanceSession>> getAttendanceBySessionId(
    String sessionId,
  );
  Future<Either<String, void>> recordAttendance(
    String classId,
    String studentId,
    String status,
    String? note,
  );
  Future<Either<String, void>> batchRecordAttendance(
    String sessionId,
    List<Map<String, dynamic>> records,
  );

  Future<Either<String, List<TeacherSchedule>>> getWeekSchedule(DateTime date);
  Future<Either<String, List<TeacherSchedule>>> getTodaySchedule();

  Future<Either<String, TeacherProfile>> getProfile();
  Future<Either<String, void>> updateProfile(TeacherProfile profile);
  Future<Either<String, String>> uploadAvatar(String filePath);
}
