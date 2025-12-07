import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/vnpay_models.dart';





class VNPayResultScreen extends StatelessWidget {
  final VNPayPaymentResult result;

  const VNPayResultScreen({
    super.key,
    required this.result,
  });

  String _formatCurrency(String? amountStr) {
    if (amountStr == null) return '--';
    final amount = int.tryParse(amountStr) ?? 0;
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _navigateToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: result.isSuccess
                        ? _buildSuccessContent(context, theme, isDark)
                        : _buildFailureContent(context, theme, isDark),
                  ),
                ),
                _buildBottomButtons(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 64.sp,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: AppSizes.p24),
          
          
          Text(
            'Thanh toán thành công!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            result.message ?? 'Giao dịch của bạn đã được xử lý thành công',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: AppSizes.p32),
          
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Mã hóa đơn',
                  '#${result.invoiceId ?? '--'}',
                  theme,
                ),
                Divider(height: AppSizes.p24),
                _buildDetailRow(
                  'Mã giao dịch',
                  result.transactionNo ?? '--',
                  theme,
                ),
                Divider(height: AppSizes.p24),
                _buildDetailRow(
                  'Số tiền',
                  _formatCurrency(result.amount),
                  theme,
                  valueColor: AppColors.success,
                  isBold: true,
                ),
                if (result.responseCode != null) ...[
                  Divider(height: AppSizes.p24),
                  _buildDetailRow(
                    'Mã phản hồi',
                    result.responseCode!,
                    theme,
                    valueColor: AppColors.neutral500,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error,
              size: 64.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppSizes.p24),
          
          
          Text(
            'Thanh toán thất bại',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            result.error ?? result.message ?? 'Đã có lỗi xảy ra trong quá trình thanh toán',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (result.error != null && result.message != null) ...[
            SizedBox(height: AppSizes.p4),
            Text(
              result.message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          SizedBox(height: AppSizes.p32),
          
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                if (result.invoiceId != null) ...[
                  _buildDetailRow(
                    'Mã hóa đơn',
                    '#${result.invoiceId}',
                    theme,
                  ),
                  Divider(height: AppSizes.p24),
                ],
                if (result.responseCode != null)
                  _buildDetailRow(
                    'Mã lỗi',
                    result.responseCode!,
                    theme,
                    valueColor: AppColors.error,
                  ),
              ],
            ),
          ),
          
          SizedBox(height: AppSizes.p16),
          
          
          Container(
            padding: EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 20.sp,
                ),
                SizedBox(width: AppSizes.p8),
                Expanded(
                  child: Text(
                    'Nếu số tiền đã bị trừ, vui lòng liên hệ bộ phận hỗ trợ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToHome(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: result.isSuccess ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
            ),
            child: Text(
              result.isSuccess ? 'Hoàn tất' : 'Về trang chủ',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        
        if (result.isFailed) ...[
          SizedBox(height: AppSizes.p12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToHome(BuildContext context) {
    
    final targetRoute = result.isStudentPayment 
        ? AppRouter.studentDashboard 
        : AppRouter.adminHome;
    
    Navigator.of(context).pushNamedAndRemoveUntil(
      targetRoute,
      (route) => false,
    );
  }
}
