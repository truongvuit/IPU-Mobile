import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../widgets/teacher_class_card.dart';
import '../widgets/teacher_app_bar.dart';



class TeacherClassListScreen extends StatefulWidget {
  final String? mode;
  final bool showScaffold;

  const TeacherClassListScreen({
    super.key,
    this.mode,
    this.showScaffold = false,
  });

  @override
  State<TeacherClassListScreen> createState() => _TeacherClassListScreenState();
}

class _TeacherClassListScreenState extends State<TeacherClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    
    
    context.read<TeacherBloc>().add(LoadMyClasses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    final content = Column(
      children: [
        
        TeacherAppBar(
          title: widget.mode == 'attendance'
              ? 'Chọn lớp điểm danh'
              : 'Lớp học của tôi',
          showBackButton: widget.showScaffold,
        ),

        
        Container(
          padding: EdgeInsets.all(isDesktop ? 32.w : 20.w),
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: isDesktop ? 18.sp : 16.sp),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc mã lớp...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondary,
                  fontFamily: 'Lexend',
                ),
                prefixIcon: Icon(Icons.search, size: isDesktop ? 28.w : 24.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF374151)
                    : AppColors.backgroundAlt,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<TeacherBloc>().add(LoadMyClasses());
                } else {
                  context.read<TeacherBloc>().add(SearchClasses(value));
                }
              },
            ),
          ),
        ),

        
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.w : 20.w,
            vertical: 12.h,
          ),
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả', isDark, isDesktop),
                SizedBox(width: 8.w),
                _buildFilterChip('ongoing', 'Đang diễn ra', isDark, isDesktop),
                SizedBox(width: 8.w),
                _buildFilterChip('upcoming', 'Sắp diễn ra', isDark, isDesktop),
                SizedBox(width: 8.w),
                _buildFilterChip('completed', 'Đã kết thúc', isDark, isDesktop),
              ],
            ),
          ),
        ),

        
        Expanded(
          child: BlocBuilder<TeacherBloc, TeacherState>(
            builder: (context, state) {
              if (state is TeacherError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isDesktop ? 64.sp : 48.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: TextStyle(fontSize: isDesktop ? 18.sp : 16.sp),
                        ),
                        SizedBox(height: 16.h),
                        BlocBuilder<TeacherBloc, TeacherState>(
                          builder: (context, btnState) {
                            final isLoading = btnState is TeacherLoading;
                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<TeacherBloc>().add(
                                        LoadMyClasses(),
                                      );
                                    },
                              child: isLoading
                                  ? SizedBox(
                                      height: 24.h,
                                      width: 24.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Thử lại',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 18.sp : 16.sp,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ClassesLoaded) {
                if (state.classes.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    child: EmptyStateWidget(
                      icon: Icons.class_outlined,
                      message: 'Không tìm thấy lớp học',
                    ),
                  );
                }

                final isMobile = MediaQuery.of(context).size.width < 600;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<TeacherBloc>().add(LoadMyClasses());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 32.w : 16.w,
                      0,
                      isDesktop ? 32.w : 16.w,
                      100.h,
                    ),
                    itemCount: state.classes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                        child: isMobile
                            ? TeacherClassCard(
                                classItem: state.classes[index],
                                compact: true,
                                onTap: () {
                                  final classId = state.classes[index].id;

                                  if (widget.mode == 'attendance') {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamed(
                                      AppRouter.teacherAttendance,
                                      arguments: classId,
                                    );
                                  } else {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamed(
                                      AppRouter.teacherClassDetail,
                                      arguments: classId,
                                    );
                                  }
                                },
                              )
                            : SizedBox(
                                height: 250.h,
                                child: TeacherClassCard(
                                  classItem: state.classes[index],
                                  onTap: () {
                                    final classId = state.classes[index].id;

                                    if (widget.mode == 'attendance') {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(
                                        AppRouter.teacherAttendance,
                                        arguments: classId,
                                      );
                                    } else {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed(
                                        AppRouter.teacherClassDetail,
                                        arguments: classId,
                                      );
                                    }
                                  },
                                ),
                              ),
                      );
                    },
                  ),
                );
              }

              
              
              return ListView.builder(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: SkeletonWidget.rectangular(height: 130.h),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.showScaffold) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF9FAFB),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Widget _buildFilterChip(
    String value,
    String label,
    bool isDark,
    bool isDesktop,
  ) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        context.read<TeacherBloc>().add(FilterClasses(value));
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF374151) : Colors.white),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF4B5563) : AppColors.border),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
