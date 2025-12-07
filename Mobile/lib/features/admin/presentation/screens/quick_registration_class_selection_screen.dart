import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

import '../widgets/class_selection_card.dart';
import '../../domain/entities/admin_class.dart';

class QuickRegistrationClassSelectionScreen extends StatefulWidget {
  const QuickRegistrationClassSelectionScreen({super.key});

  @override
  State<QuickRegistrationClassSelectionScreen> createState() =>
      _QuickRegistrationClassSelectionScreenState();
}

class _QuickRegistrationClassSelectionScreenState
    extends State<QuickRegistrationClassSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  Set<String> _selectedClassIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<RegistrationBloc>().add(const LoadAvailableClasses());

    final state = context.read<RegistrationBloc>().state;
    if (state is RegistrationInProgress) {
      _selectedClassIds = state.selectedClasses.map((c) => c.classId).toSet();
    } else if (state is ClassesLoaded) {
      _selectedClassIds = state.currentRegistration.selectedClasses
          .map((c) => c.classId)
          .toSet();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AdminClass> _filterClasses(List<AdminClass> classes) {
    final searchQuery = _searchController.text.toLowerCase();

    var filtered = classes.where((c) {
      if (searchQuery.isNotEmpty) {
        return c.name.toLowerCase().contains(searchQuery) ||
            c.teacherName.toLowerCase().contains(searchQuery) ||
            c.courseName.toLowerCase().contains(searchQuery);
      }
      return true;
    }).toList();

    switch (_tabController.index) {
      case 0:
        return filtered
            .where((c) => c.status != ClassStatus.completed)
            .toList();
      case 1:
        return filtered.where((c) => c.status == ClassStatus.upcoming).toList();
      case 2:
        return filtered.where((c) => c.status == ClassStatus.ongoing).toList();
      default:
        return filtered;
    }
  }

  void _toggleClass(AdminClass classItem) {
    setState(() {
      if (_selectedClassIds.contains(classItem.id)) {
        _selectedClassIds.remove(classItem.id);
      } else {
        _selectedClassIds.add(classItem.id);
      }
    });

    context.read<RegistrationBloc>().add(
      SelectClass(
        classId: classItem.id,
        className: classItem.name,
        tuitionFee: classItem.tuitionFee,
        courseId: classItem.courseId,
        courseName: classItem.courseName,
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedClassIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một lớp học'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn ${_selectedClassIds.length} lớp học'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  void _showFilterBottomSheet(ClassesLoaded state) {
    final bloc = context.read<RegistrationBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<RegistrationBloc, RegistrationState>(
          builder: (context, blocState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            final currentFilter = (blocState is ClassesLoaded)
                ? blocState.appliedFilter
                : null;
            final selectedCourseId = currentFilter?.courseId;
            final selectedTeacherId = currentFilter?.teacherId;
            final selectedSchedule = currentFilter?.schedule;

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
                  Divider(
                    color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Khóa học',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizes.p12),
                          Wrap(
                            spacing: AppSizes.p8,
                            runSpacing: AppSizes.p8,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: selectedCourseId == null,
                                onSelected: (selected) {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: null,
                                      teacherId: selectedTeacherId,
                                      schedule: selectedSchedule,
                                    ),
                                  );
                                },
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              ),
                              ...state.courses.map((course) {
                                final courseId = course['id']?.toString();
                                final courseName =
                                    course['name']?.toString() ?? '';
                                final isSelected = selectedCourseId == courseId;
                                return FilterChip(
                                  label: Text(courseName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<RegistrationBloc>().add(
                                      FilterClasses(
                                        courseId: selected ? courseId : null,
                                        teacherId: selectedTeacherId,
                                        schedule: selectedSchedule,
                                      ),
                                    );
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.neutral300
                                              : AppColors.neutral700),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }),
                            ],
                          ),

                          SizedBox(height: AppSizes.p24),

                          Text(
                            'Giảng viên',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizes.p12),
                          Wrap(
                            spacing: AppSizes.p8,
                            runSpacing: AppSizes.p8,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: selectedTeacherId == null,
                                onSelected: (selected) {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: selectedCourseId,
                                      teacherId: null,
                                      schedule: selectedSchedule,
                                    ),
                                  );
                                },
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              ),
                              ...state.teachers.map((teacher) {
                                final teacherId = teacher['id']?.toString();
                                final teacherName =
                                    teacher['name']?.toString() ?? '';
                                final isSelected =
                                    selectedTeacherId == teacherId;
                                return FilterChip(
                                  label: Text(teacherName),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<RegistrationBloc>().add(
                                      FilterClasses(
                                        courseId: selectedCourseId,
                                        teacherId: selected ? teacherId : null,
                                        schedule: selectedSchedule,
                                      ),
                                    );
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.neutral300
                                              : AppColors.neutral700),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }),
                            ],
                          ),

                          SizedBox(height: AppSizes.p24),

                          Text(
                            'Lịch học',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizes.p12),
                          Wrap(
                            spacing: AppSizes.p8,
                            runSpacing: AppSizes.p8,
                            children: [
                              FilterChip(
                                label: const Text('Tất cả'),
                                selected: selectedSchedule == null,
                                onSelected: (selected) {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: selectedCourseId,
                                      teacherId: selectedTeacherId,
                                      schedule: null,
                                    ),
                                  );
                                },
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                              ),
                              ...state.schedules.map((schedule) {
                                final isSelected = selectedSchedule == schedule;
                                return FilterChip(
                                  label: Text(schedule),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    context.read<RegistrationBloc>().add(
                                      FilterClasses(
                                        courseId: selectedCourseId,
                                        teacherId: selectedTeacherId,
                                        schedule: selected ? schedule : null,
                                      ),
                                    );
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.neutral300
                                              : AppColors.neutral700),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                );
                              }),
                            ],
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
                            context.read<RegistrationBloc>().add(
                              const ClearClassFilter(),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.p16,
                            ),
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
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.p16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                          ),
                          child: const Text('Đóng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  int _getActiveFiltersCount(ClassFilterInfo? filter) {
    if (filter == null) return 0;
    int count = 0;
    if (filter.courseId != null) count++;
    if (filter.teacherId != null) count++;
    if (filter.schedule != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Chọn Lớp học',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Sắp mở'),
            Tab(text: 'Đang học'),
          ],
        ),
      ),
      body: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          if (state is RegistrationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RegistrationError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppSizes.iconXLarge,
                      color: AppColors.error,
                    ),
                    SizedBox(height: AppSizes.paddingMedium),
                    Text(state.message, textAlign: TextAlign.center),
                    SizedBox(height: AppSizes.paddingMedium),
                    ElevatedButton(
                      onPressed: () => context.read<RegistrationBloc>().add(
                        const LoadAvailableClasses(),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ClassesLoaded) {
            final filteredClasses = _filterClasses(state.availableClasses);

            return Column(
              children: [
                if (_selectedClassIds.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.p8,
                    ),
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: AppSizes.iconSmall,
                        ),
                        SizedBox(width: AppSizes.p8),
                        Text(
                          'Đã chọn ${_selectedClassIds.length} lớp học',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context.read<RegistrationBloc>().add(
                              const ClearAllClasses(),
                            );
                            setState(() {
                              _selectedClassIds.clear();
                            });
                          },
                          child: const Text('Bỏ chọn tất cả'),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  child: Builder(
                    builder: (context) {
                      final filter = state.appliedFilter;
                      final activeFiltersCount = _getActiveFiltersCount(filter);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.courses.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(bottom: AppSizes.p12),
                              child: DropdownButtonFormField<String>(
                                value: filter?.courseId,
                                decoration: InputDecoration(
                                  labelText: 'Lọc theo khóa học',
                                  prefixIcon: const Icon(Icons.school_outlined),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppColors.neutral700
                                      : AppColors.neutral100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.p16,
                                    vertical: AppSizes.p12,
                                  ),
                                ),
                                hint: const Text('Tất cả khóa học'),
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('Tất cả khóa học'),
                                  ),
                                  ...state.courses.map((course) {
                                    final courseId = course['id']?.toString();
                                    final courseName =
                                        course['name']?.toString() ?? '';
                                    return DropdownMenuItem<String>(
                                      value: courseId,
                                      child: Text(
                                        courseName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: value,
                                      teacherId: filter?.teacherId,
                                      schedule: filter?.schedule,
                                    ),
                                  );
                                },
                              ),
                            ),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm lớp học, giảng viên...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.neutral700
                                        : AppColors.neutral100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppSizes.p16,
                                      vertical: AppSizes.p12,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.p12),
                              InkWell(
                                onTap: () => _showFilterBottomSheet(state),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(AppSizes.p12),
                                  decoration: BoxDecoration(
                                    color: activeFiltersCount > 0
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.neutral700
                                              : AppColors.neutral100),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
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
                                                  ? AppColors.neutral300
                                                  : AppColors.neutral600),
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
                        ],
                      );
                    },
                  ),
                ),

                Builder(
                  builder: (context) {
                    final filter = state.appliedFilter;
                    final activeFiltersCount = _getActiveFiltersCount(filter);

                    if (activeFiltersCount == 0) return const SizedBox.shrink();

                    return Container(
                      height: 40.h,
                      margin: EdgeInsets.only(bottom: AppSizes.p8),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                        ),
                        children: [
                          if (filter?.courseId != null)
                            Padding(
                              padding: EdgeInsets.only(right: AppSizes.p8),
                              child: Chip(
                                label: Text(filter?.courseName ?? 'Khóa học'),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: null,
                                      teacherId: filter?.teacherId,
                                      schedule: filter?.schedule,
                                    ),
                                  );
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
                          if (filter?.teacherId != null)
                            Padding(
                              padding: EdgeInsets.only(right: AppSizes.p8),
                              child: Chip(
                                label: Text(
                                  filter?.teacherName ?? 'Giảng viên',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: filter?.courseId,
                                      teacherId: null,
                                      schedule: filter?.schedule,
                                    ),
                                  );
                                },
                                backgroundColor: AppColors.info.withValues(
                                  alpha: 0.1,
                                ),
                                labelStyle: TextStyle(
                                  color: AppColors.info,
                                  fontSize: 12.sp,
                                ),
                                side: BorderSide.none,
                              ),
                            ),
                          if (filter?.schedule != null)
                            Padding(
                              padding: EdgeInsets.only(right: AppSizes.p8),
                              child: Chip(
                                label: Text(filter!.schedule!),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  context.read<RegistrationBloc>().add(
                                    FilterClasses(
                                      courseId: filter.courseId,
                                      teacherId: filter.teacherId,
                                      schedule: null,
                                    ),
                                  );
                                },
                                backgroundColor: AppColors.success.withValues(
                                  alpha: 0.1,
                                ),
                                labelStyle: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12.sp,
                                ),
                                side: BorderSide.none,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                Expanded(
                  child: filteredClasses.isEmpty
                      ? const Center(
                          child: EmptyStateWidget(
                            icon: Icons.class_,
                            message: 'Không tìm thấy lớp học',
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(AppSizes.paddingMedium),
                          itemCount: filteredClasses.length,
                          itemBuilder: (context, index) {
                            final classItem = filteredClasses[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: AppSizes.p12),
                              child: ClassSelectionCard(
                                classItem: classItem,
                                isSelected: _selectedClassIds.contains(
                                  classItem.id,
                                ),
                                onTap: () => _toggleClass(classItem),
                              ),
                            );
                          },
                        ),
                ),

                Container(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          _selectedClassIds.isEmpty
                              ? 'Xác nhận'
                              : 'Xác nhận (${_selectedClassIds.length} lớp)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
