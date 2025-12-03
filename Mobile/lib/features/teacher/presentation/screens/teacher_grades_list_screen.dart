import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/class_grade_summary.dart';
import '../bloc/teacher_grades_bloc.dart';
import '../bloc/teacher_grades_event.dart';
import '../bloc/teacher_grades_state.dart';
import '../widgets/teacher_app_bar.dart';



class TeacherGradesListScreen extends StatefulWidget {
  final String classId;
  final String className;

  const TeacherGradesListScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<TeacherGradesListScreen> createState() =>
      _TeacherGradesListScreenState();
}

class _TeacherGradesListScreenState extends State<TeacherGradesListScreen> {
  String _sortBy = 'name'; 
  bool _sortAscending = true;
  String _filterStatus = 'all'; 

  @override
  void initState() {
    super.initState();
    
    context.read<TeacherGradesBloc>().add(LoadClassGrades(widget.classId));
  }

  List<ClassGradeSummary> _applyFiltersAndSorting(
    List<ClassGradeSummary> grades,
  ) {
    
    var filtered = grades.where((grade) {
      if (_filterStatus == 'completed') return grade.isCompleted;
      if (_filterStatus == 'incomplete') return !grade.isCompleted;
      return true;
    }).toList();

    
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'finalGrade':
          comparison = a.finalGrade.compareTo(b.finalGrade);
          break;
        case 'classification':
          comparison = a.classification.compareTo(b.classification);
          break;
        default: 
          comparison = a.studentName.compareTo(b.studentName);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSizes.p20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sắp xếp theo',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.p16),
            _buildSortOption('Tên học viên', 'name'),
            _buildSortOption('Điểm tổng kết', 'finalGrade'),
            _buildSortOption('Xếp loại', 'classification'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18.sp,
            )
          : null,
      onTap: () {
        setState(() {
          if (_sortBy == value) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = value;
            _sortAscending = true;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocBuilder<TeacherGradesBloc, TeacherGradesState>(
        builder: (context, state) {
          
          final allGrades = state is TeacherGradesLoaded
              ? state.grades
              : <ClassGradeSummary>[];
          final filteredGrades = _applyFiltersAndSorting(allGrades);

          return Column(
            children: [
              TeacherAppBar(
                title: 'Bảng điểm lớp',
                showBackButton: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortOptions,
                    tooltip: 'Sắp xếp',
                  ),
                ],
              ),

              
              if (state is TeacherGradesLoaded) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p12,
                  ),
                  color: isDark ? AppColors.gray800 : Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tất cả', 'all', allGrades.length),
                        SizedBox(width: AppSizes.p8),
                        _buildFilterChip(
                          'Hoàn thành',
                          'completed',
                          allGrades.where((g) => g.isCompleted).length,
                        ),
                        SizedBox(width: AppSizes.p8),
                        _buildFilterChip(
                          'Chưa hoàn thành',
                          'incomplete',
                          allGrades.where((g) => !g.isCompleted).length,
                        ),
                      ],
                    ),
                  ),
                ),

                
                Container(
                  padding: EdgeInsets.all(AppSizes.p16),
                  color: isDark ? AppColors.gray800 : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Tổng số',
                        '${allGrades.length}',
                        Icons.people,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'Điểm TB',
                        allGrades.isEmpty
                            ? '0.0'
                            : (allGrades
                                          .map((g) => g.finalGrade)
                                          .reduce((a, b) => a + b) /
                                      allGrades.length)
                                  .toStringAsFixed(1),
                        Icons.star,
                        AppColors.warning,
                      ),
                      _buildStatItem(
                        'Hoàn thành',
                        allGrades.isEmpty
                            ? '0%'
                            : '${(allGrades.where((g) => g.isCompleted).length / allGrades.length * 100).toStringAsFixed(0)}%',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
              ],

              
              Expanded(child: _buildGradesList(state, filteredGrades)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradesList(
    TeacherGradesState state,
    List<ClassGradeSummary> filteredGrades,
  ) {
    if (state is TeacherGradesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is TeacherGradesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: AppSizes.p16),
            Text(
              state.message,
              style: TextStyle(fontSize: 16.sp, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.p16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TeacherGradesBloc>().add(
                  LoadClassGrades(widget.classId),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state is TeacherGradesLoaded && filteredGrades.isEmpty) {
      return const EmptyStateWidget(
        message: 'Chưa có điểm nào',
        icon: Icons.grade_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TeacherGradesBloc>().add(LoadClassGrades(widget.classId));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(AppSizes.p16),
        itemCount: filteredGrades.length,
        itemBuilder: (context, index) {
          final grade = filteredGrades[index];
          return _buildGradeCard(grade);
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
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
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGradeCard(ClassGradeSummary grade) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _showGradeDetail(grade),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
                  
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      grade.studentName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.p12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.studentName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          grade.studentId,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          grade.classificationColor.replaceFirst('#', '0xFF'),
                        ),
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          grade.classificationIcon,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          grade.classification,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(
                              int.parse(
                                grade.classificationColor.replaceFirst(
                                  '#',
                                  '0xFF',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p16),

              
              Row(
                children: [
                  Expanded(
                    child: _buildScoreItem(
                      'Chuyên cần',
                      grade.attendanceScore,
                      Icons.check_circle_outline,
                    ),
                  ),
                  Expanded(
                    child: _buildScoreItem(
                      'Giữa kỳ',
                      grade.midtermScore,
                      Icons.edit_note,
                    ),
                  ),
                  Expanded(
                    child: _buildScoreItem(
                      'Cuối kỳ',
                      grade.finalScore,
                      Icons.assignment_turned_in,
                    ),
                  ),
                  Expanded(
                    child: _buildScoreItem(
                      'Tổng kết',
                      grade.finalGrade,
                      Icons.star,
                      isHighlight: true,
                    ),
                  ),
                ],
              ),

              
              if (grade.lastGradedDate != null) ...[
                SizedBox(height: AppSizes.p12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Cập nhật: ${DateFormat('dd/MM/yyyy').format(grade.lastGradedDate!)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      grade.isCompleted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                      size: 14.sp,
                      color: grade.isCompleted
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      grade.completionStatus,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: grade.isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(
    String label,
    double? score,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isHighlight ? AppColors.primary : AppColors.textSecondary,
        ),
        SizedBox(height: 4.h),
        Text(
          score?.toStringAsFixed(1) ?? '--',
          style: TextStyle(
            fontSize: isHighlight ? 18.sp : 16.sp,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showGradeDetail(ClassGradeSummary grade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(AppSizes.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p24),

              
              Row(
                children: [
                  CircleAvatar(
                    radius: 32.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      grade.studentName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade.studentName,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          grade.studentId,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          grade.email,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.p24),
              const Divider(),
              SizedBox(height: AppSizes.p16),

              
              Text(
                'Chi tiết điểm số',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.p16),

              _buildDetailScoreRow(
                'Điểm chuyên cần',
                grade.attendanceScore,
                '10%',
              ),
              _buildDetailScoreRow('Điểm giữa kỳ', grade.midtermScore, '30%'),
              _buildDetailScoreRow('Điểm cuối kỳ', grade.finalScore, '60%'),

              Divider(height: AppSizes.p24),

              _buildDetailScoreRow(
                'Điểm tổng kết',
                grade.finalGrade,
                '100%',
                isTotal: true,
              ),

              SizedBox(height: AppSizes.p16),

              
              Container(
                padding: EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(
                      grade.classificationColor.replaceFirst('#', '0xFF'),
                    ),
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  children: [
                    Text(
                      grade.classificationIcon,
                      style: TextStyle(fontSize: 32.sp),
                    ),
                    SizedBox(width: AppSizes.p12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xếp loại',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          grade.classification,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              int.parse(
                                grade.classificationColor.replaceFirst(
                                  '#',
                                  '0xFF',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.p24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailScoreRow(
    String label,
    double? score,
    String weight, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16.sp : 14.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            weight,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(width: AppSizes.p16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isTotal
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              score?.toStringAsFixed(1) ?? '--',
              style: TextStyle(
                fontSize: isTotal ? 18.sp : 16.sp,
                fontWeight: FontWeight.bold,
                color: isTotal ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
