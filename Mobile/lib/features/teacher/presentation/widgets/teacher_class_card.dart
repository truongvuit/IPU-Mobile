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
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                
                Container(
                  width: 5.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        classItem.name ?? 'Không có tên',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14.sp,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              '${classItem.schedule ?? 'N/A'} • ${_formatTime(classItem.startTime)}-${_formatTime(classItem.endTime)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
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
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              (classItem.room != null && classItem.room!.isNotEmpty)
                                  ? classItem.room!
                                  : 'Chưa có phòng',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? AppColors.neutral400 : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14.sp,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${classItem.totalStudents}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.neutral300 : AppColors.neutral600,
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
                  color: isDark ? AppColors.neutral500 : AppColors.neutral400,
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
        return AppColors.neutral500;
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
