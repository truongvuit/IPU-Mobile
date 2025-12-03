import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/routing/app_router.dart';

import '../widgets/admin_app_bar.dart';
import '../widgets/admin_activity_item.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load được quản lý bởi HomeAdminScreen._loadDataForTab
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminInitial || state is AdminLoading) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: [
                SkeletonWidget.rectangular(height: 64.h),
                SizedBox(height: AppSizes.paddingMedium),
                SkeletonWidget.rectangular(height: 100.h),
                SizedBox(height: AppSizes.paddingMedium),
                SkeletonWidget.rectangular(height: 200.h),
                SizedBox(height: AppSizes.paddingMedium),
                SkeletonWidget.rectangular(height: 150.h),
              ],
            ),
          );
        }

        if (state is AdminError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: isDesktop ? 64.sp : 48.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: isDesktop ? 18.sp : 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AdminBloc>().add(
                      const LoadAdminDashboard(),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      'Thử lại',
                      style: TextStyle(
                        fontSize: isDesktop ? 18.sp : 16.sp,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AdminDashboardLoaded) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<AdminBloc>().add(const RefreshAdminDashboard());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (scaffoldContext) {
                      return AdminAppBar(
                        greeting: AppStrings.welcomeGreeting(
                          state.profile.firstName,
                        ),
                        avatarUrl: state.profile.avatarUrl,
                        onAvatarTap: () {
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                      );
                    },
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: AppSizes.p8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : 2,
                      mainAxisSpacing: AppSizes.p8,
                      crossAxisSpacing: AppSizes.p8,
                      childAspectRatio: isDesktop ? 2.0 : 1.5,
                    ),
                    delegate: SliverChildListDelegate([
                      _LargeStatCard(
                        title: 'Lớp đang diễn ra',
                        value: state.stats.ongoingClasses.toString(),
                        icon: Icons.class_,
                        iconColor: AppColors.primary,
                        gradient: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                        onTap: () {
                          final homeState = context
                              .findAncestorStateOfType<State>();
                          if (homeState != null && homeState.mounted) {}
                        },
                      ),
                      _LargeStatCard(
                        title: 'Đăng ký hôm nay',
                        value: state.stats.todayRegistrations.toString(),
                        icon: Icons.person_add,
                        iconColor: AppColors.success,
                        gradient: [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.7),
                        ],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.adminQuickRegistration,
                          );
                        },
                      ),
                      _LargeStatCard(
                        title: 'Học viên đang học',
                        value: state.stats.activeStudents.toString(),
                        icon: Icons.people,
                        iconColor: AppColors.info,
                        gradient: [
                          AppColors.info,
                          AppColors.info.withValues(alpha: 0.7),
                        ],
                        onTap: () {},
                      ),
                      _LargeStatCard(
                        title: 'Giảng viên',
                        value: '${state.stats.totalTeachers ?? 0}',
                        icon: Icons.school,
                        iconColor: AppColors.warning,
                        gradient: [
                          AppColors.warning,
                          AppColors.warning.withValues(alpha: 0.7),
                        ],
                        onTap: () {},
                      ),
                    ]),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.p8,
                    ),
                    child: Text(
                      'Thao tác nhanh',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: AppSizes.textXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.app_registration,
                            label: 'Đăng ký học viên',
                            color: AppColors.success,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.adminQuickRegistration,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.menu_book,
                            label: 'Khóa học',
                            color: AppColors.info,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.adminCourseList,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.local_offer,
                            label: 'Khuyến mãi',
                            color: Colors.pink,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.adminPromotions,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.paddingMedium,
                      AppSizes.p20,
                      AppSizes.paddingMedium,
                      AppSizes.p12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hoạt động gần đây',
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: AppSizes.textXl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.recentActivities.length > 5)
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Có ${state.recentActivities.length} hoạt động',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Xem tất cả',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (state.recentActivities.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child: const EmptyStateWidget(
                        icon: Icons.history,
                        message: 'Chưa có hoạt động nào',
                      ),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.paddingMedium,
                      0,
                      AppSizes.paddingMedium,
                      0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final activity = state.recentActivities[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSizes.p12),
                            child: AdminActivityItem(
                              key: ValueKey('activity_${activity.id}'),
                              activity: activity,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Chi tiết hoạt động: ${activity.title}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: state.recentActivities.length > 5
                            ? 5
                            : state.recentActivities.length,
                      ),
                    ),
                  ),
                ],

                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            children: [
              SkeletonWidget.rectangular(height: 64.h),
              SizedBox(height: AppSizes.paddingMedium),
              SkeletonWidget.rectangular(height: 100.h),
              SizedBox(height: AppSizes.paddingMedium),
              SkeletonWidget.rectangular(height: 200.h),
              SizedBox(height: AppSizes.paddingMedium),
              SkeletonWidget.rectangular(height: 150.h),
            ],
          ),
        );
      },
    );
  }
}

class _LargeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _LargeStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(height: 6.h),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          height: 100.h,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isDark ? AppColors.gray700 : AppColors.gray200,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(height: 6.h),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
