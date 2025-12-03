import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class AdminAppBar extends StatelessWidget {
  final String greeting;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const AdminAppBar({
    super.key,
    required this.greeting,
    this.avatarUrl,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMedium,
        MediaQuery.of(context).padding.top + AppSizes.p8,
        AppSizes.paddingMedium,
        AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: AppSizes.p20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: AppSizes.iconMedium,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.textLg,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            icon: Icon(
              Icons.notifications_outlined,
              size: AppSizes.iconMedium,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
