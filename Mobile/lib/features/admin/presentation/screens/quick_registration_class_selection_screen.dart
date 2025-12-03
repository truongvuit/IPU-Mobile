import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            c.teacherName.toLowerCase().contains(searchQuery);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chọn Lớp học'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Thời áp'),
            Tab(text: 'Thời gian'),
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
                      onPressed: () {
                        context.read<RegistrationBloc>().add(
                          const LoadAvailableClasses(),
                        );
                      },
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
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm lớp học, giảng viên...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
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
