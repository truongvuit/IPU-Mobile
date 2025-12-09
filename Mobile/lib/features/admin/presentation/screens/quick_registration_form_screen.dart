import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/admin_icon_action.dart';
import '../widgets/simple_admin_app_bar.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

import 'quick_registration_payment_screen.dart';
import 'quick_registration_class_selection_screen.dart';
import 'quick_registration_promotion_screen.dart';
import 'quick_registration_student_selection_screen.dart';

class QuickRegistrationFormScreen extends StatefulWidget {
  const QuickRegistrationFormScreen({super.key});

  @override
  State<QuickRegistrationFormScreen> createState() =>
      _QuickRegistrationFormScreenState();
}

class _QuickRegistrationFormScreenState
    extends State<QuickRegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(const InitializeRegistration());

    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _phoneController.removeListener(_onFormChanged);
    _notesController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToStudentSelection() {
    final bloc = context.read<RegistrationBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const QuickRegistrationStudentSelectionScreen(),
        ),
      ),
    );
  }

  void _navigateToClassSelection() {
    final bloc = context.read<RegistrationBloc>();
    final state = bloc.state;
    if (state is RegistrationInProgress && state.isNewStudent) {
      bloc.add(
        UpdateStudentInfo(
          studentName: _nameController.text,
          phoneNumber: _phoneController.text,
          email: _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const QuickRegistrationClassSelectionScreen(),
        ),
      ),
    );
  }

  void _navigateToPromotion() {
    final bloc = context.read<RegistrationBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const QuickRegistrationPromotionScreen(),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  void _switchToNewStudent() {
    context.read<RegistrationBloc>().add(const SwitchStudentMode(true));
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
  }

  void _switchToExistingStudent() {
    context.read<RegistrationBloc>().add(const SwitchStudentMode(false));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: const SimpleAdminAppBar(title: 'Đăng ký nhanh'),
      body: BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          RegistrationInProgress? regState;
          if (state is RegistrationInProgress) {
            regState = state;
          } else if (state is ClassesLoaded) {
            regState = state.currentRegistration;
          }

          if (regState?.cartPreviewError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(regState!.cartPreviewError!)),
                  ],
                ),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 4),
              ),
            );

            context.read<RegistrationBloc>().add(const ClearCartPreviewError());
          }
        },
        builder: (context, state) {
          RegistrationInProgress? regState;
          if (state is RegistrationInProgress) {
            regState = state;
          } else if (state is ClassesLoaded) {
            regState = state.currentRegistration;
          } else if (state is PromotionsLoaded) {
            regState = state.currentRegistration;
          }

          if (regState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStudentModeToggle(regState, isDark),
                    SizedBox(height: AppSizes.p20),

                    if (regState.isNewStudent)
                      _buildNewStudentForm(isDark)
                    else
                      _buildExistingStudentSelector(regState, isDark),

                    SizedBox(height: AppSizes.p20),

                    _buildSectionTitle('Chọn khóa học/lớp học'),
                    SizedBox(height: AppSizes.p12),

                    if (regState.selectedClasses.isNotEmpty) ...[
                      ...regState.selectedClasses.map(
                        (classInfo) => Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(AppSizes.p12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      classInfo.className,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (classInfo.courseName != null) ...[
                                      SizedBox(height: 2.h),
                                      Text(
                                        classInfo.courseName!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.neutral400
                                                  : AppColors.neutral600,
                                            ),
                                      ),
                                    ],
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatCurrency(classInfo.tuitionFee),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AdminIconAction(
                                icon: Icons.close,
                                iconColor: AppColors.error,
                                iconSize: 20.sp,
                                onTap: () {
                                  context.read<RegistrationBloc>().add(
                                    RemoveClass(classInfo.classId),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],

                    InkWell(
                      onTap: _navigateToClassSelection,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.paddingMedium),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                          border: Border.all(
                            color: regState.selectedClasses.isNotEmpty
                                ? (isDark
                                      ? AppColors.neutral700
                                      : AppColors.neutral200)
                                : AppColors.primary.withValues(alpha: 0.5),
                            style: regState.selectedClasses.isNotEmpty
                                ? BorderStyle.solid
                                : BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              regState.selectedClasses.isNotEmpty
                                  ? Icons.add_circle_outline
                                  : Icons.search,
                              color: regState.selectedClasses.isNotEmpty
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.neutral400
                                        : AppColors.neutral600),
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              regState.selectedClasses.isNotEmpty
                                  ? 'Thêm lớp học khác'
                                  : 'Tìm kiếm lớp học/khóa học',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: regState.selectedClasses.isNotEmpty
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.neutral400
                                          : AppColors.neutral600),
                                fontWeight: regState.selectedClasses.isNotEmpty
                                    ? FontWeight.w600
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.p20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Thông tin thanh toán'),
                        if (regState.hasAutoPromotions &&
                            regState.cartPreview != null)
                          TextButton.icon(
                            onPressed: () =>
                                _showPromotionBreakdownModal(regState!),
                            icon: Icon(
                              Icons.receipt_long,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              'Chi tiết',
                              style: TextStyle(
                                fontSize: AppSizes.textSm,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.p8,
                                vertical: AppSizes.p4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSizes.p12),

                    _buildEnhancedPaymentSection(regState, isDark),
                    SizedBox(height: AppSizes.paddingMedium),

                    if (regState.hasAutoPromotions)
                      _buildAppliedPromotionsChips(regState, isDark),

                    if (!regState.hasAutoPromotions)
                      InkWell(
                        onTap: _navigateToPromotion,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMedium,
                            vertical: AppSizes.p12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            border: Border.all(
                              color: regState.promotionCode != null
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.neutral700
                                        : AppColors.neutral200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: regState.promotionCode != null
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.neutral400
                                          : AppColors.neutral600),
                                size: 20.sp,
                              ),
                              SizedBox(width: AppSizes.p12),
                              Expanded(
                                child: Text(
                                  regState.promotionCode != null
                                      ? 'Đã áp dụng: ${regState.promotionCode}'
                                      : 'Chọn hoặc nhập mã khuyến mãi',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: regState.promotionCode != null
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.neutral400
                                              : AppColors.neutral600),
                                    fontWeight: regState.promotionCode != null
                                        ? FontWeight.w600
                                        : null,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: AppSizes.textBase,
                                color: isDark
                                    ? AppColors.neutral400
                                    : AppColors.neutral600,
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: AppSizes.p20),

                    // Payment method selection removed - it's in PaymentScreen
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canProceedToPayment(regState)
                            ? () {
                                if (regState!.isNewStudent &&
                                    !(_formKey.currentState?.validate() ??
                                        false)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng kiểm tra lại thông tin',
                                      ),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                  return;
                                }

                                final bloc = context.read<RegistrationBloc>();

                                if (regState.isNewStudent) {
                                  bloc.add(
                                    UpdateStudentInfo(
                                      studentName: _nameController.text.trim(),
                                      phoneNumber: _phoneController.text.trim(),
                                      email:
                                          _emailController.text
                                              .trim()
                                              .isNotEmpty
                                          ? _emailController.text.trim()
                                          : null,
                                    ),
                                  );
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: bloc,
                                      child:
                                          const QuickRegistrationPaymentScreen(),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: AppSizes.textBase,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _canProceedToPayment(RegistrationInProgress state) {
    if (state.selectedClasses.isEmpty) return false;

    if (state.isNewStudent) {
      return _nameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty;
    } else {
      return state.studentId != null;
    }
  }

  Widget _buildStudentModeToggle(RegistrationInProgress state, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _switchToNewStudent,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: state.isNewStudent
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 18.sp,
                      color: state.isNewStudent
                          ? Colors.white
                          : AppColors.neutral500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Học viên mới',
                      style: TextStyle(
                        color: state.isNewStudent
                            ? Colors.white
                            : AppColors.neutral600,
                        fontWeight: state.isNewStudent
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _switchToExistingStudent,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !state.isNewStudent
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_search,
                      size: 18.sp,
                      color: !state.isNewStudent
                          ? Colors.white
                          : AppColors.neutral500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Học viên cũ',
                      style: TextStyle(
                        color: !state.isNewStudent
                            ? Colors.white
                            : AppColors.neutral600,
                        fontWeight: !state.isNewStudent
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewStudentForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin học viên mới'),
        SizedBox(height: AppSizes.p12),

        _buildTextField(
          controller: _nameController,
          label: 'Họ và tên *',
          hintText: 'Nhập họ và tên học viên',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (value.length < 2) {
              return 'Họ tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.p12),

        _buildTextField(
          controller: _phoneController,
          label: 'Số điện thoại *',
          hintText: 'Nhập số điện thoại',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }

            final phoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');
            final cleanPhone = value.replaceAll(RegExp(r'[\s\-\.]'), '');
            if (!phoneRegex.hasMatch(cleanPhone)) {
              return 'Số điện thoại không hợp lệ (VD: 0912345678)';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.p12),

        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'Nhập email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );
              if (!emailRegex.hasMatch(value)) {
                return 'Email không hợp lệ';
              }
            }
            return null;
          },
        ),

        SizedBox(height: AppSizes.p8),
        Container(
          padding: EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16.sp, color: AppColors.info),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Hệ thống sẽ tự tạo tài khoản cho học viên với mật khẩu mặc định: 123456',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingStudentSelector(
    RegistrationInProgress state,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chọn học viên'),
        SizedBox(height: AppSizes.p12),

        InkWell(
          onTap: _navigateToStudentSelection,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: state.studentId != null
                    ? AppColors.primary
                    : (isDark ? AppColors.neutral700 : AppColors.neutral200),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: state.studentId != null
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : (isDark ? AppColors.neutral600 : AppColors.neutral200),
                  child: Icon(
                    state.studentId != null
                        ? Icons.person
                        : Icons.person_search,
                    color: state.studentId != null
                        ? AppColors.primary
                        : AppColors.neutral500,
                  ),
                ),
                SizedBox(width: AppSizes.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.studentName ?? 'Tìm kiếm và chọn học viên',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: state.studentName != null
                              ? null
                              : (isDark
                                    ? AppColors.neutral400
                                    : AppColors.neutral600),
                          fontWeight: state.studentName != null
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                      if (state.studentName != null &&
                          state.phoneNumber != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'SĐT: ${state.phoneNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.textBase,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPromotionBreakdownModal(RegistrationInProgress state) {
    if (state.cartPreview == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartPreview = state.cartPreview!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: AppSizes.p12),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                  SizedBox(width: AppSizes.p12),
                  Text(
                    'Chi tiết khuyến mãi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...cartPreview.items.map(
                      (item) => _buildItemBreakdown(item, isDark),
                    ),

                    if (cartPreview.items.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                        child: Divider(),
                      ),

                    _buildSummarySection(cartPreview.summary, isDark),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBreakdown(dynamic item, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.courseName ?? 'Khóa học',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.className != null)
            Text(
              item.className!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          SizedBox(height: AppSizes.p8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Học phí gốc', style: theme.textTheme.bodySmall),
              Text(
                _formatCurrency(item.tuitionFee?.toDouble() ?? 0),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),

          if ((item.singleCourseDiscountPercent ?? 0) > 0) ...[
            SizedBox(height: AppSizes.p4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🏷️ Giảm giá khóa lẻ (-${item.singleCourseDiscountPercent}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '-${_formatCurrency(item.singleCourseDiscountAmount?.toDouble() ?? 0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: AppSizes.p4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tiền',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatCurrency(
                  item.priceAfterSingleDiscount?.toDouble() ??
                      item.tuitionFee?.toDouble() ??
                      0,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(dynamic summary, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng kết',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.p12),

        _buildSummaryRow(
          'Tổng học phí gốc',
          summary.totalTuitionFee?.toDouble() ?? 0,
        ),

        if ((summary.totalSingleCourseDiscount ?? 0) > 0)
          _buildSummaryRow(
            '🏷️ Giảm giá khóa lẻ',
            -(summary.totalSingleCourseDiscount?.toDouble() ?? 0),
            color: AppColors.success,
          ),

        if ((summary.totalComboDiscount ?? 0) > 0) ...[
          ...((summary.appliedCombos as List?)?.map(
                (combo) => _buildSummaryRow(
                  '🎁 ${combo.comboName ?? 'Combo'} (-${combo.discountPercent ?? 0}%)',
                  -(combo.discountAmount?.toDouble() ?? 0),
                  color: AppColors.success,
                ),
              ) ??
              []),
        ],

        if ((summary.returningDiscountAmount ?? 0) > 0)
          _buildSummaryRow(
            '🎉 Ưu đãi học viên cũ',
            -(summary.returningDiscountAmount?.toDouble() ?? 0),
            color: AppColors.success,
          ),

        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
          child: Divider(),
        ),

        if ((summary.totalDiscountAmount ?? 0) > 0)
          _buildSummaryRow(
            'Tổng giảm giá',
            -(summary.totalDiscountAmount?.toDouble() ?? 0),
            color: AppColors.success,
            isBold: true,
          ),

        SizedBox(height: AppSizes.p8),

        Container(
          padding: EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                _formatCurrency(summary.finalAmount?.toDouble() ?? 0),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    Color? color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.p4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w600 : null,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: AppSizes.textBase,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.textSm,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
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
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildEnhancedPaymentSection(
    RegistrationInProgress state,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            'Học phí gốc',
            state.hasSingleCourseDiscount
                ? state.totalTuitionFee
                : state.tuitionFee,
          ),

          if (state.hasSingleCourseDiscount) ...[
            SizedBox(height: AppSizes.p8),
            _buildPaymentRow(
              '🏷️ Giảm giá khóa lẻ',
              -state.singleCourseDiscountAmount,
              color: AppColors.success,
            ),
          ],

          if (state.appliedCombos.isNotEmpty) ...[
            SizedBox(height: AppSizes.p8),
            ...state.appliedCombos.map(
              (combo) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.p4),
                child: _buildPaymentRow(
                  '🎁 ${combo.comboName} (-${combo.discountPercent}%)',
                  -combo.discountAmount,
                  color: AppColors.success,
                ),
              ),
            ),
          ],

          if (state.returningDiscountAmount > 0) ...[
            SizedBox(height: AppSizes.p4),
            _buildPaymentRow(
              '🎉 Ưu đãi học viên cũ',
              -state.returningDiscountAmount,
              color: AppColors.success,
            ),
          ],

          if (state.totalDiscount > 0 &&
              !state.hasSingleCourseDiscount &&
              state.appliedCombos.isEmpty &&
              state.returningDiscountAmount == 0) ...[
            SizedBox(height: AppSizes.p8),
            _buildPaymentRow(
              'Giảm giá',
              -state.totalDiscount,
              color: AppColors.error,
            ),
          ],

          if (state.isCalculatingPreview)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.sp,
                    height: 16.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSizes.p8),
                  Text(
                    'Đang tính khuyến mãi...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),

          Divider(height: AppSizes.p20),

          _buildPaymentRow('Tổng thanh toán', state.totalAmount, isTotal: true),

          if (state.totalDiscount > 0)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.p8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p12,
                  vertical: AppSizes.p8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppSizes.p8),
                    Text(
                      'Bạn tiết kiệm ${_formatCurrency(state.totalDiscount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppliedPromotionsChips(
    RegistrationInProgress state,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16.sp, color: AppColors.success),
              SizedBox(width: AppSizes.p8),
              Text(
                'Khuyến mãi tự động áp dụng',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.p8),
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            children: [
              if (state.hasSingleCourseDiscount)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p12,
                    vertical: AppSizes.p8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sell, size: 14.sp, color: AppColors.info),
                      SizedBox(width: AppSizes.p4),
                      Text(
                        'Giảm giá khóa lẻ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              ...state.appliedCombos.map(
                (combo) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p12,
                    vertical: AppSizes.p8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.p4),
                      Flexible(
                        child: Text(
                          '${combo.comboName} (-${combo.discountPercent}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.returningDiscountAmount > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p12,
                    vertical: AppSizes.p8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14.sp, color: AppColors.success),
                      SizedBox(width: AppSizes.p4),
                      Text(
                        'Học viên cũ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    double amount, {
    Color? color,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : null,
            fontSize: isTotal ? AppSizes.textBase : AppSizes.textSm,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color ?? (isTotal ? AppColors.primary : null),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? AppSizes.textXl : AppSizes.textSm,
          ),
        ),
      ],
    );
  }
}
