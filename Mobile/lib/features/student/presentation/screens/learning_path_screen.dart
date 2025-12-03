import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/student_app_bar.dart';

/// Learning Path Screen - Chức năng đang phát triển
/// API chưa được triển khai ở backend
class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const StudentAppBar(title: 'Lộ trình học tập', showBackButton: true),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.construction_rounded,
                        size: 64.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Chức năng đang phát triển',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Lộ trình học tập sẽ sớm được cập nhật.\nVui lòng quay lại sau!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'Lexend',
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
