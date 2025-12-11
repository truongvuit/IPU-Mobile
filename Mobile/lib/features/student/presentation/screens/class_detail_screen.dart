import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';
import '../widgets/class_detail/class_detail_widgets.dart';

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
              if (studentClass.schedulePattern != null &&
                  studentClass.schedulePattern!.isNotEmpty) {
                scheduleText = studentClass.schedulePattern!;
              } else if (studentClass.schedule.isNotEmpty) {
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

              String timeText = 'Chưa có giờ';
              if (studentClass.dailyStartTime != null &&
                  studentClass.dailyEndTime != null) {
                
                try {
                  final start = studentClass.dailyStartTime!.substring(0, 5);
                  final end = studentClass.dailyEndTime!.substring(0, 5);
                  timeText = '$start - $end';
                } catch (e) {
                  timeText =
                      '${studentClass.dailyStartTime} - ${studentClass.dailyEndTime}';
                }
              } else {
                timeText =
                    '${timeFormat.format(studentClass.startTime)} - ${timeFormat.format(studentClass.endTime)}';
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
                          child: ClassBasicInfoSection(
                            isDark: isDark,
                            scheduleText: scheduleText,
                            isOnline: studentClass.isOnline,
                            room: studentClass.room,
                            timeText: timeText,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ClassTeacherCard(
                            isDark: isDark,
                            teacherName: studentClass.teacherName,
                            teacherEmail: studentClass.teacherEmail,
                            teacherSpecialization:
                                studentClass.teacherSpecialization,
                            teacherCertificates:
                                studentClass.teacherCertificates,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        if (studentClass.courseType != null ||
                            studentClass.level != null ||
                            studentClass.duration != null)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: ClassCourseInfoSection(
                              isDark: isDark,
                              courseType: studentClass.courseType,
                              level: studentClass.level,
                              duration: studentClass.duration,
                            ),
                          ),

                        if (studentClass.courseType != null ||
                            studentClass.level != null ||
                            studentClass.duration != null)
                          SizedBox(height: 12.h),

                        if (studentClass.students.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: ClassStudentListSection(
                              isDark: isDark,
                              students: studentClass.students,
                            ),
                          ),

                        SizedBox(height: 16.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ClassDetailActions(
                            classId: studentClass.id,
                            className: studentClass.courseName,
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
}
