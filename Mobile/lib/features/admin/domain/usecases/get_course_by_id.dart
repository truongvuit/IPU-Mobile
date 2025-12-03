import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/course_detail.dart';
import '../repositories/admin_course_repository.dart';

class GetCourseById implements UseCase<CourseDetail, String> {
  final AdminCourseRepository repository;

  GetCourseById({required this.repository});

  @override
  Future<Either<Failure, CourseDetail>> call(String id) async {
    return await repository.getCourseById(id);
  }
}
