import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
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
                      message: 'Bạn chưa được phân công lớp học nào',
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

                                  
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(
                                    AppRouter.teacherClassDetail,
                                    arguments: classId,
                                  );
                                },
                              )
                            : TeacherClassCard(
                                classItem: state.classes[index],
                                onTap: () {
                                  final classId = state.classes[index].id;

                                  
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(
                                    AppRouter.teacherClassDetail,
                                    arguments: classId,
                                  );
                                },
                              ),
                      );
                    },
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: EmptyStateWidget(
                  icon: Icons.class_outlined,
                  message: 'Đang tải danh sách lớp...',
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
}
