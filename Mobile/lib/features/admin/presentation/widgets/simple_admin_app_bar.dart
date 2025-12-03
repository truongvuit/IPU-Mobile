import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class SimpleAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const SimpleAdminAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizes.textLg,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      foregroundColor: isDark
          ? AppColors.textPrimaryDark
          : AppColors.textPrimary,
      elevation: 2,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
