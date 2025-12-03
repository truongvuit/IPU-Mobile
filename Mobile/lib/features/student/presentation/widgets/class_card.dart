import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/student_class.dart';

class ClassCard extends StatelessWidget {
  final StudentClass studentClass;
  final VoidCallback? onTap;
  final bool showAction;
  final bool compact;

  const ClassCard({
    super.key,
    required this.studentClass,
    this.onTap,
    this.showAction = true,
    this.compact = false,
  });

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    
    final useCompact = compact || isMobile;

    if (useCompact) {
      return _buildCompactCard(context, isDark);
    }
    return _buildFullCard(context, isDark);
  }

  Widget _buildCompactCard(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(minWidth: 280.w),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(12.r),
              ),
              child: SizedBox(
                width: 100.w,
                height: 90.h,
                child: Image.network(
                  studentClass.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                      child: Icon(
                        Icons.class_,
                        size: 32.sp,
                        color: const Color(0xFF135BEC),
                      ),
                    );
                  },
                ),
              ),
            ),

            
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    Text(
                      studentClass.courseName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Lexend',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12.sp,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatTime(studentClass.startTime),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontFamily: 'Lexend',
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          studentClass.isOnline
                              ? Icons.videocam
                              : Icons.location_on,
                          size: 12.sp,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            studentClass.isOnline
                                ? 'Online'
                                : studentClass.room,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
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
                          Icons.person_outline,
                          size: 12.sp,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            studentClass.teacherName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
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
            ),

            
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, bool isDark) {
    return Container(
      constraints: BoxConstraints(minWidth: 280.w),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                studentClass.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.class_,
                      size: 48.sp,
                      color: const Color(0xFF135BEC),
                    ),
                  );
                },
              ),
            ),
          ),

          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text(
                  studentClass.courseName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'Lexend',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                
                Text(
                  '${_formatTime(studentClass.startTime)} - ${studentClass.room} - ${studentClass.teacherName}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontFamily: 'Lexend',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (showAction) ...[
                  SizedBox(height: 16.h),

                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: studentClass.isOnline
                            ? const Color(0xFF135BEC).withValues(alpha: 0.2)
                            : const Color(0xFF135BEC),
                        foregroundColor: const Color(0xFF135BEC),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: studentClass.isOnline
                              ? const Color(0xFF135BEC)
                              : Colors.white,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
