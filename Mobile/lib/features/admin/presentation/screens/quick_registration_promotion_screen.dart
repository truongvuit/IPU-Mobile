import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../widgets/simple_admin_app_bar.dart';

class QuickRegistrationPromotionScreen extends StatefulWidget {
  const QuickRegistrationPromotionScreen({super.key});

  @override
  State<QuickRegistrationPromotionScreen> createState() =>
      _QuickRegistrationPromotionScreenState();
}

class _QuickRegistrationPromotionScreenState
    extends State<QuickRegistrationPromotionScreen> {
  @override
  void initState() {
    super.initState();
    
    context.read<RegistrationBloc>().add(const CalculateCartPreview());
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
      appBar: const SimpleAdminAppBar(title: 'Khuyến mãi tự động'),
      body: BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) {
          RegistrationInProgress? registrationData;

          if (state is RegistrationInProgress) {
            registrationData = state;
          } else if (state is ClassesLoaded) {
            registrationData = state.currentRegistration;
          } else if (state is PromotionsLoaded) {
            registrationData = state.currentRegistration;
          }

          if (registrationData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          
          if (registrationData.isCalculatingPreview) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tính toán khuyến mãi...'),
                ],
              ),
            );
          }

          
          if (registrationData.cartPreviewError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    registrationData.cartPreviewError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<RegistrationBloc>().add(
                        const CalculateCartPreview(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final hasAnyDiscount = registrationData.hasAutoPromotions;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Container(
                        padding: EdgeInsets.all(AppSizes.p16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.info,
                              size: 24,
                            ),
                            SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Khuyến mãi tự động',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hệ thống tự động áp dụng các khuyến mãi phù hợp dựa trên lớp học đã chọn.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppSizes.p20),

                      
                      if (hasAnyDiscount) ...[
                        Text(
                          'Khuyến mãi được áp dụng',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSizes.p12),

                        
                        if (registrationData.hasSingleCourseDiscount)
                          _buildDiscountCard(
                            icon: Icons.local_offer,
                            title: 'Giảm giá khóa học lẻ',
                            description:
                                'Khuyến mãi trực tiếp trên từng khóa học',
                            amount: registrationData.singleCourseDiscountAmount,
                            color: AppColors.success,
                            isDark: isDark,
                          ),

                        
                        if (registrationData.appliedCombos.isNotEmpty) ...[
                          for (final combo in registrationData.appliedCombos)
                            _buildDiscountCard(
                              icon: Icons.auto_awesome,
                              title: combo.comboName,
                              description:
                                  'Combo ${combo.courseNames.length} khóa',
                              amount: combo.discountAmount,
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                        ],

                        
                        if (registrationData.returningDiscountAmount > 0)
                          _buildDiscountCard(
                            icon: Icons.person_outline,
                            title: 'Ưu đãi học viên cũ',
                            description: 'Áp dụng cho học viên đã từng đăng ký',
                            amount: registrationData.returningDiscountAmount,
                            color: AppColors.secondary,
                            isDark: isDark,
                          ),

                        SizedBox(height: AppSizes.p20),

                        
                        Container(
                          padding: EdgeInsets.all(AppSizes.p16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.neutral700
                                  : AppColors.neutral200,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow(
                                'Tổng học phí gốc',
                                _formatCurrency(registrationData.tuitionFee),
                                isDark,
                              ),
                              const Divider(height: 20),
                              _buildSummaryRow(
                                'Tổng giảm giá',
                                '-${_formatCurrency(registrationData.totalDiscount)}',
                                isDark,
                                valueColor: AppColors.success,
                              ),
                              const Divider(height: 20),
                              _buildSummaryRow(
                                'Thành tiền',
                                _formatCurrency(registrationData.totalAmount),
                                isDark,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppSizes.p24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.neutral400,
                                size: 48,
                              ),
                              SizedBox(height: AppSizes.p12),
                              Text(
                                'Không có khuyến mãi áp dụng',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                              SizedBox(height: AppSizes.p8),
                              Text(
                                'Các khóa học đã chọn hiện không có chương trình khuyến mãi nào phù hợp.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.neutral400,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
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
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                      child: Text(
                        hasAnyDiscount ? 'Tiếp tục với khuyến mãi' : 'Tiếp tục',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscountCard({
    required IconData icon,
    required String title,
    required String description,
    required double amount,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.p8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${_formatCurrency(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color:
                valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
