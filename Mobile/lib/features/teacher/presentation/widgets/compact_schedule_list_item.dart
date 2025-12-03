import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class CompactScheduleListItem extends StatelessWidget {
  final dynamic schedule;
  final VoidCallback? onTap;

  const CompactScheduleListItem({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    final startTime = schedule.startTime is DateTime
        ? DateFormat('HH:mm').format(schedule.startTime)
        : schedule.startTime.toString();

    final endTime = schedule.endTime is DateTime
        ? DateFormat('HH:mm').format(schedule.endTime)
        : schedule.endTime.toString();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
        ),
        child: Row(
          children: [
            
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '$startTime-$endTime',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.className ?? 'Lớp học',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    schedule.roomNumber ?? 'Phòng chưa xác định',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),

            
            if (schedule.studentCount != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 12.sp,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${schedule.studentCount}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(width: 8.w),

            
            Icon(
              Icons.chevron_right,
              size: 18.sp,
              color: isDark ? AppColors.gray600 : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
