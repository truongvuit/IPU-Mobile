import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/student_app_bar.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/review.dart';

class RatingScreen extends StatefulWidget {
  final String classId;

  const RatingScreen({super.key, required this.classId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen>
    with SingleTickerProviderStateMixin {
  int _overallRating = 0;
  int _facilityRating = 0;
  int _teacherRating = 0;
  final _commentController = TextEditingController();
  final Set<String> _selectedTags = {};
  final List<File> _selectedImages = [];
  Timer? _debounce;
  Review? _existingReview;
  bool _isViewMode = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Map<String, String> _getRatingInfo(int rating) {
    switch (rating) {
      case 1:
        return {'emoji': '😞', 'text': 'Rất không hài lòng', 'color': 'red'};
      case 2:
        return {'emoji': '😕', 'text': 'Không hài lòng', 'color': 'orange'};
      case 3:
        return {'emoji': '😐', 'text': 'Bình thường', 'color': 'yellow'};
      case 4:
        return {'emoji': '😊', 'text': 'Hài lòng', 'color': 'lightGreen'};
      case 5:
        return {'emoji': '🤩', 'text': 'Rất hài lòng', 'color': 'green'};
      default:
        return {'emoji': '⭐', 'text': 'Chọn đánh giá của bạn', 'color': 'grey'};
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  final List<String> _availableTags = [
    'Nội dung phong phú',
    'Giáo viên tận tâm',
    'Thời gian hợp lý',
    'Giá trị xứng đáng',
    'Đạt mục tiêu',
    'Hỗ trợ tốt',
    'Tài liệu chất lượng',
    'Học được nhiều',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    context.read<StudentBloc>().add(LoadClassReview(widget.classId));
  }

  void _populateExistingReview(Review review) {
    setState(() {
      _existingReview = review;
      _overallRating = review.overallRating;
      _teacherRating = review.teacherRating ?? 0;
      _facilityRating = review.facilityRating ?? 0;
      _commentController.text = review.comment ?? '';
      _isViewMode = true;
    });
  }

  void _switchToEditMode() {
    setState(() {
      _isViewMode = false;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _debounce?.cancel();
    _animationController.dispose();
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
          classId: widget.classId,
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
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is ClassReviewLoaded && state.review != null) {
            _populateExistingReview(state.review!);
          } else if (state is RatingSubmitted) {
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
          if (state is StudentLoading && _existingReview == null) {
            return Column(
              children: [
                StudentAppBar(
                  title: 'Đánh giá khóa học',
                  showBackButton: true,
                  onBackPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;

              return Column(
                children: [
                  StudentAppBar(
                    title: _isViewMode
                        ? 'Đánh giá của bạn'
                        : 'Đánh giá khóa học',
                    showBackButton: true,
                    onBackPressed: () => Navigator.pop(context),
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
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 20.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isViewMode && _existingReview != null) ...[
                                _buildExistingReviewInfo(isDark, isDesktop),
                                SizedBox(height: 24.h),
                              ],

                              _buildRatingSection(
                                'Đánh giá tổng quan',
                                _overallRating,
                                _isViewMode
                                    ? null
                                    : (rating) => setState(
                                        () => _overallRating = rating,
                                      ),
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
                                _isViewMode
                                    ? null
                                    : (rating) => setState(
                                        () => _facilityRating = rating,
                                      ),
                                isDark,
                                isDesktop,
                              ),
                              SizedBox(height: 12.h),
                              _buildDetailedRating(
                                'Giảng viên',
                                Icons.person,
                                _teacherRating,
                                _isViewMode
                                    ? null
                                    : (rating) => setState(
                                        () => _teacherRating = rating,
                                      ),
                                isDark,
                                isDesktop,
                              ),
                              SizedBox(height: 24.h),

                              if (!_isViewMode) ...[
                                Text(
                                  'Điểm nổi bật',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _availableTags.map((tag) {
                                    final isSelected = _selectedTags.contains(
                                      tag,
                                    );
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
                                      selectedColor: AppColors.primary
                                          .withValues(alpha: 0.2),
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
                              ],

                              Text(
                                _isViewMode ? 'Nhận xét của bạn' : 'Nhận xét',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16.sp : 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              if (_isViewMode)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
                                    ),
                                  ),
                                  child: Text(
                                    _commentController.text.isEmpty
                                        ? 'Không có nhận xét'
                                        : _commentController.text,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontFamily: 'Lexend',
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                )
                              else
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
                                      color: AppColors.textSecondary,
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

                              if (!_isViewMode) ...[
                                Text(
                                  'Thêm ảnh (tùy chọn)',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16.sp : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.grey[700]!
                                                  : Colors.grey[400]!,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add_photo_alternate,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 32.h),
                              ],

                              if (!_isViewMode)
                                BlocBuilder<StudentBloc, StudentState>(
                                  builder: (context, btnState) {
                                    final isLoading =
                                        btnState is StudentLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            (_overallRating > 0 && !isLoading)
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
                                                _existingReview != null
                                                    ? 'Cập nhật đánh giá'
                                                    : 'Gửi đánh giá',
                                                style: TextStyle(
                                                  fontFamily: 'Lexend',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: isDesktop
                                                      ? 18.sp
                                                      : 16.sp,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),

                              if (_isViewMode) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _switchToEditMode,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isDesktop ? 20.h : 16.h,
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusMedium,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Chỉnh sửa đánh giá',
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w700,
                                        fontSize: isDesktop ? 18.sp : 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExistingReviewInfo(bool isDark, bool isDesktop) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn đã đánh giá lớp học này',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                    fontFamily: 'Lexend',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Ngày đánh giá: ${dateFormat.format(_existingReview!.createdAt)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(
    String title,
    int rating,
    Function(int)? onRatingChanged,
    bool isDark,
    bool isDesktop,
  ) {
    final bool isReadOnly = onRatingChanged == null;
    final ratingInfo = _getRatingInfo(rating);
    final ratingColor = _getRatingColor(rating);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1F2937), const Color(0xFF111827)]
              : [Colors.white, const Color(0xFFF3F4F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
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

          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              ratingInfo['emoji']!,
              key: ValueKey(rating),
              style: TextStyle(fontSize: isDesktop ? 60.sp : 48.sp),
            ),
          ),
          SizedBox(height: 8.h),

          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              ratingInfo['text']!,
              key: ValueKey(ratingInfo['text']),
              style: TextStyle(
                fontSize: isDesktop ? 16.sp : 14.sp,
                fontWeight: FontWeight.w600,
                color: rating > 0 ? ratingColor : Colors.grey,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          SizedBox(height: 20.h),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isFilled = index < rating;
              return GestureDetector(
                onTap: isReadOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        _animationController.forward().then((_) {
                          _animationController.reverse();
                        });
                        onRatingChanged!(index + 1);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? AppColors.warning : Colors.grey[400],
                    size: isDesktop ? 52.sp : 44.sp,
                  ),
                ),
              );
            }),
          ),

          if (!isReadOnly) ...[
            SizedBox(height: 12.h),
            Text(
              'Nhấn để chọn số sao',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRating(
    String label,
    IconData icon,
    int rating,
    Function(int)? onRatingChanged,
    bool isDark,
    bool isDesktop,
  ) {
    final bool isReadOnly = onRatingChanged == null;
    final ratingColor = _getRatingColor(rating);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rating > 0
              ? ratingColor.withValues(alpha: 0.3)
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(
              alpha: 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Lexend',
                  ),
                ),
                if (rating > 0)
                  Text(
                    _getRatingInfo(rating)['text']!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ratingColor,
                      fontFamily: 'Lexend',
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < rating;
              return GestureDetector(
                onTap: isReadOnly
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onRatingChanged!(index + 1);
                      },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? AppColors.warning : Colors.grey[400],
                    size: isDesktop ? 26.sp : 22.sp,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
