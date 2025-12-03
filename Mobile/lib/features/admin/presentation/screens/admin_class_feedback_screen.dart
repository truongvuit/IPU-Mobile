import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../domain/entities/admin_feedback.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminClassFeedbackScreen extends StatefulWidget {
  final String classId;

  const AdminClassFeedbackScreen({super.key, required this.classId});

  @override
  State<AdminClassFeedbackScreen> createState() => _AdminClassFeedbackScreenState();
}

class _AdminClassFeedbackScreenState extends State<AdminClassFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadClassFeedbacks(widget.classId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Phản hồi học viên')),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return _buildLoadingSkeleton();
          }

          if (state is AdminError) {
            return _buildErrorState(state.message);
          }

          if (state is ClassFeedbacksLoaded) {
            final feedbacks = state.feedbacks;
            
            if (feedbacks.isEmpty) {
              return _buildEmptyState(theme, isDark);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(LoadClassFeedbacks(widget.classId));
              },
              child: ListView.separated(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: feedbacks.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: AppSizes.p12),
                itemBuilder: (context, index) {
                  final feedback = feedbacks[index];
                  return _FeedbackCard(feedback: feedback, isDark: isDark);
                },
              ),
            );
          }

          return _buildEmptyState(theme, isDark);
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppSizes.p12),
        child: SkeletonWidget.rectangular(height: 120.h),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: AppSizes.p16),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: AppSizes.p16),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(LoadClassFeedbacks(widget.classId));
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          SizedBox(height: AppSizes.p16),
          Text(
            'Chưa có phản hồi nào',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            'Học viên chưa gửi đánh giá cho lớp học này',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.gray500 : AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final AdminFeedback feedback;
  final bool isDark;

  const _FeedbackCard({required this.feedback, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  feedback.studentName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.studentName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dateFormat.format(feedback.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: AppColors.warning, size: 14.sp),
                    SizedBox(width: 4),
                    Text(
                      feedback.rating.toString(),
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.p12),
          Text(
            feedback.comment,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
