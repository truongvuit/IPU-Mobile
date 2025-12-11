import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class StudentDrawer extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const StudentDrawer({
    super.key,
    this.currentRoute = '',
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        String displayName = 'Học viên';
        String? displayAvatar;
        bool isLoading = state is StudentLoading || state is StudentInitial;

        if (state is DashboardLoaded && state.profile != null) {
          displayName = state.profile!.fullName;
          displayAvatar = state.profile!.avatarUrl;
        } else if (state is StudentLoaded && state.profile != null) {
          displayName = state.profile!.fullName;
          displayAvatar = state.profile!.avatarUrl;
        } else if (state is ProfileLoaded) {
          displayName = state.profile.fullName;
          displayAvatar = state.profile.avatarUrl;
        } else if (state is ProfileUpdated) {
          displayName = state.profile.fullName;
          displayAvatar = state.profile.avatarUrl;
        }

        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            }
          },
          child: Drawer(
            backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: displayAvatar != null && displayAvatar.isNotEmpty
                            ? ClipOval(
                                child: CustomImage(
                                  imageUrl: displayAvatar,
                                  cacheKey:
                                      '${displayAvatar}_${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
                                  width: 72.w,
                                  height: 72.h,
                                  fit: BoxFit.cover,
                                  isAvatar: true,
                                ),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  'assets/images/avatar-default.png',
                                  width: 72.w,
                                  height: 72.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      SizedBox(height: 16.h),
                      isLoading
                          ? Container(
                              height: 24.h,
                              width: 150.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            )
                          : Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Lexend',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      SizedBox(height: 4.h),
                      Text(
                        'Học viên',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),

                
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 16.h,
                    ),
                    children: [
                      _buildNavItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        title: 'Tổng quan',
                        route: AppRouter.studentDashboard,
                        isDark: isDark,
                      ),
                      SizedBox(height: 4.h),
                      _buildNavItem(
                        context,
                        icon: Icons.class_outlined,
                        activeIcon: Icons.class_,
                        title: 'Lớp học của tôi',
                        route: AppRouter.studentClasses,
                        isDark: isDark,
                      ),
                      SizedBox(height: 4.h),
                      _buildNavItem(
                        context,
                        icon: Icons.calendar_month_outlined,
                        activeIcon: Icons.calendar_month,
                        title: 'Lịch học',
                        route: AppRouter.studentSchedule,
                        isDark: isDark,
                      ),
                      SizedBox(height: 4.h),
                      _buildNavItem(
                        context,
                        icon: Icons.grading_outlined,
                        activeIcon: Icons.grading,
                        title: 'Kết quả học tập',
                        route: AppRouter.studentGrades,
                        isDark: isDark,
                      ),
                      SizedBox(height: 4.h),
                      _buildNavItem(
                        context,
                        icon: Icons.explore_outlined,
                        activeIcon: Icons.explore,
                        title: 'Khám phá khóa học',
                        route: AppRouter.studentCourses,
                        isDark: isDark,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),

                      _buildNavItem(
                        context,
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings,
                        title: 'Cài đặt tài khoản',
                        isDark: isDark,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRouter.settings,
                            arguments: {'userRole': 'student'},
                          );
                        },
                      ),
                    ],
                  ),
                ),

                
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
                      ),
                      SizedBox(height: 16.h),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context, isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Phiên bản 1.0.2',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String title,
    String? route,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    final isActive = route != null && currentRoute == route;
    final color = isActive
        ? AppColors.primary
        : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563));

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(
          isActive ? (activeIcon ?? icon) : icon,
          color: color,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? AppColors.primary
                : (isDark ? Colors.white : const Color(0xFF1F2937)),
            fontFamily: 'Lexend',
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        onTap:
            onTap ??
            () {
              if (route != null) {
                onNavigate(route);
              }
            },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    final authBloc = context.read<AuthBloc>();
    final studentBloc = context.read<StudentBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'Lexend',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
                  fontFamily: 'Lexend',
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF374151),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        Navigator.of(context).pop(); 

                        
                        try {
                          studentBloc.add(const ResetStudentState());
                        } catch (_) {}

                        
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.welcome,
                            (route) => false,
                          );
                        }

                        
                        try {
                          authBloc.add(const LogoutRequested());
                        } catch (_) {}
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
