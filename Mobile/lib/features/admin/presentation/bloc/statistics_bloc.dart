import 'package:flutter_bloc/flutter_bloc.dart';

import 'statistics_event.dart';
import 'statistics_state.dart';

import '../../domain/entities/revenue_statistics.dart';
import '../../domain/entities/student_statistics.dart';
import '../../domain/entities/teacher_statistics.dart';
import '../../domain/entities/classroom_statistics.dart';
import '../../domain/entities/course_statistics.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc() : super(const StatisticsInitial()) {
    on<LoadRevenueStatistics>(_onLoadRevenueStatistics);
    on<LoadStudentStatistics>(_onLoadStudentStatistics);
    on<LoadTeacherStatistics>(_onLoadTeacherStatistics);
    on<LoadClassroomStatistics>(_onLoadClassroomStatistics);
    on<LoadCourseStatistics>(_onLoadCourseStatistics);
    on<ExportRevenueReport>(_onExportRevenueReport);
    on<ExportStudentReport>(_onExportStudentReport);
    on<ExportTeacherReport>(_onExportTeacherReport);
    on<ExportClassroomReport>(_onExportClassroomReport);
  }

  Future<void> _onLoadRevenueStatistics(
    LoadRevenueStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final statistics = _getMockRevenueStatistics();

      emit(
        RevenueStatisticsLoaded(
          statistics: statistics,
          selectedMonth: event.month,
          selectedYear: event.year,
        ),
      );
    } catch (e) {
      emit(StatisticsError('Không thể tải báo cáo doanh thu: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStudentStatistics(
    LoadStudentStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final statistics = _getMockStudentStatistics();

      emit(StudentStatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError('Không thể tải báo cáo học viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTeacherStatistics(
    LoadTeacherStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final statistics = _getMockTeacherStatistics();

      emit(TeacherStatisticsLoaded(statistics));
    } catch (e) {
      emit(
        StatisticsError('Không thể tải báo cáo giảng viên: ${e.toString()}'),
      );
    }
  }

  Future<void> _onLoadClassroomStatistics(
    LoadClassroomStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final statistics = _getMockClassroomStatistics();

      emit(ClassroomStatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError('Không thể tải báo cáo phòng học: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCourseStatistics(
    LoadCourseStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final statistics = _getMockCourseStatistics();

      emit(CourseStatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError('Không thể tải báo cáo khóa học: ${e.toString()}'));
    }
  }

  Future<void> _onExportRevenueReport(
    ExportRevenueReport event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const RevenueReportExporting());

    try {
      await Future.delayed(const Duration(seconds: 2));

      final filePath = '/downloads/revenue_report.${event.format}';

      emit(RevenueReportExported(filePath: filePath, format: event.format));
    } catch (e) {
      emit(StatisticsError('Không thể xuất báo cáo: ${e.toString()}'));
    }
  }

  Future<void> _onExportStudentReport(
    ExportStudentReport event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StudentReportExporting());

    try {
      await Future.delayed(const Duration(seconds: 2));

      final filePath = '/downloads/student_report.${event.format}';

      emit(StudentReportExported(filePath: filePath, format: event.format));
    } catch (e) {
      emit(StatisticsError('Không thể xuất báo cáo: ${e.toString()}'));
    }
  }

  Future<void> _onExportTeacherReport(
    ExportTeacherReport event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const TeacherReportExporting());

    try {
      await Future.delayed(const Duration(seconds: 2));

      final filePath = '/downloads/teacher_report.${event.format}';

      emit(TeacherReportExported(filePath: filePath, format: event.format));
    } catch (e) {
      emit(StatisticsError('Không thể xuất báo cáo: ${e.toString()}'));
    }
  }

  Future<void> _onExportClassroomReport(
    ExportClassroomReport event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const ClassroomReportExporting());

    try {
      await Future.delayed(const Duration(seconds: 2));

      final filePath = '/downloads/classroom_report.${event.format}';

      emit(ClassroomReportExported(filePath: filePath, format: event.format));
    } catch (e) {
      emit(StatisticsError('Không thể xuất báo cáo: ${e.toString()}'));
    }
  }

  
  RevenueStatistics _getMockRevenueStatistics() {
    return RevenueStatistics(
      totalRevenue: 1200000000, 
      monthlyRevenue: 50000000, 
      growthRate: 15.2,
      revenueByMonth: {
        'T1': 45000000,
        'T2': 48000000,
        'T3': 52000000,
        'T4': 49000000,
        'T5': 51000000,
        'T6': 50000000,
      },
      revenueByCourse: {
        'IELTS': 30000000,
        'TOEIC': 15000000,
        'Giao tiếp': 5000000,
      },
      revenueByTeacher: {
        'Ms. Alines': 20000000,
        'Ms. Tram': 18000000,
        'Ms. Gabby': 12000000,
      },
      monthlyData: [
        MonthlyRevenue(
          month: 1,
          year: 2024,
          revenue: 45000000,
          target: 40000000,
        ),
        MonthlyRevenue(
          month: 2,
          year: 2024,
          revenue: 48000000,
          target: 45000000,
        ),
        MonthlyRevenue(
          month: 3,
          year: 2024,
          revenue: 52000000,
          target: 45000000,
        ),
        MonthlyRevenue(
          month: 4,
          year: 2024,
          revenue: 49000000,
          target: 45000000,
        ),
        MonthlyRevenue(
          month: 5,
          year: 2024,
          revenue: 51000000,
          target: 50000000,
        ),
        MonthlyRevenue(
          month: 6,
          year: 2024,
          revenue: 50000000,
          target: 50000000,
        ),
      ],
    );
  }

  StudentStatistics _getMockStudentStatistics() {
    return StudentStatistics(
      totalStudents: 85,
      newStudents: 12,
      completionRate: 82.0,
      conversionRate: 90.0,
      studentsByRegion: {'Hà Nội': 45, 'TP.HCM': 25, 'Đà Nẵng': 10, 'Khác': 5},
      studentsBySource: {
        'Website': 40,
        'Facebook': 25,
        'Giới thiệu': 15,
        'Khác': 5,
      },
      topStudents: [
        TopStudent(
          studentId: 's1',
          studentName: 'Nguyễn Văn An',
          averageScore: 9.2,
          coursesCompleted: 3,
          attendanceRate: 98.0,
        ),
        TopStudent(
          studentId: 's2',
          studentName: 'Trần Thị Bình',
          averageScore: 8.8,
          coursesCompleted: 2,
          attendanceRate: 95.0,
        ),
        TopStudent(
          studentId: 's3',
          studentName: 'Lê Văn Cường',
          averageScore: 8.5,
          coursesCompleted: 2,
          attendanceRate: 92.0,
        ),
      ],
      potentialStudents: [
        PotentialStudent(
          studentId: 'p1',
          studentName: 'Phạm Thị Dung',
          phoneNumber: '0912345678',
          status: 'Đang học',
          lastContact: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PotentialStudent(
          studentId: 'p2',
          studentName: 'Hoàng Văn Em',
          phoneNumber: '0987654321',
          status: 'Vắng học',
          lastContact: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
    );
  }

  TeacherStatistics _getMockTeacherStatistics() {
    return TeacherStatistics(
      totalTeachers: 15,
      teachersByDepartment: {
        'IELTS': 5,
        'TOEIC': 4,
        'Giao tiếp': 4,
        'Trẻ em': 2,
      },
      teachersBySpecialization: {
        'Nghe - Nói': 6,
        'Đọc - Viết': 5,
        'Ngữ pháp': 4,
      },
      topTeachers: [
        TopTeacher(
          teacherId: 't1',
          teacherName: 'Ms. Alines',
          rating: 4.9,
          totalClasses: 8,
          totalStudents: 120,
          attendanceRate: 95.0,
          specialization: 'IELTS',
        ),
        TopTeacher(
          teacherId: 't2',
          teacherName: 'Ms. Tram',
          rating: 4.7,
          totalClasses: 6,
          totalStudents: 90,
          attendanceRate: 92.0,
          specialization: 'TOEIC',
        ),
        TopTeacher(
          teacherId: 't3',
          teacherName: 'Ms. Gabby',
          rating: 4.6,
          totalClasses: 5,
          totalStudents: 75,
          attendanceRate: 90.0,
          specialization: 'Giao tiếp',
        ),
      ],
      averageRating: 4.5,
      attendanceRate: 78.0,
    );
  }

  ClassroomStatistics _getMockClassroomStatistics() {
    return ClassroomStatistics(
      totalRooms: 15,
      availableRooms: 5,
      occupiedRooms: 8,
      maintenanceRooms: 2,
      utilizationRate: 76.0,
      roomUsage: [
        ClassroomUsage(
          roomId: 'r1',
          roomName: 'Phòng A101',
          status: RoomStatus.occupied,
          capacity: 20,
          totalHoursUsed: 35,
          totalHoursAvailable: 40,
          schedule: [
            RoomSchedule(
              classId: '1',
              className: 'IELTS 6.5',
              timeSlot: '18:00 - 20:00',
              dayOfWeek: 'T2-T4-T6',
              teacherName: 'Ms. Alines',
            ),
          ],
        ),
      ],
      usageByTimeSlot: {'Sáng': 10, 'Chiều': 15, 'Tối': 25},
    );
  }

  CourseStatistics _getMockCourseStatistics() {
    return CourseStatistics(
      totalCourses: 12,
      activeCourses: 8,
      popularCourses: [
        PopularCourse(
          courseId: 'c1',
          courseName: 'IELTS Intensive',
          totalStudents: 150,
          averageRating: 4.8,
          totalClasses: 10,
        ),
        PopularCourse(
          courseId: 'c2',
          courseName: 'TOEIC Foundation',
          totalStudents: 120,
          averageRating: 4.5,
          totalClasses: 8,
        ),
        PopularCourse(
          courseId: 'c3',
          courseName: 'Giao tiếp cơ bản',
          totalStudents: 90,
          averageRating: 4.6,
          totalClasses: 6,
        ),
        PopularCourse(
          courseId: 'c4',
          courseName: 'Tiếng Anh trẻ em',
          totalStudents: 60,
          averageRating: 4.9,
          totalClasses: 4,
        ),
      ],
      enrollmentTrend: [
        CourseEnrollmentTrend(month: 'T1', enrollments: 40),
        CourseEnrollmentTrend(month: 'T2', enrollments: 45),
        CourseEnrollmentTrend(month: 'T3', enrollments: 55),
        CourseEnrollmentTrend(month: 'T4', enrollments: 50),
        CourseEnrollmentTrend(month: 'T5', enrollments: 60),
        CourseEnrollmentTrend(month: 'T6', enrollments: 65),
      ],
    );
  }
}
