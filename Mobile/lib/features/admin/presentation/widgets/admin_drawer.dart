import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const AdminDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        child: Column(
          children: [
            _buildDrawerHeader(context, isDark),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSectionHeader(context, 'MENU CHÍNH'),

                  _DrawerMenuItem(
                    icon: Icons.dashboard,
                    title: 'Tổng quan',
                    isSelected: currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      onTabSelected(0);
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.class_,
                    title: 'Quản lý lớp học',
                    isSelected: currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onTabSelected(1);
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.school,
                    title: 'Quản lý giảng viên',
                    isSelected: currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onTabSelected(2);
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.people,
                    title: 'Quản lý học viên',
                    isSelected: currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      onTabSelected(3);
                    },
                  ),

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                  ),

                  _buildSectionHeader(context, 'TÍNH NĂNG'),

                  _DrawerMenuItem(
                    icon: Icons.app_registration,
                    title: 'Đăng ký nhanh',
                    subtitle: 'Đăng ký & Thu tiền',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRouter.adminQuickRegistration,
                      );
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.menu_book,
                    title: 'Quản lý khóa học',
                    subtitle: 'Xem & chỉnh sửa',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.adminCourseList);
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.local_offer,
                    title: 'Khuyến mãi',
                    subtitle: 'Mã giảm giá',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.adminPromotions);
                    },
                  ),

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                  ),

                  _buildSectionHeader(context, 'CÀI ĐẶT'),

                  _DrawerMenuItem(
                    icon: Icons.settings,
                    title: 'Cài đặt ứng dụng',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRouter.settings,
                        arguments: {'userRole': 'admin'},
                      );
                    },
                  ),

                  _DrawerMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.changePassword);
                    },
                  ),
                ],
              ),
            ),

            _buildLogoutButton(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDark) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Người dùng';
        String userEmail = '';
        String userRole = 'employee';
        String? avatarUrl;

        if (state is AuthSuccess) {
          userName = (state.user.fullName?.isNotEmpty == true)
              ? state.user.fullName!
              : (state.user.username ?? 'Người dùng');
          userEmail = state.user.email;
          userRole = state.user.role;
          avatarUrl = state.user.avatarUrl;
        }

        final isAdmin = userRole.toLowerCase() == 'admin';

        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 48.h, 16.w, 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAdmin
                  ? [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ]
                  : [AppColors.info, AppColors.info.withValues(alpha: 0.7)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32.r,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: CustomImage(
                                imageUrl: avatarUrl,
                                width: 60.r,
                                height: 60.r,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin ? Icons.verified_user : Icons.person,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isAdmin ? 'Quản trị viên' : 'Nhân viên học vụ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.neutral500 : AppColors.neutral500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutConfirmation(context),
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final adminBloc = context.read<AdminBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
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
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
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
                                ? AppColors.neutral600
                                : AppColors.neutral300,
                          ),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.neutral300
                              : AppColors.neutral700,
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
                          adminBloc.add(const ResetAdminState());
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
                          authBloc.add(LogoutRequested());
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

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.neutral400 : AppColors.neutral600);

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: effectiveIconColor, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      onTap: onTap,
    );
  }
}
