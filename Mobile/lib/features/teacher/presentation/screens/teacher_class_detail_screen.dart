import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/class_student.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../widgets/student_grid_item.dart';
import '../widgets/teacher_app_bar.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  final String classId;

  const TeacherClassDetailScreen({super.key, required this.classId});

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _studentSearchController =
      TextEditingController();
  String _studentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TeacherBloc>().add(LoadClassDetail(widget.classId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return AppColors.success;
      case 'upcoming':
        return AppColors.info;
      case 'completed':
        return AppColors.neutral500;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return 'Đang diễn ra';
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocListener<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherError) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return BlocBuilder<TeacherBloc, TeacherState>(
              builder: (context, state) {
                if (state is TeacherLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is TeacherError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        isDesktop ? AppSizes.p32 : AppSizes.p24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isDesktop ? 80.sp : 64.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 18.sp : 16.sp,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ClassDetailLoaded) {
                  final classDetail = state.classDetail;
                  final students = state.students;

                  return Column(
                    children: [
                      const TeacherAppBar(
                        title: 'Hiệu suất lớp học',
                        showBackButton: true,
                      ),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSizes.p20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.neutral800 : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    classDetail.name ?? 'Không có tên',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      classDetail.status ?? 'ongoing',
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
                                    ),
                                  ),
                                  child: Text(
                                    _getStatusText(
                                      classDetail.status ?? 'ongoing',
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(
                                        classDetail.status ?? 'ongoing',
                                      ),
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  classDetail.schedule ?? 'Chưa có lịch',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                SizedBox(width: 20.w),
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  classDetail.room ?? 'Chưa có phòng',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(
                        color: isDark ? AppColors.neutral800 : Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: isDark
                              ? Colors.grey[500]
                              : Colors.grey[600],
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Tổng quan'),
                            Tab(text: 'Học viên'),
                            Tab(text: 'Phân tích'),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOverviewTab(
                              classDetail,
                              students,
                              isDark,
                              isDesktop,
                            ),
                            _buildStudentsTab(students, isDark, isDesktop),
                            _buildAnalyticsTab(students, isDark, isDesktop),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    dynamic classDetail,
    List students,
    bool isDark,
    bool isDesktop,
  ) {
    
    double avgAttendance = 0.0;
    double avgScore = 0.0;
    int completedCount = 0;

    if (students.isNotEmpty) {
      
      final totalAttendance = students.fold<double>(0.0, (sum, s) {
        final student = s as ClassStudent;
        return sum + student.attendanceRate;
      });
      avgAttendance = totalAttendance / students.length;

      
      final studentsWithScore = students
          .where((s) => (s as ClassStudent).averageScore != null)
          .toList();
      if (studentsWithScore.isNotEmpty) {
        final totalScore = studentsWithScore.fold<double>(
          0.0,
          (sum, s) => sum + ((s as ClassStudent).averageScore ?? 0),
        );
        avgScore = totalScore / studentsWithScore.length;
      }

      
      completedCount = studentsWithScore.length;
    }

    final completionRate = students.isEmpty
        ? 0.0
        : (completedCount / students.length * 100);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSizes.p32 : AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.3,
            children: [
              _buildMetricCard(
                'Học viên',
                '${students.length}',
                Icons.people,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Điểm danh TB',
                '${avgAttendance.toStringAsFixed(0)}%',
                Icons.check_circle,
                Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Điểm TB',
                avgScore.toStringAsFixed(1),
                Icons.star,
                Colors.orange,
                isDark,
              ),
              _buildMetricCard(
                'Hoàn thành',
                '${completionRate.toStringAsFixed(0)}%',
                Icons.trending_up,
                Colors.purple,
                isDark,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          
        ],
      ),
    );
  }

  Widget _buildStudentsTab(List students, bool isDark, bool isDesktop) {
    
    final filteredStudents = _studentSearchQuery.isEmpty
        ? students
        : students.where((s) {
            final student = s as ClassStudent;
            final query = _studentSearchQuery.toLowerCase();
            return student.fullName.toLowerCase().contains(query) ||
                student.studentCode.toLowerCase().contains(query) ||
                (student.email?.toLowerCase().contains(query) ?? false);
          }).toList();

    return Column(
      children: [
        
        Container(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? AppSizes.p32 : AppSizes.p16,
            AppSizes.p12,
            isDesktop ? AppSizes.p32 : AppSizes.p16,
            AppSizes.p8,
          ),
          child: TextField(
            controller: _studentSearchController,
            onChanged: (value) {
              setState(() {
                _studentSearchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên, mã HV...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.neutral500 : AppColors.textSecondary,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                size: 20.sp,
              ),
              suffixIcon: _studentSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18.sp),
                      onPressed: () {
                        _studentSearchController.clear();
                        setState(() {
                          _studentSearchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.neutral800 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
            ),
          ),
        ),

        
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? AppSizes.p32 : AppSizes.p16,
            vertical: AppSizes.p8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách học viên (${filteredStudents.length})',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (_studentSearchQuery.isNotEmpty &&
                  filteredStudents.length != students.length)
                Text(
                  'Tổng: ${students.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        
        Expanded(
          child: filteredStudents.isEmpty
              ? Center(
                  child: EmptyStateWidget(
                    message: _studentSearchQuery.isNotEmpty
                        ? 'Không tìm thấy học viên phù hợp'
                        : 'Danh sách học viên đang được tải',
                    icon: _studentSearchQuery.isNotEmpty
                        ? Icons.search_off
                        : Icons.people_outline,
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? AppSizes.p32 : AppSizes.p16,
                    AppSizes.p8,
                    isDesktop ? AppSizes.p32 : AppSizes.p16,
                    AppSizes.p24,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: isDesktop ? 2.2 : 1.6,
                  ),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index] as ClassStudent;
                    return StudentGridItem(
                      student: student,
                      onTap: () {
                        _showStudentDetailBottomSheet(context, student);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(List students, bool isDark, bool isDesktop) {
    
    int excellent = 0; 
    int good = 0; 
    int average = 0; 
    int needImprove = 0; 

    for (final s in students) {
      final student = s as ClassStudent;
      final score = student.averageScore;
      if (score == null) continue;

      if (score >= 8.5) {
        excellent++;
      } else if (score >= 7.0) {
        good++;
      } else if (score >= 5.0) {
        average++;
      } else {
        needImprove++;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? AppSizes.p32 : AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral800 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thống kê tổng quan',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Tổng học viên',
                      '${students.length}',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Có điểm',
                      '${excellent + good + average + needImprove}',
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Chưa có điểm',
                      '${students.length - (excellent + good + average + needImprove)}',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Phân khúc học viên theo điểm',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSegmentCard('Xuất sắc (≥8.5)', excellent, Colors.green, isDark),
          SizedBox(height: 8.h),
          _buildSegmentCard('Khá (≥7.0)', good, Colors.blue, isDark),
          SizedBox(height: 8.h),
          _buildSegmentCard(
            'Trung bình (≥5.0)',
            average,
            Colors.orange,
            isDark,
          ),
          SizedBox(height: 8.h),
          _buildSegmentCard(
            'Cần cải thiện (<5.0)',
            needImprove,
            Colors.red,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCard(String label, int count, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            '$count HV',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetailBottomSheet(
    BuildContext context,
    ClassStudent student,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p24),

              Row(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: student.avatarUrl != null
                        ? NetworkImage(student.avatarUrl!)
                        : null,
                    child: student.avatarUrl == null
                        ? Text(
                            student.fullName.isNotEmpty
                                ? student.fullName.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Mã HV: ${student.studentCode}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.p24),
              const Divider(),
              SizedBox(height: AppSizes.p16),

              Text(
                'Thông tin liên hệ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: AppSizes.p12),

              if (student.email != null)
                _buildInfoRow(Icons.email_outlined, 'Email', student.email!),
              if (student.phoneNumber != null)
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Điện thoại',
                  student.phoneNumber!,
                ),

              SizedBox(height: AppSizes.p20),

              Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: AppSizes.p12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Điểm TB',
                      student.averageScore?.toStringAsFixed(1) ?? '--',
                      Icons.star_outline,
                      AppColors.warning,
                    ),
                  ),
                  SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: _buildStatCard(
                      'Có mặt',
                      '${student.totalPresences}',
                      Icons.check_circle_outline,
                      AppColors.success,
                    ),
                  ),
                  SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: _buildStatCard(
                      'Vắng',
                      '${student.totalAbsences}',
                      Icons.cancel_outlined,
                      AppColors.error,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.p20),

              _buildInfoRow(
                Icons.calendar_today_outlined,
                'Ngày tham gia',
                DateFormatter.formatDate(student.enrollmentDate),
              ),

              SizedBox(height: AppSizes.p20),

              Container(
                padding: EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tỷ lệ chuyên cần',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${student.attendanceRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: AppSizes.p12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
