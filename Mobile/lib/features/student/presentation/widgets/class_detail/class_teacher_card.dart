import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';

class ClassTeacherCard extends StatelessWidget {
  final bool isDark;
  final String teacherName;
  final String? teacherEmail;
  final String? teacherSpecialization;
  final String? teacherCertificates;

  const ClassTeacherCard({
    super.key,
    required this.isDark,
    required this.teacherName,
    this.teacherEmail,
    this.teacherSpecialization,
    this.teacherCertificates,
  });

  @override
  Widget build(BuildContext context) {
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
            'Giảng viên',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 32.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                backgroundImage: const AssetImage(
                  'assets/images/avatar-default.png',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    if (teacherEmail != null && teacherEmail!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              teacherEmail!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                                fontFamily: 'Lexend',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (teacherSpecialization != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Chuyên ngành: $teacherSpecialization',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                    if (teacherCertificates != null) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14.sp,
                            color: AppColors.success,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              teacherCertificates!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.success,
                                fontFamily: 'Lexend',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
