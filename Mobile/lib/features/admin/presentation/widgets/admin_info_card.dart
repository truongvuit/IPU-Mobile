import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';








class AdminInfoCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? description;
  final List<Widget>? badges;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AdminInfoCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.description,
    this.badges,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              
              if (leading != null) ...[leading!, SizedBox(width: AppSizes.p12)],

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    
                    if (subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    
                    if (description != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral500,
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    
                    if (badges != null && badges!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: AppSizes.p8,
                        runSpacing: AppSizes.p4,
                        children: badges!,
                      ),
                    ],
                  ],
                ),
              ),

              
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    size: 20.sp,
                    color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}


class AdminCardAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData fallbackIcon;
  final double size;

  const AdminCardAvatar({
    super.key,
    this.imageUrl,
    this.fallbackIcon = Icons.person,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.neutral700 : AppColors.neutral200,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                width: size.r,
                height: size.r,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(isDark),
              ),
            )
          : _buildFallback(isDark),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Icon(
      fallbackIcon,
      size: (size * 0.6).sp,
      color: isDark ? AppColors.neutral500 : AppColors.neutral600,
    );
  }
}


class AdminCardBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const AdminCardBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: badgeColor),
        SizedBox(width: 4.w),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
