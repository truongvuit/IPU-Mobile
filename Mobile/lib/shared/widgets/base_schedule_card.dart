import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';



class BaseScheduleCard extends StatelessWidget {
  
  final String id;
  
  
  final String className;
  
  
  final DateTime startTime;
  
  
  final DateTime endTime;
  
  
  final String? room;
  
  
  final String? note;
  
  
  final String? teacherName;
  
  
  final bool isOngoing;
  
  
  final bool isUpcoming;
  
  
  final bool isCompleted;
  
  
  final VoidCallback? onTap;
  
  
  final List<Widget>? actions;
  
  
  final bool showStatus;
  
  
  final String? statusText;
  
  
  final Color? statusColor;

  const BaseScheduleCard({
    super.key,
    required this.id,
    required this.className,
    required this.startTime,
    required this.endTime,
    this.room,
    this.note,
    this.teacherName,
    this.isOngoing = false,
    this.isUpcoming = false,
    this.isCompleted = false,
    this.onTap,
    this.actions,
    this.showStatus = true,
    this.statusText,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('HH:mm');
    
    final effectiveStatusColor = statusColor ?? _getStatusColor();
    final effectiveStatusText = statusText ?? _getStatusText();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isOngoing
            ? Border.all(color: AppColors.success, width: 2)
            : isUpcoming
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isCompleted ? 0.02 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    children: [
                      if (showStatus)
                        _buildStatusBadge(effectiveStatusText, effectiveStatusColor),
                      const Spacer(),
                      _buildTimeRange(dateFormat, isDark),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  
                  Text(
                    className,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  
                  
                  if (note != null && note!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      note!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                  
                  
                  if (teacherName != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14.sp,
                          color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          teacherName!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 12.h),

                  
                  Row(
                    children: [
                      if (room != null) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          room!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.primary,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (actions != null) ...actions!,
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRange(DateFormat format, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16.sp,
          color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Text(
          '${format.format(startTime)} - ${format.format(endTime)}',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (isOngoing) return AppColors.success;
    if (isUpcoming) return AppColors.primary;
    if (isCompleted) return AppColors.neutral500;
    return AppColors.primary;
  }

  String _getStatusText() {
    if (isOngoing) return 'Đang diễn ra';
    if (isUpcoming) return 'Sắp tới';
    if (isCompleted) return 'Đã kết thúc';
    return '';
  }
}
