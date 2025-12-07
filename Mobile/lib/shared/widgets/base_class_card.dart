import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';



class BaseClassCard extends StatelessWidget {
  
  final String name;
  
  
  final String? code;
  
  
  final String? schedule;
  
  
  final String? timeRange;
  
  
  final String? room;
  
  
  final String? statusText;
  
  
  final Color statusColor;
  
  
  final int? studentCount;
  
  
  final VoidCallback? onTap;
  
  
  final bool compact;
  
  
  final Widget? trailing;
  
  
  final Widget? leading;
  
  
  final List<Widget>? additionalInfo;

  const BaseClassCard({
    super.key,
    required this.name,
    this.code,
    this.schedule,
    this.timeRange,
    this.room,
    this.statusText,
    this.statusColor = AppColors.primary,
    this.studentCount,
    this.onTap,
    this.compact = false,
    this.trailing,
    this.leading,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: compact ? 10.h : 14.h,
            ),
            child: Row(
              children: [
                
                leading ?? Container(
                  width: 4.w,
                  height: compact ? 40.h : 50.h,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: compact ? 14.sp : 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (schedule != null || timeRange != null) ...[
                        SizedBox(height: 4.h),
                        _buildInfoRow(
                          Icons.schedule,
                          [
                            if (schedule != null) schedule!,
                            if (timeRange != null) timeRange!,
                          ].join(' • '),
                          isDark,
                        ),
                      ],
                      if (room != null) ...[
                        SizedBox(height: 2.h),
                        _buildInfoRow(Icons.location_on_outlined, room!, isDark),
                      ],
                      if (additionalInfo != null) ...additionalInfo!,
                    ],
                  ),
                ),
                
                if (trailing != null || statusText != null || studentCount != null) ...[
                  SizedBox(width: 8.w),
                  trailing ?? _buildDefaultTrailing(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultTrailing(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (statusText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              statusText!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        if (studentCount != null) ...[
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline,
                size: 12.sp,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
              SizedBox(width: 2.w),
              Text(
                '$studentCount',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
