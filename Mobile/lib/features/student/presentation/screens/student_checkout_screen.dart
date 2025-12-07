import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../bloc/student_checkout_bloc.dart';
import '../bloc/student_checkout_event.dart';
import '../bloc/student_checkout_state.dart';



class StudentCheckoutScreen extends StatefulWidget {
  final List<int> classIds;
  final String? courseName;

  const StudentCheckoutScreen({
    super.key,
    required this.classIds,
    this.courseName,
  });

  @override
  State<StudentCheckoutScreen> createState() => _StudentCheckoutScreenState();
}

class _StudentCheckoutScreenState extends State<StudentCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    
    context.read<StudentCheckoutBloc>().add(
      LoadCartPreview(classIds: widget.classIds),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
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
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<StudentCheckoutBloc, StudentCheckoutState>(
        listener: (context, state) {
          if (state is StudentCheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          if (state is StudentCheckoutOrderCreated) {
            
            Navigator.of(context).pushReplacementNamed(
              '/payment/vnpay',
              arguments: {
                'invoiceId': state.invoiceId,
                'amount': state.totalAmount,
                'paymentUrl': state.paymentUrl,
              },
            );
          }
        },
        builder: (context, state) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  if (widget.courseName != null)
                    _buildSectionCard(
                      title: 'Khóa học',
                      child: Text(
                        widget.courseName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildCartPreviewSection(state, theme, isDark),

                  SizedBox(height: AppSizes.paddingMedium),

                  
                  _buildCheckoutButton(state, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          child,
        ],
      ),
    );
  }

  Widget _buildCartPreviewSection(
    StudentCheckoutState state,
    ThemeData theme,
    bool isDark,
  ) {
    if (state is StudentCheckoutLoading) {
      return _buildSectionCard(
        title: 'Chi tiết thanh toán',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.paddingLarge),
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is StudentCheckoutPreviewLoaded) {
      return _buildSectionCard(
        title: 'Chi tiết thanh toán',
        child: Column(
          children: [
            
            ...state.cartPreview.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.paddingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.className,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            item.courseName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discountAmount > 0)
                          Text(
                            _formatCurrency(item.tuitionFee),
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          _formatCurrency(item.finalAmount),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Divider(height: AppSizes.paddingLarge),

            
            _buildSummaryRow(
              'Tổng học phí:',
              _formatCurrency(state.cartPreview.summary.totalTuitionFee),
              theme,
            ),

            if (state.cartPreview.summary.totalDiscount > 0) ...[
              SizedBox(height: AppSizes.paddingExtraSmall),
              _buildSummaryRow(
                'Giảm giá:',
                '-${_formatCurrency(state.cartPreview.summary.totalDiscount)}',
                theme,
                valueColor: AppColors.success,
              ),
            ],

            SizedBox(height: AppSizes.paddingSmall),
            _buildSummaryRow(
              'Thành tiền:',
              _formatCurrency(state.cartPreview.summary.totalAmount),
              theme,
              isBold: true,
              valueColor: AppColors.primary,
            ),

            
            if (state.cartPreview.summary.hasAnyDiscount) ...[
              SizedBox(height: AppSizes.paddingMedium),
              _buildDiscountBreakdown(state, theme, isDark),
            ],
          ],
        ),
      );
    }

    if (state is StudentCheckoutError) {
      return _buildSectionCard(
        title: 'Chi tiết thanh toán',
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48.sp),
              SizedBox(height: AppSizes.paddingSmall),
              Text(
                'Không thể tải thông tin thanh toán',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppSizes.paddingMedium),
              ElevatedButton(
                onPressed: () {
                  context.read<StudentCheckoutBloc>().add(
                    LoadCartPreview(classIds: widget.classIds),
                  );
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    
    return const SizedBox.shrink();
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountBreakdown(
    StudentCheckoutPreviewLoaded state,
    ThemeData theme,
    bool isDark,
  ) {
    final summary = state.cartPreview.summary;

    return Container(
      padding: EdgeInsets.all(AppSizes.paddingSmall),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, size: 16.sp, color: AppColors.success),
              SizedBox(width: AppSizes.paddingExtraSmall),
              Text(
                'Chi tiết giảm giá',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingExtraSmall),
          if (summary.courseDiscountPercent > 0)
            Text(
              '• Khuyến mãi khóa học: ${summary.courseDiscountPercent}%',
              style: theme.textTheme.bodySmall,
            ),
          if (summary.comboDiscountPercent > 0)
            Text(
              '• Khuyến mãi combo: ${summary.comboDiscountPercent}%',
              style: theme.textTheme.bodySmall,
            ),
          if (summary.returningStudentDiscountPercent > 0)
            Text(
              '• Học viên cũ: ${summary.returningStudentDiscountPercent}%',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(StudentCheckoutState state, bool isDark) {
    final isLoading =
        state is StudentCheckoutLoading ||
        state is StudentCheckoutCreatingOrder;
    final canCheckout = state is StudentCheckoutPreviewLoaded;

    return ElevatedButton(
      onPressed: canCheckout && !isLoading
          ? () {
              context.read<StudentCheckoutBloc>().add(
                CreateOrder(classIds: widget.classIds),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 24.h,
              width: 24.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment),
                SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'Thanh toán với VNPay',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
    );
  }
}
