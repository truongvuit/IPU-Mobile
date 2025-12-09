import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:trungtamngoaingu/features/student/domain/entities/student_profile.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/schedule.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/dashboard/streak_indicator.dart';
import '../widgets/dashboard/progress_circle.dart';
import '../widgets/dashboard/performance_card.dart';
import '../widgets/dashboard/today_focus_card.dart';

class StudentHomeTab extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const StudentHomeTab({super.key, required this.onOpenDrawer});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load dashboard data when tab first opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentBloc>().add(const LoadDashboard());
      }
    });
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        int activeCourses = 0;
        if (state is DashboardLoaded && state.profile != null) {
          activeCourses = state.profile!.activeCourses;
        } else if (state is StudentLoaded && state.profile != null) {
          activeCourses = state.profile!.activeCourses;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: isDesktop ? 24.sp : 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Theo dõi tiến độ học tập của bạn',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              StreakIndicator(streakDays: activeCourses, isDark: isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayFocus(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading || state is StudentInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tập trung hôm nay',
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is StudentError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Không thể tải lịch học',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.error,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<StudentBloc>().add(const LoadDashboard());
                    },
                    child: Text('Thử lại', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ),
            ),
          );
        }

        List<Schedule> todaySchedules = [];

        if (state is DashboardLoaded) {
          todaySchedules = state.todaySchedules;
        }

        if (todaySchedules.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        Schedule? nextSchedule;
        for (var s in todaySchedules) {
          if (s.endTime.isAfter(now)) {
            nextSchedule = s;
            break;
          }
        }

        if (nextSchedule == null) {
          return const SizedBox.shrink();
        }

        final startHour = nextSchedule.startTime.hour.toString().padLeft(
          2,
          '0',
        );
        final startMin = nextSchedule.startTime.minute.toString().padLeft(
          2,
          '0',
        );
        final endHour = nextSchedule.endTime.hour.toString().padLeft(2, '0');
        final endMin = nextSchedule.endTime.minute.toString().padLeft(2, '0');
        final timeSlot = '$startHour:$startMin - $endHour:$endMin';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tập trung hôm nay',
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              TodayFocusCard(
                className: nextSchedule.courseName ?? nextSchedule.className,
                timeSlot: timeSlot,
                room: nextSchedule.room,
                isOnline: nextSchedule.isOnline,
                isDark: isDark,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.studentClassDetail,
                    arguments: nextSchedule!.classId,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLearningProgress(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading || state is StudentInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is StudentError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Không thể tải tiến độ học tập',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.error,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<StudentBloc>().add(
                            const LoadDashboard(),
                          );
                        },
                        child: Text(
                          'Thử lại',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        double courseProgress = 0.0;
        double attendanceProgress = 0.0;
        double assignmentProgress = 0.0;

        List<StudentClass> classes = [];
        if (state is DashboardLoaded) {
          classes = state.upcomingClasses;
        } else if (state is ClassesLoaded) {
          classes = state.classes;
        } else if (state is StudentLoaded && state.classes != null) {
          classes = state.classes!;
        }

        if (classes.isNotEmpty) {
          double totalAttendance = 0.0;
          double totalProgress = 0.0;
          for (var c in classes) {
            totalAttendance += c.attendanceRate;
            totalProgress += c.progress;
          }
          attendanceProgress = totalAttendance / classes.length / 100;
          courseProgress = totalProgress / classes.length / 100;

          assignmentProgress = (courseProgress + attendanceProgress) / 2;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiến độ học tập',
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ProgressCircle(
                    progress: courseProgress.clamp(0.0, 1.0),
                    label: 'Hoàn thành\nkhóa học',
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  ProgressCircle(
                    progress: attendanceProgress.clamp(0.0, 1.0),
                    label: 'Điểm danh',
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                  ProgressCircle(
                    progress: assignmentProgress.clamp(0.0, 1.0),
                    label: 'Bài tập',
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceSnapshot(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading || state is StudentInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thành tích',
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: isDesktop ? 1.4 : 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: isDesktop ? 1.4 : 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (state is StudentError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thành tích',
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Không thể tải thành tích',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.error,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<StudentBloc>().add(
                            const LoadDashboard(),
                          );
                        },
                        child: Text(
                          'Thử lại',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        double gpa = 0.0;
        int activeCourses = 0;
        int onlineCount = 0;
        int offlineCount = 0;

        StudentProfile? profile;
        List<StudentClass> classes = [];

        if (state is DashboardLoaded) {
          profile = state.profile;
          classes = state.upcomingClasses;
        } else if (state is StudentLoaded) {
          profile = state.profile;
          classes = state.classes ?? [];
        }

        if (profile != null) {
          gpa = profile.gpa;
          activeCourses = profile.activeCourses;
        }

        for (var c in classes) {
          if (c.isOnline) {
            onlineCount++;
          } else {
            offlineCount++;
          }
        }

        String classSubtitle = '';
        if (onlineCount > 0 || offlineCount > 0) {
          List<String> parts = [];
          if (onlineCount > 0) parts.add('$onlineCount online');
          if (offlineCount > 0) parts.add('$offlineCount offline');
          classSubtitle = parts.join(', ');
        } else {
          classSubtitle = 'Chưa đăng ký lớp nào';
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thành tích',
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: isDesktop ? 1.4 : 0.9,
                          child: PerformanceCard(
                            title: 'Điểm trung bình',
                            value: gpa > 0 ? gpa.toStringAsFixed(1) : '--',
                            subtitle: gpa > 0
                                ? 'Điểm GPA hiện tại'
                                : 'Chưa có điểm',
                            icon: Icons.trending_up,
                            color: Colors.green,
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.studentGrades,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: isDesktop ? 1.4 : 0.9,
                          child: PerformanceCard(
                            title: 'Lớp đang học',
                            value: activeCourses.toString(),
                            subtitle: classSubtitle,
                            icon: Icons.school,
                            color: Colors.blue,
                            isDark: isDark,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.studentClasses,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExploreCourses(bool isDark, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRouter.studentCourses);
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Khám phá khóa học',
                          style: TextStyle(
                            fontSize: isDesktop ? 18.sp : 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tìm kiếm và đăng ký các khóa học phù hợp với bạn',
                      style: TextStyle(
                        fontSize: isDesktop ? 14.sp : 12.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: widget.onOpenDrawer,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào!',
              style: TextStyle(
                fontSize: isDesktop ? 24.sp : 20.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'Lexend',
              ),
            ),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                String displayName = '';
                bool isLoading =
                    state is StudentLoading || state is StudentInitial;

                if (state is DashboardLoaded && state.profile != null) {
                  displayName = state.profile!.fullName;
                } else if (state is StudentLoaded && state.profile != null) {
                  displayName = state.profile!.fullName;
                } else if (state is ProfileLoaded) {
                  displayName = state.profile.fullName;
                } else if (state is ProfileUpdated) {
                  displayName = state.profile.fullName;
                }

                if (isLoading && displayName.isEmpty) {
                  return Container(
                    height: 14.h,
                    width: 100.w,
                    margin: EdgeInsets.only(top: 2.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }

                if (displayName.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Text(
                  displayName,
                  style: TextStyle(
                    fontSize: isDesktop ? 14.sp : 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontFamily: 'Lexend',
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: isDesktop ? 26.sp : 24.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<StudentBloc>().add(const LoadDashboard());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark, isDesktop),
              SizedBox(height: 24.h),
              _buildExploreCourses(isDark, isDesktop),
              SizedBox(height: 24.h),
              _buildLearningProgress(isDark, isDesktop),
              SizedBox(height: 24.h),
              _buildPerformanceSnapshot(isDark, isDesktop),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingClassesCarousel(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        if (state is StudentLoading || state is StudentInitial) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Text(
                  'Lớp học sắp tới',
                  style: TextStyle(
                    fontSize: isDesktop ? 20.sp : 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              SizedBox(
                height: isDesktop ? 200.h : 180.h,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        if (state is StudentError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Text(
                  'Lớp học sắp tới',
                  style: TextStyle(
                    fontSize: isDesktop ? 20.sp : 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Không thể tải danh sách lớp học',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.error,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<StudentBloc>().add(
                            const LoadDashboard(),
                          );
                        },
                        child: Text(
                          'Thử lại',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        List<StudentClass> upcomingClasses = [];

        if (state is DashboardLoaded) {
          upcomingClasses = state.upcomingClasses;
        } else if (state is ClassesLoaded) {
          upcomingClasses = state.classes;
        } else if (state is StudentLoaded && state.classes != null) {
          upcomingClasses = state.classes!;
        }

        if (upcomingClasses.isNotEmpty) {
          final displayClasses = upcomingClasses.take(5).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                child: Text(
                  'Lớp học sắp tới',
                  style: TextStyle(
                    fontSize: isDesktop ? 20.sp : 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              CarouselSlider.builder(
                itemCount: displayClasses.length,
                options: CarouselOptions(
                  height: isDesktop ? 200.h : 180.h,
                  viewportFraction: isDesktop ? 0.5 : 0.85,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: displayClasses.length > 1,
                  autoPlay: displayClasses.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final classItem = displayClasses[index];
                  return _buildClassCard(classItem, isDark, isDesktop);
                },
              ),
              if (displayClasses.length > 1)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: displayClasses.asMap().entries.map((entry) {
                      return Container(
                        width: _currentCarouselIndex == entry.key ? 24.w : 8.w,
                        height: 8.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: _currentCarouselIndex == entry.key
                              ? AppColors.primary
                              : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48.sp,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Chưa có lớp học nào',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassCard(StudentClass classItem, bool isDark, bool isDesktop) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.studentClassDetail,
          arguments: classItem.id,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              classItem.isOnline
                                  ? '🌐 Online'
                                  : '📍 ${classItem.room}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            classItem.courseName,
                            style: TextStyle(
                              fontSize: isDesktop ? 16.sp : 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            classItem.teacherName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                      ],
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
}
