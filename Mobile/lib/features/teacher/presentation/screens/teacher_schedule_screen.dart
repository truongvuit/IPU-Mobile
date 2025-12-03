import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../widgets/teacher_app_bar.dart';
import '../widgets/teacher_schedule_detail_modal.dart';
import '../widgets/teacher_schedule_card.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    context.read<TeacherBloc>().add(LoadWeekSchedule(_selectedDay));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<TeacherBloc>().add(LoadWeekSchedule(selectedDay));
    }
  }

  List<TeacherSchedule> _filterSchedules(List<TeacherSchedule> schedules) {
    
    final dateFiltered = schedules
        .where((s) => isSameDay(s.startTime, _selectedDay))
        .toList();

    
    List<TeacherSchedule> filtered;
    if (_searchQuery.isEmpty) {
      filtered = dateFiltered;
    } else {
      filtered = dateFiltered.where((s) {
        return s.className.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.room.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    
    filtered.sort((a, b) {
      final priorityCompare = a.sortPriority.compareTo(b.sortPriority);
      if (priorityCompare != 0) return priorityCompare;
      
      return a.startTime.compareTo(b.startTime);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Column(
        children: [
          TeacherAppBar(
            title: 'Lịch dạy',
            showBackButton: false,
            actions: [
              IconButton(
                onPressed: () => setState(() => _showSearch = !_showSearch),
                icon: Icon(
                  _showSearch ? Icons.search_off : Icons.search,
                  size: isDesktop
                      ? AppSizes.iconMedium
                      : AppSizes.iconSmall + 4,
                ),
                color: _showSearch
                    ? AppColors.primary
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),

          Container(
            color: isDark ? AppColors.gray800 : Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: 'vi_VN',
              availableCalendarFormats: const {
                CalendarFormat.month: 'Tháng',
                CalendarFormat.twoWeeks: '2 tuần',
                CalendarFormat.week: 'Tuần',
              },
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },

              calendarBuilders: CalendarBuilders(
                headerTitleBuilder: (context, day) {
                  final monthNames = [
                    'Tháng 1',
                    'Tháng 2',
                    'Tháng 3',
                    'Tháng 4',
                    'Tháng 5',
                    'Tháng 6',
                    'Tháng 7',
                    'Tháng 8',
                    'Tháng 9',
                    'Tháng 10',
                    'Tháng 11',
                    'Tháng 12',
                  ];
                  return Center(
                    child: Text(
                      '${monthNames[day.month - 1]} năm ${day.year}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),

              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                formatButtonShowsNext: false,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
              ),

              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                weekendTextStyle: const TextStyle(color: AppColors.error),
                outsideTextStyle: TextStyle(
                  color: isDark
                      ? Colors.white24
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: AppColors.error.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearch ? null : 0,
            child: _showSearch
                ? Container(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.gray900
                          : AppColors.backgroundAlt,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.gray700 : AppColors.divider,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm theo tên lớp, phòng học...',
                        hintStyle: TextStyle(
                          fontSize: isDesktop
                              ? AppSizes.textBase
                              : AppSizes.textSm,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.gray800 : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isDesktop ? AppSizes.p16 : AppSizes.p12,
                          horizontal: AppSizes.p16,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: BlocBuilder<TeacherBloc, TeacherState>(
              builder: (context, state) {
                if (state is TeacherLoading) {
                  return ListView.builder(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: SkeletonWidget.rectangular(height: 80.h),
                    ),
                  );
                }

                if (state is TeacherError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        isDesktop ? AppSizes.p32 : AppSizes.p24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isDesktop ? 64.sp : 48.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(
                            height: isDesktop ? AppSizes.p24 : AppSizes.p16,
                          ),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? AppSizes.textXl
                                  : AppSizes.textLg,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: isDesktop ? AppSizes.p24 : AppSizes.p16,
                          ),
                          ElevatedButton.icon(
                            onPressed: () => context.read<TeacherBloc>().add(
                              LoadWeekSchedule(_selectedDay),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              'Thử lại',
                              style: TextStyle(
                                fontSize: isDesktop
                                    ? AppSizes.textLg
                                    : AppSizes.textBase,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop
                                    ? AppSizes.p16
                                    : AppSizes.p12,
                                horizontal: isDesktop
                                    ? AppSizes.p32
                                    : AppSizes.p24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ScheduleLoaded) {
                  final filteredSchedules = _filterSchedules(state.schedule);
                  final isToday = isSameDay(_selectedDay, DateTime.now());

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<TeacherBloc>().add(
                        LoadWeekSchedule(_selectedDay),
                      );
                    },
                    child: filteredSchedules.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.paddingMedium),
                              child: EmptyStateWidget(
                                icon: _searchQuery.isNotEmpty
                                    ? Icons.search_off
                                    : Icons.calendar_today_outlined,
                                message: _searchQuery.isNotEmpty
                                    ? 'Không tìm thấy lịch dạy phù hợp'
                                    : 'Không có lịch dạy cho ngày này',
                              ),
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                              isDesktop ? AppSizes.p32 : AppSizes.paddingMedium,
                              AppSizes.p16,
                              isDesktop ? AppSizes.p32 : AppSizes.paddingMedium,
                              100,
                            ),
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: AppSizes.p16),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop
                                      ? AppSizes.p16
                                      : AppSizes.p12,
                                  vertical: isDesktop
                                      ? AppSizes.p12
                                      : AppSizes.p8,
                                ),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppColors.primary.withValues(
                                          alpha: 0.12,
                                        )
                                      : (isDark
                                            ? AppColors.gray800
                                            : AppColors.backgroundAlt),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSmall,
                                  ),
                                  border: isToday
                                      ? Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isToday
                                          ? Icons.today
                                          : Icons.calendar_today,
                                      size: isDesktop
                                          ? AppSizes.iconSmall + 4
                                          : AppSizes.iconSmall + 2,
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    SizedBox(width: AppSizes.p12),
                                    Expanded(
                                      child: Text(
                                        isToday
                                            ? 'Lịch dạy hôm nay'
                                            : 'Lịch dạy ngày ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? AppSizes.textLg
                                              : AppSizes.textBase + 1,
                                          fontWeight: FontWeight.w700,
                                          color: isToday
                                              ? AppColors.primary
                                              : (isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary),
                                        ),
                                      ),
                                    ),
                                    if (isToday)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSizes.p8,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusMedium,
                                          ),
                                        ),
                                        child: Text(
                                          'Hôm nay',
                                          style: TextStyle(
                                            fontSize: AppSizes.textXs + 1,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: AppSizes.p12),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.p12 - 2,
                                        vertical: AppSizes.p4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.gray900
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMedium,
                                        ),
                                      ),
                                      child: Text(
                                        '${filteredSchedules.length} lớp',
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? AppSizes.textSm
                                              : AppSizes.textXs,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ...filteredSchedules.map(
                                (schedule) => TeacherScheduleCard(
                                  schedule: schedule,
                                  onTap: () {
                                    try {
                                      TeacherScheduleDetailModal.show(
                                        context,
                                        schedule,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Không thể mở chi tiết: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
