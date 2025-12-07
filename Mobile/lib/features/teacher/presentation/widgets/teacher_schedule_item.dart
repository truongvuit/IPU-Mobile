import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/teacher_schedule.dart';

class TeacherScheduleItem extends StatelessWidget {
  final TeacherSchedule schedule;
  final VoidCallback? onTap;

  const TeacherScheduleItem({
    super.key,
    required this.schedule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final textTheme = Theme.of(context).textTheme;
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? AppSizes.p12 + 2 : AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? AppSizes.radiusMedium + 2 : AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isDesktop ? AppSizes.radiusMedium + 2 : AppSizes.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? AppSizes.p16 + 2 : AppSizes.p16),
            child: Row(
              children: [
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? AppSizes.p12 + 2 : AppSizes.p12,
                    vertical: isDesktop ? AppSizes.p12 : AppSizes.p12 - 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall + 2),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: isDesktop ? AppSizes.iconSmall + 6 : AppSizes.iconSmall + 4,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: AppSizes.p8 - 2),
                      Text(
                        timeFormat.format(schedule.startTime),
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase + 1,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: AppSizes.p4),
                        width: AppSizes.p24,
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.primary.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        timeFormat.format(schedule.endTime),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isDesktop ? AppSizes.p16 + 2 : AppSizes.p16),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        schedule.className,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase + 1,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.p8),

                      
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSizes.p8 - 2),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall - 2),
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: isDesktop ? AppSizes.iconSmall : AppSizes.iconSmall - 2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: AppSizes.p8),
                          Expanded(
                            child: Text(
                              schedule.room,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.black.withValues(alpha: 0.7),
                                fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      
                      if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                        SizedBox(height: AppSizes.p8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.p12 - 2,
                            vertical: AppSizes.p8 - 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall - 2),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: isDesktop ? AppSizes.textBase : AppSizes.textSm,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: AppSizes.p8 - 2),
                              Expanded(
                                child: Text(
                                  schedule.note!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.warning,
                                    fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: isDesktop ? AppSizes.p12 : AppSizes.p8),

                
                Icon(
                  Icons.arrow_forward_ios,
                  size: isDesktop ? AppSizes.iconSmall + 2 : AppSizes.iconSmall,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

