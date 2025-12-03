import '../models/course_detail_model.dart';

abstract class AdminCourseDataSource {
  Future<List<CourseDetailModel>> getCourses({
    String? search,
    String? categoryId,
    bool? isActive,
  });

  Future<CourseDetailModel> getCourseById(String id);

  Future<CourseDetailModel> updateCourse(
    String id,
    UpdateCourseRequest request,
  );

  Future<void> deleteCourse(String id);
}
