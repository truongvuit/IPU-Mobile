import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Schedule Detail Modal - Hiển thị chi tiết buổi học
class ScheduleDetailModal extends StatelessWidget {
  final Schedule schedule;

  const ScheduleDetailModal({
    super.key,
    required this.schedule,
  });

  static void show(BuildContext context, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailModal(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN');

    // Determine if schedule is today
    final now = DateTime.now();
    final isToday = schedule.startTime.year == now.year &&
        schedule.startTime.month == now.month &&
        schedule.startTime.day == now.day;

    // Determine if schedule is upcoming
    final isUpcoming = schedule.startTime.isAfter(now);
    final isPast = schedule.endTime.isBefore(now);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with status badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chi tiết buổi học',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                      if (isToday)
                        _buildStatusBadge(
                          'Hôm nay',
                          const Color(0xFF135BEC),
                          isDark,
                        )
                      else if (isUpcoming)
                        _buildStatusBadge(
                          'Sắp tới',
                          const Color(0xFFF59E0B),
                          isDark,
                        )
                      else if (isPast)
                        _buildStatusBadge(
                          'Đã qua',
                          const Color(0xFF6B7280),
                          isDark,
                        ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Class name
                  _buildInfoSection(
                    icon: Icons.school,
                    label: 'Lớp học',
                    value: schedule.className,
                    isDark: isDark,
                  ),

                  SizedBox(height: 16.h),

                  // Teacher
                  _buildInfoSection(
                    icon: Icons.person,
                    label: 'Giảng viên',
                    value: schedule.teacherName,
                    isDark: isDark,
                  ),

                  SizedBox(height: 16.h),

                  // Time
                  _buildInfoSection(
                    icon: Icons.access_time,
                    label: 'Thời gian',
                    value: '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}',
                    isDark: isDark,
                  ),

                  SizedBox(height: 16.h),

                  // Date
                  _buildInfoSection(
                    icon: Icons.calendar_today,
                    label: 'Ngày học',
                    value: dateFormat.format(schedule.startTime),
                    isDark: isDark,
                  ),

                  SizedBox(height: 16.h),

                  // Room/Location
                  _buildInfoSection(
                    icon: schedule.isOnline ? Icons.videocam : Icons.location_on,
                    label: schedule.isOnline ? 'Link học online' : 'Phòng học',
                    value: schedule.room,
                    isDark: isDark,
                    isLink: schedule.isOnline,
                  ),

                  SizedBox(height: 24.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                          ),
                          child: Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isLink = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: AppColors.primary,
            ),
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
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isLink ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimary),
                    fontFamily: 'Lexend',
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
