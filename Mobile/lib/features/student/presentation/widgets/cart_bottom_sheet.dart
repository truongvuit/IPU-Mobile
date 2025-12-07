import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  static void show(BuildContext context) {
    final bloc = context.read<StudentBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          BlocProvider.value(value: bloc, child: const CartBottomSheet()),
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
    final bloc = context.read<StudentBloc>();
    final cartItems = bloc.cartItems;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral600 : AppColors.neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Giỏ hàng',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),

          // Cart content
          if (cartItems.isEmpty)
            _buildEmptyCart(theme, isDark)
          else
            _buildCartContent(context, theme, isDark, cartItems),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64.sp,
            color: isDark ? AppColors.neutral500 : AppColors.neutral400,
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Giỏ hàng trống',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.neutral400 : AppColors.neutral600,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Hãy thêm khóa học vào giỏ hàng',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<dynamic> cartItems,
  ) {
    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.price as double),
    );

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Items list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? AppColors.neutral700 : AppColors.neutral200,
              ),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _buildCartItem(context, theme, isDark, item);
              },
            ),
          ),

          // Summary & Checkout
          Container(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.neutral100,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Subtotal row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tạm tính (${cartItems.length} khóa)',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        _formatCurrency(subtotal),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingSmall),
                  // Discount hint
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_offer,
                          color: AppColors.success,
                          size: 20.sp,
                        ),
                        SizedBox(width: AppSizes.paddingSmall),
                        Expanded(
                          child: Text(
                            'Khuyến mãi sẽ được tự động áp dụng khi thanh toán',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),
                  // Checkout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        final classIds = cartItems
                            .map((e) => e.classId as int)
                            .toList();
                        Navigator.of(context).pushNamed(
                          AppRouter.studentCheckout,
                          arguments: {
                            'classIds': classIds,
                            'courseName': cartItems.length == 1
                                ? cartItems.first.courseName as String
                                : '${cartItems.length} khóa học',
                          },
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text('Tiến hành thanh toán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMedium,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
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

  Widget _buildCartItem(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic item,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        children: [
          // Course icon
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(Icons.school, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(width: AppSizes.paddingSmall),
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseName as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item.className as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatCurrency(item.price as double),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: () {
              context.read<StudentBloc>().add(
                RemoveFromCart(item.classId as int),
              );
              Navigator.pop(context);
              CartBottomSheet.show(context);
            },
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}
