import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/entities/attendance_arguments.dart';


class TeacherScheduleDetailModal extends StatelessWidget {
  final TeacherSchedule schedule;

  const TeacherScheduleDetailModal({
    super.key,
    required this.schedule,
  });

  static void show(BuildContext context, TeacherSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeacherScheduleDetailModal(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final startTime = DateFormat('HH:mm').format(schedule.startTime);
    final endTime = DateFormat('HH:mm').format(schedule.endTime);
    final date = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(schedule.startTime);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusLarge),
          topRight: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Container(
            margin: EdgeInsets.only(top: AppSizes.p12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral600 : AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.neutral700 : AppColors.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primary,
                        size: isDesktop ? 28.sp : 24.sp,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        startTime,
                        style: TextStyle(
                          fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        endTime,
                        style: TextStyle(
                          fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.p16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.className,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isDesktop ? AppSizes.text2Xl : AppSizes.textXl,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        date,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                        ),
                      ),
                    ],
                  ),
                ),
                
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    children: [
                      _buildStatCard(
                        context,
                        Icons.location_on_outlined,
                        schedule.room,
                        'Phòng học',
                        isDark,
                        isDesktop,
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.p24),

                  
                  _buildSectionTitle('Thông tin chi tiết', isDark, isDesktop),
                  SizedBox(height: AppSizes.p12),

                  _buildDetailRow(
                    context,
                    Icons.school,
                    'Lớp học',
                    schedule.className,
                    isDark,
                    isDesktop,
                  ),
                  SizedBox(height: AppSizes.p12),

                  _buildDetailRow(
                    context,
                    Icons.schedule,
                    'Thời gian',
                    '$startTime - $endTime (${_getDuration(schedule.startTime, schedule.endTime)})',
                    isDark,
                    isDesktop,
                  ),
                  SizedBox(height: AppSizes.p12),

                  _buildDetailRow(
                    context,
                    Icons.calendar_today,
                    'Ngày học',
                    date,
                    isDark,
                    isDesktop,
                  ),
                  SizedBox(height: AppSizes.p12),

                  _buildDetailRow(
                    context,
                    Icons.room,
                    'Phòng học',
                    schedule.room,
                    isDark,
                    isDesktop,
                  ),

                  if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                    SizedBox(height: AppSizes.p24),
                    _buildSectionTitle('Ghi chú', isDark, isDesktop),
                    SizedBox(height: AppSizes.p12),
                    Container(
                      padding: EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neutral900.withValues(alpha: 0.5)
                            : AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        schedule.note!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSizes.p24),

                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.of(context, rootNavigator: true).pushNamed(
                              AppRouter.teacherClassDetail,
                              arguments: schedule.classId,
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Xem lớp học'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? AppSizes.p16 : AppSizes.p12,
                            ),
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.p12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: schedule.isCompleted
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  Navigator.of(context, rootNavigator: true).pushNamed(
                                    AppRouter.teacherAttendance,
                                    arguments: AttendanceArguments.fromSchedule(
                                      sessionId: schedule.id,
                                      classId: schedule.classId,
                                      className: schedule.className,
                                      sessionDate: schedule.startTime,
                                      room: schedule.room,
                                    ),
                                  );
                                },
                          icon: Icon(schedule.isCompleted ? Icons.lock_outline : Icons.checklist),
                          label: Text(schedule.isCompleted ? 'Đã kết thúc' : 'Điểm danh'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? AppSizes.p16 : AppSizes.p12,
                            ),
                            backgroundColor: schedule.isCompleted ? AppColors.neutral400 : AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.neutral300,
                            disabledForegroundColor: AppColors.neutral500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  
                  SizedBox(height: MediaQuery.of(context).padding.bottom + AppSizes.p16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    bool isDark,
    bool isDesktop,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(isDesktop ? AppSizes.p16 : AppSizes.p12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.neutral900.withValues(alpha: 0.5)
              : AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isDark ? AppColors.neutral700 : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: isDesktop ? AppSizes.iconMedium : AppSizes.iconSmall + 4,
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? AppSizes.textXl : AppSizes.textLg,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, bool isDesktop) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDark,
    bool isDesktop,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            size: isDesktop ? AppSizes.iconSmall + 2 : AppSizes.iconSmall,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: AppSizes.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '$hours giờ $minutes phút';
    } else if (hours > 0) {
      return '$hours giờ';
    } else {
      return '$minutes phút';
    }
  }
}
