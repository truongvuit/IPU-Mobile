import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../admin/data/models/course_detail_model.dart';
import '../entities/course_detail.dart';
import '../repositories/admin_course_repository.dart';

class UpdateCourse implements UseCase<CourseDetail, UpdateCourseParams> {
  final AdminCourseRepository repository;

  UpdateCourse({required this.repository});

  @override
  Future<Either<Failure, CourseDetail>> call(UpdateCourseParams params) async {
    return await repository.updateCourse(params.id, params.request);
  }
}

class UpdateCourseParams {
  final String id;
  final UpdateCourseRequest request;

  UpdateCourseParams({required this.id, required this.request});
}
