import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/student_class.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_image.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadClassDetail(widget.classId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark
          ? const Color(0xFF101622)
          : const Color(0xFFF6F6F8),

      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state is StudentLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is StudentError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ClassDetailLoaded) {
              final studentClass = state.studentClass;

              
              String scheduleText = 'Chưa có lịch';
              if (studentClass.schedule.isNotEmpty) {
                final weekdays = <int>{};
                for (var dt in studentClass.schedule) {
                  weekdays.add(dt.weekday);
                }
                final sortedDays = weekdays.toList()..sort();
                const dayNames = [
                  '',
                  'Thứ 2',
                  'Thứ 3',
                  'Thứ 4',
                  'Thứ 5',
                  'Thứ 6',
                  'Thứ 7',
                  'CN',
                ];
                scheduleText = sortedDays.map((d) => dayNames[d]).join(', ');
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180.h,
                    pinned: true,
                    backgroundColor: isDark
                        ? const Color(0xFF101622)
                        : const Color(0xFFF6F6F8),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24.w,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'Chi tiết Lớp học',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Lexend',
                          color: Colors.white,
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          
                          if (studentClass.imageUrl.isEmpty)
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF6B35), 
                                    Color(0xFFE85A24),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.school,
                                  size: 64.sp,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          else
                            CustomImage(
                              imageUrl: studentClass.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentClass.courseName,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontFamily: 'Lexend',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Mã lớp: ${studentClass.id}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildSection(
                            isDark,
                            'Thông tin cơ bản',
                            Column(
                              children: [
                                _buildInfoRow(
                                  Icons.calendar_month,
                                  'Lịch học',
                                  scheduleText,
                                  isDark,
                                ),
                                SizedBox(height: 12.h),
                                _buildInfoRow(
                                  studentClass.isOnline
                                      ? Icons.videocam
                                      : Icons.meeting_room,
                                  studentClass.isOnline
                                      ? 'Online'
                                      : 'Phòng học',
                                  studentClass.room,
                                  isDark,
                                ),
                                SizedBox(height: 12.h),
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Thời gian',
                                  '${timeFormat.format(studentClass.startTime)} - ${timeFormat.format(studentClass.endTime)}',
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: _buildSection(
                            isDark,
                            'Giảng viên',
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32.r,
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  backgroundImage: const AssetImage(
                                    'assets/images/avatar-default.png',
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentClass.teacherName,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontFamily: 'Lexend',
                                        ),
                                      ),
                                      
                                      if (studentClass.teacherEmail != null &&
                                          studentClass
                                              .teacherEmail!
                                              .isNotEmpty) ...[
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 14.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Text(
                                                studentClass.teacherEmail!,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontFamily: 'Lexend',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (studentClass.teacherSpecialization !=
                                          null) ...[
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Chuyên ngành: ${studentClass.teacherSpecialization}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColors.textSecondary,
                                            fontFamily: 'Lexend',
                                          ),
                                        ),
                                      ],
                                      if (studentClass.teacherCertificates !=
                                          null) ...[
                                        SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 14.sp,
                                              color: AppColors.success,
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Text(
                                                studentClass
                                                    .teacherCertificates!,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColors.success,
                                                  fontFamily: 'Lexend',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        
                        if (studentClass.courseType != null ||
                            studentClass.level != null ||
                            studentClass.duration != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: _buildSection(
                              isDark,
                              'Thông tin khóa học',
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (studentClass.courseType != null) ...[
                                    _buildCourseInfoRow(
                                      Icons.school_outlined,
                                      'Loại khóa học',
                                      studentClass.courseType!,
                                      isDark,
                                    ),
                                    SizedBox(height: 10.h),
                                  ],
                                  if (studentClass.level != null) ...[
                                    _buildCourseInfoRow(
                                      Icons.signal_cellular_alt,
                                      'Trình độ',
                                      studentClass.level!,
                                      isDark,
                                    ),
                                    SizedBox(height: 10.h),
                                  ],
                                  if (studentClass.duration != null)
                                    _buildCourseInfoRow(
                                      Icons.timer_outlined,
                                      'Thời lượng',
                                      studentClass.duration!,
                                      isDark,
                                    ),
                                ],
                              ),
                            ),
                          ),

                        if (studentClass.courseType != null ||
                            studentClass.level != null ||
                            studentClass.duration != null)
                          SizedBox(height: 12.h),

                        if (studentClass.students.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: _buildStudentListSection(
                              isDark,
                              studentClass.students,
                            ),
                          ),

                        SizedBox(height: 16.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentGrades,
                                  arguments: studentClass.courseName,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Xem điểm số',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentRating,
                                  arguments: studentClass
                                      .id, 
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                side: BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Đánh giá khóa học',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSection(bool isDark, String title, Widget content) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 12.h),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Lexend',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lexend',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  
  Widget _buildStudentListSection(bool isDark, List<ClassStudent> students) {
    const int maxVisible = 5;
    final bool hasMore = students.length > maxVisible;
    final displayStudents = hasMore
        ? students.take(maxVisible).toList()
        : students;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách học viên (${students.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lexend',
                ),
              ),
              if (hasMore)
                TextButton(
                  onPressed: () {
                    _showAllStudentsModal(context, students, isDark);
                  },
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ...displayStudents.map(
            (student) => _buildStudentItem(student, isDark),
          ),
          if (hasMore)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Center(
                child: Text(
                  '+ ${students.length - maxVisible} học viên khác',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(ClassStudent student, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : AppColors.neutral50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            backgroundImage:
                (student.avatarUrl != null && student.avatarUrl!.isNotEmpty)
                ? NetworkImage(student.avatarUrl!)
                : const AssetImage('assets/images/avatar-default.png')
                      as ImageProvider,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
                Text(
                  student.code,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllStudentsModal(
    BuildContext context,
    List<ClassStudent> students,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách học viên (${students.length})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.border),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildStudentItem(students[index], isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
