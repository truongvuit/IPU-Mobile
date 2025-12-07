import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/class_student.dart';

class StudentGridItem extends StatelessWidget {
  final ClassStudent student;
  final VoidCallback? onTap;
  final bool showStats;

  const StudentGridItem({
    super.key,
    required this.student,
    this.onTap,
    this.showStats = true,
  });

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppColors.success;
    if (score >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return AppColors.success;
    if (rate >= 75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final nameParts = student.fullName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts.first[0]}${nameParts.last[0]}'
        : (nameParts.isNotEmpty ? nameParts.first[0] : '?');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child:
                          student.avatarUrl != null &&
                              student.avatarUrl!.isNotEmpty
                          ? CustomImage(
                              imageUrl: student.avatarUrl!,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                initials.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          student.studentCode,
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (showStats) ...[
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCompactStat(
                      icon: Icons.star_rounded,
                      value: student.averageScore?.toStringAsFixed(1) ?? '--',
                      color: student.averageScore != null
                          ? _getScoreColor(student.averageScore!)
                          : AppColors.neutral500,
                    ),
                    _buildCompactStat(
                      icon: Icons.check_circle_rounded,
                      value: '${student.attendanceRate.toStringAsFixed(0)}%',
                      color: _getAttendanceColor(student.attendanceRate),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 3.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
