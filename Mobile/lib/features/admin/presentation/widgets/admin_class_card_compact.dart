import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_class.dart';

class AdminClassCardCompact extends StatelessWidget {
  final AdminClass classItem;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onChangeRoom;

  const AdminClassCardCompact({
    super.key,
    required this.classItem,
    this.onTap,
    this.onReschedule,
    this.onChangeRoom,
  });

  Color _getStatusColor() {
    switch (classItem.status) {
      case ClassStatus.ongoing:
        return AppColors.success;
      case ClassStatus.upcoming:
        return AppColors.info;
      case ClassStatus.completed:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Slidable(
      key: Key(classItem.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onReschedule?.call(),
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Icons.schedule,
            label: 'Đổi lịch',
            borderRadius: BorderRadius.circular(10.r),
          ),
          SlidableAction(
            onPressed: (_) => onChangeRoom?.call(),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            icon: Icons.room,
            label: 'Đổi phòng',
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark
                ? AppColors.neutral700.withValues(alpha: 0.3)
                : AppColors.neutral200,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          classItem.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12.sp,
                              color: isDark
                                  ? AppColors.neutral400
                                  : AppColors.neutral500,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${classItem.schedule} • ${classItem.timeRange}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark
                                    ? AppColors.neutral400
                                    : AppColors.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStudentCountColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people,
                              size: 11.sp,
                              color: _getStudentCountColor(),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              classItem.studentCountText,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStudentCountColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      Text(
                        classItem.statusText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right,
                    size: 20.sp,
                    color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStudentCountColor() {
    if (classItem.isFull) {
      return AppColors.error;
    } else if (classItem.totalStudents >= classItem.maxStudents * 0.8) {
      return AppColors.warning;
    }
    return AppColors.success;
  }
}
