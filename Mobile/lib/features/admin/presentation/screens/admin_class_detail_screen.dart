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
import '../../domain/entities/class_session.dart';

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
    _loadClassDetail();
  }

  void _loadClassDetail() {
    context.read<AdminBloc>().add(LoadClassDetail(widget.classId));
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildSessionsSection(
    BuildContext context,
    dynamic classInfo,
    bool isDark,
    ThemeData theme,
  ) {
    final sessions = classInfo.sessions as List<ClassSession>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách buổi học',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppSizes.textXl,
              ),
            ),
            Text(
              classInfo.sessionStatsText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
                fontSize: AppSizes.textLg,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.p12),

        
        _buildSessionStats(classInfo, isDark, theme),
        SizedBox(height: AppSizes.p12),

        
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: sessions.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Center(
                    child: Text(
                      'Chưa có buổi học nào',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    ...sessions.take(5).map((session) {
                      final index = sessions.indexOf(session);
                      return _SessionItem(
                        session: session,
                        sessionNumber: index + 1,
                        isDark: isDark,
                        isLast:
                            index ==
                            (sessions.length > 5 ? 4 : sessions.length - 1),
                        onTap: () =>
                            _showSessionDetail(context, session, index + 1),
                        onStatusChange: () =>
                            _showStatusChangeDialog(context, session),
                      );
                    }),
                    if (sessions.length > 5)
                      Padding(
                        padding: EdgeInsets.all(AppSizes.p12),
                        child: TextButton.icon(
                          onPressed: () => _showAllSessions(
                            context,
                            sessions,
                            classInfo.name,
                          ),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text('Xem tất cả ${sessions.length} buổi học'),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSessionStats(dynamic classInfo, bool isDark, ThemeData theme) {
    final completed = classInfo.completedSessionsCount;
    final canceled = classInfo.canceledSessionsCount;
    final remaining = classInfo.remainingSessionsCount;
    final total = classInfo.sessions.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'Hoàn thành',
            value: '$completed',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSizes.p8),
        Expanded(
          child: _StatCard(
            icon: Icons.pending,
            label: 'Chưa học',
            value: '$remaining',
            color: AppColors.warning,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSizes.p8),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel,
            label: 'Đã hủy',
            value: '$canceled',
            color: AppColors.error,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  void _showSessionDetail(
    BuildContext context,
    ClassSession session,
    int sessionNumber,
  ) {
    Navigator.pushNamed(
      context,
      AppRouter.adminSessionDetail,
      arguments: {
        'sessionId': session.id,
        'sessionNumber': sessionNumber,
        'session': session,
        'classId': widget.classId,
      },
    ).then((_) => _loadClassDetail());
  }

  void _showStatusChangeDialog(BuildContext context, ClassSession session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray600 : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Cập nhật trạng thái buổi học',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              'Ngày: ${_formatDate(session.date)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),

            _StatusOption(
              icon: Icons.check_circle,
              label: 'Đã hoàn thành',
              description: 'Buổi học đã diễn ra bình thường',
              color: AppColors.success,
              isSelected: session.status == SessionStatus.completed,
              onTap: () => _updateSessionStatus(
                context,
                session,
                SessionStatus.completed,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            _StatusOption(
              icon: Icons.pending,
              label: 'Chưa hoàn thành',
              description: 'Buổi học chưa diễn ra hoặc đang chờ',
              color: AppColors.warning,
              isSelected: session.status == SessionStatus.notCompleted,
              onTap: () => _updateSessionStatus(
                context,
                session,
                SessionStatus.notCompleted,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            _StatusOption(
              icon: Icons.cancel,
              label: 'Đã hủy',
              description: 'Buổi học bị hủy, cần sắp xếp bù',
              color: AppColors.error,
              isSelected: session.status == SessionStatus.canceled,
              onTap: () => _updateSessionStatus(
                context,
                session,
                SessionStatus.canceled,
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSessionStatus(
    BuildContext context,
    ClassSession session,
    SessionStatus newStatus,
  ) async {
    Navigator.pop(context); 

    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bloc = context.read<AdminBloc>();
      await bloc.adminRepository.updateSession(
        sessionId: session.id,
        status: newStatus == SessionStatus.completed
            ? 'Completed'
            : newStatus == SessionStatus.canceled
            ? 'Canceled'
            : 'NotCompleted',
      );

      if (context.mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái buổi học'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadClassDetail(); 
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showAllSessions(
    BuildContext context,
    List<ClassSession> sessions,
    String className,
  ) {
    Navigator.pushNamed(
      context,
      AppRouter.adminClassSessions,
      arguments: {
        'classId': widget.classId,
        'className': className,
        'sessions': sessions,
      },
    ).then((_) => _loadClassDetail());
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
                                id:
                                    classInfo.courseId ??
                                    'course_${classInfo.courseName.hashCode}',
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
                              ).then((_) => _loadClassDetail());
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
                                ).then((_) => _loadClassDetail());
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
                          ),
                          _InfoRow(
                            icon: Icons.schedule,
                            label: classInfo.sessionStatsText,
                            isDark: isDark,
                            isLast: true,
                            hasArrow: true,
                            onTap: () => _showAllSessions(
                              context,
                              classInfo.sessions,
                              classInfo.name,
                            ),
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
                            ).then((_) => _loadClassDetail());
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
                            ).then((_) => _loadClassDetail());
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
                          }),

                          if (students.length > 3) ...[
                            SizedBox(height: AppSizes.p8),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.adminClassStudents,
                                  arguments: widget.classId,
                                ).then((_) => _loadClassDetail());
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


class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
              fontSize: 11.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class _SessionItem extends StatelessWidget {
  final ClassSession session;
  final int sessionNumber;
  final bool isDark;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const _SessionItem({
    required this.session,
    required this.sessionNumber,
    required this.isDark,
    required this.isLast,
    required this.onTap,
    required this.onStatusChange,
  });

  Color get _statusColor {
    switch (session.status) {
      case SessionStatus.completed:
        return AppColors.success;
      case SessionStatus.canceled:
        return AppColors.error;
      case SessionStatus.notCompleted:
        return session.isPast ? AppColors.warning : AppColors.gray500;
    }
  }

  IconData get _statusIcon {
    switch (session.status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.canceled:
        return Icons.cancel;
      case SessionStatus.notCompleted:
        return session.isPast ? Icons.warning : Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE', 'vi_VN');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                child: Row(
                  children: [
                    
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '$sessionNumber',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.p12),

                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(session.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dayFormat.format(session.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                          if (session.note != null && session.note!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                session.note!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),

                    
                    GestureDetector(
                      onTap: onStatusChange,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.p8,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon, color: _statusColor, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text(
                              session.statusText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: AppSizes.p8),
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


class _StatusOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.1)
          : (isDark ? AppColors.gray800 : AppColors.gray100),
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Container(
          padding: EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : null,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check, color: color, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
