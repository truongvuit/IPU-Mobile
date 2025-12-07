import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course.dart';
import '../entities/student_class.dart';
import '../entities/schedule.dart';
import '../entities/grade.dart';
import '../entities/review.dart';
import '../entities/student_profile.dart';

abstract class StudentRepository {
  Future<Either<Failure, List<StudentClass>>> getUpcomingClasses();

  Future<Either<Failure, List<Course>>> getAllCourses();
  Future<Either<Failure, List<Course>>> searchCourses(String query);
  Future<Either<Failure, Course>> getCourseById(String id);

  Future<Either<Failure, List<StudentClass>>> getMyClasses();
  Future<Either<Failure, StudentClass>> getClassById(String id);

  Future<Either<Failure, List<Schedule>>> getScheduleByDate(DateTime date);
  Future<Either<Failure, List<Schedule>>> getWeekSchedule(DateTime startDate);

  Future<Either<Failure, List<Grade>>> getMyGrades();
  Future<Either<Failure, List<Grade>>> getGradesByCourse(String courseId);
  Future<Either<Failure, Grade?>> getGradesByClass(String classId);

  Future<Either<Failure, StudentProfile>> getProfile();
  Future<Either<Failure, StudentProfile>> updateProfile(StudentProfile profile);
  Future<Either<Failure, String>> uploadAvatar(String path);

  
  Future<Either<Failure, void>> submitRating({
    required String classId,
    required int overallRating,
    int? teacherRating,
    int? facilityRating,
    required String comment,
  });

  Future<Either<Failure, List<Review>>> getReviewHistory();

  Future<Either<Failure, Review?>> getClassReview(String classId);
}
