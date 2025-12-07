import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../core/widgets/common/app_button.dart';
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

  DateTime? _dateOfBirth;
  String? _imageUrl;

  List<Map<String, dynamic>> _degreeTypes = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingData = true;

  final List<int> _selectedSubjectIds = [];

  final List<Map<String, dynamic>> _selectedQualifications = [];

  bool _isLoading = false;

  bool get _isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    _loadFormData();

    if (widget.teacher != null) {
      _nameController.text = widget.teacher!.fullName;
      _emailController.text = widget.teacher!.email ?? '';
      _phoneController.text = widget.teacher!.phoneNumber ?? '';
      _experienceController.text = widget.teacher!.experience ?? '';
      _dateOfBirth = widget.teacher!.dateOfBirth;
      _imageUrl = widget.teacher!.avatarUrl;

      
      if (widget.teacher!.qualificationsList.isNotEmpty) {
        for (var qual in widget.teacher!.qualificationsList) {
          _selectedQualifications.add({
            'degreeId': qual.degreeId,
            'degreeName': qual.degreeName,
            'level': qual.level,
          });
        }
      }
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

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      locale: const Locale('vi', 'VN'),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bloc = context.read<AdminBloc>();

      if (_isEditing) {
        
        await bloc.adminRepository.updateTeacher(
          teacherId: widget.teacher!.id,
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          dateOfBirth: _dateOfBirth,
          imageUrl: _imageUrl,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật giảng viên thành công'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context, true); 
        return;
      } else {
        
        await bloc.adminRepository.createTeacher(
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          dateOfBirth: _dateOfBirth,
          imageUrl: _imageUrl,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm giảng viên thành công'),
            backgroundColor: AppColors.success,
          ),
        );

        Navigator.pop(context, true); 
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddQualificationDialog() {
    int? selectedDegreeId;
    final levelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Thêm bằng cấp'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedDegreeId,
                    decoration: const InputDecoration(
                      labelText: 'Loại bằng cấp',
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

                  AppTextField(
                    controller: levelController,
                    hintText: 'Chi tiết (VD: IELTS 8.5, ĐH ABC...)',
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
                          final degreeName = _degreeTypes.firstWhere(
                            (d) => d['id'] == selectedDegreeId,
                          )['name'];
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

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: SimpleAdminAppBar(
        title: _isEditing ? 'Cập nhật thông tin' : 'Thêm giảng viên',
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: AppSizes.paddingMedium,
                    right: AppSizes.paddingMedium,
                    top: AppSizes.paddingMedium,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                    _buildLabel('Họ tên *'),
                    SizedBox(height: AppSizes.p8),
                    AppTextField(
                      controller: _nameController,
                      hintText: 'Nhập họ tên',
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
                    AppTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Nhập email',
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !value.contains('@')) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.paddingMedium),

                    
                    _buildLabel('Số điện thoại *'),
                    SizedBox(height: AppSizes.p8),
                    AppTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      hintText: 'Nhập số điện thoại',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (value.length < 10) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSizes.paddingMedium),

                    
                    _buildLabel('Ngày sinh'),
                    SizedBox(height: AppSizes.p8),
                    InkWell(
                      onTap: _selectDateOfBirth,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          hintText: 'Chọn ngày sinh',
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            size: 20,
                          ),
                        ),
                        child: Text(
                          _dateOfBirth != null
                              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                              : 'Chọn ngày sinh',
                          style: TextStyle(
                            color: _dateOfBirth != null
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark
                                      ? AppColors.neutral400
                                      : AppColors.neutral500),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingMedium),

                    
                    _buildLabel('Môn dạy'),
                    SizedBox(height: AppSizes.p8),
                    Wrap(
                      spacing: AppSizes.p8,
                      runSpacing: AppSizes.p8,
                      children: _categories.map((category) {
                        final categoryId = category['id'] as int;
                        final isSelected = _selectedSubjectIds.contains(
                          categoryId,
                        );
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
                          selectedColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
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
                    AppTextField(
                      controller: _experienceController,
                      maxLines: 3,
                      hintText: 'Mô tả kinh nghiệm giảng dạy...',
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
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.neutral700
                                : AppColors.neutral300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Chưa có bằng cấp nào',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.neutral400
                                  : AppColors.neutral600,
                            ),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSizes.p8,
                        runSpacing: AppSizes.p8,
                        children: _selectedQualifications.asMap().entries.map((
                          entry,
                        ) {
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
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            labelStyle: TextStyle(color: AppColors.primary),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 32.h),

                    
                    AppButton(
                      text: _isEditing ? 'Cập nhật' : 'Thêm giảng viên',
                      onPressed: _save,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 50.h,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 24.h,
                    ),
                  ],
                ),
              ),
            ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: AppSizes.textSm, fontWeight: FontWeight.w600),
    );
  }
}
