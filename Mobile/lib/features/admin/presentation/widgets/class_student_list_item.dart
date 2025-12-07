import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/class_student.dart';

class ClassStudentListItem extends StatelessWidget {
  final ClassStudent student;
  final VoidCallback? onTap;

  const ClassStudentListItem({super.key, required this.student, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.p12,
          horizontal: AppSizes.p4,
        ),
        child: Row(
          children: [
            
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child:
                    student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: student.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildInitialsAvatar(),
                            errorWidget: (context, url, error) =>
                                _buildInitialsAvatar(),
                          )
                        : _buildInitialsAvatar(),
              ),
            ),
            SizedBox(width: AppSizes.p12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    student.fullName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Mã HV: ${student.displayCode}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),

            
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.success.withValues(alpha: 0.2)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                student.attendanceText,
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        student.initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
