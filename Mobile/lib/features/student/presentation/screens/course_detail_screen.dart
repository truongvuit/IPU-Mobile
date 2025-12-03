import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';

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

  Future<void> _openRegistrationWebsite(String courseId) async {
    final url = Uri.parse(
      '${AppConstants.courseRegistrationWebUrl}/$courseId/register',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không thể mở trang đăng ký. Vui lòng thử lại sau.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
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
                                      childAspectRatio: isDesktop ? 1.2 : 1.5,
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

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isDesktop ? 24.w : 16.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Giảng viên',
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
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.2),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              course.teacherName ??
                                                  'Chưa có thông tin',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Colors.white
                                                    : AppColors.textPrimary,
                                                fontFamily: 'Lexend',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF101622).withValues(alpha: 0.8)
                                : const Color(
                                    0xFFF6F6F8,
                                  ).withValues(alpha: 0.8),
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openRegistrationWebsite(widget.courseId),
                            icon: const Icon(Icons.open_in_new, size: 20),
                            label: const Text(
                              'Đăng ký khóa học',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusMedium,
                                ),
                              ),
                            ),
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
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Lexend',
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
