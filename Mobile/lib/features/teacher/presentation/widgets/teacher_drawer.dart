import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_state.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';

class TeacherDrawerWidget extends StatelessWidget {
  final void Function(int index)? onTabChange;

  const TeacherDrawerWidget({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        String userName = 'Giảng viên';
        String userEmail = '';
        String userAvatar = '';

        if (state is TeacherLoaded) {
          final profile = state.profile;
          userName = profile.fullName;
          userEmail = profile.email ?? '';
          userAvatar = profile.avatarUrl ?? '';
        }

        return Drawer(
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
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          ClipOval(
                            child: CustomImage(
                              imageUrl: userAvatar,
                              width: 64.w,
                              height: 64.h,
                              fit: BoxFit.cover,
                              isAvatar: true,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.slate900,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isDark ? AppColors.gray400 : AppColors.slate500,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? AppColors.gray400 : AppColors.slate500,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),

                
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: [
                      _buildMenuItem(
                        context,
                        Icons.home_outlined,
                        'Trang chủ',
                        () => _navigateToTab(0),
                        isDark,
                        isSelected: true,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.school_outlined,
                        'Quản lý Lớp học',
                        () => _navigateToTab(2),
                        isDark,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.calendar_today_outlined,
                        'Lịch dạy',
                        () => _navigateToTab(1),
                        isDark,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.checklist_outlined,
                        'Điểm danh',
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRouter.teacherClasses,
                            arguments: 'attendance',
                          );
                        },
                        isDark,
                      ),
                      _buildMenuItem(
                        context,
                        Icons.edit_note_outlined,
                        'Chấm điểm & Nhận xét',
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRouter.teacherClasses,
                            arguments: 'grading',
                          );
                        },
                        isDark,
                      ),
                      Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      ),
                      SizedBox(height: 8.h),

                      _buildMenuItem(
                        context,
                        Icons.settings_outlined,
                        'Cài đặt',
                        () {
                          Navigator.pop(context);
                          if (!context.mounted) return;
                          Navigator.pushNamed(
                            context,
                            AppRouter.settings,
                            arguments: {'userRole': 'teacher'},
                          );
                        },
                        isDark,
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),

                
                _buildMenuItem(
                  context,
                  Icons.logout,
                  'Đăng xuất',
                  () => _showLogoutDialog(context),
                  isDark,
                  color: AppColors.error,
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
                          ? AppColors.gray500
                          : AppColors.gray400,
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

  
  void _navigateToTab(int tabIndex) {
    if (onTabChange != null) {
      onTabChange!(tabIndex);
    }
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark, {
    Color? color,
    bool isSelected = false,
  }) {
    final itemColor = color ?? (isDark ? Colors.white : AppColors.slate900);
    final backgroundColor = isSelected
        ? (AppColors.primary.withValues(alpha: 0.1))
        : Colors.transparent;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : itemColor,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : itemColor,
            fontFamily: 'Lexend',
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (!context.mounted) return;
              
              
              context.read<AuthBloc>().add(const LogoutRequested());
              
              
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
