import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_widget.dart';
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
                  color: isDark ? AppColors.gray600 : AppColors.gray300,
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
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
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
                        color: isDark ? AppColors.gray600 : AppColors.gray300,
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
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
          color: isDark ? AppColors.gray400 : AppColors.gray500,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? AppColors.gray400 : AppColors.gray500,
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
              color: isDark ? AppColors.gray400 : AppColors.gray600,
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
                                            ? AppColors.gray400
                                            : AppColors.gray500,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '2-4-6',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray500,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14.sp,
                                        color: isDark
                                            ? AppColors.gray400
                                            : AppColors.gray500,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Phòng A101',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark
                                              ? AppColors.gray400
                                              : AppColors.gray500,
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
                                ? AppColors.gray700
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: isDark
                            ? AppColors.gray400
                            : AppColors.gray500,
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

                
                _buildAnalyticsTab(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, List<ClassStudent> students) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goodAttendance =
        students.where((s) => s.attendanceRate >= 80).length;

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
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
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
          color: isDark ? AppColors.gray700 : AppColors.gray200,
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
              color: isDark ? AppColors.gray400 : AppColors.gray500,
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
          color: isDark ? AppColors.gray700 : AppColors.gray200,
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
                  color: isDark ? AppColors.gray300 : AppColors.gray600,
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
              backgroundColor: isDark ? AppColors.gray700 : AppColors.gray200,
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
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SkeletonWidget.rectangular(height: 70.h),
            );
          },
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
                      color: isDark ? AppColors.gray800 : AppColors.gray100,
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
                          color: isDark ? AppColors.gray500 : AppColors.gray400,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? AppColors.gray500 : AppColors.gray400,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? AppColors.gray500
                                      : AppColors.gray400,
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
                                  ? AppColors.gray700
                                  : AppColors.gray200,
                            )
                          : Border(
                              left: BorderSide(
                                color: isDark
                                    ? AppColors.gray700
                                    : AppColors.gray200,
                              ),
                              right: BorderSide(
                                color: isDark
                                    ? AppColors.gray700
                                    : AppColors.gray200,
                              ),
                              bottom: BorderSide(
                                color: isDark
                                    ? AppColors.gray700
                                    : AppColors.gray200,
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

  Widget _buildAnalyticsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64.sp,
            color: isDark ? AppColors.gray500 : AppColors.gray400,
          ),
          SizedBox(height: 16.h),
          Text(
            'Phân tích đang phát triển',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Chức năng này sẽ sớm được cập nhật',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.gray500 : AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
