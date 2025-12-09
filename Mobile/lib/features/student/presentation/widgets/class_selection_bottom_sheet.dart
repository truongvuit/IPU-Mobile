import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/course.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../../../../core/routing/app_router.dart';

/// Bottom sheet to display available classes for a course
/// Allows user to select a specific class for enrollment
class ClassSelectionBottomSheet extends StatefulWidget {
  final Course course;

  const ClassSelectionBottomSheet({super.key, required this.course});

  static Future<void> show(BuildContext context, Course course) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClassSelectionBottomSheet(course: course),
    );
  }

  @override
  State<ClassSelectionBottomSheet> createState() =>
      _ClassSelectionBottomSheetState();
}

class _ClassSelectionBottomSheetState extends State<ClassSelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CourseClassInfo> _filteredClasses = [];

  @override
  void initState() {
    super.initState();
    _filteredClasses = widget.course.availableClasses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClasses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClasses = widget.course.availableClasses;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredClasses = widget.course.availableClasses.where((classInfo) {
          return classInfo.className.toLowerCase().contains(lowerQuery) ||
              (classInfo.instructorName?.toLowerCase().contains(lowerQuery) ??
                  false) ||
              (classInfo.schedulePattern?.toLowerCase().contains(lowerQuery) ??
                  false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final totalClasses = widget.course.availableClasses.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Chọn lớp học',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalClasses lớp',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.course.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Lexend',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Học phí: ${currencyFormat.format(widget.course.price)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Search bar (only show if many classes)
            if (totalClasses > 5)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterClasses,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm lớp, giảng viên...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Lexend',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 20.sp),
                            onPressed: () {
                              _searchController.clear();
                              _filterClasses('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 8.h),

            // Filter results count
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tìm thấy ${_filteredClasses.length} lớp',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ),

            Divider(
              height: 1,
              color: isDark ? Colors.grey[700] : Colors.grey[200],
            ),

            // Classes list
            Expanded(
              child: _filteredClasses.isEmpty
                  ? _buildEmptyState(isDark, _searchController.text.isNotEmpty)
                  : ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredClasses.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final classInfo = _filteredClasses[index];
                        return _ClassCard(
                          classInfo: classInfo,
                          course: widget.course,
                          isDark: isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.class_outlined,
            size: 64.sp,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            isSearchResult
                ? 'Không tìm thấy lớp học phù hợp'
                : 'Không có lớp học nào đang mở',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearchResult
                ? 'Thử tìm kiếm với từ khóa khác'
                : 'Vui lòng liên hệ trung tâm để biết thêm thông tin',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final CourseClassInfo classInfo;
  final Course course;
  final bool isDark;

  const _ClassCard({
    required this.classInfo,
    required this.course,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasSlots = classInfo.hasAvailableSlots;
    final slotsText = classInfo.maxCapacity != null
        ? '${classInfo.currentEnrollment ?? 0}/${classInfo.maxCapacity}'
        : 'Không giới hạn';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Class name + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  classInfo.className,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              _buildStatusBadge(hasSlots),
            ],
          ),

          SizedBox(height: 10.h),

          // Compact info display
          Wrap(
            spacing: 16.w,
            runSpacing: 6.h,
            children: [
              if (classInfo.instructorName != null)
                _buildCompactInfo(
                  Icons.person_outline,
                  classInfo.instructorName!,
                ),
              if (classInfo.schedulePattern != null)
                _buildCompactInfo(Icons.schedule, classInfo.schedulePattern!),
              if (classInfo.startDate != null)
                _buildCompactInfo(
                  Icons.event,
                  dateFormat.format(classInfo.startDate!),
                ),
              _buildCompactInfo(Icons.people_outline, slotsText),
            ],
          ),

          SizedBox(height: 12.h),

          // Action buttons - more compact
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasSlots ? () => _addToCart(context) : null,
                  icon: Icon(Icons.add_shopping_cart, size: 16.sp),
                  label: Text(
                    'Thêm vào giỏ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasSlots ? () => _enrollNow(context) : null,
                  icon: Icon(Icons.flash_on, size: 16.sp),
                  label: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool hasSlots) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: hasSlots
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        hasSlots ? 'Còn chỗ' : 'Đã đầy',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: hasSlots ? AppColors.success : AppColors.error,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[300] : AppColors.textSecondary,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  void _addToCart(BuildContext context) {
    final bloc = context.read<StudentBloc>();

    // Check if already in cart
    if (bloc.isInCart(classInfo.classId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lớp học này đã có trong giỏ hàng'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

    // Add to cart
    bloc.add(
      AddCourseToCart(
        courseId: course.id,
        courseName: course.name,
        classId: classInfo.classId,
        className: classInfo.className,
        price: course.price,
        imageUrl: course.imageUrl,
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Đã thêm "${classInfo.className}" vào giỏ')),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _enrollNow(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed(
      AppRouter.studentCheckout,
      arguments: {
        'classIds': [classInfo.classId],
        'courseName': course.name,
      },
    );
  }
}
