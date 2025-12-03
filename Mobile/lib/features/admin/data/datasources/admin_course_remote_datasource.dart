import '../../../../core/api/dio_client.dart';
import '../models/course_detail_model.dart';
import 'admin_course_data_source.dart';

class AdminCourseRemoteDataSource implements AdminCourseDataSource {
  final DioClient dioClient;

  AdminCourseRemoteDataSource({required this.dioClient});

  @override
  Future<List<CourseDetailModel>> getCourses({
    String? search,
    String? categoryId,
    bool? isActive,
  }) async {
    try {
      final response = await dioClient.get(
        '/courses',
        queryParameters: {'page': 0, 'size': 100},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        final List<dynamic> courses = data['courses'] ?? [];

        List<CourseDetailModel> result = courses.map((json) {
          return _mapCourseResponseToModel(json);
        }).toList();

        if (search != null && search.isNotEmpty) {
          final query = search.toLowerCase();
          result = result
              .where((c) => c.name.toLowerCase().contains(query))
              .toList();
        }

        if (categoryId != null) {
          result = result.where((c) => c.categoryId == categoryId).toList();
        }

        if (isActive != null) {
          result = result.where((c) => c.isActive == isActive).toList();
        }

        return result;
      }

      throw Exception(response.data['message'] ?? 'Failed to load courses');
    } catch (e) {
      print('Error loading courses: $e');
      rethrow;
    }
  }

  @override
  Future<CourseDetailModel> getCourseById(String id) async {
    try {
      final response = await dioClient.get('/courses/$id');

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        return _mapCourseDetailResponseToModel(data);
      }

      throw Exception(response.data['message'] ?? 'Failed to load course');
    } catch (e) {
      print('Error loading course by id: $e');
      rethrow;
    }
  }

  @override
  Future<CourseDetailModel> updateCourse(
    String id,
    UpdateCourseRequest request,
  ) async {
    try {
      final response = await dioClient.put(
        '/courses/$id',
        data: {
          'courseName': request.name,
          'studyHours': request.totalHours,
          'tuitionFee': request.tuitionFee,
          'video': request.videoUrl,
          'image': request.imageUrl,
          'description': request.description,
          'entryLevel': request.entryRequirement,
          'targetLevel': request.exitRequirement,
          'courseCategoryId': request.categoryId != null
              ? int.tryParse(request.categoryId!)
              : null,
          'isActive': request.isActive,
        },
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return getCourseById(id);
      }

      throw Exception(response.data['message'] ?? 'Failed to update course');
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      final response = await dioClient.post('/courses/status/$id');

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw Exception(
          response.data['message'] ?? 'Failed to change course status',
        );
      }
    } catch (e) {
      print('Error changing course status: $e');
      rethrow;
    }
  }

  CourseDetailModel _mapCourseResponseToModel(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: (json['courseId'] ?? json['makhoahoc'] ?? '').toString(),
      name: json['courseName'] ?? json['tenkhoahoc'] ?? '',
      totalHours: json['studyHours'] ?? json['sogiohoc'] ?? 0,
      tuitionFee: (json['tuitionFee'] ?? json['hocphi'] ?? 0).toDouble(),
      videoUrl: json['video'],
      isActive: json['isActive'] ?? json['status'] ?? json['trangthai'] ?? true,
      createdAt: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdBy: null,
      imageUrl: json['image'] ?? json['hinhanh'],
      description: json['description'] ?? json['mota'],
      categoryId: (json['courseCategoryId'] ?? json['madanhmuc'] ?? '')
          .toString(),
      categoryName: json['category'] ?? json['danhmuc'],
      level: json['level'],
    );
  }

  CourseDetailModel _mapCourseDetailResponseToModel(Map<String, dynamic> json) {
    final classInfos = json['classInfos'] as List? ?? [];
    final totalClasses = classInfos.length;
    final activeClasses = classInfos
        .where((c) => c['status'] == 'InProgress' || c['status'] == 'ongoing')
        .length;

    int totalStudents = 0;
    for (var cls in classInfos) {
      totalStudents += (cls['currentEnrollment'] ?? 0) as int;
    }

    return CourseDetailModel(
      id: (json['courseId'] ?? json['makhoahoc'] ?? '').toString(),
      name: json['courseName'] ?? json['tenkhoahoc'] ?? '',
      totalHours: json['studyHours'] ?? json['sogiohoc'] ?? 0,
      tuitionFee: (json['tuitionFee'] ?? json['hocphi'] ?? 0).toDouble(),
      videoUrl: json['video'],
      isActive: json['status'] ?? json['trangthai'] ?? true,
      createdAt: DateTime.now(),
      createdBy: null,
      imageUrl: json['image'] ?? json['hinhanh'],
      description: json['description'] ?? json['mota'],
      entryRequirement: json['entryLevel'] ?? json['dauvao'],
      exitRequirement: json['targetLevel'] ?? json['daura'],
      categoryId: (json['courseCategoryId'] ?? json['madanhmuc'])?.toString(),
      categoryName: json['category'] ?? json['danhmuc'],
      level: json['level'],
      totalClasses: totalClasses,
      activeClasses: activeClasses,
      totalStudents: totalStudents,
      totalRevenue: 0.0,
      averageRating: 0.0,
      reviewCount: 0,
    );
  }
}
