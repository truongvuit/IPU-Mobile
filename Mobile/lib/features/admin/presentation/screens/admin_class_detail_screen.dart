import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../../../../core/routing/app_router.dart';
import '../../domain/entities/admin_teacher.dart';
import '../../domain/entities/course_detail.dart';

import 'admin_edit_class_screen.dart';

class AdminClassDetailScreen extends StatefulWidget {
  final String classId;

  const AdminClassDetailScreen({super.key, required this.classId});

  @override
  State<AdminClassDetailScreen> createState() => _AdminClassDetailScreenState();
}

class _AdminClassDetailScreenState extends State<AdminClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadClassDetail(widget.classId));
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chi tiết lớp học'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng xóa đang phát triển'),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Text('Xóa lớp học')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  SkeletonWidget.rectangular(height: 200.h),
                  SizedBox(height: AppSizes.paddingMedium),
                  SkeletonWidget.rectangular(height: 100.h),
                  SizedBox(height: AppSizes.paddingMedium),
                  SkeletonWidget.rectangular(height: 150.h),
                  SizedBox(height: AppSizes.paddingMedium),
                  SkeletonWidget.rectangular(height: 100.h),
                ],
              ),
            );
          }

          if (state is AdminError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppSizes.iconXLarge,
                      color: AppColors.error,
                    ),
                    SizedBox(height: AppSizes.paddingMedium),
                    Text(state.message, textAlign: TextAlign.center),
                    SizedBox(height: AppSizes.paddingMedium),
                    ElevatedButton(
                      onPressed: () => context.read<AdminBloc>().add(
                        LoadClassDetail(widget.classId),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ClassDetailLoaded) {
            final classInfo = state.classInfo;
            final students = state.students;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<AdminBloc>().add(LoadClassDetail(widget.classId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  classInfo.name,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSizes.text2Xl,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.p8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.p12,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              classInfo.statusText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingMedium),

                    
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.book_outlined,
                            label: classInfo.courseName,
                            isDark: isDark,
                            hasArrow: true,
                            onTap: () {
                              
                              final course = CourseDetail(
                                id: classInfo.courseId ?? 'course_${classInfo.courseName.hashCode}',
                                name: classInfo.courseName,
                                totalHours: 60,
                                tuitionFee: classInfo.tuitionFee,
                                isActive: true,
                                createdAt: DateTime.now(),
                                description: 'Khóa học ${classInfo.courseName}',
                              );
                              Navigator.pushNamed(
                                context,
                                AppRouter.adminCourseDetail,
                                arguments: course,
                              );
                            },
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: classInfo.schedule,
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.access_time,
                            label: classInfo.timeRange,
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.meeting_room_outlined,
                            label: classInfo.room,
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: classInfo.teacherName,
                            isDark: isDark,
                            hasArrow: true,
                            onTap: () {
                              if (classInfo.teacherId != null) {
                                final teacher = AdminTeacher(
                                  id: classInfo.teacherId!,
                                  fullName: classInfo.teacherName,
                                );
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.adminTeacherDetail,
                                  arguments: teacher,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Không tìm thấy thông tin giảng viên',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          _InfoRow(
                            icon: Icons.calendar_month,
                            label:
                                '${_formatDate(classInfo.startDate)} - ${classInfo.endDate != null ? _formatDate(classInfo.endDate!) : ""}',
                            isDark: isDark,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingMedium),

                    
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.p12,
                      crossAxisSpacing: AppSizes.p12,
                      childAspectRatio: 2.5,
                      children: [
                        _ActionButton(
                          label: 'Cập nhật',
                          icon: Icons.edit,
                          color: AppColors.primary,
                          onTap: () {
                            
                            final adminBloc = context.read<AdminBloc>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: adminBloc,
                                  child: AdminEditClassScreen(
                                    classInfo: classInfo,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionButton(
                          label: 'Xem phản hồi',
                          icon: Icons.rate_review_outlined,
                          color: AppColors.warning,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.adminClassFeedback,
                              arguments: widget.classId,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizes.p20),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Danh sách học viên',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.textXl,
                          ),
                        ),
                        Text(
                          classInfo.studentCountText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                            fontSize: AppSizes.textLg,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.p12),

                    
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        children: [
                          
                          ...students.take(3).map((student) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      student.initials,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.p12),
                                  Expanded(
                                    child: Text(
                                      student.fullName,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          if (students.length > 3) ...[
                            SizedBox(height: AppSizes.p8),
                            TextButton.icon(
                              onPressed: () {
                                
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.adminClassStudents,
                                  arguments: widget.classId,
                                );
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Xem tất cả học viên'),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isLast;
  final bool hasArrow;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isLast = false,
    this.hasArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : Radius.circular(AppSizes.radiusMedium),
          bottom: isLast ? Radius.circular(AppSizes.radiusMedium) : Radius.zero,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20.sp,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                    if (hasArrow)
                      Icon(
                        Icons.chevron_right,
                        size: 20.sp,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.gray700 : AppColors.gray200,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.p12,
            vertical: AppSizes.p12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18.sp),
              SizedBox(width: AppSizes.p8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.textSm,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
