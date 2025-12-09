import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/course.dart';
import '../widgets/class_selection_bottom_sheet.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(LoadCourseDetail(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark
          ? const Color(0xFF101622)
          : const Color(0xFFF6F6F8),
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            return BlocBuilder<StudentBloc, StudentState>(
              // Ignore cart update states to prevent white screen
              buildWhen: (previous, current) {
                return current is! StudentCartUpdated;
              },
              builder: (context, state) {
                if (state is StudentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is StudentError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 32.w : 24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: isDesktop ? 80.sp : 64.sp,
                            color: AppColors.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 18.sp : 16.sp,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CourseDetailLoaded) {
                  final course = state.course;

                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            expandedHeight: isDesktop ? 320.h : 256.h,
                            pinned: true,
                            backgroundColor: isDark
                                ? const Color(0xFF101622)
                                : const Color(0xFFF6F6F8),
                            leading: IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: isDesktop ? 28.w : 24.w,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            flexibleSpace: FlexibleSpaceBar(
                              centerTitle: true,
                              title: Text(
                                'Chi tiết khóa học',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Lexend',
                                  color: Colors.white,
                                ),
                              ),
                              background: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CustomImage(
                                    imageUrl: course.imageUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    borderRadius: 0,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.3),
                                          Colors.black.withValues(alpha: 0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isDesktop ? 40.w : (isTablet ? 24.w : 0),
                                right: isDesktop ? 40.w : (isTablet ? 24.w : 0),
                                bottom: 80.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                      isDesktop ? 24.w : 16.w,
                                    ),
                                    child: Text(
                                      course.name,
                                      style: TextStyle(
                                        fontSize: isDesktop ? 36.sp : 28.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24.w : 16.w,
                                    ),
                                    child: GridView.count(
                                      crossAxisCount: isDesktop ? 4 : 2,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      mainAxisSpacing: 12.w,
                                      crossAxisSpacing: 12.w,
                                      childAspectRatio: isDesktop ? 1.2 : 1.2,
                                      children: [
                                        _buildInfoCard(
                                          icon: Icons.laptop_chromebook,
                                          title: 'Online',
                                          subtitle: 'Loại khóa học',
                                          isDark: isDark,
                                        ),
                                        _buildInfoCard(
                                          icon: Icons.category,
                                          title: course.category,
                                          subtitle: 'Danh mục',
                                          isDark: isDark,
                                        ),
                                        _buildInfoCard(
                                          icon: Icons.payments,
                                          title: currencyFormat.format(
                                            course.price,
                                          ),
                                          subtitle: 'Học phí',
                                          isDark: isDark,
                                        ),
                                        _buildInfoCard(
                                          icon: Icons.door_sliding,
                                          title: 'Đang mở đăng ký',
                                          subtitle: 'Trạng thái',
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24.w : 16.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.description,
                                          maxLines: _isExpanded ? null : 3,
                                          overflow: _isExpanded
                                              ? null
                                              : TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: isDesktop ? 18.sp : 16.sp,
                                            height: 1.5,
                                            color: isDark
                                                ? AppColors.textSecondary
                                                : AppColors.textSecondary,
                                            fontFamily: 'Lexend',
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _isExpanded = !_isExpanded;
                                            });
                                          },
                                          child: Text(
                                            _isExpanded
                                                ? 'Thu gọn'
                                                : 'Xem thêm',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Lexend',
                                              fontSize: isDesktop
                                                  ? 16.sp
                                                  : 14.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24.w : 16.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mục tiêu học tập',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 24.sp : 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontFamily: 'Lexend',
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        _buildObjective(
                                          'Đạt mục tiêu đầu ra ${course.category} một cách tự tin.',
                                          isDark,
                                          isDesktop,
                                        ),
                                        _buildObjective(
                                          'Thành thạo 4 kỹ năng Nghe, Nói, Đọc, Viết ở trình độ nâng cao.',
                                          isDark,
                                          isDesktop,
                                        ),
                                        _buildObjective(
                                          'Nắm vững các chiến thuật và kỹ năng làm bài thi hiệu quả.',
                                          isDark,
                                          isDesktop,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  // Available Classes Section
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24.w : 16.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Các lớp học',
                                              style: TextStyle(
                                                fontSize: isDesktop
                                                    ? 24.sp
                                                    : 20.sp,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                                fontFamily: 'Lexend',
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${course.availableClasses.length} lớp',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                  fontFamily: 'Lexend',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        if (course.availableClasses.isEmpty)
                                          Container(
                                            padding: EdgeInsets.all(20.w),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1F2937)
                                                  : const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppSizes.radiusMedium,
                                                  ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  color: AppColors.warning,
                                                  size: 24.sp,
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Text(
                                                    'Hiện tại không có lớp nào đang mở đăng ký. Vui lòng liên hệ trung tâm.',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: isDark
                                                          ? Colors.white70
                                                          : AppColors
                                                                .textSecondary,
                                                      fontFamily: 'Lexend',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else ...[
                                          // Show only first 3 classes to prevent layout overflow
                                          ...course.availableClasses
                                              .take(3)
                                              .map(
                                                (classInfo) => _buildClassCard(
                                                  classInfo,
                                                  course,
                                                  isDark,
                                                  isDesktop,
                                                ),
                                              ),
                                          // Show "View All" button if more than 3 classes
                                          if (course.availableClasses.length >
                                              3)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.h,
                                              ),
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _showClassSelection(
                                                      context,
                                                      course,
                                                    ),
                                                icon: const Icon(
                                                  Icons.list_alt,
                                                ),
                                                label: Text(
                                                  'Xem tất cả ${course.availableClasses.length} lớp',
                                                  style: TextStyle(
                                                    fontFamily: 'Lexend',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.primary,
                                                  side: BorderSide(
                                                    color: AppColors.primary,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12.h,
                                                    horizontal: 16.w,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppSizes.radiusMedium,
                                                        ),
                                                  ),
                                                  minimumSize: Size(
                                                    double.infinity,
                                                    48.h,
                                                  ),
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
                        ],
                      ),

                      // Bottom action bar with cart button
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(
                                    0xFF101622,
                                  ).withValues(alpha: 0.95)
                                : Colors.white.withValues(alpha: 0.95),
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Price display
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Học phí',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(course.price),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontFamily: 'Lexend',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Choose class button
                              ElevatedButton.icon(
                                onPressed: course.availableClasses.isNotEmpty
                                    ? () => _showClassSelection(context, course)
                                    : null,
                                icon: const Icon(
                                  Icons.class_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  course.availableClasses.isNotEmpty
                                      ? 'Chọn lớp để đăng ký'
                                      : 'Không có lớp',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 50),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  void _showClassSelection(BuildContext context, Course course) {
    ClassSelectionBottomSheet.show(context, course);
  }

  Widget _buildClassCard(
    CourseClassInfo classInfo,
    Course course,
    bool isDark,
    bool isDesktop,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final hasSlots = classInfo.hasAvailableSlots;
    final slotsText = classInfo.maxCapacity != null
        ? '${classInfo.currentEnrollment ?? 0}/${classInfo.maxCapacity}'
        : 'Không giới hạn';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  classInfo.className,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: hasSlots
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hasSlots ? 'Còn chỗ' : 'Đã đầy',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: hasSlots ? AppColors.success : AppColors.error,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Info grid
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              if (classInfo.instructorName != null)
                _buildMiniInfo(
                  Icons.person_outline,
                  classInfo.instructorName!,
                  isDark,
                ),
              if (classInfo.schedulePattern != null)
                _buildMiniInfo(
                  Icons.calendar_today_outlined,
                  classInfo.schedulePattern!,
                  isDark,
                ),
              if (classInfo.startDate != null)
                _buildMiniInfo(
                  Icons.event_outlined,
                  dateFormat.format(classInfo.startDate!),
                  isDark,
                ),
              _buildMiniInfo(Icons.people_outline, slotsText, isDark),
            ],
          ),

          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasSlots
                      ? () => _addClassToCart(classInfo, course)
                      : null,
                  icon: Icon(Icons.add_shopping_cart, size: 16.sp),
                  label: Text(
                    'Thêm vào giỏ',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasSlots
                      ? () => _enrollClass(classInfo, course)
                      : null,
                  icon: Icon(Icons.flash_on, size: 16.sp),
                  label: Text(
                    'Đăng ký ngay',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
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

  Widget _buildMiniInfo(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.grey[300] : AppColors.textSecondary,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  void _addClassToCart(CourseClassInfo classInfo, Course course) {
    final bloc = context.read<StudentBloc>();

    if (bloc.isInCart(classInfo.classId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lớp học này đã có trong giỏ hàng'),
          backgroundColor: AppColors.info,
        ),
      );
      return;
    }

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

  void _enrollClass(CourseClassInfo classInfo, Course course) {
    Navigator.of(context).pushNamed(
      AppRouter.studentCheckout,
      arguments: {
        'classIds': [classInfo.classId],
        'courseName': course.name,
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondary : AppColors.textSecondary,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjective(String text, bool isDark, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: isDesktop ? 28.sp : 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: isDesktop ? 16.sp : 14.sp,
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.textSecondary,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
