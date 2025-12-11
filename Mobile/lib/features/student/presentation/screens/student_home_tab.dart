import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trungtamngoaingu/features/student/domain/entities/student_profile.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/student_class.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/dashboard/streak_indicator.dart';
import '../widgets/dashboard/performance_card.dart';

class StudentHomeTab extends StatefulWidget {
  final VoidCallback onOpenDrawer;

  const StudentHomeTab({super.key, required this.onOpenDrawer});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = context.read<StudentBloc>().state;
        if (state is! DashboardLoaded) {
          context.read<StudentBloc>().add(const LoadDashboard());
        }
      }
    });
  }

  Widget _buildHeader(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (previous, current) {
        if (current is StudentLoading && current.action != 'LoadDashboard') {
          return false;
        }
        return true;
      },
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

  Widget _buildPerformanceSnapshot(bool isDark, bool isDesktop) {
    return BlocBuilder<StudentBloc, StudentState>(
      buildWhen: (previous, current) {
        if (current is StudentLoading && current.action != 'LoadDashboard') {
          return false;
        }
        return true;
      },
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
          gpa = state.gpa ?? 0.0;
          activeCourses = state.activeCoursesCount ?? 0;
        } else if (state is StudentLoaded) {
          profile = state.profile;
          classes = state.classes ?? [];
          if (profile != null) {
            gpa = profile.gpa;
            activeCourses = profile.activeCourses;
          }
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
              buildWhen: (previous, current) {
                if (current is StudentLoading &&
                    current.action != 'LoadDashboard' &&
                    current.action != 'LoadProfile' &&
                    current.action != 'UpdateProfile') {
                  return false;
                }
                return true;
              },
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
        actions: [SizedBox(width: 8.w)],
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
              _buildPerformanceSnapshot(isDark, isDesktop),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}
