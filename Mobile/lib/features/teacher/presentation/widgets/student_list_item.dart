import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/class_student.dart';

class StudentListItem extends StatelessWidget {
  final ClassStudent student;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StudentListItem({
    super.key,
    required this.student,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingSmall),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              
              ClipOval(
                child: CustomImage(
                  imageUrl: student.avatarUrl ?? '',
                  width: 48.w,
                  height: 48.h,
                  fit: BoxFit.cover,
                  isAvatar: true,
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      student.studentCode,
                      style: textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (student.averageScore != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.grade,
                            size: 14,
                            color: _getScoreColor(student.averageScore!),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ĐTB: ${student.averageScore!.toStringAsFixed(1)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: _getScoreColor(student.averageScore!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: _getAttendanceColor(student.attendanceRate),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${student.attendanceRate.toStringAsFixed(0)}%',
                            style: textTheme.bodySmall?.copyWith(
                              color: _getAttendanceColor(
                                student.attendanceRate,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

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
}
