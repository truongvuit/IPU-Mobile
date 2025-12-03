import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/admin_teacher.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/simple_admin_app_bar.dart';


class AdminTeacherFormScreen extends StatefulWidget {
  final AdminTeacher? teacher; 

  const AdminTeacherFormScreen({super.key, this.teacher});

  @override
  State<AdminTeacherFormScreen> createState() => _AdminTeacherFormScreenState();
}

class _AdminTeacherFormScreenState extends State<AdminTeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();

  
  List<Map<String, dynamic>> _degreeTypes = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingData = true;

  
  final List<int> _selectedSubjectIds = [];
  
  
  final List<Map<String, dynamic>> _selectedQualifications = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
    
    if (widget.teacher != null) {
      _nameController.text = widget.teacher!.fullName;
      _emailController.text = widget.teacher!.email ?? '';
      _phoneController.text = widget.teacher!.phoneNumber ?? '';
      _experienceController.text = widget.teacher!.experience ?? '';
      
    }
  }

  Future<void> _loadFormData() async {
    try {
      final bloc = context.read<AdminBloc>();
      final degrees = await bloc.adminRepository.getDegreeTypes();
      final categories = await bloc.adminRepository.getCategories();
      
      if (mounted) {
        setState(() {
          _degreeTypes = degrees;
          _categories = categories;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một môn dạy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.teacher == null
              ? 'Thêm giảng viên thành công'
              : 'Cập nhật thông tin thành công',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  void _showAddQualificationDialog() {
    int? selectedDegreeId;
    final levelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm bằng cấp'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  DropdownButtonFormField<int>(
                    initialValue: selectedDegreeId,
                    decoration: InputDecoration(
                      labelText: 'Loại bằng cấp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                    ),
                    items: _degreeTypes.map((degree) {
                      return DropdownMenuItem<int>(
                        value: degree['id'] as int,
                        child: Text(degree['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDegreeId = value;
                      });
                    },
                  ),
                  SizedBox(height: AppSizes.paddingMedium),
                  
                  TextFormField(
                    controller: levelController,
                    decoration: InputDecoration(
                      labelText: 'Chi tiết (VD: IELTS 8.5, ĐH ABC...)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: selectedDegreeId == null
                      ? null
                      : () {
                          final degreeName = _degreeTypes
                              .firstWhere((d) => d['id'] == selectedDegreeId)['name'];
                          setState(() {
                            _selectedQualifications.add({
                              'degreeId': selectedDegreeId,
                              'degreeName': degreeName,
                              'level': levelController.text,
                            });
                          });
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.teacher != null;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: SimpleAdminAppBar(
        title: isEdit ? 'Cập nhật thông tin' : 'Thêm giảng viên',
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                children: [
                  
                  _buildLabel('Họ tên *'),
                  SizedBox(height: AppSizes.p8),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Nhập họ tên', isDark),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ tên';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildLabel('Email'),
                  SizedBox(height: AppSizes.p8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Nhập email', isDark),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildLabel('Số điện thoại'),
                  SizedBox(height: AppSizes.p8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Nhập số điện thoại', isDark),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildLabel('Môn dạy *'),
                  SizedBox(height: AppSizes.p8),
                  Wrap(
                    spacing: AppSizes.p8,
                    runSpacing: AppSizes.p8,
                    children: _categories.map((category) {
                      final categoryId = category['id'] as int;
                      final isSelected = _selectedSubjectIds.contains(categoryId);
                      return FilterChip(
                        label: Text(category['name'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSubjectIds.add(categoryId);
                            } else {
                              _selectedSubjectIds.remove(categoryId);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white : Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildLabel('Kinh nghiệm'),
                  SizedBox(height: AppSizes.p8),
                  TextFormField(
                    controller: _experienceController,
                    maxLines: 3,
                    decoration: _inputDecoration('Mô tả kinh nghiệm giảng dạy...', isDark),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Bằng cấp'),
                      TextButton.icon(
                        onPressed: _showAddQualificationDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.p8),
                  if (_selectedQualifications.isEmpty)
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(
                          color: isDark ? AppColors.gray700 : AppColors.gray300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Chưa có bằng cấp nào',
                          style: TextStyle(
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppSizes.p8,
                      runSpacing: AppSizes.p8,
                      children: _selectedQualifications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final qual = entry.value;
                        final displayText = qual['level']?.isNotEmpty == true
                            ? '${qual['degreeName']} - ${qual['level']}'
                            : qual['degreeName'];
                        return Chip(
                          label: Text(
                            displayText,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _selectedQualifications.removeAt(index);
                            });
                          },
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: AppColors.primary),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  
                  SizedBox(height: 32.h),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Lưu',
                              style: TextStyle(
                                fontSize: AppSizes.textBase,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: AppSizes.textSm,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
    );
  }
}
