import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class ClassCourseInfoSection extends StatelessWidget {
  final bool isDark;
  final String? courseType;
  final String? level;
  final String? duration;

  const ClassCourseInfoSection({
    super.key,
    required this.isDark,
    this.courseType,
    this.level,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    if (courseType == null && level == null && duration == null) {
      return const SizedBox.shrink();
    }

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
            'Thông tin khóa học',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 12.h),
          if (courseType != null) ...[
            _buildCourseInfoRow(
              Icons.school_outlined,
              'Loại khóa học',
              courseType!,
            ),
            SizedBox(height: 10.h),
          ],
          if (level != null) ...[
            _buildCourseInfoRow(
              Icons.signal_cellular_alt,
              'Trình độ',
              level!,
            ),
            SizedBox(height: 10.h),
          ],
          if (duration != null)
            _buildCourseInfoRow(
              Icons.timer_outlined,
              'Thời lượng',
              duration!,
            ),
        ],
      ),
    );
  }

  Widget _buildCourseInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
