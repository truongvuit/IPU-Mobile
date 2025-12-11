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
import '../../widgets/admin_search_bar.dart';

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
    final bloc = context.read<AdminCourseBloc>();
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
        title: const Text('Xác nhận ngưng hoạt động'),
        content: Text(
          'Bạn có chắc muốn ngưng hoạt động khóa học "${course.name}"?\n\n'
          'Lưu ý: Khóa học sẽ bị ẩn khỏi danh sách công khai nhưng dữ liệu vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text(
              'Ngưng hoạt động',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      bloc.add(DeleteCourseEvent(course.id));
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
              Padding(
                padding: EdgeInsets.all(AppSizes.p16),
                child: AdminSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm kiếm khóa học...',
                  onChanged: (value) => setState(() {}),
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p8,
                ),
                color: isDark ? AppColors.neutral800 : Colors.white,
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
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
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
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          width: 1,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : Colors.white,
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
          onTap: () async {
            debugPrint('🔵 Course tapped: ${course.id} - ${course.name}');
            final bloc = context.read<AdminCourseBloc>();
            final result = await Navigator.pushNamed(
              context,
              AppRouter.adminCourseDetailById,
              arguments: course.id,
            );
            debugPrint('🔵 Returned from course detail: $result');

            if (!mounted) return;
            if (result == true) {
              bloc.add(const LoadCourses());
            }
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    child: course.imageUrl != null
                        ? Image.network(
                            course.imageUrl!,
                            width: 72.w,
                            height: 72.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                SizedBox(width: AppSizes.p16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: course.isActive
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.neutral200,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  course.isActive ? 'Hoạt động' : 'Tạm dừng',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: course.isActive
                                        ? AppColors.success
                                        : AppColors.neutral500,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                SizedBox(
                                  height: 20.h,
                                  width: 32.w,
                                  child: Transform.scale(
                                    scale: 0.6,
                                    child: Switch(
                                      value: course.isActive,
                                      activeColor: AppColors.success,
                                      onChanged: course.canDelete
                                          ? (value) {
                                              context.read<AdminCourseBloc>().add(
                                                ToggleCourseStatusEvent(
                                                  course.id,
                                                ),
                                              );
                                            }
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      
                      Row(
                        children: [
                          _buildStatChip(
                            Icons.people_outline,
                            '${course.totalStudents} HV',
                            isDark,
                          ),
                          SizedBox(width: 8.w),
                          _buildStatChip(
                            Icons.class_outlined,
                            '${course.activeClasses}/${course.totalClasses} lớp',
                            isDark,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      
                      Text(
                        currencyFormat.format(course.tuitionFee),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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

  Widget _buildStatChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Icon(
        Icons.school,
        size: 32.sp,
        color: isDark ? AppColors.neutral500 : AppColors.neutral400,
      ),
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
