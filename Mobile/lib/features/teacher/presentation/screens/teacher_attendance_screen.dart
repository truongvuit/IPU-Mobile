import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_image.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';



class TeacherAttendanceScreen extends StatefulWidget {
  final String classId;
  final String? className;
  final String? teacherName;
  final String? teacherAvatar;

  const TeacherAttendanceScreen({
    super.key,
    required this.classId,
    this.className,
    this.teacherName,
    this.teacherAvatar,
  });

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() {
    context.read<TeacherBloc>().add(
      LoadAttendance(widget.classId, _selectedDate),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadAttendance();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
    _loadAttendance();
  }

  void _selectToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(theme, isDark),

            
            _buildDateNavigator(theme, isDark),

            
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

                    return _buildAttendanceContent(session, isDark, theme);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final teacherName = widget.teacherName ?? 'Giáo viên';
    final teacherInitial = teacherName.isNotEmpty ? teacherName[0] : 'G';

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
                Text(
                  'Điểm danh',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    
                    widget.teacherAvatar != null
                        ? ClipOval(
                            child: CustomImage(
                              imageUrl: widget.teacherAvatar!,
                              width: 20.r,
                              height: 20.r,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            radius: 10.r,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              teacherInitial.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'Người điểm danh: $teacherName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigator(ThemeData theme, bool isDark) {
    final dateFormat = DateFormat('dd/MM');
    final isToday =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      color: isDark ? AppColors.gray800 : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          InkWell(
            onTap: _previousDay,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray700 : AppColors.slate100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.chevron_left, size: 20.sp),
            ),
          ),

          SizedBox(width: 12.w),

          
          InkWell(
            onTap: isToday ? null : _selectToday,
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Hôm nay' : 'Ngày đã chọn',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dateFormat.format(_selectedDate),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12.w),

          
          InkWell(
            onTap: _nextDay,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray700 : AppColors.slate100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.chevron_right, size: 20.sp),
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
        
        _buildClassInfoCard(session, theme, isDark),

        
        if (filteredRecords.length > 8)
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

  Widget _buildClassInfoCard(dynamic session, ThemeData theme, bool isDark) {
    final className = widget.className ?? 'Lớp học';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14.sp,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Giảng viên: ${widget.teacherName ?? "Chưa cập nhật"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${DateFormat('HH:mm').format(_selectedDate)} - ${DateFormat('HH:mm').format(_selectedDate.add(const Duration(hours: 1, minutes: 30)))}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
    final isPresent = record.status == 'present';
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
            onTap: () {
              context.read<TeacherBloc>().add(
                RecordAttendance(
                  widget.classId,
                  record.studentId,
                  isPresent ? 'absent' : 'present',
                ),
              );
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: isPresent ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isPresent
                      ? AppColors.primary
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
            onPressed: session.isCompleted
                ? null
                : () {
                    context.read<TeacherBloc>().add(
                      SubmitAttendance(session.id),
                    );
                  },
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
              session.isCompleted ? 'Đã lưu điểm danh' : 'Xác nhận điểm danh',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(message),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadAttendance,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
