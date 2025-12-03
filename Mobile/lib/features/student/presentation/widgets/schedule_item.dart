import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/schedule.dart';

class ScheduleItem extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback? onTap;

  const ScheduleItem({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Determine if schedule is today
    final now = DateTime.now();
    final isToday = schedule.startTime.year == now.year &&
        schedule.startTime.month == now.month &&
        schedule.startTime.day == now.day;

    // Determine if schedule is upcoming (within next 2 hours)
    final isUpcoming = schedule.startTime.isAfter(now) &&
        schedule.startTime.difference(now).inHours < 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: const Color(0xFF135BEC),
                  width: 2,
                )
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
            // Time indicator
            Container(
              width: 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF135BEC)
                    : (isDark
                        ? const Color(0xFF111827)
                        : const Color(0xFFF8FAFC)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    timeFormat.format(schedule.startTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(schedule.endTime),
                    style: TextStyle(
                      fontSize: 14,
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

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course name
                    Text(
                      schedule.className,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Teacher
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            schedule.teacherName,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Room
                    Row(
                      children: [
                        Icon(
                          schedule.isOnline
                              ? Icons.videocam
                              : Icons.location_on,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          schedule.room,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),

                    // Date (if not today)
                    if (!isToday) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(schedule.startTime),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Status badge
                    if (isUpcoming) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Sắp diễn ra',
                              style: TextStyle(
                                fontSize: 12,
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

