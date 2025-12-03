import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../../domain/entities/grade.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class GradesScreen extends StatefulWidget {
  final String? initialFilter; // Optional className filter

  const GradesScreen({super.key, this.initialFilter});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'all'; // all, excellent, good, average, poor

  @override
  void initState() {
    super.initState();
    
    // Set initial filter if provided
    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      _searchController.text = widget.initialFilter!;
      _searchQuery = widget.initialFilter!.toLowerCase();
    }
    
    context.read<StudentBloc>().add(const LoadGradesByCourse(''));
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesGradeFilter(double score) {
    // Thang điểm 10
    switch (_selectedGradeFilter) {
      case 'excellent':
        return score >= 9;
      case 'good':
        return score >= 8 && score < 9;
      case 'average':
        return score >= 6.5 && score < 8;
      case 'poor':
        return score < 6.5;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          StudentAppBar(
            title: 'Điểm số',
            showBackButton: true,
            onBackPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.studentDashboard,
                (route) => false,
              );
            },
          ),
          
          // Search Bar
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lexend',
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm môn học...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    size: 20.sp,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            size: 20.sp,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('Xuất sắc', 'excellent', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('Giỏi', 'good', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('Khá', 'average', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('Yếu', 'poor', isDark),
              ],
            ),
          ),

          SizedBox(height: AppSizes.paddingSmall),

          Expanded(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                if (state is StudentLoading) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
                    itemCount: 3,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.paddingMedium),
                      child: SkeletonWidget.rectangular(height: 180.h),
                    ),
                  );
                }

                if (state is StudentError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.error,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  );
                }

                if (state is CourseGradesLoaded || state is GradesLoaded) {
                  final grades = state is CourseGradesLoaded ? state.grades : (state as GradesLoaded).grades;
                  
                  // Filter by search query and grade filter
                  final filteredGrades = grades.where((grade) {
                    // Search filter by courseName or className
                    final searchText = '${grade.courseName ?? ''} ${grade.className ?? ''}'.toLowerCase();
                    if (!searchText.contains(_searchQuery)) {
                      return false;
                    }

                    // Grade filter by totalScore
                    if (_selectedGradeFilter != 'all') {
                      final score = grade.totalScore ?? 0;
                      return _matchesGradeFilter(score);
                    }

                    return true;
                  }).toList();

                  if (filteredGrades.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.search_off,
                      message: _searchQuery.isNotEmpty 
                          ? 'Không tìm thấy môn học nào'
                          : 'Chưa có điểm số nào',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<StudentBloc>().add(const LoadGradesByCourse(''));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.paddingMedium, 
                        0, 
                        AppSizes.paddingMedium, 
                        100.h
                      ),
                      itemCount: filteredGrades.length,
                      itemBuilder: (context, index) {
                        final grade = filteredGrades[index];
                        return _buildGradeCard(context, grade, isDark);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedGradeFilter == value;
    
    Color chipColor;
    switch (value) {
      case 'excellent':
        chipColor = const Color(0xFF10B981);
        break;
      case 'good':
        chipColor = const Color(0xFF3B82F6);
        break;
      case 'average':
        chipColor = const Color(0xFFF59E0B);
        break;
      case 'poor':
        chipColor = const Color(0xFFEF4444);
        break;
      default:
        chipColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedGradeFilter = value;
        });
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, Grade grade, bool isDark) {
    final totalScore = grade.totalScore ?? 0;
    final status = grade.status ?? _getGradeStatus(totalScore);
    final statusColor = _getStatusColor(totalScore);
    final letterGrade = grade.grade ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with course name and status
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade.courseName ?? 'Chưa xác định',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      if (grade.className != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          grade.className!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (letterGrade.isNotEmpty) ...[
                        Text(
                          letterGrade,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            fontFamily: 'Lexend',
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Scores Row
          Container(
            color: isDark ? const Color(0xFF374151) : Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildScoreColumn('Chuyên cần', grade.attendanceScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn('Giữa kỳ', grade.midtermScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn('Cuối kỳ', grade.finalScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn('Tổng', totalScore, isDark, isAverage: true),
                ),
              ],
            ),
          ),

          // Comment if available
          if (grade.comment != null && grade.comment!.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 16.sp,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      grade.comment!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Graded by info
          if (grade.gradedByName != null || grade.lastGradedAt != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Row(
                children: [
                  if (grade.gradedByName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14.sp,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      grade.gradedByName!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  if (grade.lastGradedAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(grade.lastGradedAt!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Progress Bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: (totalScore / 10).clamp(0.0, 1.0),
                backgroundColor: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildScoreColumn(String title, double? score, bool isDark, {bool isAverage = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            fontFamily: 'Lexend',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          score != null ? score.toStringAsFixed(1) : '--',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isAverage 
                ? const Color(0xFF2563EB) 
                : (isDark ? Colors.white : AppColors.textPrimary),
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  String _getGradeStatus(double score) {
    // Thang điểm 10
    if (score >= 9) return 'Xuất sắc';
    if (score >= 8) return 'Giỏi';
    if (score >= 6.5) return 'Khá';
    if (score >= 5) return 'Trung bình';
    return 'Yếu';
  }

  Color _getStatusColor(double score) {
    // Thang điểm 10
    if (score >= 9) return const Color(0xFF10B981); // Success/Green
    if (score >= 8) return const Color(0xFF3B82F6); // Blue
    if (score >= 6.5) return const Color(0xFFF59E0B); // Warning/Orange
    return const Color(0xFFEF4444); // Error/Red
  }
}
