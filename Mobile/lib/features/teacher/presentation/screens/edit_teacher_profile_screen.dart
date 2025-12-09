import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/custom_image.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../widgets/teacher_app_bar.dart';
import '../../domain/entities/teacher_profile.dart';

class EditTeacherProfileScreen extends StatefulWidget {
  const EditTeacherProfileScreen({super.key});

  @override
  State<EditTeacherProfileScreen> createState() =>
      _EditTeacherProfileScreenState();
}

class _EditTeacherProfileScreenState extends State<EditTeacherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _specializationController;
  DateTime? _selectedDate;
  String? _selectedGender;
  TeacherProfile? _currentProfile;
  Uint8List? _selectedImageBytes;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _specializationController = TextEditingController();
    context.read<TeacherBloc>().add(LoadTeacherProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  void _loadProfileData(TeacherProfile profile) {
    if (_currentProfile != null) return;

    _currentProfile = profile;
    _nameController.text = profile.fullName;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _addressController.text = profile.address ?? '';
    _specializationController.text = profile.specialization ?? '';
    _selectedDate = profile.dateOfBirth;
    _selectedGender = profile.gender;
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _currentProfile != null) {
      final updatedProfile = _currentProfile!.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        specialization: _specializationController.text.trim().isEmpty
            ? null
            : _specializationController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
      );

      context.read<TeacherBloc>().add(UpdateTeacherProfile(updatedProfile));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          TeacherAppBar(title: 'Chỉnh sửa hồ sơ', showBackButton: true),
          Expanded(
            child: BlocConsumer<TeacherBloc, TeacherState>(
              listener: (context, state) {
                if (state is ProfileUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: AppSizes.p12),
                          Expanded(child: Text(state.message)),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                }
                if (state is TeacherError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                if (state is ProfileLoaded) {
                  _loadProfileData(state.profile);
                }
              },
              builder: (context, state) {
                if (state is TeacherLoading && _currentProfile == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is TeacherError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        isDesktop ? AppSizes.p32 : AppSizes.p24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isDesktop ? 64.sp : 48.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: AppSizes.p16),
                          Text(
                            state.message,
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? AppSizes.textLg
                                  : AppSizes.textBase,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSizes.p16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<TeacherBloc>().add(
                                LoadTeacherProfile(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? AppSizes.p32 : AppSizes.paddingMedium,
                      AppSizes.paddingMedium,
                      isDesktop ? AppSizes.p32 : AppSizes.paddingMedium,
                      AppSizes.paddingMedium + keyboardInset,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 600 : double.infinity,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAvatarSection(isDark, isDesktop),
                              SizedBox(height: AppSizes.p32),

                              _buildSectionHeader(
                                'Thông tin cơ bản',
                                Icons.person_outline,
                                isDark,
                                isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              _buildTextField(
                                controller: _nameController,
                                label: 'Họ và tên',
                                icon: Icons.badge_outlined,
                                required: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập họ tên';
                                  }
                                  return null;
                                },
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              InkWell(
                                onTap: () => _selectDate(context),
                                child: InputDecorator(
                                  decoration: _inputDecoration(
                                    'Ngày sinh',
                                    Icons.cake_outlined,
                                    isDark,
                                    isDesktop,
                                  ),
                                  child: Text(
                                    _selectedDate != null
                                        ? dateFormat.format(_selectedDate!)
                                        : 'Chọn ngày sinh',
                                    style: TextStyle(
                                      fontSize: isDesktop
                                          ? AppSizes.textBase
                                          : AppSizes.textSm,
                                      color: _selectedDate != null
                                          ? (isDark
                                                ? Colors.white
                                                : AppColors.textPrimary)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSizes.p16),

                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? AppSizes.textBase
                                      : AppSizes.textSm,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                                decoration: _inputDecoration(
                                  'Giới tính',
                                  Icons.wc_outlined,
                                  isDark,
                                  isDesktop,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Nam',
                                    child: Text('Nam'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Nữ',
                                    child: Text('Nữ'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Khác',
                                    child: Text('Khác'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedGender = value);
                                },
                              ),
                              SizedBox(height: AppSizes.p24),

                              _buildSectionHeader(
                                'Thông tin liên hệ',
                                Icons.contact_phone_outlined,
                                isDark,
                                isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              _buildTextField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: InputValidators.email,
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              _buildTextField(
                                controller: _phoneController,
                                label: 'Số điện thoại',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: InputValidators.phone,
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              _buildTextField(
                                controller: _addressController,
                                label: 'Địa chỉ',
                                icon: Icons.location_on_outlined,
                                maxLines: 2,
                                validator: InputValidators.address,
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                              SizedBox(height: AppSizes.p24),

                              _buildSectionHeader(
                                'Thông tin chuyên môn',
                                Icons.workspace_premium_outlined,
                                isDark,
                                isDesktop,
                              ),
                              SizedBox(height: AppSizes.p16),

                              _buildTextField(
                                controller: _specializationController,
                                label: 'Chuyên môn',
                                icon: Icons.school_outlined,
                                hint: 'VD: IELTS, TOEIC, Giao tiếp',
                                isDark: isDark,
                                isDesktop: isDesktop,
                              ),
                              SizedBox(height: AppSizes.p32),

                              BlocBuilder<TeacherBloc, TeacherState>(
                                builder: (context, btnState) {
                                  final isLoading = btnState is TeacherLoading;
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: isDesktop
                                              ? AppSizes.p20
                                              : AppSizes.p16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusMedium,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                              height: isDesktop ? 24.h : 20.h,
                                              width: isDesktop ? 24.h : 20.h,
                                              child:
                                                  const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.save_outlined),
                                                SizedBox(width: AppSizes.p8),
                                                Text(
                                                  'Lưu thay đổi',
                                                  style: TextStyle(
                                                    fontSize: isDesktop
                                                        ? AppSizes.textLg
                                                        : AppSizes.textBase,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark, bool isDesktop) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: isDesktop ? 140.w : 120.w,
            height: isDesktop ? 140.w : 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImageBytes != null
                  ? Image.memory(
                      _selectedImageBytes!,
                      width: isDesktop ? 140.w : 120.w,
                      height: isDesktop ? 140.w : 120.w,
                      fit: BoxFit.cover,
                    )
                  : CustomImage(
                      imageUrl: _currentProfile?.avatarUrl ?? '',
                      width: isDesktop ? 140.w : 120.w,
                      height: isDesktop ? 140.w : 120.w,
                      fit: BoxFit.cover,
                      isAvatar: true,
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(isDesktop ? AppSizes.p12 : AppSizes.p8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.neutral800 : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: isDesktop ? 24.sp : 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    bool isDark,
    bool isDesktop,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.p8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: isDesktop ? 20.sp : 18.sp,
          ),
        ),
        SizedBox(width: AppSizes.p12),
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required bool isDesktop,
    bool required = false,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: isDesktop ? AppSizes.textBase : AppSizes.textSm,
      ),
      decoration: _inputDecoration(
        '$label${required ? ' *' : ''}',
        icon,
        isDark,
        isDesktop,
        hint: hint,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    bool isDark,
    bool isDesktop, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
      ),
      hintStyle: TextStyle(
        fontSize: isDesktop ? AppSizes.textSm : AppSizes.textXs,
        color: AppColors.textSecondary,
      ),
      prefixIcon: Icon(icon, size: isDesktop ? 24.sp : 20.sp),
      filled: true,
      fillColor: isDark
          ? AppColors.neutral900.withValues(alpha: 0.5)
          : AppColors.backgroundAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(
          color: isDark ? AppColors.neutral700 : AppColors.divider,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(
          color: isDark ? AppColors.neutral700 : AppColors.divider,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppSizes.p16 : AppSizes.p12,
        horizontal: AppSizes.p16,
      ),
    );
  }
}
