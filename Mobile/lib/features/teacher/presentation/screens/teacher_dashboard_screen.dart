import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

import '../widgets/teacher_app_bar.dart';
import '../widgets/teacher_schedule_detail_modal.dart';
import '../widgets/teacher_class_card.dart';
import '../widgets/teacher_schedule_item.dart';
import '../widgets/compact_schedule_list_item.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedDayIndex = 0;
  DateTime? _startOfWeek;
  bool _isCompactMode = false; 

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startOfWeek = _getStartOfWeek(now);

    _selectedDayIndex = now.weekday - 1;

    context.read<TeacherBloc>().add(LoadTeacherDashboard());
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getDayName(int index) {
    return AppStrings.dayOfWeek(
      index + 1,
    ).replaceAll('Thứ ', 'T').replaceAll('Chủ nhật', 'CN');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading) {
          return Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              children: [
                SkeletonWidget.rectangular(height: 64.h),
                SizedBox(height: AppSizes.paddingMedium),
                SkeletonWidget.rectangular(height: 100.h),
                SizedBox(height: AppSizes.paddingMedium),
                SkeletonWidget.rectangular(height: 200.h),
              ],
            ),
          );
        }

        if (state is TeacherError) {
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
                  BlocBuilder<TeacherBloc, TeacherState>(
                    builder: (context, btnState) {
                      final isLoading = btnState is TeacherLoading;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<TeacherBloc>().add(
                                LoadTeacherDashboard(),
                              ),
                        child: isLoading
                            ? SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Thử lại',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18.sp : 16.sp,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          if (_startOfWeek == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedDate = _startOfWeek!.add(
            Duration(days: _selectedDayIndex),
          );

          final schedulesForSelectedDate = (() {
            try {
              if (state.weekSchedule != null) {
                return state.weekSchedule!
                    .where((s) => _isSameDate(s.startTime, selectedDate))
                    .toList();
              }

              if (_isSameDate(selectedDate, DateTime.now())) {
                return state.todaySchedule;
              }

              return <dynamic>[];
            } catch (_) {
              return <dynamic>[];
            }
          })();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<TeacherBloc>().add(LoadTeacherDashboard());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (scaffoldContext) {
                      return TeacherAppBar(
                        greeting: AppStrings.welcomeGreeting(
                          state.profile.fullName.split(' ').last,
                        ),
                        avatarUrl: state.profile.avatarUrl,
                        onAvatarTap: () {
                          final scaffold = Scaffold.maybeOf(scaffoldContext);
                          if (scaffold?.hasDrawer ?? false) {
                            scaffold!.openDrawer();
                          }
                        },
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? 20.h : 16.h,
                    ),
                    color: isDark ? AppColors.gray800 : Colors.white,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 1200 : double.infinity,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32.w : 16.w,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(7, (index) {
                                  if (_startOfWeek == null) {
                                    return const SizedBox();
                                  }

                                  final date = _startOfWeek!.add(
                                    Duration(days: index),
                                  );
                                  final isSelected = _selectedDayIndex == index;
                                  final isToday = _isSameDate(
                                    DateTime.now(),
                                    date,
                                  );

                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedDayIndex = index;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMedium,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: isDesktop ? 16.h : 12.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : (isDark
                                                      ? AppColors.gray700
                                                      : AppColors.slate100),
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.radiusMedium,
                                            ),
                                            border: isToday
                                                ? Border.all(
                                                    color: AppColors.primary,
                                                    width: 2,
                                                  )
                                                : null,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  _getDayName(index),
                                                  style: textTheme.bodySmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: isDesktop
                                                            ? 14.sp
                                                            : 11.sp,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : (isDark
                                                                  ? Colors
                                                                        .white70
                                                                  : Colors
                                                                        .black87),
                                                      ),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  "${date.day}",
                                                  style: textTheme.titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: isDesktop
                                                            ? 18.sp
                                                            : 16.sp,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : (isDark
                                                                  ? Colors.white
                                                                  : Colors
                                                                        .black),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 32.w : 20.w,
                          20.h,
                          20.w,
                          12.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isSameDate(selectedDate, DateTime.now())
                                  ? "Lịch dạy hôm nay"
                                  : "Lịch dạy ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: isDesktop ? 26.sp : 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            if (schedulesForSelectedDate.length > 5)
                              IconButton(
                                icon: Icon(
                                  _isCompactMode
                                      ? Icons.view_agenda
                                      : Icons.view_list,
                                  size: 24.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isCompactMode = !_isCompactMode;
                                  });
                                },
                                tooltip: _isCompactMode
                                    ? 'Chế độ thường'
                                    : 'Chế độ thu gọn',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (schedulesForSelectedDate.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child: EmptyStateWidget(
                        icon: Icons.calendar_today,
                        message: "Không có lịch cho ngày này",
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        
                        final maxDisplay = _isCompactMode ? schedulesForSelectedDate.length : 5;
                        
                        if (index >= maxDisplay) return null;
                        
                        final schedule = schedulesForSelectedDate[index];

                        
                        final useCompact =
                            _isCompactMode ||
                            schedulesForSelectedDate.length > 5;

                        return useCompact
                            ? CompactScheduleListItem(
                                schedule: schedule,
                                onTap: () {
                                  TeacherScheduleDetailModal.show(
                                    context,
                                    schedule,
                                  );
                                },
                              )
                            : TeacherScheduleItem(
                                schedule: schedule,
                                onTap: () {
                                  TeacherScheduleDetailModal.show(
                                    context,
                                    schedule,
                                  );
                                },
                              );
                      }, childCount: _isCompactMode 
                          ? schedulesForSelectedDate.length 
                          : (schedulesForSelectedDate.length > 5 ? 5 : schedulesForSelectedDate.length)),
                    ),
                  ),
                
                
                if (schedulesForSelectedDate.length > 5 && !_isCompactMode)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isCompactMode = true;
                          });
                        },
                        icon: const Icon(Icons.expand_more),
                        label: Text(
                          'Xem thêm ${schedulesForSelectedDate.length - 5} buổi',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Lớp học của tôi", style: textTheme.titleLarge),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.teacherClasses,
                            );
                          },
                          child: const Text("Xem tất cả"),
                        ),
                      ],
                    ),
                  ),
                ),

                if (state.recentClasses.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32.w : 20.w,
                      ),
                      child: EmptyStateWidget(
                        icon: Icons.class_,
                        message: "Bạn chưa có lớp học nào.",
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32.w : 20.w,
                    ),
                    sliver: isDesktop || isTablet
                        
                        ? SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isDesktop ? 3 : 2,
                              mainAxisSpacing: 20.h,
                              crossAxisSpacing: 20.w,
                              childAspectRatio: isDesktop ? 1.3 : 1.2,
                            ),
                            delegate: SliverChildBuilderDelegate((context, index) {
                              
                              if (index >= 3) return null;
                              final classItem = state.recentClasses[index];
                              return TeacherClassCard(
                                classItem: classItem,
                                onTap: () {
                                  if (classItem.id.isNotEmpty) {
                                    try {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(
                                        AppRouter.teacherClassDetail,
                                        arguments: classItem.id,
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lỗi khi mở chi tiết lớp: $e',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            }, childCount: state.recentClasses.length > 3 ? 3 : state.recentClasses.length),
                          )
                        
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              
                              if (index >= 3) return null;
                              final classItem = state.recentClasses[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: TeacherClassCard(
                                  classItem: classItem,
                                  compact: true,
                                  onTap: () {
                                    if (classItem.id.isNotEmpty) {
                                      try {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pushNamed(
                                          AppRouter.teacherClassDetail,
                                          arguments: classItem.id,
                                        );
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Lỗi khi mở chi tiết lớp: $e',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              );
                            }, childCount: state.recentClasses.length > 3 ? 3 : state.recentClasses.length),
                          ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
