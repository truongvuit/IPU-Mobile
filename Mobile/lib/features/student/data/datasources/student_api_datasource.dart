import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/specs/student_api_spec.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/course_model.dart';
import '../models/grade_model.dart';
import '../models/review_model.dart';
import '../models/student_class_model.dart';
import '../models/student_profile_model.dart';
import '../models/weekly_schedule_model.dart';
import '../../domain/entities/student_cart_preview.dart';

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

  
  Future<WeeklyScheduleResponse> getScheduleByWeek({required DateTime date});

  
  Future<WeeklyScheduleResponse> getStudentSchedule({required DateTime date});

  Future<String> uploadAvatar(String filePath);

  
  
  @Deprecated(
    'Endpoint /enrollments does not exist. Use createOrder for enrollment.',
  )
  Future<void> enrollCourse(Map<String, dynamic> data);

  
  Future<List<GradeModel>> getGrades();

  
  Future<GradeModel?> getGradesByClass(String classId);

  Future<void> submitReview({
    required int classId,
    required int overallRating,
    int? teacherRating,
    int? facilityRating,
    required String comment,
  });

  Future<List<ReviewModel>> getReviewHistory();

  
  Future<StudentCartPreview> getCartPreview(List<int> classIds);

  Future<Map<String, dynamic>> createOrder({
    required List<int> classIds,
    int? paymentMethodId,
  });

  
  Future<Map<String, dynamic>> createPayment({
    required int invoiceId,
    required double totalAmount,
  });
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
  Future<WeeklyScheduleResponse> getScheduleByWeek({
    required DateTime date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.scheduleByWeek,
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return WeeklyScheduleResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
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
      if (e is ServerException) rethrow;
      throw const ServerException('Get schedule failed');
    }
  }

  @override
  Future<WeeklyScheduleResponse> getStudentSchedule({
    required DateTime date,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.studentSchedule,
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return WeeklyScheduleResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
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
      if (e is ServerException) rethrow;
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
  @Deprecated(
    'Endpoint /enrollments does not exist. Use createOrder for enrollment.',
  )
  Future<void> enrollCourse(Map<String, dynamic> data) async {
    
    
    throw const ServerException(
      'Direct enrollment is not supported. Please use the checkout flow.',
    );
  }

  @override
  Future<List<GradeModel>> getGrades() async {
    try {
      final response = await dioClient.get(ApiEndpoints.studentGrades);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((json) => GradeModel.fromJson(json as Map<String, dynamic>))
              .toList();
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
  Future<GradeModel?> getGradesByClass(String classId) async {
    try {
      final response = await dioClient.get(
        StudentApiSpec.getGradesByClass(classId),
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return GradeModel.fromJson(data);
        }
        return null;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get grades by class failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get grades by class failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Get grades by class failed: $e');
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

  

  @override
  Future<StudentCartPreview> getCartPreview(List<int> classIds) async {
    try {
      final response = await dioClient.post(
        StudentApiSpec.cartPreview,
        data: {'courseClassIds': classIds},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return StudentCartPreview.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Get cart preview failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Get cart preview failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Get cart preview failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder({
    required List<int> classIds,
    int? paymentMethodId,
  }) async {
    try {
      final response = await dioClient.post(
        StudentApiSpec.createOrder,
        data: {
          'classIds': classIds,
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Create order failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Create order failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Create order failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createPayment({
    required int invoiceId,
    required double totalAmount,
  }) async {
    try {
      final response = await dioClient.post(
        '/orders/payment/create',
        data: {
          
          
          'amount': totalAmount.round().toString(),
          'invoiceId': invoiceId,
          'orderInfo': 'Thanh toan khoa hoc',
        },
        
        
        
        options: Options(
          headers: {'X-Client-Type': 'mobile', 'X-User-Role': 'STUDENT'},
        ),
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Create payment failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Create payment failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Create payment failed: $e');
    }
  }
}
