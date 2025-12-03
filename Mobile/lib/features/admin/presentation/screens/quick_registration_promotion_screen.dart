import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

import '../widgets/promotion_card.dart';

class QuickRegistrationPromotionScreen extends StatefulWidget {
  const QuickRegistrationPromotionScreen({super.key});

  @override
  State<QuickRegistrationPromotionScreen> createState() =>
      _QuickRegistrationPromotionScreenState();
}

class _QuickRegistrationPromotionScreenState
    extends State<QuickRegistrationPromotionScreen> {
  final _promoCodeController = TextEditingController();
  String? _selectedPromoCode;
  List<String> _selectedCourseIds = [];

  @override
  void initState() {
    super.initState();
    
    final state = context.read<RegistrationBloc>().state;
    String? courseId;
    
    if (state is RegistrationInProgress) {
      _selectedPromoCode = state.promotionCode;
      courseId = state.courseId;
      _selectedCourseIds = state.selectedCourseIds;
      if (_selectedPromoCode != null) {
        _promoCodeController.text = _selectedPromoCode!;
      }
    } else if (state is ClassesLoaded) {
      _selectedCourseIds = state.currentRegistration.selectedCourseIds;
      _selectedPromoCode = state.currentRegistration.promotionCode;
      if (_selectedPromoCode != null) {
        _promoCodeController.text = _selectedPromoCode!;
      }
    }
    
    // Load promotions với selectedCourseIds để lọc theo khóa đã chọn
    context.read<RegistrationBloc>().add(LoadPromotions(
      courseId: courseId,
      selectedCourseIds: _selectedCourseIds,
    ));
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _applyPromotion(String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã khuyến mãi'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    context.read<RegistrationBloc>().add(ApplyPromotion(code));
  }

  void _selectPromotion(String code) {
    setState(() {
      _selectedPromoCode = code;
      _promoCodeController.text = code;
    });
  }

  void _confirmSelection() {
    if (_promoCodeController.text.isNotEmpty) {
      context.read<RegistrationBloc>().add(
        ApplyPromotion(_promoCodeController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Áp dụng Khuyến mãi')),
      body: BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is RegistrationInProgress &&
              state.promotionCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã áp dụng mã: ${state.promotionCode}'),
                backgroundColor: AppColors.success,
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        },
        builder: (context, state) {
          if (state is RegistrationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<dynamic> promotions = [];
          List<dynamic> allPromotions = [];
          if (state is PromotionsLoaded) {
            // validPromotions đã được lọc theo selectedCourseIds
            promotions = state.validPromotions;
            allPromotions = state.promotions;
          }

          return Column(
            children: [
              
              Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhập mã khuyến mãi',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoCodeController,
                            decoration: InputDecoration(
                              hintText: 'Ví dụ: HELLO2024',
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.gray700
                                  : AppColors.gray100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        SizedBox(width: AppSizes.p12),
                        ElevatedButton(
                          onPressed: () =>
                              _applyPromotion(_promoCodeController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.p24,
                              vertical: AppSizes.p16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Áp dụng',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              
              Padding(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Row(
                  children: [
                    Text(
                      'Chọn từ khuyến mãi có sẵn',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: allPromotions.isEmpty
                    ? const Center(
                        child: EmptyStateWidget(
                          icon: Icons.local_offer,
                          message: 'Không có khuyến mãi khả dụng',
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                        ),
                        itemCount: allPromotions.length,
                        itemBuilder: (context, index) {
                          final promotion = allPromotions[index];
                          final isApplicable = promotion.canApplyForCourses(_selectedCourseIds);
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSizes.p12),
                            child: PromotionCard(
                              promotion: promotion,
                              isSelected: _selectedPromoCode == promotion.code,
                              isApplicable: isApplicable,
                              selectedCourseIds: _selectedCourseIds,
                              onTap: isApplicable ? () => _selectPromotion(promotion.code) : null,
                            ),
                          );
                        },
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                          side: BorderSide(color: AppColors.gray400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMedium,
                            ),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmSelection,
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
                          'Xác nhận',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
