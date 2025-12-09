import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trungtamngoaingu/features/admin/admin.dart';
import '../../../../../core/routing/app_router.dart';
import '../../bloc/promotion_event.dart' as promotion_events;
import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/promotion_bloc.dart';
import '../../bloc/promotion_state.dart';
import '../../../domain/entities/promotion.dart';

class PromotionListScreen extends StatelessWidget {
  const PromotionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PromotionBloc>()..add(promotion_events.LoadPromotions()),
      child: const _PromotionListScreenContent(),
    );
  }
}

class _PromotionListScreenContent extends StatefulWidget {
  const _PromotionListScreenContent();

  @override
  State<_PromotionListScreenContent> createState() =>
      _PromotionListScreenContentState();
}

class _PromotionListScreenContentState
    extends State<_PromotionListScreenContent> {
  PromotionStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Khuyến Mãi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<PromotionBloc, PromotionState>(
        listener: (context, state) {
          if (state is PromotionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PromotionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromotionOperationSuccess) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PromotionLoaded) {
            // Sắp xếp: Active đầu tiên, rồi scheduled, rồi draft, cuối cùng là expired
            final sortedPromotions = List<Promotion>.from(state.promotions)
              ..sort((a, b) {
                int getPriority(PromotionStatus status) {
                  switch (status) {
                    case PromotionStatus.active:
                      return 0;
                    case PromotionStatus.scheduled:
                      return 1;
                    case PromotionStatus.draft:
                      return 2;
                    case PromotionStatus.expired:
                      return 3;
                  }
                }
                return getPriority(a.status).compareTo(getPriority(b.status));
              });

            final filteredPromotions = _filterStatus == null
                ? sortedPromotions
                : sortedPromotions
                      .where((p) => p.status == _filterStatus)
                      .toList();

            if (filteredPromotions.isEmpty) {
              return const Center(child: Text('Không có khuyến mãi nào'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPromotions.length,
              itemBuilder: (context, index) {
                final promotion = filteredPromotions[index];
                return _buildPromotionCard(promotion);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'promotion_list_fab',
        onPressed: () async {
          final bloc = context.read<PromotionBloc>();
          final result = await Navigator.pushNamed(
            context,
            AppRouter.adminPromotionForm,
          );
          if (!mounted) return;
          if (result == true) {
            bloc.add(promotion_events.LoadPromotions());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promotion) {
    Color statusColor = Colors.grey;
    String statusText = 'Không xác định';

    switch (promotion.status) {
      case PromotionStatus.active:
        statusColor = Colors.green;
        statusText = 'Đang chạy';
        break;
      case PromotionStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Sắp chạy';
        break;
      case PromotionStatus.expired:
        statusColor = Colors.grey;
        statusText = 'Hết hạn';
        break;
      case PromotionStatus.draft:
        statusColor = Colors.orange;
        statusText = 'Nháp';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final bloc = context.read<PromotionBloc>();
          final result = await Navigator.pushNamed(
            context,
            AppRouter.adminPromotionDetail,
            arguments: promotion.id,
          );
          if (!mounted) return;
          if (result == true) {
            bloc.add(promotion_events.LoadPromotions());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                promotion.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                promotion.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.discount, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    promotion.discountType == DiscountType.percentage
                        ? '${promotion.discountValue.toInt()}%'
                        : '${promotion.discountValue.toInt()}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${promotion.startDate.day}/${promotion.startDate.month} - ${promotion.endDate.day}/${promotion.endDate.month}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (promotion.usageLimit != null) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: promotion.usageCount / promotion.usageLimit!,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  'Đã dùng: ${promotion.usageCount}/${promotion.usageLimit}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    String getStatusLabel(PromotionStatus status) {
      switch (status) {
        case PromotionStatus.active:
          return 'Đang chạy';
        case PromotionStatus.scheduled:
          return 'Sắp diễn ra';
        case PromotionStatus.expired:
          return 'Hết hạn';
        case PromotionStatus.draft:
          return 'Bản nháp';
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Lọc theo trạng thái'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _filterStatus = null);
              Navigator.pop(dialogContext);
            },
            child: Row(
              children: [
                Icon(
                  _filterStatus == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _filterStatus == null ? AppColors.primary : null,
                ),
                const SizedBox(width: 12),
                const Text('Tất cả'),
              ],
            ),
          ),
          ...PromotionStatus.values.map(
            (status) => SimpleDialogOption(
              onPressed: () {
                setState(() => _filterStatus = status);
                Navigator.pop(dialogContext);
              },
              child: Row(
                children: [
                  Icon(
                    _filterStatus == status
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _filterStatus == status ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(getStatusLabel(status)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
