import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../../domain/entities/admin_class.dart';

class ClassSelectionCard extends StatelessWidget {
  final AdminClass classItem;
  final bool isSelected;
  final VoidCallback? onTap;

  const ClassSelectionCard({
    super.key,
    required this.classItem,
    this.isSelected = false,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (classItem.status) {
      case ClassStatus.upcoming:
        return AppColors.warning;
      case ClassStatus.ongoing:
        return AppColors.success;
      case ClassStatus.completed:
        return AppColors.gray500;
    }
  }

  String _getStatusText() {
    if (classItem.isFull) return 'Đã đầy';

    switch (classItem.status) {
      case ClassStatus.upcoming:
        return 'Sắp khai giảng';
      case ClassStatus.ongoing:
        return 'Đang mở';
      case ClassStatus.completed:
        return 'Đã kết thúc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.gray700 : AppColors.gray200),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: classItem.isFull || classItem.status == ClassStatus.completed
            ? null
            : onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      classItem.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.textBase,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.p8,
                      vertical: AppSizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontSize: AppSizes.textXs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p8),

              // Schedule
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSizes.textSm,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                  SizedBox(width: AppSizes.p8),
                  Text(
                    '${classItem.schedule} | ${classItem.timeRange}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontSize: AppSizes.textXs,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p4),

              // Teacher
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: AppSizes.textSm,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                  SizedBox(width: AppSizes.p8),
                  Text(
                    'Giảng viên: ${classItem.teacherName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      fontSize: AppSizes.textXs,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p8),

              // Student progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      child: LinearProgressIndicator(
                        value: classItem.enrollmentPercentage / 100,
                        backgroundColor: isDark
                            ? AppColors.gray700
                            : AppColors.gray200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          classItem.isFull
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                        minHeight: AppSizes.p8,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.p8),
                  Text(
                    classItem.studentCountText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.textXs,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
