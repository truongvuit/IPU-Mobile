import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_image.dart';



class BaseStudentTile extends StatelessWidget {
  
  final String name;
  
  
  final String? code;
  
  
  final String? avatarUrl;
  
  
  final String? email;
  
  
  final double? attendanceRate;
  
  
  final double? averageScore;
  
  
  final VoidCallback? onTap;
  
  
  final bool isGridItem;
  
  
  final Widget? trailing;
  
  
  final Widget? subtitle;

  const BaseStudentTile({
    super.key,
    required this.name,
    this.code,
    this.avatarUrl,
    this.email,
    this.attendanceRate,
    this.averageScore,
    this.onTap,
    this.isGridItem = false,
    this.trailing,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isGridItem) {
      return _buildGridItem(context, isDark);
    }
    return _buildListItem(context, isDark);
  }

  Widget _buildListItem(BuildContext context, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                _buildAvatar(36.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (code != null || email != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          code ?? email ?? '',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (subtitle != null) subtitle!,
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (attendanceRate != null || averageScore != null)
                  _buildStats(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                _buildAvatar(40.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (code != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          code!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (attendanceRate != null || averageScore != null) ...[
                        SizedBox(height: 4.h),
                        _buildCompactStats(isDark),
                      ],
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

  Widget _buildAvatar(double size) {
    return ClipOval(
      child: CustomImage(
        imageUrl: avatarUrl ?? '',
        width: size,
        height: size,
        fit: BoxFit.cover,
        isAvatar: true,
      ),
    );
  }

  Widget _buildStats(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (attendanceRate != null) ...[
          _buildStatChip(
            '${attendanceRate!.toStringAsFixed(0)}%',
            Icons.check_circle_outline,
            _getAttendanceColor(attendanceRate!),
            isDark,
          ),
          SizedBox(width: 6.w),
        ],
        if (averageScore != null)
          _buildStatChip(
            averageScore!.toStringAsFixed(1),
            Icons.star_outline,
            _getScoreColor(averageScore!),
            isDark,
          ),
      ],
    );
  }

  Widget _buildCompactStats(bool isDark) {
    return Row(
      children: [
        if (attendanceRate != null) ...[
          Icon(
            Icons.check_circle,
            size: 12.sp,
            color: _getAttendanceColor(attendanceRate!),
          ),
          SizedBox(width: 2.w),
          Text(
            '${attendanceRate!.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10.sp,
              color: _getAttendanceColor(attendanceRate!),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (attendanceRate != null && averageScore != null)
          SizedBox(width: 8.w),
        if (averageScore != null) ...[
          Icon(
            Icons.star,
            size: 12.sp,
            color: _getScoreColor(averageScore!),
          ),
          SizedBox(width: 2.w),
          Text(
            averageScore!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10.sp,
              color: _getScoreColor(averageScore!),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 80) return AppColors.success;
    if (rate >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return AppColors.success;
    if (score >= 6.5) return AppColors.info;
    if (score >= 5) return AppColors.warning;
    return AppColors.error;
  }
}
