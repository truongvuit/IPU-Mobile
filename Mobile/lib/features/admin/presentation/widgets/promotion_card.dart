import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../../domain/entities/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final bool isSelected;
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.isSelected = false,
    this.onTap,
  });

  bool get _isExpired => DateTime.now().isAfter(promotion.endDate);

  bool get _isFull =>
      promotion.usageLimit != null &&
      promotion.usageCount >= promotion.usageLimit!;

  bool get _isValid =>
      !_isExpired && !_isFull && promotion.status == PromotionStatus.active;

  String get _displayDate {
    final formatter = DateFormat('dd/MM/yyyy');
    return 'Đến ${formatter.format(promotion.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : (isDark ? AppColors.surfaceDark : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.gray700 : AppColors.gray200),
        ),
      ),
      child: InkWell(
        onTap: _isValid ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p12),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: AppSizes.p20,
                height: AppSizes.p20,
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
                        size: AppSizes.textSm,
                        color: Colors.white,
                      )
                    : null,
              ),
              SizedBox(width: AppSizes.p12),

              // Promotion info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promotion code
                    Text(
                      promotion.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.textSm,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    SizedBox(height: AppSizes.p4),

                    // Description
                    Text(
                      promotion.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: AppSizes.textXs,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.p4),

                    // Expiry date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: AppSizes.textXs,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                        SizedBox(width: AppSizes.p4),
                        Text(
                          _displayDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: AppSizes.textXs,
                            color: isDark
                                ? AppColors.gray400
                                : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),

                    // Status badges
                    if (!_isValid) ...[
                      SizedBox(height: AppSizes.p4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.p8,
                          vertical: AppSizes.p4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        child: Text(
                          _isExpired ? 'Đã hết hạn' : 'Đã đầy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontSize: AppSizes.textXs,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
