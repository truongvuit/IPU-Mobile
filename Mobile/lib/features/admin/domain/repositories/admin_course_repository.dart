import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../admin/data/models/course_detail_model.dart';
import '../entities/course_detail.dart';

abstract class AdminCourseRepository {
  Future<Either<Failure, List<CourseDetail>>> getCourses({
    String? search,
    String? categoryId,
    bool? isActive,
  });

  Future<Either<Failure, CourseDetail>> getCourseById(String id);

  Future<Either<Failure, CourseDetail>> updateCourse(
    String id,
    UpdateCourseRequest request,
  );

  
  Future<Either<Failure, void>> toggleCourseStatus(String id);

  Future<Either<Failure, void>> deleteCourse(String id);
}
