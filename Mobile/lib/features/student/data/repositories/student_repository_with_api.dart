import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/grade.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/student_profile.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_api_datasource.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/student_local_datasource.dart';

class StudentRepositoryWithApi implements StudentRepository {
  final StudentApiDataSource apiDataSource;
  final StudentLocalDataSource localDataSource;

  StudentRepositoryWithApi({
    required this.apiDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, StudentProfile>> getProfile() async {
    try {
      final result = await apiDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentProfile>> updateProfile(
    StudentProfile profile,
  ) async {
    return Left(ServerFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String path) async {
    try {
      final fileUrl = await apiDataSource.uploadAvatar(path);
      return Right(fileUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async {
    try {
      final result = await apiDataSource.getCourses();
      return Right(result.cast<Course>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Course>>> searchCourses(String query) async {
    try {
      final allCourses = await apiDataSource.getCourses();
      
      final filtered = allCourses.where((course) {
        final nameLower = course.name.toLowerCase();
        final queryLower = query.toLowerCase();
        final descLower = course.description.toLowerCase();
        return nameLower.contains(queryLower) || descLower.contains(queryLower);
      }).toList();
      return Right(filtered.cast<Course>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String id) async {
    try {
      final result = await apiDataSource.getCourseDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentClass>>> getMyClasses() async {
    try {
      final result = await apiDataSource.getEnrolledCourses();
      return Right(result.cast<StudentClass>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentClass>> getClassById(String id) async {
    return Left(ServerFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, List<Schedule>>> getScheduleByDate(
    DateTime date,
  ) async {
    return getWeekSchedule(date);
  }

  @override
  Future<Either<Failure, List<Schedule>>> getWeekSchedule(
    DateTime startDate,
  ) async {
    try {
      await apiDataSource.getStudentSchedule(date: startDate);
      return Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentClass>>> getUpcomingClasses() async {
    return getMyClasses();
  }

  @override
  Future<Either<Failure, List<Grade>>> getGradesByCourse(
    String courseId,
  ) async {
    return Left(ServerFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> enrollCourse(String courseId) async {
    try {
      final data = {
        'courseId': int.parse(courseId),
        'classId': null, 
      };
      await apiDataSource.enrollCourse(data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Grade>>> getMyGrades() async {
    try {
      final result = await apiDataSource.getGrades();
      return Right(result.cast<Grade>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitRating({
    required String classId,
    required int overallRating,
    int? teacherRating,
    int? facilityRating,
    required String comment,
  }) async {
    try {
      await apiDataSource.submitReview(
        classId: int.parse(classId),
        overallRating: overallRating,
        teacherRating: teacherRating,
        facilityRating: facilityRating,
        comment: comment,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviewHistory() async {
    try {
      final result = await apiDataSource.getReviewHistory();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
