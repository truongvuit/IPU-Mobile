import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class TeacherDrawerWidget extends StatelessWidget {
  final void Function(int index)? onTabChange;

  const TeacherDrawerWidget({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        final bloc = context.read<TeacherBloc>();

        String displayName = 'Giảng viên';
        String? displayAvatar;
        bool isLoading = state is TeacherLoading || state is TeacherInitial;

        if (state is TeacherLoaded) {
          displayName = state.profile.fullName;
          displayAvatar = state.profile.avatarUrl;
        } else if (state is ProfileLoaded) {
          displayName = state.profile.fullName;
          displayAvatar = state.profile.avatarUrl;
        } else if (state is ProfileUpdated && state.profile != null) {
          displayName = state.profile!.fullName;
          displayAvatar = state.profile!.avatarUrl;
        } else if (bloc.cachedProfile != null) {
          displayName = bloc.cachedProfile!.fullName;
          displayAvatar = bloc.cachedProfile!.avatarUrl;
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
            child: Container(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, AppRouter.teacherProfile);
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
                                      child: CustomImage(
                                        imageUrl: displayAvatar,
                                        cacheKey:
                                            '${displayAvatar}_${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
                                        width: 64.w,
                                        height: 64.h,
                                        fit: BoxFit.cover,
                                        isAvatar: true,
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
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
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
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToTab(0);
                            },
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            context,
                            icon: Icons.class_outlined,
                            title: 'Lớp học',
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToTab(2);
                            },
                            isDark: isDark,
                          ),
                          _buildNavItem(
                            context,
                            icon: Icons.calendar_month_outlined,
                            title: 'Lịch dạy',
                            onTap: () {
                              Navigator.pop(context);
                              _navigateToTab(1);
                            },
                            isDark: isDark,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
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
                            title: 'Cài đặt',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRouter.settings,
                                arguments: {'userRole': 'teacher'},
                              );
                            },
                            isDark: isDark,
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
                      child: _buildNavItem(
                        context,
                        icon: Icons.logout_outlined,
                        title: 'Đăng xuất',
                        onTap: () => _showLogoutDialog(context),
                        isDark: isDark,
                        isLogout: true,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        'Phiên bản 1.0.2',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral400,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToTab(int tabIndex) {
    if (onTabChange != null) {
      onTabChange!(tabIndex);
    }
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isLogout = false,
  }) {
    final color = isLogout
        ? AppColors.error
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22.sp),
                SizedBox(width: 14.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: color,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authBloc = context.read<AuthBloc>();

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
                        Navigator.of(context).pop(); 

                        
                        try {
                          final teacherBloc = context.read<TeacherBloc>();
                          teacherBloc.add(ResetTeacherState());
                        } catch (_) {
                          
                        }

                        
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.welcome,
                            (route) => false,
                          );
                        }

                        
                        try {
                          authBloc.add(const LogoutRequested());
                        } catch (_) {
                          
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
