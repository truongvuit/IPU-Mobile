import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:trungtamngoaingu/features/admin/admin.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/validators/business_rules.dart';
import '../../bloc/promotion_bloc.dart';
import '../../bloc/promotion_event.dart';
import '../../bloc/promotion_state.dart';
import '../../bloc/admin_course_bloc.dart';
import '../../bloc/admin_course_event.dart';
import '../../bloc/admin_course_state.dart';

class PromotionFormScreen extends StatelessWidget {
  final Promotion? promotion;

  const PromotionFormScreen({super.key, this.promotion});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<PromotionBloc>()),
        BlocProvider(
          create: (_) => getIt<AdminCourseBloc>()..add(const LoadCourses()),
        ),
      ],
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
  late PromotionType _promotionType;
  late bool _requireAllCourses;

  List<String> _selectedCourseIds = [];
  List<String> _selectedCourseNames = [];

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
    _promotionType = p?.promotionType ?? PromotionType.single;
    _requireAllCourses = p?.requireAllCourses ?? false;
    _selectedCourseIds = List.from(p?.applicableCourseIds ?? []);
    _selectedCourseNames = List.from(p?.applicableCourseNames ?? []);
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
      final dateRangeError = DateValidators.validateDateRange(
        _startDate,
        _endDate,
      );
      if (dateRangeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dateRangeError), backgroundColor: Colors.red),
        );
        return;
      }

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
        applicableCourseIds: _selectedCourseIds.isEmpty
            ? null
            : _selectedCourseIds,
        applicableCourseNames: _selectedCourseNames.isEmpty
            ? null
            : _selectedCourseNames,
        promotionType: _promotionType,
        requireAllCourses: _requireAllCourses,
      );

      if (_isEditing) {
        context.read<PromotionBloc>().add(UpdatePromotion(newPromotion));
      } else {
        context.read<PromotionBloc>().add(CreatePromotion(newPromotion));
      }
    }
  }

  void _showCourseSelectionDialog(List<CourseDetail> courses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chọn khóa học áp dụng',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final isSelected = _selectedCourseIds.contains(course.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setModalState(() {
                            setState(() {
                              if (value == true) {
                                _selectedCourseIds.add(course.id);
                                _selectedCourseNames.add(course.name);
                              } else {
                                _selectedCourseIds.remove(course.id);
                                _selectedCourseNames.remove(course.name);
                              }
                            });
                          });
                        },
                        title: Text(
                          course.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${course.categoryName ?? ''} • ${course.formattedTuitionFee}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral600,
                          ),
                        ),
                        secondary: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      );
                    },
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.neutral700
                            : AppColors.neutral200,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                setState(() {
                                  _selectedCourseIds.clear();
                                  _selectedCourseNames.clear();
                                });
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: const Text('Xóa tất cả'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Xác nhận (${_selectedCourseIds.length})',
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            Navigator.pop(context, true);
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codeController,
                  readOnly: _isEditing,
                  enabled: !_isEditing,
                  decoration: InputDecoration(
                    labelText: 'Mã khuyến mãi (Code)',
                    hintText: 'VD: SUMMER2024',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    filled: _isEditing,
                    fillColor: _isEditing
                        ? AppColors.neutral100.withValues(alpha: 0.5)
                        : null,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Vui lòng nhập mã' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _titleController,
                  readOnly: _isEditing,
                  enabled: !_isEditing,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề',
                    hintText: 'VD: Khuyến mãi mùa hè',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    filled: _isEditing,
                    fillColor: _isEditing
                        ? AppColors.neutral100.withValues(alpha: 0.5)
                        : null,
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Vui lòng nhập tiêu đề' : null,
                ),
                SizedBox(height: 16.h),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<DiscountType>(
                        initialValue: _discountType,
                        decoration: InputDecoration(
                          labelText: 'Loại giảm giá',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                          filled: _isEditing,
                          fillColor: _isEditing
                              ? AppColors.neutral100.withValues(alpha: 0.5)
                              : null,
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: DiscountType.percentage,
                            child: Text('Phần trăm (%)'),
                          ),
                          DropdownMenuItem(
                            value: DiscountType.fixedAmount,
                            child: Text('Số tiền'),
                          ),
                        ],
                        onChanged: _isEditing
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _discountType = value);
                                }
                              },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _discountValueController,
                        decoration: InputDecoration(
                          labelText: 'Giá trị',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nhập giá trị';
                          }
                          if (_discountType == DiscountType.percentage) {
                            return NumericValidators.validateDiscountPercent(
                              value,
                            );
                          } else {
                            final numVal = double.tryParse(value);
                            if (numVal == null) return 'Không hợp lệ';
                            if (numVal < 0) return 'Giá trị không thể âm';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày bắt đầu',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_startDate),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Ngày kết thúc',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_endDate),
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usageLimitController,
                        decoration: InputDecoration(
                          labelText: 'Giới hạn',
                          hintText: 'Vô hạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _minOrderValueController,
                        decoration: InputDecoration(
                          labelText: 'Đơn tối thiểu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                DropdownButtonFormField<PromotionType>(
                  initialValue: _promotionType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Loại khuyến mãi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    filled: _isEditing,
                    fillColor: _isEditing
                        ? AppColors.neutral100.withValues(alpha: 0.5)
                        : null,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: PromotionType.single,
                      child: Text(
                        'Đơn lẻ (1 hoặc nhiều khóa)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    DropdownMenuItem(
                      value: PromotionType.combo,
                      child: Text(
                        'Combo (phải chọn đủ khóa)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                  onChanged: _isEditing
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _promotionType = value;
                              _requireAllCourses = value == PromotionType.combo;
                            });
                          }
                        },
                ),
                SizedBox(height: 16.h),

                Text(
                  'Khóa học áp dụng',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                  ),
                ),
                SizedBox(height: 8.h),
                BlocBuilder<AdminCourseBloc, AdminCourseState>(
                  builder: (context, state) {
                    List<CourseDetail> courses = [];
                    if (state is AdminCourseLoaded) {
                      courses = state.courses;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? AppColors.neutral600
                              : AppColors.neutral300,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_selectedCourseNames.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12.w),
                              child: Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: _selectedCourseNames.map((name) {
                                  final index = _selectedCourseNames.indexOf(
                                    name,
                                  );
                                  return Chip(
                                    label: Text(
                                      name,
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                    deleteIcon: Icon(Icons.close, size: 16.sp),
                                    onDeleted: () {
                                      setState(() {
                                        if (index < _selectedCourseIds.length) {
                                          _selectedCourseIds.removeAt(index);
                                        }
                                        _selectedCourseNames.removeAt(index);
                                      });
                                    },
                                    backgroundColor: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    labelStyle: TextStyle(
                                      color: AppColors.primary,
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                'Áp dụng cho tất cả khóa học',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? AppColors.neutral400
                                      : AppColors.neutral500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                          InkWell(
                            onTap: state is AdminCourseLoading
                                ? null
                                : () => _showCourseSelectionDialog(courses),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: isDark
                                        ? AppColors.neutral600
                                        : AppColors.neutral300,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (state is AdminCourseLoading)
                                    SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 18.sp,
                                      color: AppColors.primary,
                                    ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    state is AdminCourseLoading
                                        ? 'Đang tải...'
                                        : 'Chọn khóa học',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16.h),

                DropdownButtonFormField<PromotionStatus>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
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
                SizedBox(height: 32.h),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Cập Nhật' : 'Tạo Mới',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
