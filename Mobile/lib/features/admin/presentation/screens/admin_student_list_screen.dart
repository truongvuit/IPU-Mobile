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

class AdminStudentListScreen extends StatefulWidget {
  const AdminStudentListScreen({super.key});

  @override
  State<AdminStudentListScreen> createState() => _AdminStudentListScreenState();
}

class _AdminStudentListScreenState extends State<AdminStudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load được quản lý bởi HomeAdminScreen._loadDataForTab
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SimpleAdminAppBar(title: 'Quản lý Học viên'),
      body: Column(
        children: [
          
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email, SĐT',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.backgroundAlt,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      context.read<AdminBloc>().add(
                        LoadStudentList(searchQuery: value),
                      );
                    },
                  ),
                ),
                SizedBox(width: AppSizes.p12),
                
                Container(
                  padding: EdgeInsets.all(AppSizes.p12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: isDark ? AppColors.gray700 : AppColors.gray300,
                    ),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: isDark ? AppColors.gray300 : AppColors.gray700,
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
                  final students = state.students;

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

  Widget _buildStudentCard(AdminStudent student, bool isDark, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
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
            // Reload list khi quay lại từ màn chi tiết
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
              
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.gray700 : AppColors.gray200,
                ),
                child:
                    student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: CustomImage(
                          imageUrl: student.avatarUrl!,
                          width: 48.r,
                          height: 48.r,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 28.sp,
                        color: isDark ? AppColors.gray500 : AppColors.gray600,
                      ),
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      student.email,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 14.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${student.totalClassesEnrolled} lớp',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: isDark ? AppColors.gray600 : AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
