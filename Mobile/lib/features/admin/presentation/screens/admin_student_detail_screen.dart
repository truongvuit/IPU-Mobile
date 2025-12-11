import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/admin_icon_action.dart';

import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/entities/admin_student.dart';

class AdminStudentDetailScreen extends StatefulWidget {
  final String studentId;

  const AdminStudentDetailScreen({super.key, required this.studentId});

  @override
  State<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState extends State<AdminStudentDetailScreen> {
  AdminStudent? _currentStudent;

  @override
  void initState() {
    super.initState();
    _loadStudentDetail();
  }

  void _loadStudentDetail() {
    context.read<AdminBloc>().add(LoadStudentDetail(widget.studentId));
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thực hiện cuộc gọi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openZalo(String phoneNumber) async {
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (formattedPhone.startsWith('84')) {
      formattedPhone = '0${formattedPhone.substring(2)}';
    } else if (formattedPhone.startsWith('+84')) {
      formattedPhone = '0${formattedPhone.substring(3)}';
    }

    final Uri zaloUri = Uri.parse('https://zalo.me/$formattedPhone');

    if (await canLaunchUrl(zaloUri)) {
      await launchUrl(zaloUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở Zalo. Vui lòng cài đặt ứng dụng Zalo'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
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
          if (state is AdminLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 48.sp, color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text('Đang tải thông tin...', style: TextStyle(fontSize: 14.sp)),
                ],
              ),
            );
          }

          if (state is AdminError) {
            return _buildErrorState(context, state.message);
          }

          if (state is StudentDetailLoaded) {
            final student = state.student;
            final classes = state.enrolledClasses;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_currentStudent != student) {
                _currentStudent = student;
              }
            });

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
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 40.h),
                            
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 36.r,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.3,
                                ),
                                backgroundImage:
                                    student.avatarUrl != null &&
                                        student.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        student.avatarUrl!,
                                      )
                                    : null,
                                child:
                                    student.avatarUrl == null ||
                                        student.avatarUrl!.isEmpty
                                    ? Text(
                                        student.initials,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24.sp,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingMedium,
                              ),
                              child: Text(
                                student.fullName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
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
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${student.totalClassesEnrolled} lớp đang học',
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
                      onPressed: () async {
                        if (_currentStudent != null) {
                          final bloc = context.read<AdminBloc>();
                          final result = await Navigator.pushNamed(
                            context,
                            AppRouter.adminEditStudent,
                            arguments: _currentStudent,
                          );
                          if (!mounted) return;
                          if (result == true) {
                            bloc.add(LoadStudentDetail(widget.studentId));
                          }
                        }
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
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Xóa học viên',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
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
                            student,
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
                            student,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        
                        _buildSection(
                          context,
                          theme,
                          isDark,
                          title: 'Thông tin học tập',
                          icon: Icons.school,
                          child: _buildEducationInfoContent(
                            context,
                            theme,
                            isDark,
                            student,
                          ),
                        ),

                        SizedBox(height: 24.h),

                        
                        _buildSectionHeader(
                          context,
                          'Lớp học đăng ký (${classes.length})',
                          classes.length > 3 ? () {} : () {},
                        ),
                        SizedBox(height: AppSizes.p12),
                        _buildEnrolledClasses(context, isDark, classes),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXLarge,
              color: AppColors.error,
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: AppSizes.paddingMedium),
            ElevatedButton(
              onPressed: () => context.read<AdminBloc>().add(
                LoadStudentDetail(widget.studentId),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildQuickContactButtons(BuildContext context, AdminStudent student) {
    return Row(
      children: [
        Expanded(
          child: _ContactButton(
            icon: Icons.phone,
            label: 'Gọi điện',
            color: AppColors.success,
            onTap: () => _makePhoneCall(student.phoneNumber),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ContactButton(
            icon: Icons.chat,
            label: 'Nhắn Zalo',
            color: const Color(0xFF0068FF),
            onTap: () => _openZalo(student.phoneNumber),
          ),
        ),
      ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
              color: AppColors.primary.withValues(alpha: 0.1),
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
    AdminStudent student,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.badge,
          label: 'Mã học viên',
          value: student.id,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.person,
          label: 'Họ và tên',
          value: student.fullName,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.cake,
          label: 'Ngày sinh',
          value: _formatDate(student.dateOfBirth),
        ),
        if (student.age != null)
          _buildInfoRow(
            theme,
            isDark,
            icon: Icons.calendar_today,
            label: 'Tuổi',
            value: '${student.age} tuổi',
          ),
        if (student.address != null && student.address!.isNotEmpty)
          _buildInfoRow(
            theme,
            isDark,
            icon: Icons.location_on,
            label: 'Địa chỉ',
            value: student.address!,
          ),
      ],
    );
  }

  
  Widget _buildContactInfoContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminStudent student,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.email,
          label: 'Email',
          value: student.email,
          canCopy: true,
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.phone,
          label: 'Số điện thoại',
          value: student.phoneNumber,
          canCopy: true,
        ),
      ],
    );
  }

  
  Widget _buildEducationInfoContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AdminStudent student,
  ) {
    return Column(
      children: [
        if (student.occupation != null && student.occupation!.isNotEmpty)
          _buildInfoRow(
            theme,
            isDark,
            icon: Icons.work,
            label: 'Nghề nghiệp',
            value: student.occupation!,
          ),
        if (student.educationLevel != null &&
            student.educationLevel!.isNotEmpty)
          _buildInfoRow(
            theme,
            isDark,
            icon: Icons.school,
            label: 'Trình độ học vấn',
            value: student.educationLevel!,
          ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.event,
          label: 'Ngày đăng ký',
          value: _formatDate(student.enrollmentDate),
        ),
        _buildInfoRow(
          theme,
          isDark,
          icon: Icons.class_,
          label: 'Tổng số lớp',
          value: '${student.totalClassesEnrolled} lớp',
        ),
      ],
    );
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
            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
          ),
          SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral600,
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
                      AdminIconAction(
                        icon: Icons.copy,
                        iconSize: 16.sp,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã sao chép: $value'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
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
      ],
    );
  }

  
  Widget _buildEnrolledClasses(
    BuildContext context,
    bool isDark,
    List<dynamic> classes,
  ) {
    if (classes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.class_outlined,
                size: 48.sp,
                color: isDark ? AppColors.neutral600 : AppColors.neutral400,
              ),
              SizedBox(height: 8.h),
              Text(
                'Chưa đăng ký lớp học nào',
                style: TextStyle(
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: classes.map((classItem) {
        return _buildClassCard(context, classItem, isDark);
      }).toList(),
    );
  }

  Widget _buildClassCard(BuildContext context, dynamic classItem, bool isDark) {
    final theme = Theme.of(context);
    
    
    final String classId = classItem.id?.toString() ?? '';
    final String className = classItem.name?.toString() ?? 'N/A';
    final String schedule = classItem.schedule?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: classId.isNotEmpty ? () {
            Navigator.pushNamed(
              context,
              AppRouter.adminClassDetail,
              arguments: classId,
            ).then((_) => _loadStudentDetail());
          } : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p12),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.class_,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: AppSizes.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        className,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (schedule.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14.sp,
                              color: isDark
                                  ? AppColors.neutral400
                                  : AppColors.neutral600,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                schedule,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.neutral400
                                      : AppColors.neutral600,
                                  fontSize: AppSizes.textXs,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
