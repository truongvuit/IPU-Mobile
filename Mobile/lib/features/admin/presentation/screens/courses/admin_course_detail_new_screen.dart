import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/di/injector.dart';
import '../../../domain/entities/course_detail.dart';
import '../../../domain/entities/promotion.dart';
import '../../../domain/repositories/promotion_repository.dart';
import '../../bloc/admin_course_bloc.dart';
import '../../bloc/admin_course_state.dart';

class AdminCourseDetailNewScreen extends StatefulWidget {
  final CourseDetail course;

  const AdminCourseDetailNewScreen({super.key, required this.course});

  @override
  State<AdminCourseDetailNewScreen> createState() =>
      _AdminCourseDetailNewScreenState();
}

class _AdminCourseDetailNewScreenState
    extends State<AdminCourseDetailNewScreen> {
  late CourseDetail _course;
  late AdminCourseBloc _courseBloc;
  List<Promotion> _promotions = [];
  bool _isLoadingPromotions = true;
  bool _isClassesExpanded = false;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    _courseBloc = getIt<AdminCourseBloc>();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    try {
      final promotionRepo = getIt<PromotionRepository>();
      final result = await promotionRepo.getPromotionsByCourse(_course.id);
      result.fold(
        (failure) {
          if (mounted) {
            setState(() => _isLoadingPromotions = false);
          }
        },
        (promotions) {
          if (mounted) {
            setState(() {
              _promotions = promotions;
              _isLoadingPromotions = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPromotions = false);
      }
    }
  }

  void _onBlocStateChanged(BuildContext context, AdminCourseState state) {
    if (state is AdminCourseSuccess) {
      if (state.message.contains('Xóa')) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (state is AdminCourseError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return BlocListener<AdminCourseBloc, AdminCourseState>(
      bloc: _courseBloc,
      listener: _onBlocStateChanged,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Chi tiết khóa học')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_course.imageUrl != null)
                Image.network(
                  _course.imageUrl!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(),
                )
              else
                _buildPlaceholderImage(),

              Padding(
                padding: EdgeInsets.all(AppSizes.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _course.name,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                _course.statusColor.replaceFirst('#', '0xFF'),
                              ),
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSmall,
                            ),
                          ),
                          child: Text(
                            _course.statusText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                int.parse(
                                  _course.statusColor.replaceFirst('#', '0xFF'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.p12),

                    Row(
                      children: [
                        if (_course.level != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  _course.levelBadgeColor.replaceFirst(
                                    '#',
                                    '0xFF',
                                  ),
                                ),
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSmall,
                              ),
                            ),
                            child: Text(
                              'Cấp độ ${_course.level}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(
                                  int.parse(
                                    _course.levelBadgeColor.replaceFirst(
                                      '#',
                                      '0xFF',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        if (_course.categoryName != null)
                          Expanded(
                            child: Text(
                              _course.categoryName!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: AppSizes.p24),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.p8,
                      crossAxisSpacing: AppSizes.p8,
                      childAspectRatio: 1.8,
                      children: [
                        _buildStatCard(
                          'Học phí',
                          currencyFormat.format(_course.tuitionFee),
                          Icons.monetization_on,
                          AppColors.success,
                          isDark,
                        ),
                        _buildStatCard(
                          'Thời lượng',
                          '${_course.totalHours} giờ',
                          Icons.access_time,
                          AppColors.warning,
                          isDark,
                        ),
                        _buildStatCard(
                          'Lớp học',
                          '${_course.activeClasses}/${_course.totalClasses}',
                          Icons.class_,
                          AppColors.info,
                          isDark,
                        ),
                        _buildStatCard(
                          'Học viên',
                          '${_course.totalStudents}',
                          Icons.people,
                          AppColors.primary,
                          isDark,
                        ),
                        _buildStatCard(
                          'Doanh thu',
                          _course.formattedRevenue,
                          Icons.attach_money,
                          Colors.green,
                          isDark,
                        ),
                        _buildStatCard(
                          'Đánh giá',
                          '${_course.averageRating.toStringAsFixed(1)} ⭐',
                          Icons.star,
                          Colors.orange,
                          isDark,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.p24),

                    if (_course.description != null) ...[
                      _buildSectionTitle('Mô tả khóa học', isDark),
                      SizedBox(height: AppSizes.p12),
                      Text(
                        _course.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.neutral300
                              : AppColors.neutral700,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: AppSizes.p24),
                    ],

                    if (_course.entryRequirement != null) ...[
                      _buildSectionTitle('Yêu cầu đầu vào', isDark),
                      SizedBox(height: AppSizes.p12),
                      Container(
                        padding: EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.neutral800
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppColors.success,
                              size: 20.sp,
                            ),
                            SizedBox(width: AppSizes.p8),
                            Expanded(
                              child: Text(
                                _course.entryRequirement!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? AppColors.neutral300
                                      : AppColors.neutral700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.p16),
                    ],

                    if (_course.exitRequirement != null) ...[
                      _buildSectionTitle('Mục tiêu đầu ra', isDark),
                      SizedBox(height: AppSizes.p12),
                      Container(
                        padding: EdgeInsets.all(AppSizes.p12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.neutral800
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: AppSizes.p8),
                            Expanded(
                              child: Text(
                                _course.exitRequirement!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? AppColors.neutral300
                                      : AppColors.neutral700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.p24),
                    ],

                    if (_course.videoUrl != null) ...[
                      _buildSectionTitle('Video giới thiệu', isDark),
                      SizedBox(height: AppSizes.p12),
                      Container(
                        padding: EdgeInsets.all(AppSizes.p16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.neutral800
                              : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              color: AppColors.error,
                              size: 32.sp,
                            ),
                            SizedBox(width: AppSizes.p12),
                            Expanded(
                              child: Text(
                                _course.videoUrl!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.p24),
                    ],

                    if (_course.objectives.isNotEmpty) ...[
                      _buildSectionTitle('Mục tiêu khóa học', isDark),
                      SizedBox(height: AppSizes.p12),
                      _buildObjectivesSection(isDark),
                      SizedBox(height: AppSizes.p24),
                    ],

                    if (_course.modules.isNotEmpty) ...[
                      _buildSectionTitle('Nội dung khóa học', isDark),
                      SizedBox(height: AppSizes.p12),
                      _buildModulesSection(isDark),
                      SizedBox(height: AppSizes.p24),
                    ],

                    if (_course.classInfos.isNotEmpty) ...[
                      _buildSectionTitle(
                        'Lớp học (${_course.classInfos.length})',
                        isDark,
                      ),
                      SizedBox(height: AppSizes.p12),
                      _buildClassesSection(isDark),
                      SizedBox(height: AppSizes.p24),
                    ],

                    _buildSectionTitle(
                      'Khuyến mãi áp dụng${_promotions.isNotEmpty ? ' (${_promotions.length})' : ''}',
                      isDark,
                    ),
                    SizedBox(height: AppSizes.p12),
                    _buildPromotionsSection(isDark, currencyFormat),
                    SizedBox(height: AppSizes.p24),

                    _buildSectionTitle('Thông tin khác', isDark),
                    SizedBox(height: AppSizes.p12),
                    _buildInfoRow(
                      'Ngày tạo',
                      dateFormat.format(_course.createdAt),
                      Icons.calendar_today,
                      isDark,
                    ),
                    if (_course.createdBy != null)
                      _buildInfoRow(
                        'Người tạo',
                        _course.createdBy!,
                        Icons.person,
                        isDark,
                      ),
                    _buildInfoRow(
                      'Số đánh giá',
                      '${_course.reviewCount} đánh giá',
                      Icons.rate_review,
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectivesSection(bool isDark) {
    return Column(
      children: _course.objectives.map((objective) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSizes.p8),
          child: Container(
            padding: EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.neutral800 : AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 20.sp),
                SizedBox(width: AppSizes.p8),
                Expanded(
                  child: Text(
                    objective.name,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? AppColors.neutral300
                          : AppColors.neutral700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModulesSection(bool isDark) {
    return Column(
      children: _course.modules.asMap().entries.map((entry) {
        final index = entry.key;
        final module = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.p12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: isDark ? AppColors.neutral700 : AppColors.neutral200,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
            title: Text(
              module.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            subtitle: module.duration != null
                ? Text(
                    '${module.duration} giờ',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            children: [
              if (module.contents.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nội dung:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.p4),
                      ...module.contents.map(
                        (content) => Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? AppColors.neutral400
                                      : AppColors.neutral600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  content.name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? AppColors.neutral400
                                        : AppColors.neutral600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (module.documents.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tài liệu:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.p4),
                      ...module.documents.map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  doc.fileName ?? 'Tài liệu',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSizes.p8),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassesSection(bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final allClasses = _course.classInfos;
    final maxToShow = 2;
    final hasMore = allClasses.length > maxToShow;
    final classesToShow = _isClassesExpanded
        ? allClasses
        : allClasses.take(maxToShow).toList();

    return Column(
      children: [
        ...classesToShow.map((classInfo) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.adminClassDetail,
                arguments: classInfo.classId,
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: AppSizes.p8),
              padding: EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.neutral800 : Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: isDark ? AppColors.neutral700 : AppColors.neutral200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          classInfo.className,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: classInfo.isActive
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.neutral400.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          classInfo.status ?? 'N/A',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: classInfo.isActive
                                ? AppColors.success
                                : AppColors.neutral500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  if (classInfo.instructorName != null)
                    _buildClassInfoRow(
                      Icons.person,
                      classInfo.instructorName!,
                      isDark,
                    ),
                  if (classInfo.roomName != null)
                    _buildClassInfoRow(Icons.room, classInfo.roomName!, isDark),
                  if (classInfo.startDate != null)
                    _buildClassInfoRow(
                      Icons.calendar_today,
                      '${dateFormat.format(classInfo.startDate!)}${classInfo.endDate != null ? ' - ${dateFormat.format(classInfo.endDate!)}' : ''}',
                      isDark,
                    ),
                  if (classInfo.schedulePattern != null)
                    _buildClassInfoRow(
                      Icons.schedule,
                      classInfo.schedulePattern!,
                      isDark,
                    ),
                ],
              ),
            ),
          );
        }),
        if (hasMore)
          InkWell(
            onTap: () {
              setState(() {
                _isClassesExpanded = !_isClassesExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isClassesExpanded
                        ? 'Thu gọn'
                        : 'Xem thêm ${allClasses.length - maxToShow} lớp',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _isClassesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClassInfoRow(IconData icon, String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.neutral400 : AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200.h,
      color: AppColors.neutral200,
      child: Icon(Icons.school, size: 80.sp, color: AppColors.neutral400),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSizes.p8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral800 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.neutral700 : AppColors.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(height: 2.h),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.textSecondary),
          SizedBox(width: AppSizes.p8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.neutral300 : AppColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsSection(bool isDark, NumberFormat currencyFormat) {
    if (_isLoadingPromotions) {
      return Container(
        padding: EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Center(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_promotions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 20.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.p8),
            Text(
              'Chưa có khuyến mãi nào áp dụng',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    return Column(
      children: _promotions.map((promotion) {
        final isActive = promotion.status == PromotionStatus.active;
        final statusColor = isActive ? AppColors.success : AppColors.neutral500;
        final statusText = isActive ? 'Đang áp dụng' : promotion.status.name;

        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.p8),
          padding: EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.neutral800 : AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: isActive
                ? Border.all(color: AppColors.success.withValues(alpha: 0.5))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    size: 18.sp,
                    color: isActive ? AppColors.success : AppColors.neutral500,
                  ),
                  SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      promotion.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p8),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      promotion.code,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.p8),
                  Text(
                    promotion.discountType == DiscountType.percentage
                        ? 'Giảm ${promotion.discountValue.toInt()}%'
                        : 'Giảm ${currencyFormat.format(promotion.discountValue)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.p8),
              Text(
                '${dateFormat.format(promotion.startDate)} - ${dateFormat.format(promotion.endDate)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_course.promotionPrice != null && isActive) ...[
                SizedBox(height: AppSizes.p8),
                Row(
                  children: [
                    Text(
                      currencyFormat.format(_course.tuitionFee),
                      style: TextStyle(
                        fontSize: 12.sp,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: AppSizes.p8),
                    Text(
                      currencyFormat.format(_course.promotionPrice),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
