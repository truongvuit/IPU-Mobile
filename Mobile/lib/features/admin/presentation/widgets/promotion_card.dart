import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../../domain/entities/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final bool isSelected;
  final bool isApplicable; 
  final List<String> selectedCourseIds; 
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.isSelected = false,
    this.isApplicable = true,
    this.selectedCourseIds = const [],
    this.onTap,
  });

  bool get _isExpired => DateTime.now().isAfter(promotion.endDate);

  bool get _isFull =>
      promotion.usageLimit != null &&
      promotion.usageCount >= promotion.usageLimit!;

  bool get _isValid =>
      !_isExpired && !_isFull && promotion.status == PromotionStatus.active;
  
  bool get _isCombo => 
      promotion.promotionType == PromotionType.combo || promotion.requireAllCourses;

  String get _displayDate {
    final formatter = DateFormat('dd/MM/yyyy');
    return 'Đến ${formatter.format(promotion.endDate)}';
  }
  
  
  List<String> get _missingCourses {
    if (!_isCombo || promotion.applicableCourseIds == null) return [];
    return promotion.applicableCourseIds!
        .where((courseId) => !selectedCourseIds.contains(courseId))
        .toList();
  }
  
  
  List<String> get _missingCourseNames {
    if (!_isCombo || promotion.applicableCourseNames == null || promotion.applicableCourseIds == null) {
      return _missingCourses;
    }
    final missingNames = <String>[];
    for (int i = 0; i < promotion.applicableCourseIds!.length; i++) {
      if (!selectedCourseIds.contains(promotion.applicableCourseIds![i])) {
        if (i < promotion.applicableCourseNames!.length) {
          missingNames.add(promotion.applicableCourseNames![i]);
        }
      }
    }
    return missingNames;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canSelect = _isValid && isApplicable;

    return Opacity(
      opacity: canSelect ? 1.0 : 0.6,
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.neutral700 : AppColors.neutral200),
          ),
        ),
        child: InkWell(
          onTap: canSelect ? onTap : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p12),
            child: Row(
              children: [
                
                Container(
                  width: AppSizes.p20,
                  height: AppSizes.p20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.neutral400,
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

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Row(
                        children: [
                          if (_isCombo) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.p8,
                                vertical: AppSizes.p4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: Text(
                                'COMBO',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                  fontSize: AppSizes.textXs,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSizes.p8),
                          ],
                          Expanded(
                            child: Text(
                              promotion.code,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.textSm,
                                color: isSelected ? AppColors.primary : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.p4),

                      
                      Text(
                        promotion.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: AppSizes.textXs,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.p4),

                      
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: AppSizes.textXs,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                          ),
                          SizedBox(width: AppSizes.p4),
                          Text(
                            _displayDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: AppSizes.textXs,
                              color: isDark
                                  ? AppColors.neutral400
                                  : AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),

                      
                      if (_isCombo && promotion.applicableCourseNames != null) ...[
                        SizedBox(height: AppSizes.p8),
                        Container(
                          padding: EdgeInsets.all(AppSizes.p8),
                          decoration: BoxDecoration(
                            color: isApplicable 
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isApplicable ? Icons.check_circle : Icons.info_outline,
                                    size: AppSizes.textSm,
                                    color: isApplicable ? AppColors.success : AppColors.info,
                                  ),
                                  SizedBox(width: AppSizes.p4),
                                  Text(
                                    isApplicable ? 'Đủ điều kiện combo' : 'Yêu cầu chọn các khóa:',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: AppSizes.textXs,
                                      fontWeight: FontWeight.w600,
                                      color: isApplicable ? AppColors.success : AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                              if (!isApplicable && _missingCourseNames.isNotEmpty) ...[
                                SizedBox(height: AppSizes.p4),
                                Text(
                                  _missingCourseNames.join(', '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: AppSizes.textXs,
                                    color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      
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
      ),
    );
  }
}
