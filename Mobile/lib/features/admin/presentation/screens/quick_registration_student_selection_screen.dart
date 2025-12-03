import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';

import '../../domain/entities/admin_student.dart';

class QuickRegistrationStudentSelectionScreen extends StatefulWidget {
  const QuickRegistrationStudentSelectionScreen({super.key});

  @override
  State<QuickRegistrationStudentSelectionScreen> createState() =>
      _QuickRegistrationStudentSelectionScreenState();
}

class _QuickRegistrationStudentSelectionScreenState
    extends State<QuickRegistrationStudentSelectionScreen> {
  final _searchController = TextEditingController();
  List<AdminStudent> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents([String? searchQuery]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bloc = context.read<RegistrationBloc>();
      final repository = bloc.adminRepository;

      if (repository != null) {
        final students = await repository.getStudents(searchQuery: searchQuery);
        setState(() {
          _students = students;
          _isLoading = false;
        });
      } else {
        setState(() {
          _students = [];
          _isLoading = false;
          _errorMessage = 'Không thể kết nối với máy chủ';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi tải danh sách học viên: $e';
      });
    }
  }

  void _onSearch(String query) {
    _loadStudents(query.isNotEmpty ? query : null);
  }

  void _selectStudent(AdminStudent student) {
    setState(() {
      _selectedStudentId = student.id;
    });

    context.read<RegistrationBloc>().add(
      SelectStudent(
        studentId: student.id,
        studentName: student.fullName,
        phoneNumber: student.phoneNumber,
        email: student.email,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chọn: ${student.fullName}'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chọn Học viên'),
      ),
      body: Column(
        children: [
          
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, SĐT, email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppColors.gray700 : AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
              Text(_errorMessage!, textAlign: TextAlign.center),
              SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton(
                onPressed: () => _loadStudents(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_students.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.person_search,
          message: 'Không tìm thấy học viên',
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentCard(student, isDark);
      },
    );
  }

  Widget _buildStudentCard(AdminStudent student, bool isDark) {
    final isSelected = _selectedStudentId == student.id;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _selectStudent(student),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              
              CircleAvatar(
                radius: 24.r,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.gray600 : AppColors.gray200),
                backgroundImage: student.avatarUrl != null
                    ? NetworkImage(student.avatarUrl!)
                    : null,
                child: student.avatarUrl == null
                    ? Text(
                        student.initials,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.gray600,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: AppSizes.paddingMedium),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 14.sp,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          student.phoneNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    if (student.email.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14.sp,
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              student.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24.sp,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
