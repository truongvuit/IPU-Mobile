import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? avatarUrl;
  final String? greeting;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final bool showNotificationBadge;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const StudentAppBar({
    super.key,
    this.title,
    this.avatarUrl,
    this.greeting,
    this.onAvatarTap,
    this.onNotificationTap,
    this.showNotificationBadge = false,
    this.showBackButton = false,
    this.onBackPressed,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left side (Back button or Avatar or Menu)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : AppColors.slate800,
                        size: AppSizes.iconMedium,
                      ),
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    )
                  else if (showMenuButton)
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDark ? Colors.white : AppColors.slate800,
                        size: AppSizes.iconMedium,
                      ),
                      onPressed: onMenuPressed,
                    )
                  else if (avatarUrl != null || greeting != null)
                    Row(
                      children: [
                        // Avatar
                        if (avatarUrl != null)
                          GestureDetector(
                            onTap: onAvatarTap,
                            child: CustomImage(
                              imageUrl: avatarUrl!,
                              width: 48.w,
                              height: 48.w,
                              borderRadius: 24.r,
                              isAvatar: true,
                            ),
                          ),
                        if (greeting != null) ...[
                          SizedBox(width: AppSizes.p12),
                          Text(
                            greeting!,
                            style: TextStyle(
                              fontSize: AppSizes.textXl,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.slate900,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),

            // Center Title
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.textXl,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.slate900,
                  fontFamily: 'Lexend',
                ),
              ),

            // Right side (Notification)
            if (onNotificationTap != null)
              Align(
                alignment: Alignment.centerRight,
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: isDark
                            ? AppColors.gray300
                            : AppColors.slate600,
                        size: AppSizes.iconMedium,
                      ),
                      onPressed: onNotificationTap,
                    ),
                    if (showNotificationBadge)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
