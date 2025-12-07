import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/input_validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _avatarUrl;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.neutral900 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Lexend',
          ),
        ),
      ),
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _nameController.text = state.profile.fullName;
            _emailController.text = state.profile.email ?? '';
            _phoneController.text = state.profile.phoneNumber ?? '';
            _addressController.text = state.profile.address ?? '';
            _dateOfBirth = state.profile.dateOfBirth;
            _avatarUrl = state.profile.avatarUrl;
          }

          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật thành công'),
                backgroundColor: AppColors.success,
              ),
            );
            if (context.mounted) {
              Navigator.pop(context);
            }
          }

          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSizes.paddingMedium,
              right: AppSizes.paddingMedium,
              top: AppSizes.paddingMedium,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  AppSizes.paddingMedium,
            ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? Image.file(
                                  _pickedImage!,
                                  width: 120.w,
                                  height: 120.h,
                                  fit: BoxFit.cover,
                                )
                              : (_avatarUrl != null
                                    ? Image.network(
                                        _avatarUrl!,
                                        width: 120.w,
                                        height: 120.h,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 60.sp,
                                                color: AppColors.primary,
                                              );
                                            },
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 60.sp,
                                        color: AppColors.primary,
                                      )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.camera_alt,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                _buildTextField(
                  _nameController,
                  'Họ và tên',
                  Icons.person,
                  isDark,
                  isDesktop,
                  validator: InputValidators.name,
                ),
                SizedBox(height: AppSizes.paddingMedium),
                _buildTextField(
                  _emailController,
                  'Email',
                  Icons.email,
                  isDark,
                  isDesktop,
                  enabled: false,
                  validator: InputValidators.email,
                ),
                SizedBox(height: AppSizes.paddingMedium),
                _buildTextField(
                  _phoneController,
                  'Số điện thoại',
                  Icons.phone,
                  isDark,
                  isDesktop,
                  validator: InputValidators.phone,
                ),
                SizedBox(height: AppSizes.paddingMedium),
                _buildTextField(
                  _addressController,
                  'Địa chỉ',
                  Icons.location_on,
                  isDark,
                  isDesktop,
                  validator: InputValidators.address,
                ),
                SizedBox(height: AppSizes.paddingMedium),
                _buildDateField(isDark, isDesktop),
                SizedBox(height: AppSizes.paddingExtraLarge),

                BlocBuilder<StudentBloc, StudentState>(
                  builder: (context, state) {
                    final isLoading = state is StudentLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 56.h : 48.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
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
                                "Lưu thay đổi",
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: isDesktop ? 18.sp : 16.sp,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isDark,
    bool isDesktop, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textPrimary,
        fontFamily: 'Lexend',
        fontSize: isDesktop ? 18.sp : 16.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Lexend',
          fontSize: isDesktop ? 16.sp : 14.sp,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.primary,
          size: isDesktop ? 28.w : 24.w,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: isDesktop ? 20.h : 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField(bool isDark, bool isDesktop) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _dateOfBirth = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          labelStyle: TextStyle(
            fontFamily: 'Lexend',
            fontSize: isDesktop ? 16.sp : 14.sp,
          ),
          prefixIcon: Icon(
            Icons.cake,
            color: AppColors.primary,
            size: isDesktop ? 28.w : 24.w,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: isDesktop ? 20.h : 16.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
        child: Text(
          _dateOfBirth != null
              ? DateFormatter.formatDate(_dateOfBirth!)
              : "Chọn ngày sinh",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Lexend',
            fontSize: isDesktop ? 18.sp : 16.sp,
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<StudentBloc>().add(
        UpdateProfile(
          _nameController.text,
          _phoneController.text,
          _addressController.text,
          avatarPath: _pickedImage?.path,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }
}
