import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';

import '../bloc/admin_bloc.dart';
import '../../domain/entities/class_session.dart';


class AdminClassSessionsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final List<dynamic> sessions;

  const AdminClassSessionsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.sessions,
  });

  @override
  State<AdminClassSessionsScreen> createState() =>
      _AdminClassSessionsScreenState();
}

class _AdminClassSessionsScreenState extends State<AdminClassSessionsScreen> {
  late List<ClassSession> _sessions;
  String _filter = 'all'; 

  @override
  void initState() {
    super.initState();
    _sessions = widget.sessions.cast<ClassSession>();
  }

  List<ClassSession> get _filteredSessions {
    switch (_filter) {
      case 'completed':
        return _sessions
            .where((s) => s.status == SessionStatus.completed)
            .toList();
      case 'notCompleted':
        return _sessions
            .where((s) => s.status == SessionStatus.notCompleted)
            .toList();
      case 'canceled':
        return _sessions
            .where((s) => s.status == SessionStatus.canceled)
            .toList();
      default:
        return _sessions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: Text('Buổi học - ${widget.className}')),
      body: Column(
        children: [
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả (${_sessions.length})',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                SizedBox(width: AppSizes.p8),
                _FilterChip(
                  label:
                      'Hoàn thành (${_sessions.where((s) => s.status == SessionStatus.completed).length})',
                  isSelected: _filter == 'completed',
                  color: AppColors.success,
                  onTap: () => setState(() => _filter = 'completed'),
                ),
                SizedBox(width: AppSizes.p8),
                _FilterChip(
                  label:
                      'Chưa học (${_sessions.where((s) => s.status == SessionStatus.notCompleted).length})',
                  isSelected: _filter == 'notCompleted',
                  color: AppColors.warning,
                  onTap: () => setState(() => _filter = 'notCompleted'),
                ),
                SizedBox(width: AppSizes.p8),
                _FilterChip(
                  label:
                      'Đã hủy (${_sessions.where((s) => s.status == SessionStatus.canceled).length})',
                  isSelected: _filter == 'canceled',
                  color: AppColors.error,
                  onTap: () => setState(() => _filter = 'canceled'),
                ),
              ],
            ),
          ),

          
          Expanded(
            child: _filteredSessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64.sp,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                        SizedBox(height: AppSizes.paddingMedium),
                        Text(
                          'Không có buổi học nào',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                    ),
                    itemCount: _filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = _filteredSessions[index];
                      final originalIndex = _sessions.indexOf(session);

                      return _SessionCard(
                        session: session,
                        sessionNumber: originalIndex + 1,
                        isDark: isDark,
                        onTap: () =>
                            _navigateToDetail(session, originalIndex + 1),
                        onStatusChange: () => _showStatusChangeDialog(session),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ClassSession session, int sessionNumber) {
    Navigator.pushNamed(
      context,
      AppRouter.adminSessionDetail,
      arguments: {
        'sessionId': session.id,
        'sessionNumber': sessionNumber,
        'session': session,
        'classId': widget.classId,
      },
    );
  }

  void _showStatusChangeDialog(ClassSession session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');

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
              'Cập nhật trạng thái',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              'Ngày: ${dateFormat.format(session.date)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),

            _StatusOption(
              icon: Icons.check_circle,
              label: 'Đã hoàn thành',
              color: AppColors.success,
              isSelected: session.status == SessionStatus.completed,
              onTap: () => _updateStatus(session, SessionStatus.completed),
            ),
            SizedBox(height: AppSizes.p8),
            _StatusOption(
              icon: Icons.pending,
              label: 'Chưa hoàn thành',
              color: AppColors.warning,
              isSelected: session.status == SessionStatus.notCompleted,
              onTap: () => _updateStatus(session, SessionStatus.notCompleted),
            ),
            SizedBox(height: AppSizes.p8),
            _StatusOption(
              icon: Icons.cancel,
              label: 'Đã hủy',
              color: AppColors.error,
              isSelected: session.status == SessionStatus.canceled,
              onTap: () => _updateStatus(session, SessionStatus.canceled),
            ),
            SizedBox(height: AppSizes.paddingMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
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
      final updatedSession = await bloc.adminRepository.updateSession(
        sessionId: session.id,
        status: newStatus == SessionStatus.completed
            ? 'Completed'
            : newStatus == SessionStatus.canceled
            ? 'Canceled'
            : 'NotCompleted',
      );

      if (mounted) {
        Navigator.pop(context);

        
        final index = _sessions.indexWhere((s) => s.id == session.id);
        if (index != -1) {
          setState(() {
            _sessions[index] = updatedSession;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật trạng thái'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return Material(
      color: isSelected ? chipColor : chipColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.p16,
            vertical: AppSizes.p8,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ClassSession session;
  final int sessionNumber;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const _SessionCard({
    required this.session,
    required this.sessionNumber,
    required this.isDark,
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

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    '$sessionNumber',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(session.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dayFormat.format(session.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                    if (session.note != null && session.note!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          session.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
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
                    horizontal: AppSizes.p12,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        session.statusText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: AppSizes.p8),
              Icon(
                Icons.chevron_right,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
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
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
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
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : null,
                  ),
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
