import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/course_model.dart';
import '../models/review_model.dart';
import '../models/student_class_model.dart';
import '../models/student_profile_model.dart';

abstract class StudentApiDataSource {
  Future<StudentProfileModel> getProfile();

  Future<void> updateProfile(StudentProfileModel profile);

  Future<List<CourseModel>> getCourses();

  Future<List<StudentClassModel>> getEnrolledClasses({
    int page = 1,
    int size = 10,
  });

  @Deprecated('Use getEnrolledClasses instead')
  Future<List<CourseModel>> getEnrolledCourses();

  Future<CourseModel> getCourseDetail(String courseId);

  Future<StudentClassModel> getClassDetail(String classId);

  Future<Map<String, dynamic>> getScheduleByWeek({required DateTime date});

  Future<Map<String, dynamic>> getStudentSchedule({required DateTime date});

  Future<String> uploadAvatar(String filePath);

  Future<void> enrollCourse(Map<String, dynamic> data);

  Future<List<dynamic>> getGrades();

  Future<void> submitReview({
    required int classId,
    required int overallRating,
    int? teacherRating,
    int? facilityRating,
    required String comment,
  });

  Future<List<ReviewModel>> getReviewHistory();
}

class StudentApiDataSourceImpl implements StudentApiDataSource {
  final DioClient dioClient;

  StudentApiDataSourceImpl({required this.dioClient});

  @override
  Future<StudentProfileModel> getProfile() async {
    try {
      final response = await dioClient.get(ApiEndpoints.studentProfile);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return StudentProfileModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Get profile failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get profile failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get profile failed');
    }
  }

  @override
  Future<void> updateProfile(StudentProfileModel profile) async {
    try {
      final response = await dioClient.put(
        ApiEndpoints.studentUpdateProfile,
        data: profile.toJson(),
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return;
      } else {
        throw ServerException(response.data['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Update failed');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Update profile failed');
    }
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      final response = await dioClient.get(ApiEndpoints.coursesActive);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final List<dynamic> data = response.data['data'];

        List<CourseModel> courses = [];
        for (var category in data) {
          final List<dynamic> categoryCourses = category['courses'] ?? [];
          courses.addAll(
            categoryCourses.map((json) => CourseModel.fromJson(json)).toList(),
          );
        }

        return courses;
      } else {
        throw ServerException(response.data['message'] ?? 'Get courses failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get courses failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get courses failed');
    }
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses() async {
    try {
      final response = await dioClient.get(ApiEndpoints.studentCoursesEnrolled);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        List<CourseModel> courses = [];

        final categories = data['categories'] as List? ?? [];
        for (var category in categories) {
          final categoryCourses = category['courses'] as List? ?? [];
          courses.addAll(
            categoryCourses.map((json) => CourseModel.fromJson(json)).toList(),
          );
        }

        return courses;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get enrolled courses failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get enrolled courses failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get enrolled courses failed');
    }
  }

  @override
  Future<List<StudentClassModel>> getEnrolledClasses({
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.studentClassesEnrolled,
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];

        final List<dynamic> classes = data['classes'] ?? [];
        return classes.map((json) => StudentClassModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get enrolled classes failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get enrolled classes failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get enrolled classes failed');
    }
  }

  @override
  Future<CourseModel> getCourseDetail(String courseId) async {
    try {
      final response = await dioClient.get(
        '${ApiEndpoints.courseDetail}/$courseId',
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return CourseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get course detail failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get course detail failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get course detail failed');
    }
  }

  @override
  Future<StudentClassModel> getClassDetail(String classId) async {
    try {
      final response = await dioClient.get(
        '${ApiEndpoints.classDetail}/$classId',
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return StudentClassModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get class detail failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get class detail failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get class detail failed');
    }
  }

  @override
  Future<Map<String, dynamic>> getScheduleByWeek({
    required DateTime date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.scheduleByWeek,
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get schedule failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get schedule failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get schedule failed');
    }
  }

  @override
  Future<Map<String, dynamic>> getStudentSchedule({
    required DateTime date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.studentSchedule,
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get student schedule failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get student schedule failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get student schedule failed');
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dioClient.dio.post(
        ApiEndpoints.uploadFile,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return response.data['data']['fileUrl'] as String;
      } else {
        throw ServerException(response.data['message'] ?? 'Upload failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Upload failed');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException('Upload avatar failed: $e');
    }
  }

  @override
  Future<void> enrollCourse(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.enrollments,
        data: data,
      );

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(response.data['message'] ?? 'Enrollment failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Enrollment failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException('Enrollment failed: $e');
    }
  }

  @override
  Future<List<dynamic>> getGrades() async {
    try {
      final response = await dioClient.get(ApiEndpoints.studentGrades);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        if (data is List) {
          return data;
        }
        return [];
      } else {
        throw ServerException(response.data['message'] ?? 'Get grades failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get grades failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Get grades failed: $e');
    }
  }

  @override
  Future<void> submitReview({
    required int classId,
    required int overallRating,
    int? teacherRating,
    int? facilityRating,
    required String comment,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.studentReviews,
        data: {
          'classId': classId,
          'overallRating': overallRating,
          if (teacherRating != null) 'teacherRating': teacherRating,
          if (facilityRating != null) 'facilityRating': facilityRating,
          'comment': comment,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          response.data['message'] ?? 'Submit review failed',
        );
      }
      if (response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Submit review failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Submit review failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Submit review failed: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewHistory() async {
    try {
      final response = await dioClient.get(ApiEndpoints.studentReviews);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => ReviewModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get review history failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get review history failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Get review history failed: $e');
    }
  }
}
