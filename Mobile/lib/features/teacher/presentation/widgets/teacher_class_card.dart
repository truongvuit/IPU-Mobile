import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/teacher_class.dart';

class TeacherClassCard extends StatelessWidget {
  final TeacherClass classItem;
  final VoidCallback? onTap;
  final bool compact;

  const TeacherClassCard({
    super.key,
    required this.classItem,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(classItem.status);
    final statusText = _getStatusText(classItem.status);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
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
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: statusColor,
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
                        classItem.name ?? 'Không có tên',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
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
                            color: isDark ? AppColors.gray400 : AppColors.gray500,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${classItem.schedule ?? 'N/A'} • ${_formatTime(classItem.startTime)}-${_formatTime(classItem.endTime)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.gray400 : AppColors.textSecondary,
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 12.sp,
                          color: isDark ? AppColors.gray400 : AppColors.gray500,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${classItem.totalStudents}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.gray300 : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(width: 4.w),
                
                Icon(
                  Icons.chevron_right,
                  size: 20.sp,
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return AppColors.warning;
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'ongoing':
        return AppColors.success;
      case 'upcoming':
        return AppColors.info;
      case 'completed':
      case 'closed':
        return AppColors.gray500;
      default:
        return AppColors.warning;
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Chưa rõ';
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'ongoing':
        return 'Đang học';
      case 'upcoming':
        return 'Sắp tới';
      case 'completed':
      case 'closed':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
