import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/class_grade_summary.dart';

abstract class TeacherGradesRepository {
  Future<Either<Failure, List<ClassGradeSummary>>> getClassGrades(
    String classId,
  );
}
