import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';





class AdminSectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTitleTap;
  final Widget? trailing;

  const AdminSectionCard({
    super.key,
    this.title,
    this.icon,
    required this.children,
    this.padding,
    this.margin,
    this.onTitleTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin:
          margin ??
          EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.p8,
          ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          if (title != null)
            InkWell(
              onTap: onTitleTap,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusMedium),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.p16,
                  AppSizes.p16,
                  AppSizes.p16,
                  AppSizes.p8,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18.sp, color: AppColors.primary),
                      SizedBox(width: AppSizes.p8),
                    ],
                    Expanded(
                      child: Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                    if (onTitleTap != null)
                      Icon(
                        Icons.chevron_right,
                        size: 18.sp,
                        color: isDark
                            ? AppColors.neutral500
                            : AppColors.neutral400,
                      ),
                  ],
                ),
              ),
            ),

          
          Padding(
            padding:
                padding ??
                EdgeInsets.fromLTRB(
                  AppSizes.p16,
                  title != null ? 0 : AppSizes.p16,
                  AppSizes.p16,
                  AppSizes.p16,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}


class AdminActionSection extends StatelessWidget {
  final List<AdminActionButton> actions;
  final EdgeInsets? margin;

  const AdminActionSection({super.key, required this.actions, this.margin});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin:
          margin ??
          EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.p8,
          ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((action) {
            return Padding(
              padding: EdgeInsets.only(right: AppSizes.p12),
              child: _buildActionButton(action, isDark),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(AdminActionButton action, bool isDark) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        decoration: BoxDecoration(
          color:
              action.backgroundColor ??
              (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color:
                action.borderColor ??
                (isDark ? AppColors.neutral700 : AppColors.neutral200),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              size: 18.sp,
              color: action.iconColor ?? AppColors.primary,
            ),
            SizedBox(width: AppSizes.p8),
            Text(
              action.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color:
                    action.labelColor ??
                    (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AdminActionButton {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const AdminActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.backgroundColor,
    this.borderColor,
  });
}
