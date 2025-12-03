import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/permission_gate.dart';
import '../../../../core/auth/models/permission.dart';
import '../../domain/entities/admin_teacher.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/simple_admin_app_bar.dart';

import 'admin_teacher_form_screen.dart';
import '../../../../core/routing/app_router.dart';


class AdminTeacherListScreen extends StatefulWidget {
  const AdminTeacherListScreen({super.key});

  @override
  State<AdminTeacherListScreen> createState() => _AdminTeacherListScreenState();
}

class _AdminTeacherListScreenState extends State<AdminTeacherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  
  final List<String> _selectedQualifications = [];
  final List<String> _selectedSubjects = [];

  
  List<Map<String, dynamic>> _degreeTypes = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingFilters = true;

  @override
  void initState() {
    super.initState();
    
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    try {
      
      final bloc = context.read<AdminBloc>();
      final degrees = await bloc.adminRepository.getDegreeTypes();
      final categories = await bloc.adminRepository.getCategories();

      if (mounted) {
        setState(() {
          _degreeTypes = degrees;
          _categories = categories;
          _isLoadingFilters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFilters = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusLarge),
              ),
            ),
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Divider(color: isDark ? AppColors.gray700 : AppColors.gray200),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          'Trình độ',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizes.p12),
                        _isLoadingFilters
                            ? const Center(child: CircularProgressIndicator())
                            : Wrap(
                                spacing: AppSizes.p8,
                                runSpacing: AppSizes.p8,
                                children: _degreeTypes.map((degree) {
                                  final degreeName = degree['name'] as String;
                                  final isSelected = _selectedQualifications
                                      .contains(degreeName);
                                  return FilterChip(
                                    label: Text(degreeName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setStateModal(() {
                                        if (selected) {
                                          _selectedQualifications.add(
                                            degreeName,
                                          );
                                        } else {
                                          _selectedQualifications.remove(
                                            degreeName,
                                          );
                                        }
                                      });
                                      setState(() {});
                                    },
                                    selectedColor: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    checkmarkColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                                ? AppColors.gray300
                                                : AppColors.gray700),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),

                        SizedBox(height: AppSizes.p24),

                        
                        Text(
                          'Môn dạy',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizes.p12),
                        _isLoadingFilters
                            ? const Center(child: CircularProgressIndicator())
                            : Wrap(
                                spacing: AppSizes.p8,
                                runSpacing: AppSizes.p8,
                                children: _categories.map((category) {
                                  final categoryName =
                                      category['name'] as String;
                                  final isSelected = _selectedSubjects.contains(
                                    categoryName,
                                  );
                                  return FilterChip(
                                    label: Text(categoryName),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setStateModal(() {
                                        if (selected) {
                                          _selectedSubjects.add(categoryName);
                                        } else {
                                          _selectedSubjects.remove(
                                            categoryName,
                                          );
                                        }
                                      });
                                      setState(() {});
                                    },
                                    selectedColor: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    checkmarkColor: AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark
                                                ? AppColors.gray300
                                                : AppColors.gray700),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),

                
                SizedBox(height: AppSizes.p16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedQualifications.clear();
                            _selectedSubjects.clear();
                          });
                          setStateModal(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: const Text('Xóa bộ lọc'),
                      ),
                    ),
                    SizedBox(width: AppSizes.p16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: const Text('Áp dụng'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<AdminTeacher> _filterTeachers(List<AdminTeacher> teachers) {
    return teachers.where((teacher) {
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = teacher.fullName.toLowerCase().contains(query);
        final matchesPhone = teacher.phoneNumber?.contains(query) ?? false;
        if (!matchesName && !matchesPhone) return false;
      }

      
      if (_selectedQualifications.isNotEmpty) {
        
        
        
        if (teacher.qualifications == null) return false;

        bool matchesQual = false;
        for (final qual in _selectedQualifications) {
          if (teacher.qualifications?.contains(qual) ?? false) {
            matchesQual = true;
            break;
          }
        }
        if (!matchesQual) return false;
      }

      
      if (_selectedSubjects.isNotEmpty) {
        bool matchesSubject = false;
        for (final subject in _selectedSubjects) {
          if (teacher.subjects.contains(subject)) {
            matchesSubject = true;
            break;
          }
        }
        if (!matchesSubject) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final activeFiltersCount =
        _selectedQualifications.length + _selectedSubjects.length;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SimpleAdminAppBar(title: 'Quản lý Giảng viên'),
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
                      hintText: 'Tìm kiếm theo tên, SĐT',
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
                    },
                  ),
                ),
                SizedBox(width: AppSizes.p12),
                InkWell(
                  onTap: _showFilterBottomSheet,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: activeFiltersCount > 0
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface),
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      border: activeFiltersCount > 0
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppColors.gray700
                                  : AppColors.gray300,
                            ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: activeFiltersCount > 0
                              ? Colors.white
                              : (isDark
                                    ? AppColors.gray300
                                    : AppColors.gray700),
                        ),
                        if (activeFiltersCount > 0)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                activeFiltersCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          if (activeFiltersCount > 0)
            Container(
              height: 40.h,
              margin: EdgeInsets.only(bottom: AppSizes.p12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                ),
                children: [
                  ..._selectedQualifications.map(
                    (qual) => Padding(
                      padding: EdgeInsets.only(right: AppSizes.p8),
                      child: Chip(
                        label: Text(qual),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedQualifications.remove(qual);
                          });
                        },
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12.sp,
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                  ..._selectedSubjects.map(
                    (subject) => Padding(
                      padding: EdgeInsets.only(right: AppSizes.p8),
                      child: Chip(
                        label: Text(subject),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return _buildLoadingState();
                }

                if (state is AdminError) {
                  return Center(child: Text(state.message));
                }

                if (state is TeacherListLoaded) {
                  final filteredTeachers = _filterTeachers(state.teachers);

                  if (filteredTeachers.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      message: 'Không tìm thấy kết quả',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AdminBloc>().add(
                        LoadTeacherList(searchQuery: _searchQuery),
                      );
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      itemCount: filteredTeachers.length,
                      itemBuilder: (context, index) {
                        final teacher = filteredTeachers[index];
                        return _buildTeacherCard(teacher, isDark, theme);
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

      
      floatingActionButton: PermissionGate(
        requiredPermission: Permission.createTeacher,
        child: FloatingActionButton(
          heroTag: 'teacher_list_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminTeacherFormScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(AdminTeacher teacher, bool isDark, ThemeData theme) {
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
            AppRouter.adminTeacherDetail,
            arguments: teacher,
          ).then((_) {
            
            context.read<AdminBloc>().add(
              LoadTeacherList(searchQuery: _searchQuery),
            );
          });
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Row(
            children: [
              
              ClipOval(
                child: CustomImage(
                  imageUrl: teacher.avatarUrl ?? '',
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: AppSizes.p12),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: AppSizes.p8),
                        
                        Icon(Icons.star, size: 16.sp, color: AppColors.warning),
                        SizedBox(width: 4.w),
                        Text(
                          teacher.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    
                    Row(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 14.sp,
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${teacher.activeClasses} lớp',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                        SizedBox(width: AppSizes.p16),
                        Icon(
                          Icons.people_outline,
                          size: 14.sp,
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${teacher.totalStudents} HS',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
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

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.p12),
          child: SkeletonWidget.rectangular(height: 80.h),
        );
      },
    );
  }
}
