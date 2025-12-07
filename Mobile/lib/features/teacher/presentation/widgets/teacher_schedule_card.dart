import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/teacher_schedule.dart';

class TeacherScheduleCard extends StatelessWidget {
  final TeacherSchedule schedule;
  final VoidCallback? onTap;
  final bool showSessionInfo;

  const TeacherScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.showSessionInfo = true,
  });

  Color _getStatusColor() {
    switch (schedule.status) {
      case 'ongoing':
        return AppColors.success;
      case 'upcoming':
        return AppColors.info;
      case 'completed':
        return AppColors.neutral500;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusText() {
    switch (schedule.status) {
      case 'ongoing':
        return 'Đang diễn ra';
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return '';
    }
  }

  IconData _getStatusIcon() {
    switch (schedule.status) {
      case 'ongoing':
        return Icons.play_circle_filled;
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _getStatusColor();
    final isOngoing = schedule.status == 'ongoing';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isOngoing
              ? statusColor.withValues(alpha: 0.5)
              : (isDark ? AppColors.neutral700 : AppColors.neutral200),
          width: isOngoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOngoing
                ? statusColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isOngoing ? 12 : 8,
            spreadRadius: isOngoing ? 2 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildTimeColumn(isDark, textTheme, timeFormat, statusColor),
                SizedBox(width: 16.w),

                
                Expanded(
                  child: _buildContentColumn(isDark, textTheme, statusColor),
                ),

                
                Icon(
                  Icons.chevron_right,
                  size: 24.sp,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(
    bool isDark,
    TextTheme textTheme,
    DateFormat timeFormat,
    Color statusColor,
  ) {
    return Container(
      width: 72.w,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), size: 16.sp, color: statusColor),
          ),
          SizedBox(height: 8.h),

          
          Text(
            timeFormat.format(schedule.startTime),
            style: textTheme.titleMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),

          
          Container(
            margin: EdgeInsets.symmetric(vertical: 4.h),
            width: 20.w,
            height: 2,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          
          Text(
            timeFormat.format(schedule.endTime),
            style: textTheme.bodyMedium?.copyWith(
              color: statusColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentColumn(
    bool isDark,
    TextTheme textTheme,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          children: [
            Expanded(
              child: Text(
                schedule.className,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.location_on,
                size: 14.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              schedule.room,
              style: textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.neutral300 : AppColors.textSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getStatusIcon(), size: 12.sp, color: statusColor),
                  SizedBox(width: 4.w),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),

            
            if (showSessionInfo &&
                schedule.note != null &&
                schedule.note!.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 12.sp,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          schedule.note!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.info,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
