import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalendarConstants {
  static const int daysInWeek = 7;
  static double cellHeight(bool isDesktop) => isDesktop ? 56.h : 48.h;
  static double dateCircleSize(bool isDesktop) => isDesktop ? 44.w : 40.w;
  static const double eventDotSize = 4.0;
  static const double eventDotBottomOffset = 6.0;
}

class CalendarCell extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final bool hasEvents;
  final bool isDark;

  const CalendarCell({
    super.key,
    required this.date,
    required this.selectedDate,
    required this.onTap,
    required this.hasEvents,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF135BEC)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            if (!isSelected && hasEvents)
              Positioned(
                bottom: CalendarConstants.eventDotBottomOffset.h,
                child: Container(
                  width: CalendarConstants.eventDotSize.w,
                  height: CalendarConstants.eventDotSize.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF135BEC),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
