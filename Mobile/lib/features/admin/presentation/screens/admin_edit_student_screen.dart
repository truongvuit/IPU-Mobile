import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/auth/models/user_role.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/simple_admin_app_bar.dart';

import '../../domain/entities/admin_student.dart';

class AdminEditStudentScreen extends StatefulWidget {
  final AdminStudent student;

  const AdminEditStudentScreen({super.key, required this.student});

  @override
  State<AdminEditStudentScreen> createState() => _AdminEditStudentScreenState();
}

class _AdminEditStudentScreenState extends State<AdminEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  DateTime? _dateOfBirth;
  String? _selectedEducationLevel;
  bool _showPassword = false;
  bool _changePassword = false;

  final List<String> _educationLevels = [
    'Tiểu học',
    'Trung học cơ sở',
    'Trung học phổ thông',
    'Cao đẳng',
    'Đại học',
    'Thạc sĩ',
    'Tiến sĩ',
    'Khác',
  ];

  UserRole? _currentUserRole;

  @override
  void initState() {
    super.initState();
    final student = widget.student;

    _fullNameController = TextEditingController(text: student.fullName);
    _phoneController = TextEditingController(text: student.phoneNumber);
    _emailController = TextEditingController(text: student.email);
    _addressController = TextEditingController(text: student.address ?? '');
    _occupationController = TextEditingController(
      text: student.occupation ?? '',
    );
    _usernameController = TextEditingController(text: student.email);
    _passwordController = TextEditingController();

    _dateOfBirth = student.dateOfBirth;
    _selectedEducationLevel = student.educationLevel;

    if (_selectedEducationLevel != null &&
        !_educationLevels.contains(_selectedEducationLevel)) {
      _educationLevels.add(_selectedEducationLevel!);
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _currentUserRole = UserRole.fromString(authState.user.role);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final updates = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'occupation': _occupationController.text.trim().isNotEmpty
            ? _occupationController.text.trim()
            : null,
        'educationLevel': _selectedEducationLevel,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
      };

      if (_currentUserRole?.isAdmin == true && _changePassword) {
        if (_passwordController.text.isNotEmpty) {
          updates['password'] = _passwordController.text;
        }
      }

      context.read<AdminBloc>().add(
        UpdateStudent(studentId: widget.student.id, updates: updates),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = _currentUserRole?.isAdmin == true;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SimpleAdminAppBar(title: 'Chỉnh sửa học viên'),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is StudentUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật học viên thành công'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin cá nhân', Icons.person),
                SizedBox(height: AppSizes.p12),

                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên *',
                  hintText: 'Nhập họ và tên',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.p16),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại *',
                  hintText: 'Nhập số điện thoại',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.p16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hintText: 'Nhập email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSizes.p16),

                _buildLabel('Ngày sinh'),
                SizedBox(height: AppSizes.p8),
                InkWell(
                  onTap: _selectDateOfBirth,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20.sp,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                        SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Text(
                            _dateOfBirth != null
                                ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
                                : 'Chọn ngày sinh',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _dateOfBirth != null
                                  ? null
                                  : (isDark
                                        ? AppColors.neutral400
                                        : AppColors.neutral600),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.p16),

                _buildTextField(
                  controller: _addressController,
                  label: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ',
                  prefixIcon: Icons.location_on_outlined,
                ),
                SizedBox(height: AppSizes.p16),

                _buildTextField(
                  controller: _occupationController,
                  label: 'Nghề nghiệp',
                  hintText: 'Nhập nghề nghiệp',
                  prefixIcon: Icons.work_outline,
                ),
                SizedBox(height: AppSizes.p16),

                _buildLabel('Trình độ học vấn'),
                SizedBox(height: AppSizes.p8),
                DropdownButtonFormField<String>(
                  value: _selectedEducationLevel,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.school_outlined,
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                  ),
                  hint: Text(
                    'Chọn trình độ học vấn',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                    ),
                  ),
                  items: _educationLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEducationLevel = value;
                    });
                  },
                ),

                SizedBox(height: AppSizes.p24),

                if (isAdmin) ...[
                  _buildSectionTitle(
                    'Thông tin tài khoản',
                    Icons.account_circle,
                  ),
                  SizedBox(height: AppSizes.p12),

                  _buildTextField(
                    controller: _usernameController,
                    label: 'Tên đăng nhập',
                    hintText: 'Tên đăng nhập',
                    prefixIcon: Icons.account_circle_outlined,
                    enabled: false,
                  ),
                  SizedBox(height: AppSizes.p16),

                  Container(
                    padding: EdgeInsets.all(AppSizes.p12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 20.sp,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                        SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Text(
                            'Đổi mật khẩu',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Switch(
                          value: _changePassword,
                          onChanged: (value) {
                            setState(() {
                              _changePassword = value;
                              if (!value) {
                                _passwordController.clear();
                              }
                            });
                          },
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  if (_changePassword) ...[
                    SizedBox(height: AppSizes.p16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu mới',
                      hintText: 'Nhập mật khẩu mới',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_showPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (_changePassword &&
                            (value == null || value.isEmpty)) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        if (_changePassword &&
                            value != null &&
                            value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        }
                        return null;
                      },
                    ),
                  ],

                  SizedBox(height: AppSizes.p24),
                ],

                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      final isLoading = state is AdminLoading;

                      return ElevatedButton(
                        onPressed: isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontSize: AppSizes.textBase,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: AppSizes.p12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: AppSizes.textLg,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    final theme = Theme.of(context);

    return Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: AppSizes.textSm,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(height: AppSizes.p8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? (isDark ? AppColors.surfaceDark : AppColors.surface)
                : (isDark ? AppColors.neutral800 : AppColors.neutral100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
