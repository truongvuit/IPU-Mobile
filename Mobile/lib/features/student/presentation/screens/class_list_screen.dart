import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_app_bar.dart';
import '../widgets/class_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';


class ClassListScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onMenuPressed;

  const ClassListScreen({
    super.key,
    this.isTab = false,
    this.onMenuPressed,
  });

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  List<dynamic> _allClasses = [];
  List<dynamic> _filteredClasses = [];
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _loadDataIfNeeded();
  }

  void _loadDataIfNeeded() {
    final state = context.read<StudentBloc>().state;
    
    if (state is! ClassesLoaded && state is! StudentLoading) {
      context.read<StudentBloc>().add(LoadMyClasses());
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredClasses = _allClasses.where((cls) {
        final query = _searchController.text.toLowerCase();
        final matchesSearch = cls.courseName.toLowerCase().contains(query) ||
            cls.teacherName.toLowerCase().contains(query) ||
            cls.room.toLowerCase().contains(query);

        final matchesFilter = _selectedFilter == 'all' ||
            cls.status == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
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
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final padding = isDesktop ? 40.w : (isTablet ? 24.w : AppSizes.paddingMedium);

          return Column(
            children: [
              StudentAppBar(
                title: 'Lớp học của tôi',
                showBackButton: !widget.isTab,
                showMenuButton: widget.isTab,
                onMenuPressed: widget.onMenuPressed,
                onBackPressed: () {
                  
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.studentDashboard,
                    (route) => false,
                  );
                },
              ),
              
              
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding,
                AppSizes.paddingMedium,
                padding,
                AppSizes.paddingSmall,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _applyFilters();
                },
                style: TextStyle(
                  fontSize: isDesktop ? 18.sp : 16.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontFamily: 'Lexend',
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm lớp học...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
                    fontFamily: 'Lexend',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: isDesktop ? 24.w : 20.w,
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),

            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: AppSizes.paddingSmall,
              ),
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all', isDark, isDesktop),
                  SizedBox(width: AppSizes.paddingSmall),
                  _buildFilterChip('Đang học', 'active', isDark, isDesktop),
                  SizedBox(width: AppSizes.paddingSmall),
                  _buildFilterChip('Đã kết thúc', 'completed', isDark, isDesktop),
                ],
              ),
            ),

            
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                buildWhen: (previous, current) {
                  
                  return current is ClassesLoaded || 
                         current is StudentLoading || 
                         current is StudentError ||
                         current is DashboardLoaded;
                },
                builder: (context, state) {
                  
                  if (state is StudentInitial || (state is! ClassesLoaded && state is! StudentLoading && !_hasLoadedData)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_hasLoadedData) {
                        _hasLoadedData = true;
                        context.read<StudentBloc>().add(LoadMyClasses());
                      }
                    });
                  }

                  if (state is StudentLoading) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(padding, 0, padding, 80.h),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                        child: SkeletonWidget.rectangular(height: 90.h),
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
                                color: isDark ? Colors.white : AppColors.textPrimary,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<StudentBloc>().add(LoadMyClasses());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  
                  if (state is DashboardLoaded) {
                    final classes = state.upcomingClasses;
                    
                    if (_allClasses.isEmpty || _allClasses != classes) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _allClasses = classes;
                            _applyFilters();
                          });
                        }
                      });
                    }

                    final displayClasses = _filteredClasses.isEmpty && _searchController.text.isEmpty && _selectedFilter == 'all'
                        ? classes
                        : _filteredClasses;

                    if (classes.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.school_outlined,
                        message: 'Chưa có lớp học nào',
                      );
                    }

                    if (displayClasses.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off,
                        message: 'Không tìm thấy lớp học phù hợp',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<StudentBloc>().add(LoadMyClasses());
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          0,
                          padding,
                          80.h,
                        ),
                        itemCount: displayClasses.length,
                        itemBuilder: (context, index) {
                          final studentClass = displayClasses[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: ClassCard(
                              studentClass: studentClass,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentClassDetail,
                                  arguments: studentClass.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is ClassesLoaded) {
                    if (_allClasses.isEmpty || _allClasses != state.classes) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _allClasses = state.classes;
                            _applyFilters();
                          });
                        }
                      });
                    }

                    final displayClasses = _filteredClasses.isEmpty && _searchController.text.isEmpty && _selectedFilter == 'all'
                        ? state.classes
                        : _filteredClasses;

                    if (state.classes.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.school_outlined,
                        message: 'Chưa có lớp học nào',
                      );
                    }

                    if (displayClasses.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off,
                        message: 'Không tìm thấy lớp học phù hợp',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context.read<StudentBloc>().add(LoadMyClasses());
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          0,
                          padding,
                          80.h,
                        ),
                        itemCount: displayClasses.length,
                        itemBuilder: (context, index) {
                          final studentClass = displayClasses[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: ClassCard(
                              studentClass: studentClass,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.studentClassDetail,
                                  arguments: studentClass.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(padding, 0, padding, 80.h),
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                      child: SkeletonWidget.rectangular(height: 90.h),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark, bool isDesktop) {
    final isSelected = _selectedFilter == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20.w : 16.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 16.sp : 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textPrimary),
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }
}

