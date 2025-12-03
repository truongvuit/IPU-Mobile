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
    return _buildSimpleCard(context, isDark);
  }

  Widget _buildSimpleCard(BuildContext context, bool isDark) {
    final statusColor = _getStatusColor(classItem.status);
    final statusText = _getStatusText(classItem.status);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.15) 
                : Colors.black.withOpacity(0.04),
            blurRadius: 6,
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
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // Left: Status indicator bar
                Container(
                  width: 3.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // Middle: Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Class name
                      Text(
                        classItem.name ?? 'Không có tên',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                          fontFamily: 'Lexend',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Schedule & Time row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.sp,
                            color: isDark 
                                ? Colors.white.withOpacity(0.5) 
                                : const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${classItem.schedule ?? 'N/A'} • ${_formatTime(classItem.startTime)} - ${_formatTime(classItem.endTime)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark 
                                  ? Colors.white.withOpacity(0.6) 
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 3.h),
                      
                      // Students count
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 13.sp,
                            color: isDark 
                                ? Colors.white.withOpacity(0.5) 
                                : const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${classItem.totalStudents} học viên',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark 
                                  ? Colors.white.withOpacity(0.6) 
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // Right: Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color(0xFFF59E0B);
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'ongoing':
        return const Color(0xFF10B981);
      case 'upcoming':
        return const Color(0xFF6366F1);
      case 'completed':
      case 'closed':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Chưa rõ';
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'ongoing':
        return 'Đang học';
      case 'upcoming':
        return 'Sắp mở';
      case 'completed':
      case 'closed':
        return 'Đã xong';
      default:
        return status;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

