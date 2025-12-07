import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/domain/entities/user.dart';


class AdminProfileScreen extends StatefulWidget {
  final bool isTab;

  const AdminProfileScreen({super.key, this.isTab = false});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  User? _cachedUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserFromAuthBloc();
  }

  void _loadUserFromAuthBloc() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      setState(() {
        _cachedUser = authState.user;
        _isLoading = false;
        _errorMessage = null;
      });
    } else {
      
      context.read<AuthBloc>().add(const CheckAuthStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Column(
        children: [
          
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingMedium,
              MediaQuery.of(context).padding.top + AppSizes.p8,
              AppSizes.paddingMedium,
              AppSizes.paddingMedium,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
            ),
            child: Row(
              children: [
                if (!widget.isTab)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: widget.isTab
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                ),
                if (!widget.isTab)
                  const SizedBox(width: 48), 
              ],
            ),
          ),

          Expanded(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthSuccess) {
                  setState(() {
                    _cachedUser = state.user;
                    _isLoading = false;
                    _errorMessage = null;
                  });
                } else if (state is AuthLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                } else if (state is AuthFailure) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = state.message;
                  });
                } else if (state is AuthUnauthenticated) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Phiên đăng nhập đã hết hạn';
                  });
                }
              },
              child: _buildContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_cachedUser != null) {
      return _buildProfileContent(context, _cachedUser!, isDark);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage ?? 'Không thể tải thông tin',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              context.read<AuthBloc>().add(const CheckAuthStatus());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          SkeletonWidget.circular(size: 100.w),
          SizedBox(height: AppSizes.paddingMedium),
          SkeletonWidget.rectangular(height: 24.h, width: 180.w),
          SizedBox(height: AppSizes.paddingSmall),
          SkeletonWidget.rectangular(height: 16.h, width: 120.w),
          SizedBox(height: AppSizes.paddingLarge),
          SkeletonWidget.rectangular(height: 60.h),
          SizedBox(height: AppSizes.paddingSmall),
          SkeletonWidget.rectangular(height: 60.h),
          SizedBox(height: AppSizes.paddingSmall),
          SkeletonWidget.rectangular(height: 60.h),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user, bool isDark) {
    final role = user.role.toLowerCase();
    final isAdmin = role == 'admin';

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          
          _buildAvatarSection(
            user.avatarUrl,
            user.fullName ?? user.username ?? 'User',
            isAdmin,
          ),

          SizedBox(height: 16.h),

          
          Text(
            user.fullName ?? user.username ?? 'Người dùng',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              isAdmin ? 'Quản trị viên' : 'Nhân viên học vụ',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isAdmin ? AppColors.primary : AppColors.info,
              ),
            ),
          ),

          SizedBox(height: 32.h),

          
          _buildInfoCard(
            context,
            isDark,
            title: 'Thông tin liên hệ',
            items: [
              _InfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                _InfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Số điện thoại',
                  value: user.phoneNumber!,
                ),
            ],
          ),

          SizedBox(height: 16.h),

          _buildInfoCard(
            context,
            isDark,
            title: 'Tài khoản',
            items: [
              _InfoItem(
                icon: Icons.person_outline,
                label: 'Tên đăng nhập',
                value: user.username ?? user.email.split('@').first,
              ),
              _InfoItem(
                icon: Icons.badge_outlined,
                label: 'ID',
                value: user.id,
              ),
              _InfoItem(
                icon: Icons.circle,
                label: 'Trạng thái',
                value: user.isActive ? 'Đang hoạt động' : 'Tạm khóa',
                valueColor: user.isActive ? AppColors.success : AppColors.error,
              ),
            ],
          ),

          SizedBox(height: 32.h),

          
          _buildActionButton(
            context,
            icon: Icons.lock_outline,
            label: 'Đổi mật khẩu',
            color: AppColors.warning,
            onTap: () {
              Navigator.pushNamed(context, AppRouter.changePassword);
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String? avatarUrl, String name, bool isAdmin) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isAdmin ? AppColors.primary : AppColors.info,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isAdmin ? AppColors.primary : AppColors.info)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50.r,
            backgroundColor: isAdmin
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.info.withValues(alpha: 0.1),
            child: avatarUrl != null && avatarUrl.isNotEmpty
                ? ClipOval(
                    child: CustomImage(
                      imageUrl: avatarUrl,
                      width: 96.r,
                      height: 96.r,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: isAdmin ? AppColors.primary : AppColors.info,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isAdmin ? AppColors.primary : AppColors.info,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              isAdmin ? Icons.verified_user : Icons.person,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<_InfoItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      item.icon,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                item.valueColor ??
                                (isDark ? Colors.white : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 20.sp, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}
