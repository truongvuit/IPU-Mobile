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
import '../../../../core/widgets/empty_state_widget.dart';

class GradesScreen extends StatefulWidget {
  final String? initialFilter;
  final bool isTab;
  final VoidCallback? onMenuPressed;

  const GradesScreen({
    super.key,
    this.initialFilter,
    this.isTab = false,
    this.onMenuPressed,
  });

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'all';
  bool _hasLoadedGrades = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<Grade>? _cachedGrades;

  @override
  void initState() {
    super.initState();

    if (widget.initialFilter != null && widget.initialFilter!.isNotEmpty) {
      _searchController.text = widget.initialFilter!;
      _searchQuery = widget.initialFilter!.toLowerCase();
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGradesIfNeeded();
    });
  }

  void _loadGradesIfNeeded() {
    if (!mounted) return;

    final bloc = context.read<StudentBloc>();
    final state = bloc.state;

    
    if (state is GradesLoaded) {
      _cachedGrades = state.grades;
      _hasLoadedGrades = true;
      _isLoading = false;
      return;
    }
    if (state is CourseGradesLoaded) {
      _cachedGrades = state.grades;
      _hasLoadedGrades = true;
      _isLoading = false;
      return;
    }

    
    if (!_hasLoadedGrades) {
      _isLoading = true;
      bloc.add(const LoadGradesByCourse(''));
    }
  }

  void _updateCachedGrades(StudentState state) {
    if (state is GradesLoaded) {
      setState(() {
        _cachedGrades = state.grades;
        _hasLoadedGrades = true;
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (state is CourseGradesLoaded) {
      setState(() {
        _cachedGrades = state.grades;
        _hasLoadedGrades = true;
        _isLoading = false;
        _errorMessage = null;
      });
    } else if (state is StudentLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else if (state is StudentError) {
      setState(() {
        _isLoading = false;
        _errorMessage = state.message;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesGradeFilter(double score) {
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
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          StudentAppBar(
            title: 'Điểm số',
            showBackButton: !widget.isTab,
            showMenuButton: widget.isTab,
            onMenuPressed: widget.onMenuPressed,
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),

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
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    fontFamily: 'Lexend',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                    size: 20.sp,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                            size: 20.sp,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                ),
              ),
            ),
          ),

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
            child: BlocListener<StudentBloc, StudentState>(
              listenWhen: (previous, current) {
                if (current is StudentLoading &&
                    current.action != 'LoadGradesByCourse' &&
                    current.action != 'LoadMyGrades') {
                  return false;
                }
                return current is StudentLoading ||
                    current is GradesLoaded ||
                    current is CourseGradesLoaded ||
                    current is StudentError;
              },
              listener: (context, state) {
                _updateCachedGrades(state);
              },
              child: _buildGradesContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesContent(bool isDark) {
    if (_errorMessage != null && _cachedGrades == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.error,
                fontFamily: 'Lexend',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                context.read<StudentBloc>().add(const LoadGradesByCourse(''));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _cachedGrades == null) {
      return const EmptyStateWidget(
        icon: Icons.hourglass_empty,
        message: 'Đang tải điểm số...',
      );
    }

    if (_cachedGrades != null) {
      final grades = _cachedGrades!;

      final filteredGrades = grades.where((grade) {
        final searchText = '${grade.courseName ?? ''} ${grade.className ?? ''}'
            .toLowerCase();
        if (!searchText.contains(_searchQuery)) {
          return false;
        }

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
            100.h,
          ),
          itemCount: filteredGrades.length,
          itemBuilder: (context, index) {
            final grade = filteredGrades[index];
            return _buildGradeCard(context, grade, isDark);
          },
        ),
      );
    }

    return const EmptyStateWidget(
      icon: Icons.school_outlined,
      message: 'Chưa có điểm số nào',
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
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          title: Row(
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
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      grade.totalScore != null
                          ? grade.totalScore!.toStringAsFixed(1)
                          : '--',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildScoreColumn(
                    'Chuyên cần',
                    grade.attendanceScore,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildScoreColumn(
                    'Giữa kỳ',
                    grade.midtermScore,
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildScoreColumn('Cuối kỳ', grade.finalScore, isDark),
                ),
                Expanded(
                  child: _buildScoreColumn(
                    'Điểm chữ',
                    null, 
                    isDark,
                    customValue: letterGrade, 
                    isAverage: true,
                  ),
                ),
              ],
            ),
            if (grade.comment != null && grade.comment!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16.sp,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        grade.comment!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? const Color(0xFFD1D5DB)
                              : const Color(0xFF4B5563),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (grade.gradedByName != null || grade.lastGradedAt != null) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (grade.gradedByName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14.sp,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      grade.gradedByName!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  if (grade.lastGradedAt != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatDate(grade.lastGradedAt!),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildScoreColumn(
    String title,
    double? score,
    bool isDark, {
    bool isAverage = false,
    String? customValue,
  }) {
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
          customValue ?? (score != null ? score.toStringAsFixed(1) : '--'),
          style: TextStyle(
            fontSize: 16.sp,
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
    if (score >= 9) return 'Xuất sắc';
    if (score >= 8) return 'Giỏi';
    if (score >= 6.5) return 'Khá';
    if (score >= 5) return 'Trung bình';
    return 'Yếu';
  }

  Color _getStatusColor(double score) {
    if (score >= 9) return const Color(0xFF10B981);
    if (score >= 8) return const Color(0xFF3B82F6);
    if (score >= 6.5) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
