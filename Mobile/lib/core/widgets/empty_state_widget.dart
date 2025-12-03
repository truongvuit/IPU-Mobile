import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../constants/app_sizes.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.gray800 
                    : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
              ),
            ),
            SizedBox(height: AppSizes.p16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.textLg,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontFamily: 'Lexend',
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: AppSizes.p24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p24,
                    vertical: AppSizes.p12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: TextStyle(
                    fontSize: AppSizes.textBase,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
