import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/todays_focus_item.dart';


class AdminTodaysFocusCard extends StatelessWidget {
  final List<TodaysFocusItem> items;
  final VoidCallback? onViewAll;
  final Function(TodaysFocusItem)? onItemTap;

  const AdminTodaysFocusCard({
    super.key,
    required this.items,
    this.onViewAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.today_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hôm nay cần làm',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${items.length} việc cần xử lý',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.neutral400
                              : AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Xem tất cả'),
                  ),
              ],
            ),
          ),

          
          Divider(
            height: 1,
            color: isDark ? AppColors.neutral700 : AppColors.neutral200,
          ),

          
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
            itemCount: items.length > 5 ? 5 : items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 56.w,
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _FocusItemTile(
                item: item,
                onTap: onItemTap != null ? () => onItemTap!(item) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FocusItemTile extends StatelessWidget {
  final TodaysFocusItem item;
  final VoidCallback? onTap;

  const _FocusItemTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.p16,
          vertical: AppSizes.p12,
        ),
        child: Row(
          children: [
            
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: _getPriorityColor(item.priority).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(
                  _getTypeIcon(item.type),
                  color: _getPriorityColor(item.priority),
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: AppSizes.p12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            
            if (item.count > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getPriorityColor(item.priority),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  item.count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            SizedBox(width: AppSizes.p8),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.neutral500 : AppColors.neutral400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(FocusItemType type) {
    switch (type) {
      case FocusItemType.attendance:
        return Icons.fact_check_outlined;
      case FocusItemType.payment:
        return Icons.payment_outlined;
      case FocusItemType.conflict:
        return Icons.warning_amber_outlined;
      case FocusItemType.approval:
        return Icons.approval_outlined;
      case FocusItemType.classToday:
        return Icons.class_outlined;
      case FocusItemType.other:
        return Icons.task_alt_outlined;
    }
  }

  Color _getPriorityColor(FocusItemPriority priority) {
    switch (priority) {
      case FocusItemPriority.urgent:
        return AppColors.error;
      case FocusItemPriority.high:
        return Colors.orange;
      case FocusItemPriority.normal:
        return AppColors.primary;
    }
  }
}
