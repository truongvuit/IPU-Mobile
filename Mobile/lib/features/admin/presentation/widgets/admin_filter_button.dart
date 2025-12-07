import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';





class AdminFilterButton extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;
  final int? activeFilterCount;

  const AdminFilterButton({
    super.key,
    required this.hasActiveFilter,
    required this.onTap,
    this.activeFilterCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: hasActiveFilter
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: hasActiveFilter
                ? AppColors.primary
                : (isDark ? AppColors.neutral700 : AppColors.neutral300),
          ),
          boxShadow: hasActiveFilter
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.filter_list,
              color: hasActiveFilter
                  ? AppColors.primary
                  : (isDark ? AppColors.neutral300 : AppColors.neutral700),
              size: 20.sp,
            ),
            if (hasActiveFilter &&
                activeFilterCount != null &&
                activeFilterCount! > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$activeFilterCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
