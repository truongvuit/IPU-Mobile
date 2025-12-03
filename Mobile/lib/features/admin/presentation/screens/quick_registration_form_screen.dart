import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../../domain/entities/quick_registration.dart';
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
      appBar: AppBar(title: const Text('Đăng ký nhanh')),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                                                ? AppColors.gray400
                                                : AppColors.gray600,
                                          ),
                                    ),
                                  ],
                                  SizedBox(height: 4.h),
                                  Text(
                                    _formatCurrency(classInfo.tuitionFee),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<RegistrationBloc>().add(
                                  RemoveClass(classInfo.classId),
                                );
                              },
                              icon: Icon(
                                Icons.close,
                                color: AppColors.error,
                                size: 20.sp,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],

                  
                  InkWell(
                    onTap: _navigateToClassSelection,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                              ? (isDark ? AppColors.gray700 : AppColors.gray200)
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
                                      ? AppColors.gray400
                                      : AppColors.gray600),
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
                                        ? AppColors.gray400
                                        : AppColors.gray600),
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

                  
                  _buildSectionTitle('Thông tin thanh toán'),
                  SizedBox(height: AppSizes.p12),

                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingMedium),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentRow('Học phí', regState.tuitionFee),
                        SizedBox(height: AppSizes.p8),
                        _buildPaymentRow(
                          'Giảm giá',
                          -regState.discount,
                          color: AppColors.error,
                        ),
                        Divider(height: AppSizes.p20),
                        _buildPaymentRow(
                          'Tổng cộng',
                          regState.totalAmount,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),

                  
                  InkWell(
                    onTap: _navigateToPromotion,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
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
                                    ? AppColors.gray700
                                    : AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: regState.promotionCode != null
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600),
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
                                          ? AppColors.gray400
                                          : AppColors.gray600),
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
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.p20),

                  
                  _buildSectionTitle('Phương thức thanh toán'),
                  SizedBox(height: AppSizes.p12),

                  _buildPaymentMethodSelector(regState, isDark),

                  SizedBox(height: 32.h),

                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceedToPayment(regState)
                          ? () {
                              final bloc = context.read<RegistrationBloc>();

                              
                              if (regState?.isNewStudent == true) {
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
        color: isDark ? AppColors.surfaceDark : AppColors.gray100,
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
                          : AppColors.gray500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Học viên mới',
                      style: TextStyle(
                        color: state.isNewStudent
                            ? Colors.white
                            : AppColors.gray600,
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
                          : AppColors.gray500,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Học viên cũ',
                      style: TextStyle(
                        color: !state.isNewStudent
                            ? Colors.white
                            : AppColors.gray600,
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
            return null;
          },
        ),
        SizedBox(height: AppSizes.p12),

        _buildTextField(
          controller: _emailController,
          label: 'Email (không bắt buộc)',
          hintText: 'Nhập email',
          keyboardType: TextInputType.emailAddress,
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
                    : (isDark ? AppColors.gray700 : AppColors.gray200),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: state.studentId != null
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : (isDark ? AppColors.gray600 : AppColors.gray200),
                  child: Icon(
                    state.studentId != null
                        ? Icons.person
                        : Icons.person_search,
                    color: state.studentId != null
                        ? AppColors.primary
                        : AppColors.gray500,
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
                                    ? AppColors.gray400
                                    : AppColors.gray600),
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
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSizes.textBase,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ],
            ),
          ),
        ),
      ],
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
                color: isDark ? AppColors.gray700 : AppColors.gray200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              borderSide: BorderSide(
                color: isDark ? AppColors.gray700 : AppColors.gray200,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(
    RegistrationInProgress state,
    bool isDark,
  ) {
    final methods = [
      (PaymentMethod.cash, Icons.money, 'Tiền mặt'),
      (PaymentMethod.transfer, Icons.account_balance, 'Chuyển khoản'),
      (PaymentMethod.card, Icons.credit_card, 'Quẹt thẻ'),
    ];

    return Row(
      children: methods.map((item) {
        final (method, icon, label) = item;
        final isSelected = state.paymentMethod == method;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: InkWell(
              onTap: () {
                context.read<RegistrationBloc>().add(
                  UpdatePaymentMethod(method),
                );
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.gray700 : AppColors.gray200),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 24.sp,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.gray400 : AppColors.gray600),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.gray400 : AppColors.gray600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
