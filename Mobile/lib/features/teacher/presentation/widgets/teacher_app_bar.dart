import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';


class TeacherAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  final List<Widget>? actions;

  const TeacherAppBar({
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
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _buildLeading(context, isDark),
              ),
              if (title != null)
                Center(
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: _buildTrailing(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context, bool isDark) {
    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      );
    }

    if (showMenuButton) {
      return IconButton(
        icon: Icon(
          Icons.menu,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        onPressed: onMenuPressed,
      );
    }

    if (avatarUrl != null || greeting != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (avatarUrl != null)
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: CustomImage(
                    imageUrl: avatarUrl!,
                    width: 48.w,
                    height: 48.h,
                    fit: BoxFit.cover,
                    isAvatar: true,
                  ),
                ),
              ),
            ),
          if (greeting != null) ...[
            SizedBox(width: AppSizes.paddingSmall),
            Text(
              greeting!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ],
      );
    }

    return SizedBox(width: 48.w); // balance title centering
  }

  Widget _buildTrailing(bool isDark) {
    final trailing = <Widget>[];

    if (onNotificationTap != null) {
      trailing.add(
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
              ),
              onPressed: onNotificationTap,
            ),
            if (showNotificationBadge)
              Positioned(
                right: 10.w,
                top: 10.h,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (actions != null) {
      trailing.addAll(actions!);
    }

    if (trailing.isEmpty) {
      return SizedBox(width: 48.w); // mirror leading width when no actions
    }

    return Row(mainAxisSize: MainAxisSize.min, children: trailing);
  }
}

