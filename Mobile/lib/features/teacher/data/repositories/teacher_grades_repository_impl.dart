import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/class_grade_summary.dart';
import '../../domain/repositories/teacher_grades_repository.dart';
import '../datasources/teacher_grades_data_source.dart';

class TeacherGradesRepositoryImpl implements TeacherGradesRepository {
  final TeacherGradesDataSource dataSource;

  TeacherGradesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ClassGradeSummary>>> getClassGrades(
    String classId,
  ) async {
    try {
      final models = await dataSource.getClassGrades(classId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
