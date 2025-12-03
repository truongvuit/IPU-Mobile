import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_course_repository.dart';

class DeleteCourse implements UseCase<void, String> {
  final AdminCourseRepository repository;

  DeleteCourse({required this.repository});

  @override
  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteCourse(id);
  }
}
