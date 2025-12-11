import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/grade.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class ClassGradesScreen extends StatefulWidget {
  final String classId;
  final String? className;

  const ClassGradesScreen({super.key, required this.classId, this.className});

  @override
  State<ClassGradesScreen> createState() => _ClassGradesScreenState();
}

class _ClassGradesScreenState extends State<ClassGradesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadGradesByClass(widget.classId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.className ?? 'Điểm số lớp học')),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const EmptyStateWidget(
              icon: Icons.hourglass_empty,
              message: 'Đang tải điểm số...',
            );
          }

          if (state is StudentError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              message: 'Không thể tải điểm số: ${state.message}',
              buttonText: 'Thử lại',
              onButtonPressed: () {
                context.read<StudentBloc>().add(
                  LoadGradesByClass(widget.classId),
                );
              },
            );
          }

          if (state is ClassGradesLoaded) {
            final grade = state.grade;
            if (grade == null) {
              return const EmptyStateWidget(
                icon: Icons.assignment_outlined,
                message:
                    'Chưa có điểm số. Điểm số của bạn trong lớp học này chưa được cập nhật.',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.p16),
              child: _buildGradeCard(grade, isDark, theme),
            );
          }

          return const EmptyStateWidget(
            icon: Icons.assignment_outlined,
            message: 'Chưa có điểm số',
          );
        },
      ),
    );
  }

  Widget _buildGradeCard(Grade grade, bool isDark, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.school,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.className ?? 'Lớp học',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      grade.courseName ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSizes.p24),

          Text(
            'Chi tiết điểm',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.p12),

          if (grade.attendanceScore != null)
            _buildGradeRow(
              'Điểm chuyên cần',
              grade.attendanceScore!.toStringAsFixed(1),
              null,
              isDark,
              theme,
            ),

          if (grade.midtermScore != null)
            _buildGradeRow(
              'Điểm giữa kỳ',
              grade.midtermScore!.toStringAsFixed(1),
              null,
              isDark,
              theme,
            ),

          if (grade.finalScore != null)
            _buildGradeRow(
              'Điểm cuối kỳ',
              grade.finalScore!.toStringAsFixed(1),
              null,
              isDark,
              theme,
            ),

          const Divider(height: 24),

          Container(
            padding: EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: _getGradeColor(grade.totalScore).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điểm tổng kết',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  grade.totalScore?.toStringAsFixed(1) ?? '-',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(grade.totalScore),
                  ),
                ),
              ],
            ),
          ),

          if (grade.status != null && grade.status != 'Chưa hoàn thành') ...[
            SizedBox(height: AppSizes.p12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  grade.status == 'Đạt'
                      ? Icons.check_circle
                      : Icons.warning_outlined,
                  color: grade.status == 'Đạt'
                      ? AppColors.success
                      : AppColors.warning,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  grade.status!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: grade.status == 'Đạt'
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGradeRow(
    String label,
    String score,
    double? weight,
    bool isDark,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                if (weight != null) ...[
                  SizedBox(width: 4.w),
                  Text(
                    '(${(weight * 100).toInt()}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            score,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _getGradeColor(double.tryParse(score)),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(double? grade) {
    if (grade == null) return AppColors.textSecondary;
    if (grade >= 8.5) return AppColors.success;
    if (grade >= 7.0) return AppColors.info;
    if (grade >= 5.0) return AppColors.warning;
    return AppColors.error;
  }
}
