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

        // Parse response format từ ClassGradesResponse
        final className = data['className'] ?? '';
        final courseName = data['courseName'] ?? '';
        final students = data['students'] as List? ?? [];

        return students.map((student) {
          // Map từ API response format sang ClassGradeSummaryModel format
          return ClassGradeSummaryModel.fromJson({
            'mahocvien': student['studentId']?.toString() ?? '',
            'ten_hocvien': student['studentName'] ?? '',
            'email': student['email'] ?? '',
            'sdt': '', // API không trả về phone
            'malop': classId,
            'tenlop': className,
            'tenkhoahoc': courseName,
            'diem_chuyencan': student['attendanceScore']?.toDouble(),
            'diem_giuaky': student['midtermScore']?.toDouble(),
            'diem_cuoiky': student['finalScore']?.toDouble(),
            'diem_tongket': student['totalScore']?.toDouble() ?? 0.0,
            'xeploai': student['grade'] ?? _getClassification(student['totalScore']?.toDouble()),
            'ngay_chamdiem_cuoicung': student['finalGrade']?['gradedAt'],
            'trangthai_hoantat': student['status'] ?? 'Chưa hoàn thành',
          });
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

  String _getClassification(double? score) {
    if (score == null) return 'Chưa xếp loại';
    if (score >= 8.5) return 'Xuất sắc';
    if (score >= 7.0) return 'Giỏi';
    if (score >= 5.5) return 'Khá';
    if (score >= 4.0) return 'Trung bình';
    return 'Yếu';
  }
}
