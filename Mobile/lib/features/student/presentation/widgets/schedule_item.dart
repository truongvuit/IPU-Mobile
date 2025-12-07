import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';

class ScheduleItem extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;

  const ScheduleItem({super.key, required this.schedule, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    
    final now = DateTime.now();
    final isToday =
        schedule.startTime.year == now.year &&
        schedule.startTime.month == now.month &&
        schedule.startTime.day == now.day;

    
    final isUpcoming =
        schedule.startTime.isAfter(now) &&
        schedule.startTime.difference(now).inHours < 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isToday
              ? Border.all(color: const Color(0xFF135BEC), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            
            Container(
              width: 80.w,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF135BEC)
                    : (isDark
                          ? const Color(0xFF111827)
                          : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    timeFormat.format(schedule.startTime),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    timeFormat.format(schedule.endTime),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.9)
                          : (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B)),
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(
                      schedule.className,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Lexend',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16.sp,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            schedule.teacherName.isEmpty ? 'TBA' : schedule.teacherName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    
                    Row(
                      children: [
                        Icon(
                          schedule.isOnline
                              ? Icons.videocam
                              : Icons.location_on,
                          size: 16.sp,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            schedule.room.isEmpty ? 'TBA' : schedule.room,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    
                    if (!isToday) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16.sp,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            dateFormat.format(schedule.startTime),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],

                    
                    if (isUpcoming) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.sp,
                              color: const Color(0xFFF59E0B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Sắp diễn ra',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF59E0B),
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
