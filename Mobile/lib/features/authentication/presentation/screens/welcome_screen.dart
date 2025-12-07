import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/common/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 600
                      : (isTablet ? 500 : double.infinity),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40.w : 32.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Container(
                              width: isDesktop ? 180.w : 150.w,
                              height: isDesktop ? 180.w : 150.w,
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.backgroundLight,
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.school_rounded,
                                    size: 80.w,
                                    color: AppColors.primary,
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 48.h),

                            
                            Text(
                              'Chào mừng đến với',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isDesktop ? 20.sp : 18.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            SizedBox(height: 12.h),

                            Text(
                              'IELTS Power Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isDesktop ? 36.sp : 32.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Lexend',
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            
                            Text(
                              'Nền tảng học tập và ôn luyện IELTS\nhàng đầu dành cho bạn.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isDesktop ? 16.sp : 15.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                                fontFamily: 'Lexend',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      
                      Padding(
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: AppButton(
                          text: 'Bắt đầu ngay',
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                          width: double.infinity,
                          height: isDesktop ? 56.h : 52.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
