import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';

import '../bloc/admin_bloc.dart';
import '../../domain/entities/class_session.dart';
import '../../data/datasources/admin_api_datasource.dart';


class AdminSessionDetailScreen extends StatefulWidget {
  final int sessionId;
  final int sessionNumber;
  final ClassSession? session;
  final String classId;

  const AdminSessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionNumber,
    this.session,
    required this.classId,
  });

  @override
  State<AdminSessionDetailScreen> createState() =>
      _AdminSessionDetailScreenState();
}

class _AdminSessionDetailScreenState extends State<AdminSessionDetailScreen> {
  bool _isLoading = true;
  String? _error;
  SessionAttendanceInfo? _attendanceInfo;
  ClassSession? _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bloc = context.read<AdminBloc>();
      final info = await bloc.adminRepository.getSessionAttendance(
        widget.sessionId,
      );

      if (mounted) {
        setState(() {
          _attendanceInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
      appBar: AppBar(
        title: Text('Buổi ${widget.sessionNumber}'),
        actions: [
          if (_session != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditNoteDialog(),
              tooltip: 'Sửa ghi chú',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildContent(theme, isDark),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          SkeletonWidget.rectangular(height: 120.h),
          SizedBox(height: AppSizes.paddingMedium),
          SkeletonWidget.rectangular(height: 200.h),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: AppSizes.paddingMedium),
            Text(_error ?? 'Có lỗi xảy ra', textAlign: TextAlign.center),
            SizedBox(height: AppSizes.paddingMedium),
            ElevatedButton(
              onPressed: _loadAttendance,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    final entries = _attendanceInfo?.entries ?? [];
    final presentCount = entries.where((e) => !e.isAbsent).length;
    final absentCount = entries.where((e) => e.isAbsent).length;

    return RefreshIndicator(
      onRefresh: _loadAttendance,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            if (_session != null) _buildSessionInfoCard(theme, isDark),
            SizedBox(height: AppSizes.paddingMedium),

            
            _buildAttendanceStats(
              theme,
              isDark,
              presentCount,
              absentCount,
              entries.length,
            ),
            SizedBox(height: AppSizes.paddingMedium),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách điểm danh',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${entries.length} học viên',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.p12),

            
            if (entries.isEmpty)
              Container(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48.sp,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      SizedBox(height: AppSizes.p12),
                      Text(
                        'Chưa có dữ liệu điểm danh',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Column(
                  children: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final student = entry.value;
                    return _AttendanceItem(
                      student: student,
                      isDark: isDark,
                      isLast: index == entries.length - 1,
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard(ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayFormat = DateFormat('EEEE', 'vi_VN');

    Color statusColor;
    IconData statusIcon;
    switch (_session!.status) {
      case SessionStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case SessionStatus.canceled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case SessionStatus.notCompleted:
        statusColor = _session!.isPast ? AppColors.warning : AppColors.gray500;
        statusIcon = _session!.isPast ? Icons.warning : Icons.pending;
        break;
    }

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    '${widget.sessionNumber}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
                      dateFormat.format(_session!.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dayFormat.format(_session!.date),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p12,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      _session!.statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_session!.note != null && _session!.note!.isNotEmpty) ...[
            SizedBox(height: AppSizes.p12),
            Container(
              padding: EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, color: AppColors.info, size: 18.sp),
                  SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      _session!.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceStats(
    ThemeData theme,
    bool isDark,
    int presentCount,
    int absentCount,
    int totalCount,
  ) {
    final attendanceRate = totalCount > 0
        ? (presentCount / totalCount * 100)
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            label: 'Có mặt',
            value: '$presentCount',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSizes.p8),
        Expanded(
          child: _StatCard(
            icon: Icons.cancel,
            label: 'Vắng',
            value: '$absentCount',
            color: AppColors.error,
            isDark: isDark,
          ),
        ),
        SizedBox(width: AppSizes.p8),
        Expanded(
          child: _StatCard(
            icon: Icons.percent,
            label: 'Tỷ lệ có mặt',
            value: '${attendanceRate.toStringAsFixed(0)}%',
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  void _showEditNoteDialog() {
    final controller = TextEditingController(text: _session?.note ?? '');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        title: const Text('Sửa ghi chú buổi học'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Nhập ghi chú...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateSessionNote(controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSessionNote(String note) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final bloc = context.read<AdminBloc>();
      final updatedSession = await bloc.adminRepository.updateSession(
        sessionId: widget.sessionId,
        status: _session?.statusValue ?? 'NotCompleted',
        note: note,
      );

      if (mounted) {
        Navigator.pop(context); 
        setState(() {
          _session = updatedSession;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật ghi chú'),
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


class _AttendanceItem extends StatelessWidget {
  final StudentAttendanceEntry student;
  final bool isDark;
  final bool isLast;

  const _AttendanceItem({
    required this.student,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.p16),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
            child: Row(
              children: [
                
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    _getInitials(student.studentName),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.p12),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (student.note != null && student.note!.isNotEmpty)
                        Text(
                          student.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p12,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: student.isAbsent
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        student.isAbsent ? Icons.close : Icons.check,
                        color: student.isAbsent
                            ? AppColors.error
                            : AppColors.success,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        student.isAbsent ? 'Vắng' : 'Có mặt',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: student.isAbsent
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
