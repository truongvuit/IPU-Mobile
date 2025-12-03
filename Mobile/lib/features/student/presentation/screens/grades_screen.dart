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

  bool _matchesGradeFilter(double averageScore) {
    switch (_selectedGradeFilter) {
      case 'excellent':
        return averageScore >= 90;
      case 'good':
        return averageScore >= 80 && averageScore < 90;
      case 'average':
        return averageScore >= 65 && averageScore < 80;
      case 'poor':
        return averageScore < 65;
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
                  
                  // Group grades by course
                  final Map<String, List<Grade>> groupedGrades = {};
                  for (var grade in grades) {
                    if (!groupedGrades.containsKey(grade.courseName)) {
                      groupedGrades[grade.courseName] = [];
                    }
                    groupedGrades[grade.courseName]!.add(grade);
                  }

                  // Filter by search query and grade filter
                  final filteredCourses = groupedGrades.keys.where((courseName) {
                    // Search filter
                    if (!courseName.toLowerCase().contains(_searchQuery)) {
                      return false;
                    }

                    // Grade filter
                    if (_selectedGradeFilter != 'all') {
                      final courseGrades = groupedGrades[courseName]!;
                      double totalScore = 0;
                      int scoreCount = 0;
                      for (var grade in courseGrades) {
                        totalScore += grade.percentage;
                        scoreCount++;
                      }
                      final averageScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;
                      return _matchesGradeFilter(averageScore);
                    }

                    return true;
                  }).toList();

                  if (filteredCourses.isEmpty) {
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
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final courseName = filteredCourses[index];
                        final courseGrades = groupedGrades[courseName]!;
                        return _buildCourseGradeCard(context, courseName, courseGrades, isDark);
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

  Widget _buildCourseGradeCard(BuildContext context, String courseName, List<Grade> grades, bool isDark) {
    // Extract scores
    double? midtermScore;
    double? finalScore;
    double totalScore = 0;
    int scoreCount = 0;

    for (var grade in grades) {
      final type = grade.examType.toLowerCase();
      if (type.contains('midterm') || type.contains('giữa')) {
        midtermScore = grade.percentage;
      } else if (type.contains('final') || type.contains('cuối')) {
        finalScore = grade.percentage;
      }
      
      totalScore += grade.percentage;
      scoreCount++;
    }

    final averageScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;
    final status = _getGradeStatus(averageScore);
    final statusColor = _getStatusColor(averageScore);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    courseName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Lexend',
                    ),
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
                  child: _buildScoreColumn('Giữa kỳ', midtermScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn('Cuối kỳ', finalScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn('Trung bình', averageScore, isDark, isAverage: true),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Đánh giá: ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
          
          // Progress Bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: averageScore / 100,
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
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Giỏi';
    if (score >= 65) return 'Khá';
    if (score >= 50) return 'Trung bình';
    return 'Yếu';
  }

  Color _getStatusColor(double score) {
    if (score >= 90) return const Color(0xFF10B981); // Success/Green
    if (score >= 80) return const Color(0xFF3B82F6); // Blue
    if (score >= 65) return const Color(0xFFF59E0B); // Warning/Orange
    return const Color(0xFFEF4444); // Error/Red
  }
}
