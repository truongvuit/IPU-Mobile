import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/promotion.dart';
import '../../bloc/promotion_bloc.dart';
import '../../bloc/promotion_event.dart' as promotion_events;
import '../../bloc/promotion_state.dart';

class PromotionDetailScreen extends StatelessWidget {
  final String promotionId;

  const PromotionDetailScreen({super.key, required this.promotionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PromotionBloc>()..add(promotion_events.LoadPromotions()),
      child: _PromotionDetailContent(promotionId: promotionId),
    );
  }
}

class _PromotionDetailContent extends StatelessWidget {
  final String promotionId;

  const _PromotionDetailContent({required this.promotionId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromotionBloc, PromotionState>(
      listener: (context, state) {
        if (state is PromotionOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context, true); 
        } else if (state is PromotionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        Promotion? promotion;
        if (state is PromotionLoaded) {
          try {
            promotion = state.promotions.firstWhere((p) => p.id == promotionId);
          } catch (e) {
            return const Scaffold(
              body: Center(child: Text('Không tìm thấy khuyến mãi')),
            );
          }
        } else if (state is PromotionLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (promotion == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi Tiết Khuyến Mãi'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRouter.adminPromotionForm,
                    arguments: promotion,
                  );
                  if (result == true) {
                    
                    if (context.mounted) {
                      context.read<PromotionBloc>().add(
                        promotion_events.LoadPromotions(),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(context, promotion!),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(promotion),
                const SizedBox(height: 24),
                _buildInfoSection(promotion),
                const SizedBox(height: 24),
                _buildApplicableCoursesSection(promotion),
                const SizedBox(height: 24),
                _buildUsageSection(promotion),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Promotion promotion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              promotion.code.length > 20 
                  ? '${promotion.code.substring(0, 20)}...'
                  : promotion.code,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            promotion.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            promotion.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Promotion promotion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin chi tiết',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.discount,
          'Giảm giá',
          promotion.discountType == DiscountType.percentage
              ? '${promotion.discountValue}%'
              : NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(promotion.discountValue),
        ),
        _buildInfoRow(
          Icons.calendar_today,
          'Thời gian',
          '${DateFormat('dd/MM/yyyy').format(promotion.startDate)} - ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}',
        ),
        _buildInfoRow(
          Icons.shopping_cart,
          'Đơn tối thiểu',
          promotion.minOrderValue != null
              ? NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(promotion.minOrderValue)
              : 'Không có',
        ),
        _buildInfoRow(
          Icons.info_outline,
          'Trạng thái',
          _getStatusText(promotion.status),
          valueColor: _getStatusColor(promotion.status),
        ),
      ],
    );
  }

  Widget _buildUsageSection(Promotion promotion) {
    if (promotion.usageLimit == null) return const SizedBox.shrink();

    final percent = promotion.usageCount / promotion.usageLimit!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê sử dụng',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Đã sử dụng', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    '${promotion.usageCount}/${promotion.usageLimit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[100],
                color: AppColors.primary,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Text(
                '${(percent * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.active:
        return 'Đang hoạt động';
      case PromotionStatus.scheduled:
        return 'Đã lên lịch';
      case PromotionStatus.expired:
        return 'Đã hết hạn';
      case PromotionStatus.draft:
        return 'Bản nháp';
    }
  }

  Color _getStatusColor(PromotionStatus status) {
    switch (status) {
      case PromotionStatus.active:
        return Colors.green;
      case PromotionStatus.scheduled:
        return Colors.blue;
      case PromotionStatus.expired:
        return Colors.grey;
      case PromotionStatus.draft:
        return Colors.orange;
    }
  }

  Widget _buildApplicableCoursesSection(Promotion promotion) {
    final courseIds = promotion.applicableCourseIds;
    final courseNames = promotion.applicableCourseNames;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Áp dụng cho',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: courseIds == null || courseIds.isEmpty
              ? Row(
                  children: [
                    Icon(Icons.all_inclusive, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tất cả khóa học',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${courseIds.length} khóa học',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(courseIds.length, (index) {
                        
                        final displayText = (courseNames != null && index < courseNames.length)
                            ? courseNames[index]
                            : 'Khóa học ${courseIds[index]}';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa khuyến mãi?'),
        content: Text(
          'Bạn có chắc chắn muốn xóa khuyến mãi "${promotion.title}" không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PromotionBloc>().add(
                promotion_events.DeletePromotion(promotion.id),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
