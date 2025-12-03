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
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium, vertical: AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            else if (avatarUrl != null || greeting != null)
              Row(
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
              ),

            
            if (title != null)
              Expanded(
                child: Text(
                  title!,
                  textAlign: showBackButton ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
              )
            else
              const Spacer(),

            
            if (onNotificationTap != null)
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
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

            
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

