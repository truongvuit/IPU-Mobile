import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/entities/attendance_arguments.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

class TeacherAttendanceListScreen extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const TeacherAttendanceListScreen({super.key, this.onOpenDrawer});

  @override
  State<TeacherAttendanceListScreen> createState() =>
      _TeacherAttendanceListScreenState();
}

class _TeacherAttendanceListScreenState
    extends State<TeacherAttendanceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'active'; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTodaySchedule();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedFilter = 'active'; 
          break;
        case 1:
          _selectedFilter = 'completed';
          break;
        case 2:
          _selectedFilter = 'all';
          break;
      }
    });
  }

  void _loadTodaySchedule() {
    context.read<TeacherBloc>().add(LoadTodaySchedule());
  }

  List<TeacherSchedule> _filterSchedules(List<TeacherSchedule> schedules) {
    List<TeacherSchedule> filtered;
    
    switch (_selectedFilter) {
      case 'ongoing':
        filtered = schedules.where((s) => s.isOngoing).toList();
        break;
      case 'upcoming':
        filtered = schedules.where((s) => s.isUpcoming).toList();
        break;
      case 'completed':
        filtered = schedules.where((s) => s.isCompleted).toList();
        break;
      case 'active':
        
        filtered = schedules.where((s) => s.isOngoing || s.isUpcoming).toList();
        break;
      default:
        filtered = schedules;
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        leading: widget.onOpenDrawer != null
            ? IconButton(
                icon: Icon(
                  Icons.menu,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                onPressed: widget.onOpenDrawer,
              )
            : null,
        title: Text(
          'Điểm danh',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontFamily: 'Lexend',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: _loadTodaySchedule,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white70 : AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lexend',
          ),
          tabs: const [
            Tab(text: 'Cần điểm danh'),
            Tab(text: 'Đã kết thúc'),
            Tab(text: 'Tất cả'),
          ],
        ),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading) {
            return _buildLoadingState();
          }

          if (state is TeacherError) {
            return _buildErrorState(state.message);
          }

          
          List<TeacherSchedule> todaySchedule = [];

          if (state is DashboardLoaded) {
            todaySchedule = state.todaySchedule;
          } else if (state is ScheduleLoaded) {
            todaySchedule = state.schedule;
          }

          if (todaySchedule.isEmpty) {
            return _buildEmptyState(isDark);
          }

          
          final filteredSchedules = _filterSchedules(todaySchedule);
          
          if (filteredSchedules.isEmpty) {
            return _buildEmptyFilterState(isDark);
          }

          return _buildScheduleList(filteredSchedules, todaySchedule.length, isDark);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: SkeletonWidget.rectangular(height: 100.h),
          ),
        ),
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
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _loadTodaySchedule,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyStateWidget(
      icon: Icons.event_available_outlined,
      message: 'Không có buổi học hôm nay cần điểm danh',
    );
  }

  Widget _buildEmptyFilterState(bool isDark) {
    String message;
    switch (_selectedFilter) {
      case 'active':
        message = 'Không có buổi học nào đang diễn ra hoặc sắp tới';
        break;
      case 'completed':
        message = 'Chưa có buổi học nào kết thúc hôm nay';
        break;
      default:
        message = 'Không có buổi học phù hợp với bộ lọc';
    }
    return EmptyStateWidget(
      icon: Icons.filter_list_off,
      message: message,
    );
  }

  Widget _buildScheduleList(List<TeacherSchedule> schedules, int totalCount, bool isDark) {
    final now = DateTime.now();
    final dateFormat = DateFormat('HH:mm');

    return RefreshIndicator(
      onRefresh: () async => _loadTodaySchedule(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: schedules.length + 1, 
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Hôm nay, ${DateFormat('dd/MM/yyyy').format(now)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${schedules.length}/$totalCount buổi',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final schedule = schedules[index - 1];
          final isPast = schedule.endTime.isBefore(now);
          final isOngoing =
              schedule.startTime.isBefore(now) && schedule.endTime.isAfter(now);

          return _buildScheduleCard(
            schedule: schedule,
            dateFormat: dateFormat,
            isDark: isDark,
            isPast: isPast,
            isOngoing: isOngoing,
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard({
    required TeacherSchedule schedule,
    required DateFormat dateFormat,
    required bool isDark,
    required bool isPast,
    required bool isOngoing,
  }) {
    final isUpcoming = !isPast && !isOngoing;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isOngoing
            ? Border.all(color: AppColors.success, width: 2)
            : isUpcoming
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPast ? 0.02 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isPast ? 0.7 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToAttendance(schedule, isPast),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOngoing
                              ? AppColors.success.withValues(alpha: 0.1)
                              : isPast
                                  ? AppColors.gray200.withValues(alpha: 0.5)
                                  : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOngoing)
                              Container(
                                width: 8.w,
                                height: 8.w,
                                margin: EdgeInsets.only(right: 6.w),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              isOngoing
                                  ? 'Đang diễn ra'
                                  : isPast
                                      ? 'Đã kết thúc'
                                      : 'Sắp tới',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: isOngoing
                                    ? AppColors.success
                                    : isPast
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16.sp,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${dateFormat.format(schedule.startTime)} - ${dateFormat.format(schedule.endTime)}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  
                  Text(
                    schedule.className,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: 'Lexend',
                    ),
                  ),
                  if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      schedule.note!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF64748B),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        schedule.room ?? 'Chưa có phòng',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const Spacer(),
                      
                      _buildAttendanceButton(isPast: isPast, isOngoing: isOngoing, isUpcoming: isUpcoming),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceButton({
    required bool isPast,
    required bool isOngoing,
    required bool isUpcoming,
  }) {
    if (isPast) {
      
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              'Xem lại',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      );
    }
    
    if (isOngoing) {
      
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fact_check,
              size: 16.sp,
              color: Colors.white,
            ),
            SizedBox(width: 6.w),
            Text(
              'Điểm danh ngay',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),
      );
    }
    
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fact_check_outlined,
            size: 16.sp,
            color: Colors.white,
          ),
          SizedBox(width: 6.w),
          Text(
            'Điểm danh',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAttendance(TeacherSchedule schedule, bool isPast) {
    
    
    
    
    
    
    
    if (isPast) {
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28.sp),
              SizedBox(width: 8.w),
              Text(
                'Buổi học đã kết thúc',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          content: Text(
            'Buổi học "${schedule.className}" đã kết thúc lúc ${DateFormat('HH:mm').format(schedule.endTime)}.\n\nBạn chỉ có thể xem lại thông tin điểm danh, không thể chỉnh sửa.',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Lexend',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _doNavigateToAttendance(schedule, viewOnly: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Xem điểm danh',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _doNavigateToAttendance(schedule, viewOnly: false);
    }
  }

  void _doNavigateToAttendance(TeacherSchedule schedule, {required bool viewOnly}) {
    final args = AttendanceArguments(
      classId: schedule.classId,
      sessionId: schedule.id,
      className: schedule.className,
      sessionDate: schedule.startTime,
      room: schedule.room,
      viewOnly: viewOnly,
    );

    
    Navigator.of(context, rootNavigator: true).pushNamed(
      AppRouter.teacherAttendance,
      arguments: args,
    );
  }
}
