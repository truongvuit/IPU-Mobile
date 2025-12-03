import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../widgets/course_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadAllCourses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final padding = isDesktop
              ? 40.w
              : (isTablet ? 24.w : AppSizes.paddingMedium);

          return Column(
            children: [
              StudentAppBar(
                title: 'Khám phá Khóa học',
                showBackButton: true,
                onBackPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.studentDashboard,
                    (route) => false,
                  );
                },
              ),

              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<StudentBloc>().add(SearchCourses(query));
                        },
                        style: TextStyle(
                          fontSize: isDesktop ? 18.sp : 16.sp,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: 'Lexend',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm khóa học…',
                          hintStyle: TextStyle(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
                            fontFamily: 'Lexend',
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: isDesktop ? 24.w : 20.w,
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF1F2937)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFDBDFE6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFDBDFE6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.paddingSmall),

                    Container(
                      width: isDesktop ? 64.w : 56.w,
                      height: isDesktop ? 64.h : 56.h,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFDBDFE6),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          size: isDesktop ? 28.w : 24.w,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        onPressed: () {
                          _showFilterBottomSheet(context, isDark, isDesktop);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    if (state is StudentLoading) {
                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(padding, 0, padding, 16.h),
                        itemCount: 5,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSizes.paddingMedium,
                          ),
                          child: SkeletonWidget.rectangular(height: 200.h),
                        ),
                      );
                    }

                    if (state is StudentError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: isDesktop ? 80.sp : 64.sp,
                                color: AppColors.error,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isDesktop ? 18.sp : 16.sp,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                              SizedBox(height: 24.h),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<StudentBloc>().add(
                                    LoadAllCourses(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 32.w : 24.w,
                                    vertical: isDesktop ? 16.h : 12.h,
                                  ),
                                ),
                                child: Text(
                                  'Thử lại',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18.sp : 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is CoursesLoaded) {
                      if (state.courses.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.search_off,
                          message: 'Không tìm thấy khóa học nào',
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context.read<StudentBloc>().add(LoadAllCourses());
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            padding,
                            0,
                            padding,
                            16.h,
                          ),
                          itemCount: state.courses.length,
                          itemBuilder: (context, index) {
                            final course = state.courses[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: CourseCard(
                                course: course,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.studentCourseDetail,
                                    arguments: course.id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    bool isDark,
    bool isDesktop,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.gray800 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lọc khóa học',
              style: TextStyle(
                fontSize: isDesktop ? 24.sp : 20.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Lexend',
              ),
            ),
            SizedBox(height: 24.h),
            _buildFilterOption(context, isDark, isDesktop, 'Tất cả', 'all'),
            _buildFilterOption(context, isDark, isDesktop, 'IELTS', 'IELTS'),
            _buildFilterOption(context, isDark, isDesktop, 'TOEIC', 'TOEIC'),
            _buildFilterOption(
              context,
              isDark,
              isDesktop,
              'Giao tiếp',
              'Communication',
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    bool isDark,
    bool isDesktop,
    String label,
    String category,
  ) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: isDesktop ? 18.sp : 16.sp,
          fontFamily: 'Lexend',
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã chọn: $label')));
      },
    );
  }
}
