import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../widgets/admin_class_card_compact.dart';
import '../../domain/entities/admin_class.dart';
import '../../../../core/routing/app_router.dart';

class AdminClassListScreen extends StatefulWidget {
  const AdminClassListScreen({super.key});

  @override
  State<AdminClassListScreen> createState() => _AdminClassListScreenState();
}

class _AdminClassListScreenState extends State<AdminClassListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCourse;

  
  static const int _pageSize = 20;
  int _displayedCount = 20;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _displayedCount = _pageSize;
        });
      }
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _displayedCount = _pageSize;
      });
    });

    _scrollController.addListener(_onScroll);

    context.read<AdminBloc>().add(const LoadClassList());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayedCount += _pageSize;
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<AdminClass> _filterClasses(List<AdminClass> classes) {
    return classes.where((c) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery) ||
          c.courseName.toLowerCase().contains(_searchQuery) ||
          c.teacherName.toLowerCase().contains(_searchQuery) ||
          c.room.toLowerCase().contains(_searchQuery);

      if (!matchesSearch) return false;

      if (_selectedCourse != null && c.courseName != _selectedCourse) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
      appBar: AppBar(
        title: const Text('Quản lý lớp học'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Đang học'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return _buildLoadingSkeleton();
          }

          if (state is AdminError) {
            return _buildErrorState(state.message);
          }

          if (state is ClassListLoaded) {
            return _buildClassList(state, isDark, theme);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: EdgeInsets.all(12.w),
      itemCount: 10,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, __) => SkeletonWidget.rectangular(height: 72.h),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<AdminBloc>().add(const LoadClassList()),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList(ClassListLoaded state, bool isDark, ThemeData theme) {
    List<AdminClass> baseList;
    switch (_tabController.index) {
      case 0:
        baseList = state.ongoingClasses;
        break;
      case 1:
        baseList = state.upcomingClasses;
        break;
      case 2:
        baseList = state.completedClasses;
        break;
      default:
        baseList = state.classes;
    }

    final courses = baseList.map((e) => e.courseName).toSet().toList()..sort();
    final filteredClasses = _filterClasses(baseList);
    final totalCount = filteredClasses.length;
    final displayClasses = filteredClasses.take(_displayedCount).toList();
    final hasMore = displayClasses.length < totalCount;

    return Column(
      children: [
        
        _buildSearchAndFilterRow(courses, isDark, theme),

        
        _buildResultCount(totalCount, isDark),

        
        Expanded(
          child: filteredClasses.isEmpty
              ? const Center(
                  child: EmptyStateWidget(
                    icon: Icons.search_off,
                    message: 'Không tìm thấy lớp học nào',
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<AdminBloc>().add(const LoadClassList());
                    setState(() => _displayedCount = _pageSize);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                    itemCount: displayClasses.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayClasses.length) {
                        return _buildLoadMoreIndicator();
                      }

                      final classItem = displayClasses[index];
                      return AdminClassCardCompact(
                        classItem: classItem,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.adminClassDetail,
                            arguments: classItem.id,
                          );
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRow(
      List<String> courses, bool isDark, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(12.w),
      child: Row(
        children: [
          
          Expanded(
            flex: 2,
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                    fontSize: 13.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                    size: 18.sp,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 18.sp),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                ),
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
          ),

          SizedBox(width: 10.w),

          
          if (courses.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedCourse,
                    isExpanded: true,
                    hint: Text(
                      'Khóa học',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18.sp,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.gray800,
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'Tất cả',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                      ...courses.map((course) => DropdownMenuItem<String?>(
                            value: course,
                            child: Text(
                              course,
                              style: TextStyle(fontSize: 12.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                        _displayedCount = _pageSize;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCount(int totalCount, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$totalCount lớp',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          if (_selectedCourse != null) ...[
            SizedBox(width: 8.w),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedCourse = null;
                  _displayedCount = _pageSize;
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _selectedCourse!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                isDark ? AppColors.gray300 : AppColors.gray700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.close,
                        size: 14.sp,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: _isLoadingMore
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Text(
                'Cuộn xuống để tải thêm',
                style: TextStyle(fontSize: 11.sp, color: AppColors.gray500),
              ),
      ),
    );
  }
}
