import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/student_app_bar.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';


class RatingScreen extends StatefulWidget {
  final String courseId;

  const RatingScreen({super.key, required this.courseId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _overallRating = 0;
  int _facilityRating = 0;
  int _teacherRating = 0;
  final _commentController = TextEditingController();
  final Set<String> _selectedTags = {};
  final List<File> _selectedImages = [];
  Timer? _debounce;

  final List<String> _availableTags = [
    '📚 Nội dung phong phú',
    '👨‍🏫 Giáo viên tận tâm',
    '⏰ Thời gian hợp lý',
    '💰 Giá trị xứng đáng',
    '🎯 Đạt mục tiêu',
    '🤝 Hỗ trợ tốt',
    '📖 Tài liệu chất lượng',
    '🎓 Học được nhiều',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được chọn tối đa 3 ảnh')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _submitRating() {
    if (_debounce?.isActive ?? false) return;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<StudentBloc>().add(
        SubmitRating(
          classId: widget.courseId,
          overallRating: _overallRating,
          teacherRating: _teacherRating > 0 ? _teacherRating : null,
          facilityRating: _facilityRating > 0 ? _facilityRating : null,
          comment: _commentController.text.trim(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;

          return Column(
            children: [
              StudentAppBar(
                title: 'Đánh giá khóa học',
                showBackButton: true,
                onBackPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.studentDashboard,
                    (route) => false,
                  );
                },
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 700 : double.infinity,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isDesktop ? 32.w : 24.w,
                        right: isDesktop ? 32.w : 24.w,
                        top: isDesktop ? 32.w : 24.w,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          _buildRatingSection(
                            'Đánh giá tổng quan',
                            _overallRating,
                            (rating) => setState(() => _overallRating = rating),
                            isDark,
                            isDesktop,
                          ),
                          SizedBox(height: 24.h),

                          
                          Text(
                            'Đánh giá chi tiết',
                            style: TextStyle(
                              fontSize: isDesktop ? 18.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildDetailedRating(
                            'Cơ sở vật chất',
                            Icons.business,
                            _facilityRating,
                            (rating) =>
                                setState(() => _facilityRating = rating),
                            isDark,
                            isDesktop,
                          ),
                          SizedBox(height: 12.h),
                          _buildDetailedRating(
                            'Giảng viên',
                            Icons.person,
                            _teacherRating,
                            (rating) => setState(() => _teacherRating = rating),
                            isDark,
                            isDesktop,
                          ),
                          SizedBox(height: 24.h),

                          
                          Text(
                            'Điểm nổi bật',
                            style: TextStyle(
                              fontSize: isDesktop ? 18.sp : 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTags.map((tag) {
                              final isSelected = _selectedTags.contains(tag);
                              return FilterChip(
                                label: Text(tag),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTags.add(tag);
                                    } else {
                                      _selectedTags.remove(tag);
                                    }
                                  });
                                },
                                backgroundColor: isDark
                                    ? const Color(0xFF1F2937)
                                    : Colors.white,
                                selectedColor: AppColors.primary.withOpacity(
                                  0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 24.h),

                          
                          TextField(
                            controller: _commentController,
                            maxLines: 5,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontFamily: 'Lexend',
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Chia sẻ trải nghiệm của bạn (tùy chọn)',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondary,
                                fontFamily: 'Lexend',
                                fontSize: isDesktop ? 16.sp : 14.sp,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          
                          Text(
                            'Thêm ảnh (tùy chọn)',
                            style: TextStyle(
                              fontSize: isDesktop ? 16.sp : 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._selectedImages.map(
                                (image) => Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.remove(image);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedImages.length < 3)
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1F2937)
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[400]!,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate,
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          
                          BlocConsumer<StudentBloc, StudentState>(
                            listener: (context, state) {
                              if (state is RatingSubmitted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cảm ơn bạn đã đánh giá!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } else if (state is StudentError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              final isLoading = state is StudentLoading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (_overallRating > 0 && !isLoading)
                                      ? _submitRating
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 20.h : 16.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMedium,
                                      ),
                                    ),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          height: 24.h,
                                          width: 24.h,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                        )
                                      : Text(
                                          'Gửi đánh giá',
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontWeight: FontWeight.w700,
                                            fontSize: isDesktop ? 18.sp : 16.sp,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget _buildRatingSection(
    String title,
    int rating,
    Function(int) onRatingChanged,
    bool isDark,
    bool isDesktop,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 24.sp : 20.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontFamily: 'Lexend',
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              iconSize: isDesktop ? 56.sp : 48.sp,
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: AppColors.warning,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                onRatingChanged(index + 1);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailedRating(
    String label,
    IconData icon,
    int rating,
    Function(int) onRatingChanged,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 24.sp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRatingChanged(index + 1);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
