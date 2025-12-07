import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_image.dart';

import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

import '../widgets/teacher_schedule_detail_modal.dart';
import '../widgets/teacher_class_card.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _selectedDayIndex = 0;
  DateTime? _startOfWeek;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startOfWeek = _getStartOfWeek(now);
    _selectedDayIndex = now.weekday - 1;
    context.read<TeacherBloc>().add(LoadTeacherDashboard());
  }

  DateTime _getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _getDayName(int index) {
    return AppStrings.dayOfWeek(index + 1)
        .replaceAll('Thứ ', 'T')
        .replaceAll('Chủ nhật', 'CN');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading) {
          return _buildLoadingState();
        }

        if (state is TeacherError) {
          return _buildErrorState(state.message);
        }

        if (state is DashboardLoaded) {
          return _buildDashboard(state, isDark);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SkeletonWidget.rectangular(height: 56.h),
          SizedBox(height: 16.h),
          SkeletonWidget.rectangular(height: 70.h),
          SizedBox(height: 16.h),
          SkeletonWidget.rectangular(height: 120.h),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<TeacherBloc>().add(LoadTeacherDashboard()),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(DashboardLoaded state, bool isDark) {
    if (_startOfWeek == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedDate = _startOfWeek!.add(Duration(days: _selectedDayIndex));
    final schedules = _getSchedulesForDate(state, selectedDate);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<TeacherBloc>().add(LoadTeacherDashboard());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          
          SliverToBoxAdapter(child: _buildHeader(state, isDark)),
          
          
          SliverToBoxAdapter(child: _buildWeekSelector(isDark)),
          
          
          SliverToBoxAdapter(
            child: _buildSectionTitle(
              _isSameDate(selectedDate, DateTime.now())
                  ? "Lịch dạy hôm nay"
                  : "Lịch dạy ${selectedDate.day}/${selectedDate.month}",
              isDark,
            ),
          ),
          
          
          if (schedules.isEmpty)
            SliverToBoxAdapter(child: _buildEmptySchedule(isDark))
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildScheduleItem(schedules[index], isDark),
                  childCount: schedules.length,
                ),
              ),
            ),
          
          
          SliverToBoxAdapter(child: _buildClassesSectionHeader(isDark)),
          
          if (state.recentClasses.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: EmptyStateWidget(
                  icon: Icons.class_,
                  message: "Bạn chưa có lớp học nào.",
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.only(bottom: 100.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= 3) return null;
                    return TeacherClassCard(
                      classItem: state.recentClasses[index],
                      onTap: () => _navigateToClassDetail(state.recentClasses[index].id),
                    );
                  },
                  childCount: state.recentClasses.length > 3 ? 3 : state.recentClasses.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(DashboardLoaded state, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                final scaffold = Scaffold.maybeOf(context);
                if (scaffold?.hasDrawer ?? false) scaffold!.openDrawer();
              },
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImage(
                    imageUrl: state.profile.avatarUrl ?? '',
                    width: 42.w,
                    height: 42.w,
                    fit: BoxFit.cover,
                    isAvatar: true,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              AppStrings.welcomeGreeting(state.profile.fullName.split(' ').last),
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = _startOfWeek!.add(Duration(days: index));
          final isSelected = _selectedDayIndex == index;
          final isToday = _isSameDate(DateTime.now(), date);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDayIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayName(index),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.neutral400 : AppColors.neutral600),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isToday
                                ? AppColors.primary
                                : (isDark ? Colors.white : AppColors.textPrimary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptySchedule(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 36.sp, color: AppColors.neutral400),
          SizedBox(height: 6.h),
          Text(
            "Không có lịch dạy",
            style: TextStyle(fontSize: 13.sp, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(dynamic schedule, bool isDark) {
    final now = DateTime.now();
    final isOngoing = now.isAfter(schedule.startTime) && now.isBefore(schedule.endTime);
    final isCompleted = now.isAfter(schedule.endTime);

    Color statusColor = AppColors.info;
    String statusText = "Sắp tới";
    if (isOngoing) {
      statusColor = AppColors.success;
      statusText = "Đang diễn ra";
    } else if (isCompleted) {
      statusColor = AppColors.neutral500;
      statusText = "Đã kết thúc";
    }

    return GestureDetector(
      onTap: () => TeacherScheduleDetailModal.show(context, schedule),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isOngoing
                ? AppColors.success.withValues(alpha: 0.5)
                : (isDark ? AppColors.neutral700 : AppColors.neutral200),
          ),
        ),
        child: Row(
          children: [
            
            Container(
              width: 52.w,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    _formatTime(schedule.startTime),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    _formatTime(schedule.endTime),
                    style: TextStyle(fontSize: 10.sp, color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.className,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12.sp, color: AppColors.neutral500),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          schedule.room,
                          style: TextStyle(fontSize: 11.sp, color: AppColors.neutral500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      _buildBadge(statusText, statusColor, isDark),
                      SizedBox(width: 4.w),
                      _buildBadge("Sessio...", AppColors.neutral500, isDark, outlined: true),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18.sp, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark, {bool outlined = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: outlined ? Border.all(color: AppColors.neutral300) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: outlined ? AppColors.neutral500 : color,
        ),
      ),
    );
  }

  Widget _buildClassesSectionHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Lớp học của tôi",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pushNamed(AppRouter.teacherClasses),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Xem tất cả",
              style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getSchedulesForDate(DashboardLoaded state, DateTime date) {
    try {
      List<dynamic> schedules = [];
      if (state.weekSchedule != null) {
        schedules = state.weekSchedule!.where((s) => _isSameDate(s.startTime, date)).toList();
      } else if (_isSameDate(date, DateTime.now())) {
        schedules = state.todaySchedule;
      }

      schedules.sort((a, b) {
        int getPriority(dynamic s) {
          final now = DateTime.now();
          if (now.isAfter(s.startTime) && now.isBefore(s.endTime)) return 0;
          if (s.startTime.isAfter(now)) return 1;
          return 2;
        }
        final p = getPriority(a).compareTo(getPriority(b));
        return p != 0 ? p : a.startTime.compareTo(b.startTime);
      });

      return schedules;
    } catch (_) {
      return [];
    }
  }

  void _navigateToClassDetail(String classId) {
    if (classId.isNotEmpty) {
      Navigator.of(context, rootNavigator: true).pushNamed(
        AppRouter.teacherClassDetail,
        arguments: classId,
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
