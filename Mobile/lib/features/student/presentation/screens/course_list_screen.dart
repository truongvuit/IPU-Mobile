import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/services/cart_service.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../widgets/course_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../widgets/cart_bottom_sheet.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';

  final List<String> _filterOptions = [
    'Tất cả',
    'Mới mở',
    'Nhập môn',
    'Nâng cao',
  ];

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
      floatingActionButton: BlocBuilder<StudentBloc, StudentState>(
        buildWhen: (previous, current) =>
            current is StudentCartUpdated || current is CoursesLoaded,
        builder: (context, state) {
          // Read cart count from CartService singleton (persists across bloc instances)
          final cartCount = CartService.instance.itemCount;

          // Always show FAB, but with different appearance based on cart count
          return FloatingActionButton.extended(
            onPressed: () => CartBottomSheet.show(context),
            backgroundColor: cartCount > 0
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.7),
            icon: cartCount > 0
                ? Badge(
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.error,
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  )
                : const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: Text(
              cartCount > 0 ? 'Giỏ hàng ($cartCount)' : 'Giỏ hàng',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
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
                  Navigator.pop(context);
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
                  ],
                ),
              ),

              // Filter Chips
              Container(
                height: 44.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  itemCount: _filterOptions.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final filter = _filterOptions[index];
                    final isSelected = filter == _selectedFilter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        // Trigger search with filter
                        context.read<StudentBloc>().add(
                          SearchCourses(_searchController.text),
                        );
                      },
                      backgroundColor: isDark
                          ? const Color(0xFF1F2937)
                          : Colors.white,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white : AppColors.textPrimary),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFDBDFE6)),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    if (state is StudentLoading) {
                      return const EmptyStateWidget(
                        icon: Icons.hourglass_empty,
                        message: 'Đang tải khóa học...',
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
                          message: 'Không có khóa học đang mở',
                        );
                      }

                      // Use ListView for mobile, GridView for tablet/desktop
                      if (!isDesktop && !isTablet) {
                        // Mobile: List view with horizontal cards
                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            context.read<StudentBloc>().add(LoadAllCourses());
                          },
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              0,
                              padding,
                              80.h, // Extra padding for FAB
                            ),
                            itemCount: state.courses.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final course = state.courses[index];
                              return CourseCard(
                                course: course,
                                isHorizontal: true,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.studentCourseDetail,
                                    arguments: course.id,
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      // Tablet/Desktop: Grid view with vertical cards
                      final crossAxisCount = isDesktop ? 3 : 2;
                      final childAspectRatio = isDesktop ? 0.75 : 0.8;

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context.read<StudentBloc>().add(LoadAllCourses());
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            padding,
                            0,
                            padding,
                            80.h, // Extra padding for FAB
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemCount: state.courses.length,
                          itemBuilder: (context, index) {
                            final course = state.courses[index];
                            return CourseCard(
                              course: course,
                              isHorizontal: false,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentCourseDetail,
                                  arguments: course.id,
                                );
                              },
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
}
