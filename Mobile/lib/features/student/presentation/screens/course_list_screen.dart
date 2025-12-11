import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/student_app_bar.dart';
import '../widgets/course_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../../domain/entities/course.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  
  String _selectedCategory = 'Tất cả';
  List<String> _categories = ['Tất cả'];
  String _sortOption =
      'Mới nhất'; 
  RangeValues _priceRange = const RangeValues(0, 10000000);
  double _minDataPrice = 0;
  double _maxDataPrice = 10000000;
  bool _isDataLoaded = false;

  final List<String> _sortOptions = [
    'Mới nhất',
    'Giá: Thấp đến Cao',
    'Giá: Cao đến Thấp',
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

  void _extractFilterData(List<Course> courses) {
    if (_isDataLoaded) return;

    
    final Set<String> categorySet = {'Tất cả'};
    double minP = double.infinity;
    double maxP = 0.0;

    for (var course in courses) {
      if (course.category.isNotEmpty) {
        categorySet.add(course.category);
      }
      if (course.price < minP) minP = course.price;
      if (course.price > maxP) maxP = course.price;
    }

    setState(() {
      _categories = categorySet.toList();
      
      _minDataPrice = (minP / 100000).floor() * 100000.0;
      _maxDataPrice = (maxP / 100000).ceil() * 100000.0;
      if (_maxDataPrice == _minDataPrice) _maxDataPrice += 1000000;

      _priceRange = RangeValues(_minDataPrice, _maxDataPrice);
      _isDataLoaded = true;
    });
  }

  void _showFilterBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bộ lọc & Sắp xếp',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  
                  Text(
                    'Sắp xếp theo',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: _sortOptions.map((option) {
                      final isSelected = _sortOption == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _sortOption = option);
                            setState(() => _sortOption = option);
                          }
                        },
                        backgroundColor: isDark
                            ? const Color(0xFF374151)
                            : Colors.grey[100],
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white : AppColors.textPrimary),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontFamily: 'Lexend',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                      ? Colors.transparent
                                      : Colors.grey[300]!),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  
                  Text(
                    'Khoảng giá',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: 'đ',
                        ).format(_priceRange.start),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: 'đ',
                        ).format(_priceRange.end),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minDataPrice,
                    max: _maxDataPrice,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    labels: RangeLabels(
                      NumberFormat.compact(
                        locale: 'vi_VN',
                      ).format(_priceRange.start),
                      NumberFormat.compact(
                        locale: 'vi_VN',
                      ).format(_priceRange.end),
                    ),
                    onChanged: (values) {
                      setModalState(() => _priceRange = values);
                      setState(() => _priceRange = values);
                    },
                  ),

                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        
                        context.read<StudentBloc>().add(
                          SearchCourses(_searchController.text),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Áp dụng',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          final cartCount = cartState.items.length;
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
                    SizedBox(width: 12.w),
                    Container(
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
                        onPressed: () =>
                            _showFilterBottomSheet(context, isDark),
                        icon: Icon(
                          Icons.tune,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        tooltip: 'Bộ lọc',
                      ),
                    ),
                  ],
                ),
              ),

              
              Container(
                height: 44.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final filter = _categories[index];
                    final isSelected = filter == _selectedCategory;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = filter;
                        });
                        
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
                      
                      if (!_isDataLoaded) {
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _extractFilterData(state.courses);
                        });
                      }

                      
                      var displayCourses = List<Course>.from(state.courses);

                      
                      if (_selectedCategory != 'Tất cả') {
                        displayCourses = displayCourses
                            .where((c) => c.category == _selectedCategory)
                            .toList();
                      }

                      
                      displayCourses = displayCourses.where((c) {
                        return c.price >= _priceRange.start &&
                            c.price <= _priceRange.end;
                      }).toList();

                      
                      if (_sortOption == 'Mới nhất') {
                        displayCourses.sort((a, b) {
                          if (a.startDate == null && b.startDate == null)
                            return 0;
                          if (a.startDate == null) return 1;
                          if (b.startDate == null) return -1;
                          return b.startDate!.compareTo(a.startDate!);
                        });
                      } else if (_sortOption == 'Giá: Thấp đến Cao') {
                        displayCourses.sort(
                          (a, b) => a.price.compareTo(b.price),
                        );
                      } else if (_sortOption == 'Giá: Cao đến Thấp') {
                        displayCourses.sort(
                          (a, b) => b.price.compareTo(a.price),
                        );
                      }

                      if (displayCourses.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.search_off,
                          message: 'Không tìm thấy khóa học phù hợp',
                        );
                      }

                      
                      if (!isDesktop && !isTablet) {
                        
                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            setState(
                              () => _isDataLoaded = false,
                            ); 
                            context.read<StudentBloc>().add(LoadAllCourses());
                          },
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              0,
                              padding,
                              80.h, 
                            ),
                            itemCount: displayCourses.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final course = displayCourses[index];
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

                      
                      final crossAxisCount = isDesktop ? 3 : 2;
                      final childAspectRatio = isDesktop ? 0.75 : 0.8;

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          setState(() => _isDataLoaded = false);
                          context.read<StudentBloc>().add(LoadAllCourses());
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            padding,
                            0,
                            padding,
                            80.h, 
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemCount: displayCourses.length,
                          itemBuilder: (context, index) {
                            final course = displayCourses[index];
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
