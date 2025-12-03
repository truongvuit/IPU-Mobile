import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/custom_image.dart';

import '../../domain/entities/student_profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onMenuPressed;

  const ProfileScreen({super.key, this.isTab = false, this.onMenuPressed});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasLoadedData = false;
  bool _isLoading = false;
  String? _errorMessage;

  
  StudentProfile? _cachedProfile;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataIfNeeded();
    });
  }

  void _loadDataIfNeeded() {
    if (!mounted || _hasLoadedData) return;

    final state = context.read<StudentBloc>().state;

    
    if (state is DashboardLoaded && state.profile != null) {
      _cachedProfile = state.profile;
      _hasLoadedData = true;
      setState(() {});
      return;
    }

    if (state is ProfileLoaded) {
      _cachedProfile = state.profile;
      _hasLoadedData = true;
      setState(() {});
      return;
    }

    if (state is ProfileUpdated) {
      _cachedProfile = state.profile;
      _hasLoadedData = true;
      setState(() {});
      return;
    }

    
    _hasLoadedData = true;
    _isLoading = true;
    context.read<StudentBloc>().add(LoadProfile());
  }

  void _updateCachedProfile(StudentState state) {
    if (state is DashboardLoaded && state.profile != null) {
      setState(() {
        _cachedProfile = state.profile;
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (state is ProfileLoaded) {
      setState(() {
        _cachedProfile = state.profile;
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (state is ProfileUpdated) {
      setState(() {
        _cachedProfile = state.profile;
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (state is StudentLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (state is StudentError) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          StudentAppBar(
            title: 'Thông tin cá nhân',
            showBackButton: !widget.isTab,
            showMenuButton: widget.isTab,
            onMenuPressed: widget.onMenuPressed,
            onBackPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.studentDashboard,
                (route) => false,
              );
            },
          ),

          Expanded(
            child: BlocListener<StudentBloc, StudentState>(
              listenWhen: (previous, current) {
                return current is ProfileLoaded ||
                    current is ProfileUpdated ||
                    current is StudentLoading ||
                    current is StudentError ||
                    current is DashboardLoaded;
              },
              listener: (context, state) {
                _updateCachedProfile(state);
              },
              child: _buildContent(isDark, isDesktop, isTablet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, bool isDesktop, bool isTablet) {
    
    if (_errorMessage != null && _cachedProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Lexend',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                context.read<StudentBloc>().add(LoadProfile());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    
    if (_isLoading && _cachedProfile == null) {
      return _buildLoadingSkeleton();
    }

    
    if (_cachedProfile != null) {
      return _buildProfileContent(_cachedProfile!, isDark, isDesktop, isTablet);
    }

    
    return _buildLoadingSkeleton();
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          SkeletonWidget.circular(size: 120.w),
          SizedBox(height: AppSizes.paddingMedium),
          SkeletonWidget.rectangular(height: 24.h, width: 200.w),
          SizedBox(height: AppSizes.paddingSmall),
          SkeletonWidget.rectangular(height: 16.h, width: 150.w),
          SizedBox(height: AppSizes.paddingLarge),
          SkeletonWidget.rectangular(height: 200.h),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    StudentProfile profile,
    bool isDark,
    bool isDesktop,
    bool isTablet,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40.w : (isTablet ? 24.w : 0),
      ),
      child: Column(
        children: [
          SizedBox(height: 24.h),

          Container(
            width: isDesktop ? 140.w : 120.w,
            height: isDesktop ? 140.h : 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: CustomImage(
                imageUrl: profile.avatarUrl ?? '',
                width: isDesktop ? 140.w : 120.w,
                height: isDesktop ? 140.h : 120.h,
                fit: BoxFit.cover,
                isAvatar: true,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            profile.fullName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Mã SV: ${profile.studentCode}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 24.h),

          _buildStatsSection(profile, isDark, isDesktop),
          SizedBox(height: 24.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.studentEditProfile);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                ),
                child: const Text(
                  'Chỉnh sửa thông tin',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          _buildInfoSection(
            'Thông tin liên hệ',
            [
              _buildInfoItem(
                Icons.email,
                'Email',
                profile.email ?? 'Chưa cập nhật',
                isDark,
                isDesktop,
              ),
              _buildInfoItem(
                Icons.phone,
                'Số điện thoại',
                profile.phoneNumber ?? 'Chưa cập nhật',
                isDark,
                isDesktop,
              ),
            ],
            isDark,
            isDesktop,
          ),
          _buildInfoSection(
            'Thông tin cá nhân',
            [
              _buildInfoItem(
                Icons.cake,
                'Ngày sinh',
                profile.dateOfBirth != null
                    ? '${profile.dateOfBirth!.day}/${profile.dateOfBirth!.month}/${profile.dateOfBirth!.year}'
                    : 'Chưa cập nhật',
                isDark,
                isDesktop,
              ),
              _buildInfoItem(
                Icons.location_on,
                'Địa chỉ',
                profile.address ?? 'Chưa cập nhật',
                isDark,
                isDesktop,
              ),
            ],
            isDark,
            isDesktop,
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    List<Widget> items,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isDesktop ? 0 : 16.w,
        0,
        isDesktop ? 0 : 16.w,
        16.h,
      ),
      padding: EdgeInsets.all(isDesktop ? 24.w : 16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 20.sp : 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 16.h),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    bool isDark,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 48.w : 40.w,
            height: isDesktop ? 48.h : 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: isDesktop ? 24.w : 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isDesktop ? 14.sp : 12.sp,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondary,
                    fontFamily: 'Lexend',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 16.sp : 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
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

  Widget _buildStatsSection(dynamic profile, bool isDark, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.school_outlined,
              '${profile.activeCourses}',
              'Lớp học',
              AppColors.primary,
              isDark,
              isDesktop,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildStatCard(
              Icons.star_outline,
              '${profile.gpa}',
              'Sao',
              AppColors.warning,
              isDark,
              isDesktop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? AppSizes.p16 : AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(icon, color: color, size: isDesktop ? 24.sp : 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? AppSizes.textXs : 10.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
