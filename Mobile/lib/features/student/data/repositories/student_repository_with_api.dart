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
import '../models/student_profile_model.dart';

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
    try {
      final profileModel = StudentProfileModel.fromEntity(profile);
      await apiDataSource.updateProfile(profileModel);

      final updatedProfile = await apiDataSource.getProfile();
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
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

  List<Course> _filterActiveCourses(List<Course> courses) {
    const activeStatuses = {
      'active',
      'open',
      'ongoing',
      'enrolling',
      'available',
      'đang mở',
      'đang học',
    };

    return courses.where((course) {
      if (course.availableClasses.isNotEmpty) {
        return course.availableClasses.any((classInfo) {
          final status = (classInfo.status ?? '').toLowerCase();
          return activeStatuses.contains(status) ||
              (status.isEmpty && classInfo.hasAvailableSlots);
        });
      }
      return true;
    }).toList();
  }

  @override
  Future<Either<Failure, List<Course>>> getAllCourses() async {
    try {
      final result = await apiDataSource.getCourses();
      final activeCourses = _filterActiveCourses(result.cast<Course>());
      return Right(activeCourses);
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
      final result = await apiDataSource.getEnrolledClasses();
      return Right(result.cast<StudentClass>());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentClass>> getClassById(String id) async {
    try {
      final result = await apiDataSource.getClassDetail(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getScheduleByDate(
    DateTime date,
  ) async {
    // Lấy tất cả các tuần trong tháng
    try {
      final List<Schedule> allSchedules = [];

      // Xác định ngày đầu và cuối tháng
      final firstDayOfMonth = DateTime(date.year, date.month, 1);
      final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

      // Lấy từng tuần trong tháng
      DateTime currentWeekStart = firstDayOfMonth;
      final Set<String> addedScheduleIds = {}; // Tránh duplicate

      while (currentWeekStart.isBefore(lastDayOfMonth) ||
          currentWeekStart.isAtSameMomentAs(lastDayOfMonth)) {
        final weekResult = await _getWeekScheduleInternal(currentWeekStart);

        weekResult.fold(
          (failure) {}, // Bỏ qua lỗi từng tuần
          (schedules) {
            for (final schedule in schedules) {
              // Chỉ thêm schedule trong tháng này và chưa có
              if (schedule.startTime.month == date.month &&
                  schedule.startTime.year == date.year) {
                final uniqueId =
                    '${schedule.classId}_${schedule.startTime.toIso8601String()}';
                if (!addedScheduleIds.contains(uniqueId)) {
                  addedScheduleIds.add(uniqueId);
                  allSchedules.add(schedule);
                }
              }
            }
          },
        );

        // Chuyển sang tuần tiếp theo (7 ngày)
        currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      }

      // Sắp xếp theo ngày
      allSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

      return Right(allSchedules);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Schedule>>> _getWeekScheduleInternal(
    DateTime startDate,
  ) async {
    try {
      final response = await apiDataSource.getStudentSchedule(date: startDate);

      final List<Schedule> schedules = [];

      // WeeklyScheduleResponse has .days property (List<WeeklyScheduleDay>)
      for (final day in response.days) {
        final dateStr = day.date;
        if (dateStr.isEmpty) continue;

        // Each day has .periods (List<WeeklySchedulePeriod>)
        for (final period in day.periods) {
          final periodName = period.periodName;

          // Each period has .sessions (List<WeeklyScheduleSession>)
          for (final session in period.sessions) {
            schedules.add(
              Schedule(
                id: session.sessionId.toString(),
                classId: session.classId.toString(),
                className: session.className,
                teacherName: session.lecturerName,
                room: session.room,
                startTime: _parseDateTime(dateStr, session.timeSlot),
                endTime: _parseDateTime(
                  dateStr,
                  session.timeSlot,
                ).add(Duration(minutes: session.durationMinutes ?? 120)),
                courseName: session.courseName,
                status: session.status ?? 'NotCompleted',
                period: periodName,
              ),
            );
          }
        }
      }

      return Right(schedules);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final date = DateTime.parse(dateStr);
      final timeParts = timeStr.split(':');
      if (timeParts.length >= 2) {
        return DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
      return date;
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Future<Either<Failure, List<Schedule>>> getWeekSchedule(
    DateTime startDate,
  ) async {
    try {
      final response = await apiDataSource.getStudentSchedule(date: startDate);

      final List<Schedule> schedules = [];

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      // WeeklyScheduleResponse has .days property (List<WeeklyScheduleDay>)
      for (final day in response.days) {
        final dateStr = day.date;
        if (dateStr.isEmpty) continue;

        final sessionDate = DateTime.parse(dateStr);

        final sessionDay = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
        );
        if (sessionDay.isBefore(todayStart)) continue;

        // Each day has .periods (List<WeeklySchedulePeriod>)
        for (final period in day.periods) {
          final periodName = period.periodName;

          // Each period has .sessions (List<WeeklyScheduleSession>)
          for (final session in period.sessions) {
            schedules.add(
              Schedule(
                id: session.sessionId.toString(),
                classId: session.classId.toString(),
                className: session.className,
                teacherName: session.lecturerName,
                room: session.room,
                startTime: _parseDateTime(dateStr, session.timeSlot),
                endTime: _parseDateTime(
                  dateStr,
                  session.timeSlot,
                ).add(Duration(minutes: session.durationMinutes ?? 120)),
                courseName: session.courseName,
                status: session.status ?? 'NotCompleted',
                period: periodName,
              ),
            );
          }
        }
      }

      return Right(schedules);
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
    try {
      final result = await apiDataSource.getGrades();
      List<Grade> grades = result.cast<Grade>();

      if (courseId.isNotEmpty) {
        grades = grades
            .where((g) => g.courseId?.toString() == courseId)
            .toList();
      }

      return Right(grades);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> enrollCourse(String courseId) async {
    try {
      final data = {'courseId': int.parse(courseId), 'classId': null};
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
      // apiDataSource.getGrades() already returns List<GradeModel> which extends Grade
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

  @override
  Future<Either<Failure, Review?>> getClassReview(String classId) async {
    try {
      final result = await apiDataSource.getReviewHistory();

      final review = result
          .cast<Review>()
          .where((r) => r.classId.toString() == classId)
          .firstOrNull;
      return Right(review);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Grade?>> getGradesByClass(String classId) async {
    try {
      final result = await apiDataSource.getGrades();
      final grade = result
          .cast<Grade>()
          .where((g) => g.classId.toString() == classId)
          .firstOrNull;
      return Right(grade);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
