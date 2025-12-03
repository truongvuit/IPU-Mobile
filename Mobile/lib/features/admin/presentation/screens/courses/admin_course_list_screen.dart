import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/di/injector.dart';
import '../../../domain/entities/course_detail.dart';
import '../../bloc/admin_course_bloc.dart';
import '../../bloc/admin_course_event.dart';
import '../../bloc/admin_course_state.dart';


class AdminCourseListScreen extends StatelessWidget {
  const AdminCourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCourseBloc>()..add(const LoadCourses()),
      child: const _AdminCourseListContent(),
    );
  }
}

class _AdminCourseListContent extends StatefulWidget {
  const _AdminCourseListContent();

  @override
  State<_AdminCourseListContent> createState() =>
      _AdminCourseListContentState();
}

class _AdminCourseListContentState extends State<_AdminCourseListContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _sortBy = 'name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CourseDetail> _filterAndSortCourses(List<CourseDetail> courses) {
    
    var filtered = courses.where((course) {
      
      final matchesSearch =
          _searchController.text.isEmpty ||
          course.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      
      final matchesStatus =
          _selectedStatus == 'all' ||
          (_selectedStatus == 'active' && course.isActive) ||
          (_selectedStatus == 'inactive' && !course.isActive);

      return matchesSearch && matchesStatus;
    }).toList();

    
    switch (_sortBy) {
      case 'tuitionFee':
        filtered.sort((a, b) => b.tuitionFee.compareTo(a.tuitionFee));
        break;
      case 'createdAt':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'students':
        filtered.sort((a, b) => b.totalStudents.compareTo(a.totalStudents));
        break;
      default: 
        filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    return filtered;
  }

  void _deleteCourse(BuildContext context, CourseDetail course) async {
    if (!course.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa khóa học có ${course.activeClasses} lớp đang hoạt động',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa khóa học "${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AdminCourseBloc>().add(DeleteCourseEvent(course.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý khóa học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Lọc và sắp xếp',
          ),
        ],
      ),
      body: BlocConsumer<AdminCourseBloc, AdminCourseState>(
        listener: (context, state) {
          if (state is AdminCourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AdminCourseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            
            context.read<AdminCourseBloc>().add(const LoadCourses());
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              
              Container(
                padding: EdgeInsets.all(AppSizes.p16),
                color: isDark ? AppColors.gray800 : Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm khóa học...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),

              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p8,
                ),
                color: isDark ? AppColors.gray800 : Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Tất cả',
                        _selectedStatus == 'all',
                        () => setState(() => _selectedStatus = 'all'),
                      ),
                      SizedBox(width: AppSizes.p8),
                      _buildFilterChip(
                        'Đang mở',
                        _selectedStatus == 'active',
                        () => setState(() => _selectedStatus = 'active'),
                      ),
                      SizedBox(width: AppSizes.p8),
                      _buildFilterChip(
                        'Đã đóng',
                        _selectedStatus == 'inactive',
                        () => setState(() => _selectedStatus = 'inactive'),
                      ),
                    ],
                  ),
                ),
              ),

              
              Expanded(child: _buildCourseList(context, state, isDark)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseList(
    BuildContext context,
    AdminCourseState state,
    bool isDark,
  ) {
    if (state is AdminCourseLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is AdminCourseLoaded) {
      final filteredCourses = _filterAndSortCourses(state.courses);

      if (filteredCourses.isEmpty) {
        return const EmptyStateWidget(
          message: 'Không tìm thấy khóa học nào',
          icon: Icons.school_outlined,
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<AdminCourseBloc>().add(const LoadCourses());
        },
        child: ListView.builder(
          padding: EdgeInsets.all(AppSizes.p16),
          itemCount: filteredCourses.length,
          itemBuilder: (context, index) {
            final course = filteredCourses[index];
            return _buildCourseCard(context, course, isDark);
          },
        ),
      );
    }

    if (state is AdminCourseError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(state.message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<AdminCourseBloc>().add(const LoadCourses());
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    CourseDetail course,
    bool isDark,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Dismissible(
        key: Key(course.id),
        direction: course.canDelete
            ? DismissDirection.endToStart
            : DismissDirection.none,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: AppSizes.p20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          _deleteCourse(context, course);
          return false;
        },
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.adminCourseDetail,
              arguments: course,
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  child: course.imageUrl != null
                      ? Image.network(
                          course.imageUrl!,
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                SizedBox(width: AppSizes.p12),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(course.isActive)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                            child: Text(
                              course.statusText,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(course.isActive),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      
                      Row(
                        children: [
                          if (course.level != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course.level!,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          if (course.categoryName != null)
                            Expanded(
                              child: Text(
                                course.categoryName!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${course.totalStudents} HV',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.class_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${course.activeClasses}/${course.totalClasses} lớp',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            currencyFormat.format(course.tuitionFee),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? AppColors.success : AppColors.gray500;
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80.w,
      height: 80.w,
      color: AppColors.gray200,
      child: Icon(Icons.school, size: 40.sp, color: AppColors.gray400),
    );
  }

  void _showFilterBottomSheet() {
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
            _buildSortOption('Tên khóa học', 'name'),
            _buildSortOption('Học phí', 'tuitionFee'),
            _buildSortOption('Ngày tạo', 'createdAt'),
            _buildSortOption('Số học viên', 'students'),
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
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }
}
