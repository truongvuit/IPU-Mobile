import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:trungtamngoaingu/features/teacher/domain/entities/attendance.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../domain/entities/attendance_arguments.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final AttendanceArguments args;

  const TeacherAttendanceScreen({super.key, required this.args});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Map<String, String> _localAttendance = {};
  bool _hasChanges = false;
  AttendanceSession? _currentSession;

  
  bool get isSessionCompleted {
    
    if (widget.args.viewOnly) return true;
    
    final sessionDate = widget.args.sessionDate;
    if (sessionDate == null) return false;
    
    return DateTime.now().isAfter(sessionDate.add(const Duration(hours: 3)));
  }

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
    });
  }

  void _loadAttendance() {
    
    if (!widget.args.hasSessionId) {
      return;
    }
    context.read<TeacherBloc>().add(
      LoadAttendance(
        sessionId: widget.args.sessionId,
        classId: widget.args.classId,
      ),
    );
  }

  void _initLocalState(AttendanceSession session) {
    if (_currentSession?.id != session.id) {
      _localAttendance = {};
      for (final record in session.records) {
        _localAttendance[record.studentId] = record.status;
      }
      _currentSession = session;
      _hasChanges = false;
    }
  }

  void _toggleAttendance(String studentId) {
    
    if (isSessionCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể điểm danh. Buổi học đã kết thúc.',
            style: TextStyle(fontFamily: 'Lexend'),
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      final currentStatus = _localAttendance[studentId] ?? 'absent';
      _localAttendance[studentId] = currentStatus == 'present'
          ? 'absent'
          : 'present';
      _hasChanges = true;
    });
  }

  String _getStatus(String studentId) {
    return _localAttendance[studentId] ?? 'absent';
  }

  void _submitAttendance() {
    if (!_hasChanges) return;

    final entries = _localAttendance.entries
        .map(
          (e) => {
            'studentId': int.tryParse(e.key) ?? 0,
            'absent': e.value == 'absent',
            'note': null,
          },
        )
        .toList();

    context.read<TeacherBloc>().add(
      BatchRecordAttendance(sessionId: widget.args.sessionId, entries: entries),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    
    
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    if (!widget.args.hasSessionId) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Điểm danh'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildNoSessionState(theme, isDark),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isDark),

            _buildSessionInfo(theme, isDark),

            Expanded(
              child: BlocConsumer<TeacherBloc, TeacherState>(
                listener: (context, state) {
                  if (state is AttendanceSubmitted) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  if (state is TeacherLoading) {
                    return _buildLoadingState();
                  }

                  if (state is TeacherError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is AttendanceLoaded ||
                      state is AttendanceRecorded) {
                    final session = state is AttendanceLoaded
                        ? state.session
                        : (state as AttendanceRecorded).session;

                    _initLocalState(session);

                    return _buildAttendanceContent(session, isDark, theme);
                  }

                  
                  return _buildLoadingState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSessionState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 48.sp,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Chưa chọn buổi học',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Vui lòng chọn buổi học từ lịch dạy để điểm danh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final className = widget.args.className ?? 'Lớp học';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Điểm danh',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (isSessionCompleted) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Chỉ xem',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  className,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(ThemeData theme, bool isDark) {
    final sessionDate = widget.args.sessionDate;
    final room = widget.args.room;

    String dateStr = 'Hôm nay';
    String timeStr = '';

    if (sessionDate != null) {
      final isToday =
          sessionDate.year == DateTime.now().year &&
          sessionDate.month == DateTime.now().month &&
          sessionDate.day == DateTime.now().day;

      dateStr = isToday
          ? 'Hôm nay'
          : DateFormat('EEEE, dd/MM/yyyy', 'vi').format(sessionDate);
      timeStr = DateFormat('HH:mm').format(sessionDate);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      color: isDark ? AppColors.gray800 : Colors.white,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (timeStr.isNotEmpty)
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          if (room != null && room.isNotEmpty)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.room_outlined,
                      color: isDark ? AppColors.gray300 : AppColors.gray600,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        room,
                        style: TextStyle(
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(
    dynamic session,
    bool isDark,
    ThemeData theme,
  ) {
    final filteredRecords = _searchQuery.isEmpty
        ? session.records
        : session.records.where((record) {
            final studentName = (record.studentName ?? '').toLowerCase();
            final studentCode = (record.studentCode ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();

            return studentName.contains(query) || studentCode.contains(query);
          }).toList();

    return Column(
      children: [
        _buildQuickStats(session, theme, isDark),

        if (session.records.length > 8)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm học viên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.gray700 : AppColors.slate100,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16.w,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

        Expanded(
          child: filteredRecords.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.people_outline,
                  message: 'Không có học viên nào',
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildStudentCheckboxItem(
                      context,
                      record,
                      isDark,
                      theme,
                    );
                  },
                ),
        ),

        _buildSubmitButton(session, isDark),
      ],
    );
  }

  Widget _buildQuickStats(dynamic session, ThemeData theme, bool isDark) {
    final totalStudents = session.records.length;

    final presentCount = _localAttendance.values
        .where((s) => s == 'present')
        .length;
    final absentCount = totalStudents - presentCount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.people,
              label: 'Tổng số',
              value: totalStudents.toString(),
              color: AppColors.primary,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 8.w),

          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle,
              label: 'Có mặt',
              value: presentCount.toString(),
              color: AppColors.success,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 8.w),

          Expanded(
            child: _buildStatItem(
              icon: Icons.cancel,
              label: 'Vắng',
              value: absentCount.toString(),
              color: AppColors.error,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCheckboxItem(
    BuildContext context,
    dynamic record,
    bool isDark,
    ThemeData theme,
  ) {
    
    final isPresent = _getStatus(record.studentId) == 'present';
    final studentName =
        record.studentName ??
        'Học viên ${record.studentId.substring(record.studentId.length > 7 ? 7 : 0)}';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CustomImage(
              imageUrl: record.studentAvatar ?? '',
              width: 32.r,
              height: 32.r,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: Text(
              studentName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          
          InkWell(
            onTap: () => _toggleAttendance(record.studentId),
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isPresent ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isPresent
                      ? AppColors.success
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                  width: 2,
                ),
              ),
              child: isPresent
                  ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(dynamic session, bool isDark) {
    final isCompleted = isSessionCompleted;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isCompleted || !_hasChanges)
                ? null
                : _submitAttendance,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.gray400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              isCompleted
                  ? 'Buổi học đã kết thúc'
                  : (_hasChanges ? 'Lưu điểm danh' : 'Chưa có thay đổi'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SkeletonWidget.rectangular(height: 100.h),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) =>
                  SkeletonWidget.rectangular(height: 60.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNotImplemented = message.toLowerCase().contains('not implemented');

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: (isNotImplemented ? AppColors.warning : AppColors.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNotImplemented ? Icons.construction : Icons.error_outline,
                size: 48.sp,
                color: isNotImplemented ? AppColors.warning : AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isNotImplemented
                  ? 'Chức năng đang phát triển'
                  : 'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isNotImplemented
                  ? 'Chức năng điểm danh sẽ được cập nhật trong phiên bản tiếp theo.'
                  : message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? AppColors.gray400 : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                if (!isNotImplemented) ...[
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: _loadAttendance,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
