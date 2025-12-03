import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

import '../../domain/entities/quick_registration.dart';

class QuickRegistrationPaymentScreen extends StatefulWidget {
  const QuickRegistrationPaymentScreen({super.key});

  @override
  State<QuickRegistrationPaymentScreen> createState() =>
      _QuickRegistrationPaymentScreenState();
}

class _QuickRegistrationPaymentScreenState
    extends State<QuickRegistrationPaymentScreen> {
  final _notesController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _paymentConfirmed = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<RegistrationBloc>().state;
    if (state is RegistrationInProgress) {
      _selectedPaymentMethod = state.paymentMethod;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  void _submitRegistration() {
    context.read<RegistrationBloc>().add(
      UpdatePaymentMethod(_selectedPaymentMethod),
    );

    if (_notesController.text.isNotEmpty) {
      context.read<RegistrationBloc>().add(UpdateNotes(_notesController.text));
    }

    context.read<RegistrationBloc>().add(const SubmitRegistration());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Xác nhận Thanh toán')),
      body: BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RegistrationSubmitted) {
            _showSuccessDialog(state.registration);
          }
        },
        builder: (context, state) {
          
          RegistrationInProgress? registrationData;
          
          if (state is RegistrationInProgress) {
            registrationData = state;
          } else if (state is ClassesLoaded) {
            registrationData = state.currentRegistration;
          } else if (state is PromotionsLoaded) {
            registrationData = state.currentRegistration;
          }

          final isSubmitting = state is RegistrationSubmitting;

          
          if (isSubmitting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 16.h),
                  Text(
                    'Đang xử lý đăng ký...',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          
          if (registrationData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(AppSizes.p24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Số tiền thanh toán',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: AppSizes.textBase,
                              ),
                            ),
                            SizedBox(height: AppSizes.p12),
                            Text(
                              _formatCurrency(registrationData.totalAmount),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36, 
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSizes.p20),

                      
                      Text(
                        'Phương thức thanh toán',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.textBase,
                        ),
                      ),
                      SizedBox(height: AppSizes.p12),

                      _buildPaymentMethodCard(
                        icon: Icons.money,
                        label: 'Tiền mặt',
                        method: PaymentMethod.cash,
                        isDark: isDark,
                      ),
                      SizedBox(height: AppSizes.p8),

                      _buildPaymentMethodCard(
                        icon: Icons.account_balance,
                        label: 'Chuyển khoản',
                        method: PaymentMethod.transfer,
                        isDark: isDark,
                      ),
                      SizedBox(height: AppSizes.p8),

                      _buildPaymentMethodCard(
                        icon: Icons.credit_card,
                        label: 'Quét thẻ',
                        method: PaymentMethod.card,
                        isDark: isDark,
                      ),

                      SizedBox(height: AppSizes.p20),

                      
                      Text(
                        'Ghi chú (không bắt buộc)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.textBase,
                        ),
                      ),
                      SizedBox(height: AppSizes.p8),

                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Thêm ghi chú cho giao dịch này...',
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
                                  ? AppColors.gray700
                                  : AppColors.gray200,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),

                      SizedBox(height: AppSizes.p16),

                      
                      Container(
                        padding: EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: _paymentConfirmed
                              ? AppColors.success.withValues(alpha: 0.1)
                              : (isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.surface),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                          border: Border.all(
                            color: _paymentConfirmed
                                ? AppColors.success
                                : (isDark
                                      ? AppColors.gray700
                                      : AppColors.gray200),
                            width: _paymentConfirmed ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _paymentConfirmed = !_paymentConfirmed;
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  color: _paymentConfirmed
                                      ? AppColors.success
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: _paymentConfirmed
                                        ? AppColors.success
                                        : AppColors.gray400,
                                    width: 2,
                                  ),
                                ),
                                child: _paymentConfirmed
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16.sp,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Xác nhận đã thu tiền',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _paymentConfirmed
                                            ? AppColors.success
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Tôi xác nhận đã nhận đủ ${_formatCurrency(registrationData.totalAmount)} từ học viên',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: isDark
                                            ? AppColors.gray400
                                            : AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: AppSizes.p16),

                      
                      Container(
                        padding: EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin đăng ký',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: AppSizes.p8),
                            _buildInfoRow(
                              'Học viên',
                              registrationData.studentName ?? '-',
                            ),
                            
                            if (registrationData
                                .selectedClasses
                                .isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.p8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 70.w,
                                      child: Text(
                                        'Lớp học',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontSize: AppSizes.textSm,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: registrationData
                                            .selectedClasses
                                            .map((classInfo) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 4.h,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        classInfo.className,
                                                        style: theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: AppSizes
                                                                  .textSm,
                                                            ),
                                                        textAlign:
                                                            TextAlign.right,
                                                        softWrap: true,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      _formatCurrency(
                                                        classInfo.tuitionFee,
                                                      ),
                                                      style: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .primary,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildInfoRow(
                                'Tổng học phí',
                                _formatCurrency(registrationData.tuitionFee),
                              ),
                            ] else ...[
                              _buildInfoRow(
                                'Lớp học',
                                registrationData.className ?? '-',
                              ),
                              _buildInfoRow(
                                'Học phí',
                                _formatCurrency(registrationData.tuitionFee),
                              ),
                            ],
                            if (registrationData.discount > 0) ...[
                              _buildInfoRow(
                                'Giảm giá',
                                '-${_formatCurrency(registrationData.discount)}',
                                valueColor: AppColors.error,
                              ),
                              if (registrationData.promotionCode != null)
                                _buildInfoRow(
                                  'Mã KM',
                                  registrationData.promotionCode!,
                                  valueColor: AppColors.primary,
                                ),
                            ],
                            Divider(height: AppSizes.p16),
                            _buildInfoRow(
                              'Tổng tiền',
                              _formatCurrency(registrationData.totalAmount),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 80.h),
                    ],
                  ),
                ),

                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium,
                      vertical: AppSizes.p12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (isSubmitting || !_paymentConfirmed)
                          ? null
                          : _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _paymentConfirmed
                            ? AppColors.success
                            : AppColors.gray400,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _paymentConfirmed
                                      ? Icons.check_circle
                                      : Icons.warning_amber,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _paymentConfirmed
                                      ? 'Hoàn tất đăng ký'
                                      : 'Vui lòng xác nhận đã thu tiền',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
        },
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String label,
    required PaymentMethod method,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.gray700 : AppColors.gray200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            
            Container(
              width: AppSizes.p24,
              height: AppSizes.p24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.gray400,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: AppSizes.textBase,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: AppSizes.paddingMedium),

            
            Container(
              padding: EdgeInsets.all(AppSizes.p8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (isDark ? AppColors.gray700 : AppColors.gray100),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.gray600,
                size: AppSizes.iconMedium,
              ),
            ),
            SizedBox(width: AppSizes.p12),

            
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: AppSizes.textSm,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : null,
                fontSize: isTotal ? AppSizes.textSm : AppSizes.textSm,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? (isTotal ? AppColors.primary : null),
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? AppSizes.textBase : AppSizes.textSm,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(QuickRegistration registration) {
    
    final classNames = registration.className.split(', ');
    final isMultiClass = classNames.length > 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 64),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Đăng ký thành công!',
              style: TextStyle(
                fontSize: AppSizes.textXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.p12),
            Text(
              isMultiClass
                  ? 'Học viên ${registration.studentName} đã được đăng ký vào ${classNames.length} lớp học'
                  : 'Học viên ${registration.studentName} đã được đăng ký vào lớp ${registration.className}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.textSm),
            ),
            if (isMultiClass) ...[
              SizedBox(height: AppSizes.p8),
              Container(
                constraints: BoxConstraints(maxHeight: 100.h),
                child: SingleChildScrollView(
                  child: Column(
                    children: classNames
                        .map(
                          (name) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 14.sp,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(fontSize: AppSizes.textSm),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
            SizedBox(height: AppSizes.p24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSizes.p12),
                ),
                child: const Text(
                  'Hoàn tất',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
