import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../domain/entities/admin_teacher.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_teacher_form_screen.dart';


class AdminTeacherDetailScreen extends StatefulWidget {
  final AdminTeacher teacher;

  const AdminTeacherDetailScreen({super.key, required this.teacher});

  @override
  State<AdminTeacherDetailScreen> createState() =>
      _AdminTeacherDetailScreenState();
}

class _AdminTeacherDetailScreenState extends State<AdminTeacherDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTeacherDetail();
  }
  
  void _loadTeacherDetail() {
    context.read<AdminBloc>().add(LoadTeacherDetail(widget.teacher.id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          AdminTeacher teacher = widget.teacher;
          if (state is TeacherDetailLoaded) {
            teacher = state.teacher;
          }

          return CustomScrollView(
            slivers: [
              
              SliverAppBar(
                expandedHeight: 180.h,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.h),
                          ClipOval(
                            child: CustomImage(
                              imageUrl: teacher.avatarUrl ?? '',
                              width: 70.r,
                              height: 70.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                            ),
                            child: Text(
                              teacher.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: AppSizes.textLg,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminTeacherFormScreen(teacher: teacher),
                        ),
                      ).then((_) => _loadTeacherDetail());
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa giảng viên'),
                      ),
                    ],
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.p12,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: teacher.status == 'active'
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          teacher.statusText,
                          style: TextStyle(
                            color: teacher.status == 'active'
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: AppSizes.textSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSizes.p20),

                      
                      if (teacher.experience != null) ...[
                        Text(
                          'Kinh nghiệm',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizes.p8),
                        Text(
                          teacher.experience!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: AppSizes.paddingMedium),
                      ],

                      
                      if (teacher.qualifications != null) ...[
                        Text(
                          'Bằng cấp',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizes.p8),
                        Text(
                          teacher.qualifications!,
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: AppSizes.paddingMedium),
                      ],

                      
                      Text(
                        'Môn dạy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizes.p8),
                      Wrap(
                        spacing: AppSizes.p8,
                        runSpacing: AppSizes.p8,
                        children: teacher.subjects.map((subject) {
                          return Chip(
                            label: Text(subject),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: AppSizes.p20),

                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSizes.p12,
                        crossAxisSpacing: AppSizes.p12,
                        childAspectRatio: 2.0,
                        children: [
                          _buildStatCard(
                            context,
                            'Lớp đang dạy',
                            teacher.activeClasses.toString(),
                            Icons.class_,
                            AppColors.primary,
                          ),
                          _buildStatCard(
                            context,
                            'Tổng học viên',
                            teacher.totalStudents.toString(),
                            Icons.people,
                            AppColors.success,
                          ),
                          _buildStatCard(
                            context,
                            'Đánh giá TB',
                            teacher.rating.toStringAsFixed(1),
                            Icons.star,
                            AppColors.warning,
                          ),
                          _buildStatCard(
                            context,
                            'Chuyên cần',
                            '${(teacher.attendanceRate * 100).toInt()}%',
                            Icons.check_circle,
                            AppColors.success,
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      
                      _buildSectionHeader(
                        context,
                        'Lịch dạy hôm nay',
                        teacher.todaySchedule.length > 3
                            ? () => _showAllSchedules(context, teacher.todaySchedule)
                            : () {},
                      ),
                      SizedBox(height: AppSizes.p12),
                      _buildTodaySchedule(
                        context,
                        isDark,
                        teacher.todaySchedule.take(3).toList(),
                        teacher.todaySchedule.length,
                      ),

                      SizedBox(height: 24.h),

                      
                      _buildSectionHeader(
                        context,
                        'Đánh giá gần đây',
                        teacher.recentReviews.length > 3
                            ? () => _showAllReviews(context, teacher.recentReviews)
                            : () {},
                      ),
                      SizedBox(height: AppSizes.p12),
                      _buildRecentReviews(
                        context,
                        isDark,
                        teacher.recentReviews.take(3).toList(),
                      ),
                      
                      
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: AppSizes.p8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.textXs,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onTap, child: const Text('Xem tất cả')),
      ],
    );
  }

  Widget _buildTodaySchedule(
    BuildContext context,
    bool isDark,
    List<TeacherSchedule> schedule,
    int totalCount,
  ) {
    if (schedule.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Center(
          child: Text(
            'Không có lịch dạy hôm nay',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...schedule.map((item) => _buildScheduleCard(item, isDark)),
        if (totalCount > 3)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              '+${totalCount - 3} lịch khác',
              style: TextStyle(
                fontSize: AppSizes.textSm,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  void _showAllSchedules(BuildContext context, List<TeacherSchedule> schedules) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch dạy hôm nay (${schedules.length})',
                    style: TextStyle(
                      fontSize: AppSizes.textLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(schedules[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllReviews(BuildContext context, List<TeacherReview> reviews) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đánh giá (${reviews.length})',
                    style: TextStyle(
                      fontSize: AppSizes.textLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(reviews[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(TeacherSchedule schedule, bool isDark) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM');

    Color subjectColor = AppColors.primary;
    if (schedule.subject == 'TOEIC') {
      subjectColor = AppColors.success;
    } else if (schedule.subject == 'Giao tiếp') {
      subjectColor = AppColors.warning;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border(
          left: BorderSide(color: subjectColor, width: 4.w),
        ),
      ),
      child: Row(
        children: [
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.p8,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Column(
              children: [
                Text(
                  dateFormat.format(schedule.startTime),
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    fontWeight: FontWeight.w600,
                    color: subjectColor,
                  ),
                ),
                Text(
                  '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}',
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    fontWeight: FontWeight.w600,
                    color: subjectColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: AppSizes.p12),

          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.className,
                  style: TextStyle(
                    fontSize: AppSizes.textSm,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  schedule.classRoom ?? 'Phòng chưa xác định',
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviews(
    BuildContext context,
    bool isDark,
    List<TeacherReview> reviews,
  ) {
    if (reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Chưa có đánh giá nào'),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        return _buildReviewCard(review, isDark);
      }).toList(),
    );
  }

  Widget _buildReviewCard(TeacherReview review, bool isDark) {
    final timeAgo = _getTimeAgo(review.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CustomImage(
                  imageUrl: review.studentAvatar ?? '',
                  width: 32.r,
                  height: 32.r,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: AppSizes.p8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: TextStyle(
                        fontSize: AppSizes.textSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: AppSizes.textXs,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    size: AppSizes.textBase,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: AppSizes.p8),
          Text(review.comment, style: TextStyle(fontSize: AppSizes.textSm)),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inMinutes} phút trước';
    }
  }
}
