import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
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
            child: SafeArea(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      onNavigate(AppRouter.studentProfile);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFF135BEC,
                              ).withValues(alpha: 0.2),
                            ),
                            child:
                                displayAvatar != null &&
                                    displayAvatar.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      displayAvatar,
                                      width: 64.w,
                                      height: 64.h,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return ClipOval(
                                          child: Image.asset(
                                            'assets/images/avatar-default.png',
                                            width: 64.w,
                                            height: 64.h,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Color(0xFF135BEC)),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.asset(
                                      'assets/images/avatar-default.png',
                                      width: 64.w,
                                      height: 64.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: isLoading
                                ? Container(
                                    height: 20.h,
                                    width: 120.w,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  )
                                : Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontFamily: 'Lexend',
                                    ),
                                  ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      children: [
                        _buildNavItem(
                          context,
                          icon: Icons.home_outlined,
                          title: 'Trang chủ',
                          route: AppRouter.studentDashboard,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context,
                          icon: Icons.class_outlined,
                          title: 'Các lớp học của tôi',
                          route: AppRouter.studentClasses,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context,
                          icon: Icons.calendar_month_outlined,
                          title: 'Lịch học',
                          route: AppRouter.studentSchedule,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context,
                          icon: Icons.grading_outlined,
                          title: 'Điểm số',
                          route: AppRouter.studentGrades,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context,
                          icon: Icons.book_outlined,
                          title: 'Khóa học',
                          route: AppRouter.studentCourses,
                          isDark: isDark,
                        ),
                        SizedBox(height: 8.h),
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                        ),
                        SizedBox(height: 8.h),
                        _buildNavItem(
                          context,
                          icon: Icons.rate_review_outlined,
                          title: 'Lịch sử đánh giá',
                          isDark: isDark,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentReviewHistory,
                            );
                          },
                        ),
                        SizedBox(height: 8.h),
                        Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                        ),
                        SizedBox(height: 8.h),
                        _buildNavItem(
                          context,
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt',
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
                  Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 24.sp,
                      ),
                      title: Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.error,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      onTap: () => _showLogoutDialog(context, isDark),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Phiên bản 1.0.2',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        fontFamily: 'Lexend',
                      ),
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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    final isActive = route != null && currentRoute == route;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF135BEC).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive
              ? const Color(0xFF135BEC)
              : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? const Color(0xFF135BEC)
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
            fontFamily: 'Lexend',
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        onTap:
            onTap ??
            () {
              if (route != null) {
                onNavigate(route);
              }
            },
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
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xác nhận đăng xuất',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF64748B),
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
                          borderRadius: BorderRadius.circular(8.r),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        Navigator.of(context).pop(); // Close drawer first
                        
                        // Reset student state
                        try {
                          studentBloc.add(const ResetStudentState());
                        } catch (_) {
                          // Bloc may already be closed, ignore
                        }
                        
                        // Navigate to welcome screen immediately
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.welcome,
                            (route) => false,
                          );
                        }
                        
                        // Then trigger logout (this clears token)
                        try {
                          authBloc.add(const LogoutRequested());
                        } catch (_) {
                          // Bloc may already be closed, ignore
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
