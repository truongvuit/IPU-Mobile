import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/admin_student.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/simple_admin_app_bar.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_filter_button.dart';

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

  @override
  State<AdminStudentListScreen> createState() => _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc học viên',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.p16),
                Text(
                  'Trạng thái đăng ký',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSizes.p8),
                Wrap(
                  spacing: AppSizes.p8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: _selectedFilter == 'all',
                      onSelected: (_) {
                        setModalState(() => _selectedFilter = 'all');
                        setState(() {});
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.neutral800
                          : AppColors.neutral100,
                      labelStyle: TextStyle(
                        color: _selectedFilter == 'all'
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.neutral200
                                  : AppColors.neutral700),
                        fontWeight: _selectedFilter == 'all'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Có lớp học'),
                      selected: _selectedFilter == 'hasClasses',
                      onSelected: (_) {
                        setModalState(() => _selectedFilter = 'hasClasses');
                        setState(() {});
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.neutral800
                          : AppColors.neutral100,
                      labelStyle: TextStyle(
                        color: _selectedFilter == 'hasClasses'
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.neutral200
                                  : AppColors.neutral700),
                        fontWeight: _selectedFilter == 'hasClasses'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    FilterChip(
                      label: const Text('Chưa có lớp'),
                      selected: _selectedFilter == 'noClasses',
                      onSelected: (_) {
                        setModalState(() => _selectedFilter = 'noClasses');
                        setState(() {});
                      },
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.neutral800
                          : AppColors.neutral100,
                      labelStyle: TextStyle(
                        color: _selectedFilter == 'noClasses'
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.neutral200
                                  : AppColors.neutral700),
                        fontWeight: _selectedFilter == 'noClasses'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.p24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AdminBloc>().add(
                        LoadStudentList(searchQuery: _searchQuery),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ),
                SizedBox(height: AppSizes.p8),
              ],
            ),
          );
        },
      ),
    );
  }

  List<AdminStudent> _applyFilter(List<AdminStudent> students) {
    switch (_selectedFilter) {
      case 'hasClasses':
        return students.where((s) => s.totalClassesEnrolled > 0).toList();
      case 'noClasses':
        return students.where((s) => s.totalClassesEnrolled == 0).toList();
      default:
        return students;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 360;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SimpleAdminAppBar(title: 'Quản lý Học viên'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: isNarrow
                ? Column(
                    children: [
                      _buildSearchField(isDark),
                      SizedBox(height: AppSizes.p8),
                      _buildFilterButton(isDark, context),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildSearchField(isDark)),
                      SizedBox(width: AppSizes.p12),
                      _buildFilterButton(isDark, context),
                    ],
                  ),
          ),

          if (_selectedFilter != 'all')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      _selectedFilter == 'hasClasses'
                          ? 'Có lớp học'
                          : 'Chưa có lớp',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    deleteIcon: Icon(Icons.close, size: 16.sp),
                    onDeleted: () {
                      setState(() => _selectedFilter = 'all');
                    },
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminError) {
                  return Center(child: Text(state.message));
                }

                if (state is StudentListLoaded) {
                  final students = _applyFilter(state.students);

                  if (students.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      message: 'Không tìm thấy học viên',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminBloc>().add(
                        LoadStudentList(searchQuery: _searchQuery),
                      );
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildStudentCard(student, isDark, theme);
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

  Widget _buildSearchField(bool isDark) {
    return AdminSearchBar(
      controller: _searchController,
      hintText: 'Tìm kiếm theo tên, email, SĐT',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        context.read<AdminBloc>().add(LoadStudentList(searchQuery: value));
      },
      onClear: () {
        setState(() {
          _searchQuery = '';
        });
        context.read<AdminBloc>().add(const LoadStudentList(searchQuery: ''));
      },
    );
  }

  Widget _buildFilterButton(bool isDark, BuildContext context) {
    return AdminFilterButton(
      hasActiveFilter: _selectedFilter != 'all',
      onTap: () => _showFilterBottomSheet(context, isDark),
    );
  }

  Widget _buildStudentCard(AdminStudent student, bool isDark, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.adminStudentDetail,
            arguments: student.id,
          ).then((_) {
            if (!mounted) return;
            context.read<AdminBloc>().add(
              LoadStudentList(searchQuery: _searchQuery),
            );
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              // Avatar - consistent with teacher
              ClipOval(
                child:
                    student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                    ? CustomImage(
                        imageUrl: student.avatarUrl!,
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 48.w,
                        height: 48.w,
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                        child: Icon(
                          Icons.person,
                          size: 24.sp,
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral600,
                        ),
                      ),
              ),
              SizedBox(width: AppSizes.p12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row - same as teacher
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),

                    // Secondary info - email (matching teacher's phone style)
                    Text(
                      student.email,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.neutral400
                            : AppColors.neutral600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),

                    // Stats row - same layout as teacher
                    Row(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 14.sp,
                          color: isDark
                              ? AppColors.neutral500
                              : AppColors.neutral600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${student.totalClassesEnrolled} lớp',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral600,
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
    );
  }
}
