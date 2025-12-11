import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../widgets/schedule_item.dart';
import '../widgets/schedule_detail_modal.dart';
import '../../domain/entities/schedule.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ScheduleScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onMenuPressed;

  const ScheduleScreen({super.key, this.isTab = false, this.onMenuPressed});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'list';
  Timer? _monthNavDebounce;

  
  List<Schedule>? _cachedSchedules;
  DateTime? _cachedMonth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduleIfNeeded();
    });
  }

  void _loadScheduleIfNeeded() {
    if (!mounted) return;

    final bloc = context.read<StudentBloc>();
    final state = bloc.state;

    
    if (state is ScheduleLoaded &&
        state.selectedDate.month == _selectedDate.month &&
        state.selectedDate.year == _selectedDate.year) {
      _cachedSchedules = state.schedules;
      _cachedMonth = _selectedDate;
      _isLoading = false;
      return;
    }

    
    if (_cachedSchedules != null &&
        _cachedMonth?.month == _selectedDate.month &&
        _cachedMonth?.year == _selectedDate.year) {
      return;
    }

    
    _isLoading = true;
    bloc.add(LoadSchedule(_selectedDate));
  }

  @override
  void dispose() {
    _monthNavDebounce?.cancel();
    super.dispose();
  }

  void _navigateMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
      );
      
      _cachedSchedules = null;
      _isLoading = true;
    });

    _monthNavDebounce?.cancel();
    _monthNavDebounce = Timer(const Duration(milliseconds: 500), () {
      context.read<StudentBloc>().add(LoadSchedule(_selectedDate));
    });
  }

  String _getDateString(DateTime date) {
    const weekdays = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    final weekday = weekdays[date.weekday - 1];
    return '$weekday, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  void _showScheduleDetail(Schedule schedule) {
    ScheduleDetailModal.show(context, schedule);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          StudentAppBar(
            title: 'Lịch học',
            showBackButton: !widget.isTab,
            showMenuButton: widget.isTab,
            onMenuPressed: widget.onMenuPressed,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.paddingMedium,
              AppSizes.paddingSmall,
              AppSizes.paddingMedium,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: isDesktop ? 28.sp : 24.sp,
                  ),
                  onPressed: () => _navigateMonth(-1),
                  padding: EdgeInsets.all(8.w),
                ),
                Text(
                  'Tháng ${_selectedDate.month}, ${_selectedDate.year}',
                  style: TextStyle(
                    fontSize: isDesktop ? 22.sp : 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    size: isDesktop ? 28.sp : 24.sp,
                  ),
                  onPressed: () => _navigateMonth(1),
                  padding: EdgeInsets.all(8.w),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMedium,
              vertical: AppSizes.paddingSmall,
            ),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      'Lịch',
                      Icons.calendar_month,
                      'calendar',
                      isDark,
                      isDesktop,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildModeButton(
                      'Danh sách',
                      Icons.list,
                      'list',
                      isDark,
                      isDesktop,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: BlocListener<StudentBloc, StudentState>(
              listenWhen: (previous, current) {
                if (current is StudentLoading &&
                    current.action != 'LoadSchedule') {
                  return false;
                }
                return current is ScheduleLoaded ||
                    current is StudentLoading ||
                    current is StudentError;
              },
              listener: (context, state) {
                if (state is ScheduleLoaded) {
                  setState(() {
                    _cachedSchedules = state.schedules;
                    _cachedMonth = state.selectedDate;
                    _isLoading = false;
                  });
                } else if (state is StudentLoading) {
                  setState(() {
                    _isLoading = true;
                  });
                } else if (state is StudentError) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: _buildScheduleContent(isDark, isDesktop),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(bool isDark, bool isDesktop) {
    
    if (_isLoading && _cachedSchedules == null) {
      return EmptyStateWidget(
        icon: Icons.hourglass_empty,
        message: 'Đang tải lịch học...',
      );
    }

    
    if (_cachedSchedules != null) {
      if (_cachedSchedules!.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.event_busy,
          message: 'Không có lịch học nào trong tháng này',
        );
      }

      return _viewMode == 'calendar'
          ? _buildCalendarView(_cachedSchedules!, isDark, isDesktop)
          : _buildListView(_cachedSchedules!, isDark, isDesktop);
    }

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentBloc>().add(LoadSchedule(_selectedDate));
      }
    });

    return EmptyStateWidget(
      icon: Icons.hourglass_empty,
      message: 'Đang tải lịch học...',
    );
  }

  Widget _buildModeButton(
    String label,
    IconData icon,
    String mode,
    bool isDark,
    bool isDesktop,
  ) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF374151) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isDesktop ? 20.sp : 18.sp,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280)),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 15.sp : 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : (isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280)),
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
    List<Schedule> schedules,
    bool isDark,
    bool isDesktop,
  ) {
    final daysInWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final firstDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    );
    final startWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.5,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  daysInWeek[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                  ),
                ),
              );
            },
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 0.9,
            ),
            itemCount: startWeekday - 1 + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) {
                return const SizedBox.shrink();
              }

              final day = index - (startWeekday - 2);
              final date = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                day,
              );
              final hasSchedule = schedules.any(
                (s) =>
                    s.startTime.year == date.year &&
                    s.startTime.month == date.month &&
                    s.startTime.day == date.day,
              );
              final isSelected =
                  _selectedDate.day == day &&
                  _selectedDate.month == date.month &&
                  _selectedDate.year == date.year;
              final isToday =
                  DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  context.read<StudentBloc>().add(LoadSchedule(date));
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isToday
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : (isDark
                                    ? const Color(0xFF1F2937)
                                    : Colors.white)),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.textPrimary),
                          fontFamily: 'Lexend',
                        ),
                      ),
                      if (hasSchedule)
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: AppSizes.paddingMedium),
          _buildSchedulesForDate(schedules, isDark, isDesktop),
        ],
      ),
    );
  }

  Widget _buildListView(List<Schedule> schedules, bool isDark, bool isDesktop) {
    final schedulesForDate = schedules
        .where(
          (s) =>
              s.startTime.year == _selectedDate.year &&
              s.startTime.month == _selectedDate.month &&
              s.startTime.day == _selectedDate.day,
        )
        .toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<StudentBloc>().add(LoadSchedule(_selectedDate));
      },
      child: schedulesForDate.isEmpty
          ? ListView(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              children: [
                Text(
                  _getDateString(_selectedDate),
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'Không có lịch học trong ngày này',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                AppSizes.paddingMedium,
                AppSizes.paddingSmall,
                AppSizes.paddingMedium,
                100.h,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                  child: Text(
                    _getDateString(_selectedDate),
                    style: TextStyle(
                      fontSize: isDesktop ? 18.sp : 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                ...schedulesForDate.map(
                  (schedule) => Padding(
                    padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                    child: ScheduleItem(
                      schedule: schedule,
                      onTap: () => _showScheduleDetail(schedule),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSchedulesForDate(
    List<Schedule> schedules,
    bool isDark,
    bool isDesktop,
  ) {
    final schedulesForDate = schedules
        .where(
          (s) =>
              s.startTime.year == _selectedDate.year &&
              s.startTime.month == _selectedDate.month &&
              s.startTime.day == _selectedDate.day,
        )
        .toList();

    if (schedulesForDate.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Center(
          child: Text(
            'Không có lịch học trong ngày này',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              fontFamily: 'Lexend',
            ),
          ),
        ),
      );
    }

    return Column(
      children: schedulesForDate
          .map(
            (schedule) => Padding(
              padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
              child: ScheduleItem(
                schedule: schedule,
                onTap: () => _showScheduleDetail(schedule),
              ),
            ),
          )
          .toList(),
    );
  }
}
