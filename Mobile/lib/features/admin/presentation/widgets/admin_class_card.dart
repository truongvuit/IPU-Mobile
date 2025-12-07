import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_class.dart';

class AdminClassCard extends StatelessWidget {
  final AdminClass classItem;
  final VoidCallback? onTap;

  const AdminClassCard({super.key, required this.classItem, this.onTap});

  Color _getStatusColor() {
    switch (classItem.status) {
      case ClassStatus.ongoing:
        return AppColors.success;
      case ClassStatus.upcoming:
        return AppColors.info;
      case ClassStatus.completed:
        return AppColors.neutral500;
    }
  }

  IconData _getStatusIcon() {
    switch (classItem.status) {
      case ClassStatus.ongoing:
        return Icons.play_circle_outline;
      case ClassStatus.upcoming:
        return Icons.schedule;
      case ClassStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? AppColors.neutral700.withValues(alpha: 0.3)
              : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 12.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                classItem.courseName,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 12.sp,
                            color: _getStatusColor(),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            classItem.statusText,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                
                Text(
                  classItem.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 10.h),

                
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_month_outlined,
                  text: classItem.schedule,
                  secondIcon: Icons.access_time_outlined,
                  secondText: classItem.timeRange,
                ),

                SizedBox(height: 6.h),

                
                _buildInfoRow(
                  context,
                  icon: Icons.person_outline,
                  text: classItem.teacherName,
                  secondIcon: Icons.room_outlined,
                  secondText: classItem.room,
                ),

                SizedBox(height: 10.h),

                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.neutral800.withValues(alpha: 0.5)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        classItem.studentCountText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    IconData? secondIcon,
    String? secondText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.neutral300 : AppColors.neutral700;

    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (secondIcon != null && secondText != null) ...[
          SizedBox(width: 12.w),
          Icon(
            secondIcon,
            size: 14.sp,
            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
          ),
          SizedBox(width: 6.w),
          Text(
            secondText,
            style: TextStyle(
              fontSize: 12.sp,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
