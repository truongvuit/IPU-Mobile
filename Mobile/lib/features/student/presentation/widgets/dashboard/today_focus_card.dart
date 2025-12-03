import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class TodayFocusCard extends StatelessWidget {
  final String className;
  final String timeSlot;
  final String room;
  final bool isOnline;
  final bool isDark;
  final VoidCallback? onTap;

  const TodayFocusCard({
    super.key,
    required this.className,
    required this.timeSlot,
    required this.room,
    this.isOnline = false,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Hôm nay học gì?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              className,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                SizedBox(width: 6.w),
                Text(
                  timeSlot,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOnline ? Icons.laptop : Icons.location_on,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isOnline ? 'Online' : room,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
