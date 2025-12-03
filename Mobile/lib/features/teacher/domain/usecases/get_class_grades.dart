import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/class_grade_summary.dart';
import '../repositories/teacher_grades_repository.dart';

class GetClassGrades implements UseCase<List<ClassGradeSummary>, String> {
  final TeacherGradesRepository repository;

  GetClassGrades({required this.repository});

  @override
  Future<Either<Failure, List<ClassGradeSummary>>> call(String classId) async {
    return await repository.getClassGrades(classId);
  }
}
