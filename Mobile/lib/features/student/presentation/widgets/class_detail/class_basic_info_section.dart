import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class ClassBasicInfoSection extends StatelessWidget {
  final bool isDark;
  final String scheduleText;
  final bool isOnline;
  final String room;
  final String timeText;

  const ClassBasicInfoSection({
    super.key,
    required this.isDark,
    required this.scheduleText,
    required this.isOnline,
    required this.room,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.calendar_month,
            'Lịch học',
            scheduleText,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            isOnline ? Icons.videocam : Icons.meeting_room,
            isOnline ? 'Online' : 'Phòng học',
            room,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.access_time,
            'Thời gian',
            timeText,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Lexend',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lexend',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
