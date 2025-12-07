import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/admin_activity.dart';

class AdminActivityItem extends StatelessWidget {
  final AdminActivity activity;
  final VoidCallback? onTap;

  const AdminActivityItem({super.key, required this.activity, this.onTap});

  IconData _getIconForType(ActivityType type) {
    switch (type) {
      case ActivityType.registration:
        return Icons.person_add;
      case ActivityType.payment:
        return Icons.payment;
      case ActivityType.classEnd:
        return Icons.class_;
      case ActivityType.profileUpdate:
        return Icons.edit;
      case ActivityType.other:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(ActivityType type) {
    switch (type) {
      case ActivityType.registration:
        return AppColors.info;
      case ActivityType.payment:
        return AppColors.success;
      case ActivityType.classEnd:
        return Colors.purple;
      case ActivityType.profileUpdate:
        return AppColors.warning;
      case ActivityType.other:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(color: isDark ? AppColors.neutral700 : AppColors.neutral200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSizes.p40,
                height: AppSizes.p40,
                decoration: BoxDecoration(
                  color: _getColorForType(activity.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(
                  _getIconForType(activity.type),
                  color: _getColorForType(activity.type),
                  size: AppSizes.iconMedium,
                ),
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.textBase,
                      ),
                    ),
                    SizedBox(height: AppSizes.p4),
                    Text(
                      activity.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        fontSize: AppSizes.textSm,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.p4),
                    Text(
                      activity.displayTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                        fontSize: AppSizes.textXs,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
