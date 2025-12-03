import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routing/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/permission_gate.dart';
import '../../../../../core/auth/models/permission.dart';
import '../../../domain/entities/course_detail.dart';



class AdminCourseDetailNewScreen extends StatefulWidget {
  final CourseDetail course;

  const AdminCourseDetailNewScreen({super.key, required this.course});

  @override
  State<AdminCourseDetailNewScreen> createState() => _AdminCourseDetailNewScreenState();
}

class _AdminCourseDetailNewScreenState extends State<AdminCourseDetailNewScreen> {
  late CourseDetail _course;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
  }

  Future<void> _deleteCourse(BuildContext context) async {
    if (!_course.canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể xóa khóa học có ${_course.activeClasses} lớp đang hoạt động',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa khóa học "${_course.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khóa học thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _togglePublishCourse() async {
    setState(() {
      _isPublishing = true;
    });

    
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      
      _course = CourseDetail(
        id: _course.id,
        name: _course.name,
        totalHours: _course.totalHours,
        tuitionFee: _course.tuitionFee,
        videoUrl: _course.videoUrl,
        isActive: !_course.isActive, 
        createdAt: _course.createdAt,
        createdBy: _course.createdBy,
        imageUrl: _course.imageUrl,
        description: _course.description,
        entryRequirement: _course.entryRequirement,
        exitRequirement: _course.exitRequirement,
        categoryId: _course.categoryId,
        categoryName: _course.categoryName,
        level: _course.level,
        totalClasses: _course.totalClasses,
        activeClasses: _course.activeClasses,
        totalStudents: _course.totalStudents,
        totalRevenue: _course.totalRevenue,
        averageRating: _course.averageRating,
        reviewCount: _course.reviewCount,
      );
      _isPublishing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _course.isActive 
              ? 'Đã công bố khóa học thành công!' 
              : 'Đã tạm dừng khóa học',
        ),
        backgroundColor: _course.isActive ? AppColors.success : AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chi tiết khóa học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRouter.adminCourseEdit,
                arguments: _course,
              );
            },
            tooltip: 'Chỉnh sửa',
          ),
          PermissionGate(
            requiredPermission: Permission.deleteClass,
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteCourse(context),
              tooltip: 'Xóa',
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: Container(
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
        child: SafeArea(
          child: SizedBox(
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: _isPublishing ? null : _togglePublishCourse,
              icon: _isPublishing
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _course.isActive ? Icons.pause_circle : Icons.publish,
                      color: Colors.white,
                      size: 24.sp,
                    ),
              label: Text(
                _isPublishing
                    ? 'Đang xử lý...'
                    : (_course.isActive ? 'Tạm dừng khóa học' : 'Công bố khóa học'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _course.isActive ? AppColors.warning : AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
          ),
        ),
      ),
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
                          ).withOpacity(0.1),
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
                            ).withOpacity(0.1),
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
                    mainAxisSpacing: AppSizes.p12,
                    crossAxisSpacing: AppSizes.p12,
                    childAspectRatio: 1.5,
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
                        color: isDark ? AppColors.gray300 : AppColors.gray700,
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
                        color: isDark ? AppColors.gray800 : AppColors.gray100,
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
                                    ? AppColors.gray300
                                    : AppColors.gray700,
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
                        color: isDark ? AppColors.gray800 : AppColors.gray100,
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
                                    ? AppColors.gray300
                                    : AppColors.gray700,
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
                        color: isDark ? AppColors.gray800 : AppColors.gray100,
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200.h,
      color: AppColors.gray200,
      child: Icon(Icons.school, size: 80.sp, color: AppColors.gray400),
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
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isDark ? AppColors.gray700 : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: AppSizes.p8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
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
                color: isDark ? AppColors.gray300 : AppColors.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

