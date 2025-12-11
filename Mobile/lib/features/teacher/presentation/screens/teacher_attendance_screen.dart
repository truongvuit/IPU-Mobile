import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_arguments.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';

enum SortType { name, code }

class TeacherAttendanceScreen extends StatefulWidget {
  final AttendanceArguments args;

  const TeacherAttendanceScreen({super.key, required this.args});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  SortType _sortType = SortType.name;
  final Map<String, bool> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendance();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _loadAttendance() {
    if (!widget.args.hasSessionId) return;
    context.read<TeacherBloc>().add(
      LoadAttendance(
        sessionId: widget.args.sessionId,
        classId: widget.args.classId,
      ),
    );
  }

  void _toggleAttendance(String studentId) {
    setState(() {
      final current = _attendanceMap[studentId] ?? false;
      _attendanceMap[studentId] = !current;
    });
  }

  void _submitAttendance() {
    final entries = _attendanceMap.entries.map((e) {
      return {
        'studentId': int.tryParse(e.key) ?? 0,
        'absent': !e.value, 
        'note': _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      };
    }).toList();

    context.read<TeacherBloc>().add(
      BatchRecordAttendance(sessionId: widget.args.sessionId, entries: entries),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return BlocConsumer<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is AttendanceSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã lưu điểm danh thành công'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else if (state is TeacherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark
              ? AppColors.neutral900
              : AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: isDark
                ? AppColors.neutral900
                : AppColors.backgroundLight,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm học viên...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.args.className ?? 'Lớp học',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(widget.args.sessionDate ?? DateTime.now())} - ${widget.args.room ?? 'Chưa cập nhật'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (!_isSearching)
                PopupMenuButton<SortType>(
                  icon: Icon(
                    Icons.sort,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (SortType result) {
                    setState(() {
                      _sortType = result;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortType>>[
                        const PopupMenuItem<SortType>(
                          value: SortType.name,
                          child: Text('Sắp xếp theo tên'),
                        ),
                        const PopupMenuItem<SortType>(
                          value: SortType.code,
                          child: Text('Sắp xếp theo mã số'),
                        ),
                      ],
                ),
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchQuery = '';
                    }
                  });
                },
              ),
            ],
          ),
          body: _buildBody(context, state, isDark, theme, isDesktop),
          bottomNavigationBar: _buildBottomActionArea(
            context,
            isDark,
            theme,
            isDesktop,
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    TeacherState state,
    bool isDark,
    ThemeData theme,
    bool isDesktop,
  ) {
    if (state is TeacherLoading) {
      return _buildLoadingState();
    }

    if (state is AttendanceLoaded) {
      
      if (_attendanceMap.isEmpty) {
        for (var record in state.session.records) {
          
          _attendanceMap[record.studentId] = record.status == 'present';
        }
      }

      return _buildAttendanceContent(
        context,
        state.session.records,
        isDark,
        theme,
        isDesktop,
      );
    }

    if (state is AttendanceRecorded) {
      if (_attendanceMap.isEmpty) {
        for (var record in state.session.records) {
          _attendanceMap[record.studentId] = record.status == 'present';
        }
      }
      return _buildAttendanceContent(
        context,
        state.session.records,
        isDark,
        theme,
        isDesktop,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAttendanceContent(
    BuildContext context,
    List<AttendanceRecord> records,
    bool isDark,
    ThemeData theme,
    bool isDesktop,
  ) {
    final filteredRecords = records.where((record) {
      final name = (record.studentName ?? '').toLowerCase();
      final code = (record.studentCode ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    filteredRecords.sort((a, b) {
      if (_sortType == SortType.name) {
        return (a.studentName ?? '').compareTo(b.studentName ?? '');
      } else {
        return (a.studentCode ?? '').compareTo(b.studentCode ?? '');
      }
    });

    return Column(
      children: [
        _buildQuickStats(context, records, isDark, theme, isDesktop),
        Expanded(
          child: filteredRecords.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.people_outline,
                  message: 'Không có học viên nào',
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? AppSizes.p32 : AppSizes.p16,
                    vertical: AppSizes.p8,
                  ),
                  itemCount: filteredRecords.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: AppSizes.p12),
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildStudentListItem(
                      context,
                      record,
                      isDark,
                      theme,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    List<AttendanceRecord> records,
    bool isDark,
    ThemeData theme,
    bool isDesktop,
  ) {
    final presentCount = _attendanceMap.values.where((v) => v).length;
    final absentCount = records.length - presentCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSizes.p32 : AppSizes.p16,
        vertical: AppSizes.p8,
      ),
      color: isDark ? AppColors.neutral800 : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildCompactStatItem(
              'Có mặt',
              presentCount.toString(),
              AppColors.success,
              isDark,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildCompactStatItem(
              'Vắng mặt',
              absentCount.toString(),
              AppColors.error,
              isDark,
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: _buildCompactStatItem(
              'Tổng số',
              records.length.toString(),
              AppColors.primary,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.p8,
        horizontal: AppSizes.p12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.textLg,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.textXs,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(
    BuildContext context,
    AttendanceRecord record,
    bool isDark,
    ThemeData theme,
  ) {
    final isPresent = _attendanceMap[record.studentId] ?? false;
    final studentName = record.studentName ?? 'Học viên';
    final studentCode = record.studentCode ?? '';

    return InkWell(
      onTap: () => _toggleAttendance(record.studentId),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isPresent
                ? AppColors.success.withValues(alpha: 0.5)
                : (isDark ? AppColors.neutral700 : AppColors.neutral200),
            width: isPresent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CustomImage(
                imageUrl: record.studentAvatar ?? '',
                width: 40.r,
                height: 40.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (studentCode.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      studentCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: isPresent
                    ? AppColors.success
                    : (isDark ? AppColors.neutral700 : AppColors.neutral100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPresent ? Icons.check : Icons.circle_outlined,
                color: isPresent
                    ? Colors.white
                    : (isDark ? AppColors.neutral500 : AppColors.neutral400),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionArea(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? AppSizes.p24 : AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSessionNote(isDark, theme),
            SizedBox(height: AppSizes.p16),
            _buildSubmitButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionNote(bool isDark, ThemeData theme) {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      minLines: 1,
      decoration: InputDecoration(
        hintText: 'Ghi chú buổi học...',
        prefixIcon: const Icon(Icons.note_alt_outlined),
        filled: true,
        fillColor: isDark ? AppColors.neutral900 : AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitAttendance,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lưu điểm danh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }
}
