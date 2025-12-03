import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:trungtamngoaingu/features/admin/admin.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/promotion_bloc.dart';
import '../../bloc/promotion_event.dart';
import '../../bloc/promotion_state.dart';

class PromotionFormScreen extends StatelessWidget {
  final Promotion? promotion;

  const PromotionFormScreen({super.key, this.promotion});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PromotionBloc>(),
      child: _PromotionFormContent(promotion: promotion),
    );
  }
}

class _PromotionFormContent extends StatefulWidget {
  final Promotion? promotion;

  const _PromotionFormContent({this.promotion});

  @override
  State<_PromotionFormContent> createState() => _PromotionFormContentState();
}

class _PromotionFormContentState extends State<_PromotionFormContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountValueController;
  late TextEditingController _usageLimitController;
  late TextEditingController _minOrderValueController;

  late DiscountType _discountType;
  late PromotionStatus _status;
  late DateTime _startDate;
  late DateTime _endDate;

  bool get _isEditing => widget.promotion != null;

  @override
  void initState() {
    super.initState();
    final p = widget.promotion;
    _codeController = TextEditingController(text: p?.code ?? '');
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _discountValueController = TextEditingController(
      text: p?.discountValue.toString() ?? '',
    );
    _usageLimitController = TextEditingController(
      text: p?.usageLimit?.toString() ?? '',
    );
    _minOrderValueController = TextEditingController(
      text: p?.minOrderValue?.toString() ?? '',
    );

    _discountType = p?.discountType ?? DiscountType.percentage;
    _status = p?.status ?? PromotionStatus.draft;
    _startDate = p?.startDate ?? DateTime.now();
    _endDate = p?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _usageLimitController.dispose();
    _minOrderValueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final discountValue = double.tryParse(_discountValueController.text) ?? 0;
      final usageLimit = int.tryParse(_usageLimitController.text);
      final minOrderValue = double.tryParse(_minOrderValueController.text);

      final newPromotion = Promotion(
        id:
            widget.promotion?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        code: _codeController.text.toUpperCase(),
        title: _titleController.text,
        description: _descriptionController.text,
        discountType: _discountType,
        discountValue: discountValue,
        startDate: _startDate,
        endDate: _endDate,
        usageLimit: usageLimit,
        status: _status,
        minOrderValue: minOrderValue,
        usageCount: widget.promotion?.usageCount ?? 0,
      );

      if (_isEditing) {
        context.read<PromotionBloc>().add(UpdatePromotion(newPromotion));
      } else {
        context.read<PromotionBloc>().add(CreatePromotion(newPromotion));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa Khuyến Mãi' : 'Tạo Khuyến Mãi'),
      ),
      body: BlocListener<PromotionBloc, PromotionState>(
        listener: (context, state) {
          if (state is PromotionOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true); // Return true to trigger refresh
          } else if (state is PromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Code & Title
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã khuyến mãi (Code)',
                  hintText: 'VD: SUMMER2024',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập mã' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'VD: Khuyến mãi mùa hè',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Discount Type & Value
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DiscountType>(
                      initialValue: _discountType,
                      decoration: const InputDecoration(
                        labelText: 'Loại giảm giá',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: DiscountType.percentage,
                          child: Text('Phần trăm (%)'),
                        ),
                        DropdownMenuItem(
                          value: DiscountType.fixedAmount,
                          child: Text('Số tiền cố định'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _discountType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountValueController,
                      decoration: const InputDecoration(
                        labelText: 'Giá trị giảm',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nhập giá trị';
                        }
                        final numVal = double.tryParse(value);
                        if (numVal == null) return 'Không hợp lệ';
                        if (_discountType == DiscountType.percentage &&
                            numVal > 100) {
                          return 'Max 100%';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày bắt đầu',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Ngày kết thúc',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Usage Limit & Min Order
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _usageLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Giới hạn sử dụng',
                        hintText: 'Để trống = Vô hạn',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minOrderValueController,
                      decoration: const InputDecoration(
                        labelText: 'Đơn tối thiểu',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<PromotionStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: PromotionStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Cập Nhật' : 'Tạo Mới',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
