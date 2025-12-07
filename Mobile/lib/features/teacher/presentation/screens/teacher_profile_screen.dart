import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/utils/date_formatter.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../widgets/teacher_app_bar.dart';


class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    
    context.read<TeacherBloc>().add(LoadTeacherProfile());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Column(
      children: [
        
        TeacherAppBar(
          title: 'Hồ sơ giảng viên',
          showBackButton: false,
          actions: [
            IconButton(
              onPressed: () {
                
                Navigator.of(context, rootNavigator: true).pushNamed(
                  AppRouter.teacherEditProfile,
                );
              },
              icon: Icon(
                Icons.edit_outlined,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              tooltip: 'Chỉnh sửa',
            ),
          ],
        ),

        Expanded(
          child: BlocBuilder<TeacherBloc, TeacherState>(
            builder: (context, state) {
              if (state is TeacherLoading) {
                return _buildLoadingSkeleton(isDesktop);
              }

              if (state is TeacherError) {
                return _buildErrorState(context, state.message, isDesktop);
              }

              if (state is ProfileLoaded) {
                final profile = state.profile;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<TeacherBloc>().add(LoadTeacherProfile());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 100.h),
                    child: Column(
                      children: [
                        
                        _buildProfileHeader(
                          profile,
                          isDark,
                          isDesktop,
                        ),

                        SizedBox(height: AppSizes.p24),

                        
                        _buildStatsSection(isDark, isDesktop, profile),

                        SizedBox(height: AppSizes.p16),

                        
                        _buildContactSection(
                          profile,
                          isDark,
                          isDesktop,
                        ),

                        SizedBox(height: AppSizes.p16),

                        
                        _buildPersonalSection(
                          profile,
                          isDark,
                          isDesktop,
                        ),

                        SizedBox(height: AppSizes.p16),

                        
                        if (profile.certificates.isNotEmpty)
                          _buildCertificatesSection(
                            profile.certificates,
                            isDark,
                            isDesktop,
                          ),
                      ],
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          SkeletonWidget.circular(size: isDesktop ? 140.w : 120.w),
          SizedBox(height: AppSizes.p16),
          SkeletonWidget.rectangular(height: 30.h, width: 200.w),
          SizedBox(height: AppSizes.p8),
          SkeletonWidget.rectangular(height: 20.h, width: 150.w),
          SizedBox(height: AppSizes.p24),
          SkeletonWidget.rectangular(height: 100.h),
          SizedBox(height: AppSizes.p16),
          SkeletonWidget.rectangular(height: 150.h),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool isDesktop) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? AppSizes.p32 : AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isDesktop ? 64.sp : 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: isDesktop ? AppSizes.p24 : AppSizes.p16),
            Text(
              message,
              style: TextStyle(fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isDesktop ? AppSizes.p24 : AppSizes.p16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TeacherBloc>().add(LoadTeacherProfile());
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                'Thử lại',
                style: TextStyle(fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    dynamic profile,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        isDesktop ? AppSizes.p48 : AppSizes.p32,
        AppSizes.paddingMedium,
        isDesktop ? AppSizes.p48 : AppSizes.p32,
      ),
      child: Column(
        children: [
          
          Container(
            width: isDesktop ? 140.w : 120.w,
            height: isDesktop ? 140.w : 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: CustomImage(
                imageUrl: profile.avatarUrl ?? '',
                width: isDesktop ? 140.w : 120.w,
                height: isDesktop ? 140.w : 120.w,
                fit: BoxFit.cover,
                isAvatar: true,
              ),
            ),
          ),
          SizedBox(height: AppSizes.p16),

          
          Text(
            profile.fullName,
            style: TextStyle(
              fontSize: isDesktop ? 28.sp : AppSizes.text2Xl,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),

          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.p12,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              profile.teacherCode,
              style: TextStyle(
                fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),

          
          if (profile.specialization != null) ...[
            SizedBox(height: AppSizes.p12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: isDesktop ? 20.sp : 18.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 6.w),
                Text(
                  profile.specialization,
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, bool isDesktop, dynamic profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.school_outlined,
              '${profile.totalClasses}',
              'Lớp học',
              AppColors.primary,
              isDark,
              isDesktop,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildStatCard(
              Icons.people_outlined,
              '${profile.totalStudents}',
              'Học viên',
              AppColors.success,
              isDark,
              isDesktop,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildStatCard(
              Icons.star_outline,
              '${profile.rating}',
              'Đánh giá',
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
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.divider,
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
            child: Icon(
              icon,
              color: color,
              size: isDesktop ? 24.sp : 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? AppSizes.textXs : 10.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
    dynamic profile,
    bool isDark,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? AppSizes.p24 : AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isDark ? AppColors.neutral700 : AppColors.divider,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_phone_outlined,
                  color: AppColors.primary,
                  size: isDesktop ? 24.sp : 20.sp,
                ),
                SizedBox(width: AppSizes.p12),
                Text(
                  'Thông tin liên hệ',
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.p16),

            if (profile.email != null)
              _buildInfoRow(
                Icons.email_outlined,
                'Email',
                profile.email!,
                isDark,
                isDesktop,
              ),
            if (profile.phoneNumber != null)
              _buildInfoRow(
                Icons.phone_outlined,
                'Số điện thoại',
                profile.phoneNumber!,
                isDark,
                isDesktop,
              ),
            if (profile.address != null)
              _buildInfoRow(
                Icons.location_on_outlined,
                'Địa chỉ',
                profile.address!,
                isDark,
                isDesktop,
              ),
                  
            if (profile.email == null && profile.phoneNumber == null && profile.address == null)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                  child: Text(
                    'Chưa cập nhật thông tin liên hệ',
                    style: TextStyle(
                      fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalSection(
    dynamic profile,
    bool isDark,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? AppSizes.p24 : AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isDark ? AppColors.neutral700 : AppColors.divider,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: isDesktop ? 24.sp : 20.sp,
                ),
                SizedBox(width: AppSizes.p12),
                Text(
                  'Thông tin cá nhân',
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.p16),

            if (profile.dateOfBirth != null)
              _buildInfoRow(
                Icons.cake_outlined,
                'Ngày sinh',
                DateFormatter.formatDate(profile.dateOfBirth!),
                isDark,
                isDesktop,
              ),
            if (profile.gender != null)
              _buildInfoRow(
                Icons.wc_outlined,
                'Giới tính',
                profile.gender!,
                isDark,
                isDesktop,
              ),

            if (profile.dateOfBirth == null && profile.gender == null)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                  child: Text(
                    'Chưa cập nhật thông tin cá nhân',
                    style: TextStyle(
                      fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesSection(
    List<String> certificates,
    bool isDark,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isDesktop ? AppSizes.p24 : AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isDark ? AppColors.neutral700 : AppColors.divider,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.primary,
                  size: isDesktop ? 24.sp : 20.sp,
                ),
                SizedBox(width: AppSizes.p12),
                Text(
                  'Chứng chỉ & Bằng cấp',
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.p16),

            ...certificates.asMap().entries.map((entry) {
              final index = entry.key;
              final cert = entry.value;
              return Container(
                margin: EdgeInsets.only(
                  bottom: index < certificates.length - 1 ? AppSizes.p12 : 0,
                ),
                padding: EdgeInsets.all(isDesktop ? AppSizes.p16 : AppSizes.p12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.p8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Icon(
                        Icons.verified,
                        size: isDesktop ? 20.sp : 18.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        cert,
                        style: TextStyle(
                          fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              icon,
              size: isDesktop ? 20.sp : 18.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
