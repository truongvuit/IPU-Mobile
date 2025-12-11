import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../widgets/class_student_list_item.dart';
import '../../domain/entities/class_student.dart';
import '../../../../core/routing/app_router.dart';

class AdminClassStudentListScreen extends StatefulWidget {
  final String classId;

  const AdminClassStudentListScreen({super.key, required this.classId});

  @override
  State<AdminClassStudentListScreen> createState() =>
      _AdminClassStudentListScreenState();
}

class _AdminClassStudentListScreenState
    extends State<AdminClassStudentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    context.read<AdminBloc>().add(LoadClassStudentList(widget.classId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ClassStudent> _filterStudents(List<ClassStudent> students) {
    if (_searchQuery.isEmpty) return students;
    final query = _searchQuery.toLowerCase();
    return students.where((s) {
      return s.fullName.toLowerCase().contains(query) ||
          s.displayCode.toLowerCase().contains(query) ||
          s.phoneNumber.contains(query);
    }).toList();
  }

  void _showStudentQuickInfo(BuildContext context, ClassStudent student) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.neutral600 : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        student.avatarUrl != null &&
                            student.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: student.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildInitialsAvatar(student),
                            errorWidget: (context, url, error) =>
                                _buildInitialsAvatar(student),
                          )
                        : _buildInitialsAvatar(student),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Mã HV: ${student.displayCode}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            _buildInfoRow(
              context,
              Icons.phone_outlined,
              'Số điện thoại',
              student.phoneNumber.isNotEmpty ? student.phoneNumber : 'Chưa có',
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Chuyên cần',
                    student.attendanceText,
                    _getAttendanceColor(student.attendanceRate),
                    Icons.check_circle_outline,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Số buổi',
                    '${student.attendedSessions}/${student.totalSessions}',
                    AppColors.primary,
                    Icons.calendar_today,
                  ),
                ),
                if (student.averageScore != null) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Điểm TB',
                      student.averageScore!.toStringAsFixed(1),
                      AppColors.warning,
                      Icons.star_border,
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(
                        color: isDark ? AppColors.neutral600 : AppColors.neutral300,
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        AppRouter.adminStudentDetail,
                        arguments: student.studentId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.person_search_outlined, size: 18.sp),
                    label: const Text('Xem hồ sơ'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(ClassStudent student) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Text(
        student.initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return AppColors.success;
    if (rate >= 75) return AppColors.info;
    if (rate >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          String className = 'Hiệu suất lớp học';
          int studentCount = 0;
          List<ClassStudent> students = [];

          if (state is ClassStudentListLoaded) {
            className = state.className;
            students = state.students;
            studentCount = students.length;
          } else if (state is AdminLoading) {
            
          } else if (state is AdminError) {
            
          } else if (state is AdminInitial) {
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<AdminBloc>().add(LoadClassStudentList(widget.classId));
              }
            });
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    'Hiệu suất lớp học',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  expandedHeight: 180.h,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          className,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Text(
                                          'Đang diễn ra',
                                          style: TextStyle(
                                            color: AppColors.success,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),

                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14.sp,
                                        color: isDark
                                            ? AppColors.neutral400
                                            : AppColors.neutral500,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '2-4-6',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark
                                              ? AppColors.neutral400
                                              : AppColors.neutral500,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14.sp,
                                        color: isDark
                                            ? AppColors.neutral400
                                            : AppColors.neutral500,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Phòng A101',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark
                                              ? AppColors.neutral400
                                              : AppColors.neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(48.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? AppColors.neutral700
                                : AppColors.neutral200,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark
                            ? AppColors.neutral400
                            : AppColors.neutral500,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 2,
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: const [
                          Tab(text: 'Tổng quan'),
                          Tab(text: 'Học viên'),
                          Tab(text: 'Phân tích'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, students),

                _buildStudentsTab(context, state, students, studentCount),

                _buildAnalyticsTab(context, students),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, List<ClassStudent> students) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goodAttendance = students.where((s) => s.attendanceRate >= 80).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  context,
                  'Tổng học viên',
                  students.length.toString(),
                  Icons.people_outline,
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildOverviewCard(
                  context,
                  'Chuyên cần tốt',
                  goodAttendance.toString(),
                  Icons.check_circle_outline,
                  AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            'Chuyên cần trung bình',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          if (students.isNotEmpty) ...[
            _buildAttendanceBar(context, students),
          ] else
            Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(
                  color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.neutral400 : AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBar(
    BuildContext context,
    List<ClassStudent> students,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avgAttendance = students.isNotEmpty
        ? students.map((s) => s.attendanceRate).reduce((a, b) => a + b) /
              students.length
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trung bình lớp',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral600,
                ),
              ),
              Text(
                '${avgAttendance.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _getAttendanceColor(avgAttendance),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: avgAttendance / 100,
              backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation(
                _getAttendanceColor(avgAttendance),
              ),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(
    BuildContext context,
    AdminState state,
    List<ClassStudent> students,
    int studentCount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is AdminLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 48.sp, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text('Đang tải danh sách...', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      );
    }

    if (state is AdminError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
              SizedBox(height: 16.h),
              Text(state.message, textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => context.read<AdminBloc>().add(
                  LoadClassStudentList(widget.classId),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredStudents = _filterStudents(students);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<AdminBloc>().add(LoadClassStudentList(widget.classId));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách học viên ($studentCount)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.neutral800 : AppColors.neutral100,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm học viên',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? AppColors.neutral500
                                      : AppColors.neutral400,
                                  size: 20.sp,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (filteredStudents.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.people_outline,
                  message: _searchQuery.isNotEmpty
                      ? 'Không tìm thấy học viên'
                      : 'Chưa có học viên nào trong lớp',
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final student = filteredStudents[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      border: index == 0
                          ? Border.all(
                              color: isDark
                                  ? AppColors.neutral700
                                  : AppColors.neutral200,
                            )
                          : Border(
                              left: BorderSide(
                                color: isDark
                                    ? AppColors.neutral700
                                    : AppColors.neutral200,
                              ),
                              right: BorderSide(
                                color: isDark
                                    ? AppColors.neutral700
                                    : AppColors.neutral200,
                              ),
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.neutral700
                                    : AppColors.neutral200,
                              ),
                            ),
                      borderRadius: index == 0
                          ? BorderRadius.vertical(top: Radius.circular(12.r))
                          : index == filteredStudents.length - 1
                          ? BorderRadius.vertical(bottom: Radius.circular(12.r))
                          : null,
                    ),
                    child: ClassStudentListItem(
                      student: student,
                      onTap: () => _showStudentQuickInfo(context, student),
                    ),
                  );
                }, childCount: filteredStudents.length),
              ),
            ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, List<ClassStudent> students) {
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (students.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.analytics_outlined,
          message: 'Chưa có dữ liệu để phân tích',
        ),
      );
    }

    
    final excellentCount = students.where((s) => s.attendanceRate >= 90).length;
    final goodCount = students
        .where((s) => s.attendanceRate >= 75 && s.attendanceRate < 90)
        .length;
    final averageCount = students
        .where((s) => s.attendanceRate >= 50 && s.attendanceRate < 75)
        .length;
    final poorCount = students.where((s) => s.attendanceRate < 50).length;

    final avgAttendance =
        students.map((s) => s.attendanceRate).reduce((a, b) => a + b) /
        students.length;

    
    final studentsWithScores = students
        .where((s) => s.averageScore != null)
        .toList();
    final hasScoreData = studentsWithScores.isNotEmpty;

    double avgScore = 0;
    if (hasScoreData) {
      avgScore =
          studentsWithScores
              .map((s) => s.averageScore!)
              .reduce((a, b) => a + b) /
          studentsWithScores.length;
    }

    
    final studentsNeedingAttention =
        students.where((s) => s.attendanceRate < 70).toList()
          ..sort((a, b) => a.attendanceRate.compareTo(b.attendanceRate));

    
    final topPerformers = hasScoreData
        ? (List<ClassStudent>.from(studentsWithScores)..sort(
                (a, b) => (b.averageScore ?? 0).compareTo(a.averageScore ?? 0),
              ))
              .take(5)
              .toList()
        : (List<ClassStudent>.from(students)
                ..sort((a, b) => b.attendanceRate.compareTo(a.attendanceRate)))
              .take(5)
              .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsSummaryCard(
                  context,
                  'Chuyên cần TB',
                  '${avgAttendance.toStringAsFixed(1)}%',
                  Icons.calendar_today_outlined,
                  _getAttendanceColor(avgAttendance),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildAnalyticsSummaryCard(
                  context,
                  hasScoreData ? 'Điểm TB' : 'Tổng học viên',
                  hasScoreData
                      ? avgScore.toStringAsFixed(1)
                      : students.length.toString(),
                  hasScoreData ? Icons.star_outline : Icons.people_outline,
                  hasScoreData ? AppColors.warning : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          
          _buildSectionHeader(
            context,
            'Phân bố chuyên cần',
            Icons.pie_chart_outline,
          ),
          SizedBox(height: 12.h),
          _buildAttendanceDistribution(
            context,
            excellentCount,
            goodCount,
            averageCount,
            poorCount,
            students.length,
          ),
          SizedBox(height: 24.h),

          
          _buildSectionHeader(context, 'Biểu đồ chuyên cần', Icons.bar_chart),
          SizedBox(height: 12.h),
          _buildAttendanceChartBars(
            context,
            excellentCount,
            goodCount,
            averageCount,
            poorCount,
            students.length,
          ),
          SizedBox(height: 24.h),

          
          if (studentsNeedingAttention.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              'Cần lưu ý (${studentsNeedingAttention.length})',
              Icons.warning_amber_outlined,
              color: AppColors.warning,
            ),
            SizedBox(height: 12.h),
            _buildStudentsList(
              context,
              studentsNeedingAttention.take(5).toList(),
              showWarning: true,
            ),
            SizedBox(height: 24.h),
          ],

          
          _buildSectionHeader(
            context,
            hasScoreData ? 'Điểm cao nhất' : 'Chuyên cần tốt nhất',
            Icons.emoji_events_outlined,
            color: AppColors.warning,
          ),
          SizedBox(height: 12.h),
          _buildTopPerformersList(context, topPerformers, hasScoreData),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: color ?? (isDark ? AppColors.neutral400 : AppColors.neutral600),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceDistribution(
    BuildContext context,
    int excellent,
    int good,
    int average,
    int poor,
    int total,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        children: [
          _buildDistributionRow(
            context,
            'Xuất sắc (≥90%)',
            excellent,
            total,
            AppColors.success,
          ),
          SizedBox(height: 12.h),
          _buildDistributionRow(
            context,
            'Khá (75-89%)',
            good,
            total,
            AppColors.info,
          ),
          SizedBox(height: 12.h),
          _buildDistributionRow(
            context,
            'Trung bình (50-74%)',
            average,
            total,
            AppColors.warning,
          ),
          SizedBox(height: 12.h),
          _buildDistributionRow(
            context,
            'Yếu (<50%)',
            poor,
            total,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                  ),
                ),
              ],
            ),
            Text(
              '$count (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: isDark ? AppColors.neutral700 : AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceChartBars(
    BuildContext context,
    int excellent,
    int good,
    int average,
    int poor,
    int total,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxCount = [
      excellent,
      good,
      average,
      poor,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildChartBar(
            context,
            'Xuất sắc',
            excellent,
            maxCount,
            AppColors.success,
          ),
          _buildChartBar(context, 'Khá', good, maxCount, AppColors.info),
          _buildChartBar(context, 'TB', average, maxCount, AppColors.warning),
          _buildChartBar(context, 'Yếu', poor, maxCount, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    BuildContext context,
    String label,
    int count,
    int maxCount,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barHeight = maxCount > 0 ? (count / maxCount * 100.h) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 40.w,
          height: barHeight.clamp(10.h, 100.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentsList(
    BuildContext context,
    List<ClassStudent> students, {
    bool showWarning = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: showWarning
              ? AppColors.warning.withValues(alpha: 0.3)
              : (isDark ? AppColors.neutral700 : AppColors.neutral200),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
              child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: student.avatarUrl!,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Text(
                          student.initials,
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      student.initials,
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
            ),
            title: Text(
              student.fullName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              student.displayCode,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getAttendanceColor(
                  student.attendanceRate,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                student.attendanceText,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: _getAttendanceColor(student.attendanceRate),
                ),
              ),
            ),
            onTap: () => _showStudentQuickInfo(context, student),
          );
        },
      ),
    );
  }

  Widget _buildTopPerformersList(
    BuildContext context,
    List<ClassStudent> students,
    bool showScore,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
        itemBuilder: (context, index) {
          final student = students[index];
          final rank = index + 1;

          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: _getRankColor(rank).withValues(alpha: 0.1),
                  child:
                      student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: student.avatarUrl!,
                            width: 40.w,
                            height: 40.w,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Text(
                              student.initials,
                              style: TextStyle(
                                color: _getRankColor(rank),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          student.initials,
                          style: TextStyle(
                            color: _getRankColor(rank),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                ),
                if (rank <= 3)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: _getRankColor(rank),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        rank.toString(),
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              student.fullName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              student.displayCode,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: showScore
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showScore ? Icons.star : Icons.check_circle,
                    size: 14.sp,
                    color: showScore ? AppColors.warning : AppColors.success,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    showScore
                        ? student.averageScore!.toStringAsFixed(1)
                        : student.attendanceText,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: showScore ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => _showStudentQuickInfo(context, student),
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); 
      case 2:
        return const Color(0xFFC0C0C0); 
      case 3:
        return const Color(0xFFCD7F32); 
      default:
        return AppColors.primary;
    }
  }
}
