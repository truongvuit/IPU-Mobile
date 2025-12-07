import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/class_grade_summary_model.dart';

abstract class TeacherGradesDataSource {
  Future<List<ClassGradeSummaryModel>> getClassGrades(String classId);
}

class TeacherGradesDataSourceImpl implements TeacherGradesDataSource {
  final DioClient dioClient;

  TeacherGradesDataSourceImpl({required this.dioClient});

  @override
  Future<List<ClassGradeSummaryModel>> getClassGrades(String classId) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.teacherClassGrades(classId),
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        final data = response.data['data'];
        if (data == null) return [];

        final className = data['className'] ?? '';
        final courseName = data['courseName'] ?? '';
        final students = data['students'] as List? ?? [];

        
        return students.map((student) {
          
          final enrichedStudent = {
            ...Map<String, dynamic>.from(student),
            'classId': classId,
            'className': className,
            'courseName': courseName,
          };
          return ClassGradeSummaryModel.fromJson(enrichedStudent);
        }).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Không thể tải điểm lớp học',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Không thể tải điểm lớp học',
        );
      }
      throw ServerException(e.message ?? 'Lỗi kết nối mạng');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Không thể tải điểm lớp học: $e');
    }
  }
}
