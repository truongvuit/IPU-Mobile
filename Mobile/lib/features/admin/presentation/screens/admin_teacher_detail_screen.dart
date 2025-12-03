import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/auth/models/user_role.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/admin_teacher.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_teacher_form_screen.dart';

class AdminTeacherDetailScreen extends StatefulWidget {
  final AdminTeacher teacher;

  const AdminTeacherDetailScreen({super.key, required this.teacher});

  @override
  State<AdminTeacherDetailScreen> createState() =>
      _AdminTeacherDetailScreenState();
}

class _AdminTeacherDetailScreenState extends State<AdminTeacherDetailScreen> {
  bool _showPassword = false;
  UserRole? _currentUserRole;
  
  bool get _isAdmin => _currentUserRole?.isAdmin == true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
    _loadTeacherDetail();
  }
  
  void _loadCurrentUserRole() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      _currentUserRole = UserRole.fromString(authState.user.role);
    }
  }

  void _loadTeacherDetail() {
    context.read<AdminBloc>().add(LoadTeacherDetail(widget.teacher.id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          AdminTeacher teacher = widget.teacher;
          if (state is TeacherDetailLoaded) {
            teacher = state.teacher;
          }

          return CustomScrollView(
            slivers: [
              
              SliverAppBar(
                expandedHeight: 200.h,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.h),
                          
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CustomImage(
                                imageUrl: teacher.avatarUrl ?? '',
                                width: 80.r,
                                height: 80.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                            ),
                            child: Text(
                              teacher.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              teacher.statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminTeacherFormScreen(teacher: teacher),
                        ),
                      ).then((_) => _loadTeacherDetail());
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'delete') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chức năng xóa đang phát triển'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa giảng viên'),
                      ),
                    ],
                  ),
                ],
              ),

              
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildStatsSection(context, teacher),

                      SizedBox(height: 24.h),

                      
                      _buildSection(
                        context,
                        theme,
                        isDark,
                        title: 'Thông tin cá nhân',
                        icon: Icons.person,
                        child: _buildPersonalInfoContent(
                          context,
                          theme,
                          isDark,
                          teacher,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      
                      _buildSection(
                        context,
                        theme,
                        isDark,
                        title: 'Thông tin liên hệ',
                        icon: Icons.contact_phone,
                        child: _buildContactInfoContent(
                          context,
                          theme,
                          isDark,
                          teacher,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      
                      _buildSection(
                        context,
                        theme,
                        isDark,
                        title: 'Bằng cấp & Chuyên môn',
                        icon: Icons.school,
                        child: _buildQualificationsContent(
                          context,
                          theme,
                          isDark,
                          teacher,
                        ),
                      ),

                      
                      if (teacher.accountInfo != null && _isAdmin) ...[
                        SizedBox(height: 16.h),
                        _buildSection(
                          context,
                          theme,
                          isDark,
                          title: 'Thông tin tài khoản',
                          icon: Icons.account_circle,
                          child: _buildAccountInfoContent(
                            context,
                            theme,
                            isDark,
                            teacher,
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      
                      _buildSectionHeader(
                        context,
                        'Lịch dạy hôm nay',
                        teacher.todaySchedule.length > 3
                            ? () => _showAllSchedules(
                                context,
                                teacher.todaySchedule,
                              )
                            : () {},
                      ),
                      SizedBox(height: AppSizes.p12),
                      _buildTodaySchedule(
                        context,
                        isDark,
                        teacher.todaySchedule.take(3).toList(),
                        teacher.todaySchedule.length,
                      ),

                      SizedBox(height: 24.h),

                      
                      _buildSectionHeader(
                        context,
                        'Đánh giá gần đây',
                        teacher.recentReviews.length > 3
                            ? () => _showAllReviews(
                                context,
                                teacher.recentReviews,
                              )
                            : () {},
                      ),
                      SizedBox(height: AppSizes.p12),
                      _buildRecentReviews(
                        context,
                        isDark,
                        teacher.recentReviews.take(3).toList(),
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  
  Widget _buildStatsSection(BuildContext context, AdminTeacher teacher) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSizes.p12,
      crossAxisSpacing: AppSizes.p12,
      childAspectRatio: 2.0,
      children: [
        _buildStatCard(
          context,
          'Lớp đang dạy',
          teacher.activeClasses.toString(),
          Icons.class_,
          AppColors.primary,
        ),
        _buildStatCard(
          context,
          'Tổng học viên',
          teacher.totalStudents.toString(),
          Icons.people,
          AppColors.success,
        ),
        _buildStatCard(
          context,
          'Đánh giá TB',
          teacher.rating > 0 ? teacher.rating.toStringAsFixed(1) : '-',
          Icons.star,
          AppColors.warning,
        ),
        _buildStatCard(
          context,
          'Số đánh giá',
          teacher.totalReviews.toString(),
          Icons.rate_review,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: AppSizes.p8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.textXs,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Container(
            padding: EdgeInsets.all(AppSizes.p12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMedium),
                topRight: Radius.circular(AppSizes.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: AppColors.primary),
                SizedBox(width: AppSizes.p8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(padding: EdgeInsets.all(AppSizes.p16), child: child),
        ],
      ),
    );
  }

  
  Widget _buildPersonalInfoContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminTeacher teacher,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.badge,
          label: 'Mã giảng viên',
          value: teacher.id,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.person,
          label: 'Họ và tên',
          value: teacher.fullName,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.cake,
          label: 'Ngày sinh',
          value: teacher.dateOfBirth != null
              ? dateFormat.format(teacher.dateOfBirth!)
              : 'Chưa cập nhật',
        ),
      ],
    );
  }

  
  Widget _buildContactInfoContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminTeacher teacher,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.email,
          label: 'Email',
          value: teacher.email ?? 'Chưa cập nhật',
          canCopy: teacher.email != null,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.phone,
          label: 'Số điện thoại',
          value: teacher.phoneNumber ?? 'Chưa cập nhật',
          canCopy: teacher.phoneNumber != null,
        ),
      ],
    );
  }

  
  Widget _buildQualificationsContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminTeacher teacher,
  ) {
    if (teacher.qualificationsList.isEmpty) {
      return Text(
        teacher.qualifications ?? 'Chưa cập nhật thông tin bằng cấp',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: teacher.qualificationsList.map((qual) {
        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.p8),
          padding: EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.gray800.withOpacity(0.5)
                : AppColors.gray100,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Row(
            children: [
              Icon(Icons.school, size: 20.sp, color: AppColors.primary),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      qual.degreeName ?? 'Bằng cấp',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (qual.level != null) ...[
                      SizedBox(height: 2),
                      Text(
                        'Trình độ: ${qual.level}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  
  Widget _buildAccountInfoContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminTeacher teacher,
  ) {
    final accountInfo = teacher.accountInfo!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      children: [
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.account_circle,
          label: 'Tên đăng nhập',
          value: accountInfo.username ?? 'N/A',
          canCopy: accountInfo.username != null,
        ),
        
        if (accountInfo.password != null)
          _buildPasswordRow(theme, isDark, accountInfo.password!),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.security,
          label: 'Vai trò',
          value: _getRoleText(accountInfo.role),
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.verified_user,
          label: 'Trạng thái xác thực',
          value: accountInfo.isVerified ? 'Đã xác thực' : 'Chưa xác thực',
          valueColor: accountInfo.isVerified
              ? AppColors.success
              : AppColors.warning,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.calendar_today,
          label: 'Ngày tạo tài khoản',
          value: accountInfo.createdAt != null
              ? dateFormat.format(accountInfo.createdAt!)
              : 'N/A',
        ),
      ],
    );
  }

  Widget _buildPasswordRow(ThemeData theme, bool isDark, String password) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock,
            size: 18.sp,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mật khẩu (đã mã hóa)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _showPassword ? password : '••••••••••••••••',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                        maxLines: _showPassword ? 3 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                        size: 18.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 18.sp),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã sao chép mật khẩu'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleText(String? role) {
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return 'Quản trị viên';
      case 'TEACHER':
        return 'Giảng viên';
      case 'STUDENT':
        return 'Học viên';
      case 'EMPLOYEE':
        return 'Nhân viên';
      default:
        return role ?? 'N/A';
    }
  }

  
  Widget _buildInfoRow(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18.sp,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: valueColor,
                        ),
                      ),
                    ),
                    if (canCopy)
                      IconButton(
                        icon: Icon(Icons.copy, size: 16.sp),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép: $value'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        constraints: BoxConstraints(),
                        padding: EdgeInsets.all(4),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(onPressed: onTap, child: const Text('Xem tất cả')),
      ],
    );
  }

  
  Widget _buildTodaySchedule(
    BuildContext context,
    bool isDark,
    List<TeacherSchedule> schedule,
    int totalCount,
  ) {
    if (schedule.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Center(
          child: Text(
            'Không có lịch dạy hôm nay',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...schedule.map((item) => _buildScheduleCard(item, isDark)),
        if (totalCount > 3)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              '+${totalCount - 3} lịch khác',
              style: TextStyle(
                fontSize: AppSizes.textSm,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  void _showAllSchedules(
    BuildContext context,
    List<TeacherSchedule> schedules,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch dạy hôm nay (${schedules.length})',
                    style: TextStyle(
                      fontSize: AppSizes.textLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                ),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  return _buildScheduleCard(schedules[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllReviews(BuildContext context, List<TeacherReview> reviews) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đánh giá (${reviews.length})',
                    style: TextStyle(
                      fontSize: AppSizes.textLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMedium,
                ),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return _buildReviewCard(reviews[index], isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(TeacherSchedule schedule, bool isDark) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM');

    Color subjectColor = AppColors.primary;
    if (schedule.subject == 'TOEIC') {
      subjectColor = AppColors.success;
    } else if (schedule.subject == 'Giao tiếp') {
      subjectColor = AppColors.warning;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border(
          left: BorderSide(color: subjectColor, width: 4.w),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.p8,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Column(
              children: [
                Text(
                  dateFormat.format(schedule.startTime),
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    fontWeight: FontWeight.w600,
                    color: subjectColor,
                  ),
                ),
                Text(
                  '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}',
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    fontWeight: FontWeight.w600,
                    color: subjectColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.className,
                  style: TextStyle(
                    fontSize: AppSizes.textSm,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  schedule.classRoom ?? 'Phòng chưa xác định',
                  style: TextStyle(
                    fontSize: AppSizes.textXs,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildRecentReviews(
    BuildContext context,
    bool isDark,
    List<TeacherReview> reviews,
  ) {
    if (reviews.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Center(
          child: Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
      );
    }

    return Column(
      children: reviews.map((review) {
        return _buildReviewCard(review, isDark);
      }).toList(),
    );
  }

  Widget _buildReviewCard(TeacherReview review, bool isDark) {
    final timeAgo = _getTimeAgo(review.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CustomImage(
                  imageUrl: review.studentAvatar ?? '',
                  width: 32.r,
                  height: 32.r,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: AppSizes.p8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName,
                      style: TextStyle(
                        fontSize: AppSizes.textSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: AppSizes.textXs,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    size: AppSizes.textBase,
                    color: AppColors.warning,
                  );
                }),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: AppSizes.p8),
            Text(review.comment, style: TextStyle(fontSize: AppSizes.textSm)),
          ],
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else {
      return '${diff.inMinutes} phút trước';
    }
  }
}
