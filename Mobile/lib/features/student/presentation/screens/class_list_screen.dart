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
import '../../domain/entities/student_class.dart';

class ClassListScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onMenuPressed;

  const ClassListScreen({super.key, this.isTab = false, this.onMenuPressed});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StudentClass> _allClasses = [];
  List<StudentClass> _activeClasses = [];
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataIfNeeded();
    });
  }

  void _loadDataIfNeeded() {
    if (!mounted || _hasLoadedData) return;

    final state = context.read<StudentBloc>().state;

    if (state is ClassesLoaded) {
      _hasLoadedData = true;
      _allClasses = state.classes;
      _filterClasses();
      setState(() {});
      return;
    }

    if (state is DashboardLoaded) {
      _hasLoadedData = true;
      _allClasses = state.upcomingClasses;
      _filterClasses();
      setState(() {});

      context.read<StudentBloc>().add(const LoadMyClasses());
      return;
    }

    if (state is! StudentLoading) {
      _hasLoadedData = true;
      context.read<StudentBloc>().add(const LoadMyClasses());
    }
  }

  void _filterClasses() {
    final query = _searchController.text.toLowerCase();

    _activeClasses = _allClasses.where((cls) {
      final matchesSearch =
          cls.courseName.toLowerCase().contains(query) ||
          cls.teacherName.toLowerCase().contains(query) ||
          cls.room.toLowerCase().contains(query);

      final statusLower = cls.status.toLowerCase();
      final isNotCompleted =
          statusLower != 'completed' &&
          statusLower != 'finished' &&
          statusLower != 'đã kết thúc' &&
          statusLower != 'cancelled' &&
          statusLower != 'đã hủy';

      return matchesSearch && isNotCompleted;
    }).toList();
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
                title: 'Lớp học của tôi',
                showBackButton: !widget.isTab,
                showMenuButton: widget.isTab,
                onMenuPressed: widget.onMenuPressed,
                onBackPressed: () {
                  Navigator.pop(context);
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
                    setState(() {
                      _filterClasses();
                    });
                  },
                  style: TextStyle(
                    fontSize: isDesktop ? 18.sp : 16.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm lớp học...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Lexend',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: isDesktop ? 24.w : 20.w,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: 14.h,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.paddingSmall),

              Expanded(
                child: BlocBuilder<StudentBloc, StudentState>(
                  buildWhen: (previous, current) {
                    return current is ClassesLoaded ||
                        current is StudentLoading ||
                        current is StudentError ||
                        current is DashboardLoaded;
                  },
                  builder: (context, state) {
                    if (state is StudentInitial ||
                        (state is! ClassesLoaded &&
                            state is! StudentLoading &&
                            !_hasLoadedData)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && !_hasLoadedData) {
                          _hasLoadedData = true;
                          context.read<StudentBloc>().add(
                            const LoadMyClasses(),
                          );
                        }
                      });
                    }

                    if (state is StudentLoading) {
                      return _buildLoadingSkeleton(padding);
                    }

                    if (state is StudentError) {
                      return _buildErrorState(state, isDark, isDesktop);
                    }

                    if (state is DashboardLoaded) {
                      _updateClassesList(state.upcomingClasses);
                    }

                    if (state is ClassesLoaded) {
                      _updateClassesList(state.classes);
                    }

                    return _buildClassList(
                      _activeClasses,
                      padding,
                      isDark,
                      'Không có lớp học đang hoạt động',
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

  void _updateClassesList(List<StudentClass> classes) {
    if (_allClasses.length != classes.length ||
        !_allClasses.every((e) => classes.contains(e))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _allClasses = classes;
            _filterClasses();
          });
        }
      });
    }
  }

  Widget _buildLoadingSkeleton(double padding) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 80.h),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
        child: SkeletonWidget.rectangular(height: 90.h),
      ),
    );
  }

  Widget _buildErrorState(StudentError state, bool isDark, bool isDesktop) {
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
                context.read<StudentBloc>().add(const LoadMyClasses());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList(
    List<StudentClass> classes,
    double padding,
    bool isDark,
    String emptyMessage,
  ) {
    if (classes.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.school_outlined,
        message: emptyMessage,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context.read<StudentBloc>().add(const LoadMyClasses());
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 80.h),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final studentClass = classes[index];
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
}
