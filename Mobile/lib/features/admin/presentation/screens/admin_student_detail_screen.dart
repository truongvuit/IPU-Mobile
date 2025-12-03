import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chi tiết học viên'),
        actions: [
          IconButton(
            onPressed: () {
              if (_currentStudent != null) {
                Navigator.pushNamed(
                  context,
                  AppRouter.adminEditStudent,
                  arguments: _currentStudent,
                ).then((result) {
                  
                  if (result == true) {
                    context.read<AdminBloc>().add(LoadStudentDetail(widget.studentId));
                  }
                });
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  SkeletonWidget.circular(size: 100.w),
                  SizedBox(height: AppSizes.paddingMedium),
                  SkeletonWidget.rectangular(height: 30.h),
                  SizedBox(height: AppSizes.paddingMedium),
                  SkeletonWidget.rectangular(height: 200.h),
                ],
              ),
            );
          }

          if (state is AdminError) {
            return Center(
              child: Padding(
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
                    Text(state.message, textAlign: TextAlign.center),
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

          if (state is StudentDetailLoaded) {
            final student = state.student;
            final classes = state.enrolledClasses;
            
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_currentStudent != student) {
                _currentStudent = student;
              }
            });

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<AdminBloc>().add(
                  LoadStudentDetail(widget.studentId),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  children: [
                    
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        children: [
                          
                          CircleAvatar(
                            radius: 50.r,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            backgroundImage:
                                student.avatarUrl != null &&
                                    student.avatarUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(student.avatarUrl!)
                                : null,
                            child:
                                student.avatarUrl == null ||
                                    student.avatarUrl!.isEmpty
                                ? Text(
                                    student.initials,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32.sp,
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: AppSizes.paddingMedium),

                          
                          Text(
                            student.fullName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.textXl,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSizes.p8),

                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email,
                                size: AppSizes.textBase,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                              SizedBox(width: AppSizes.p8),
                              Text(
                                student.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone,
                                size: AppSizes.textBase,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray600,
                              ),
                              SizedBox(width: AppSizes.p8),
                              Text(
                                student.phoneNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.paddingMedium),
                          
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                              _ContactButton(
                                icon: Icons.phone,
                                label: 'Gọi điện',
                                color: AppColors.success,
                                onTap: () => _makePhoneCall(student.phoneNumber),
                              ),
                              SizedBox(width: 16.w),
                              
                              _ContactButton(
                                icon: Icons.chat,
                                label: 'Nhắn Zalo',
                                color: const Color(0xFF0068FF), 
                                onTap: () => _openZalo(student.phoneNumber),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingMedium),

                    
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin cá nhân',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.textBase,
                            ),
                          ),
                          SizedBox(height: AppSizes.paddingMedium),
                          _InfoItem(
                            label: 'Ngày sinh',
                            value: _formatDate(student.dateOfBirth),
                            isDark: isDark,
                          ),
                          if (student.age != null)
                            _InfoItem(
                              label: 'Tuổi',
                              value: '${student.age} tuổi',
                              isDark: isDark,
                            ),
                          if (student.address != null)
                            _InfoItem(
                              label: 'Địa chỉ',
                              value: student.address!,
                              isDark: isDark,
                            ),
                          if (student.occupation != null)
                            _InfoItem(
                              label: 'Nghề nghiệp',
                              value: student.occupation!,
                              isDark: isDark,
                            ),
                          if (student.educationLevel != null)
                            _InfoItem(
                              label: 'Trình độ',
                              value: student.educationLevel!,
                              isDark: isDark,
                            ),
                          _InfoItem(
                            label: 'Ngày đăng ký',
                            value: _formatDate(student.enrollmentDate),
                            isDark: isDark,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSizes.paddingMedium),

                    
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lớp học đăng ký',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.textBase,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.p12,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                ),
                                child: Text(
                                  '${student.totalClassesEnrolled}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSizes.paddingMedium),
                          if (classes.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.paddingMedium),
                                child: Text(
                                  'Chưa đăng ký lớp học nào',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppColors.gray400
                                        : AppColors.gray600,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...classes.map((classItem) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.p12),
                                child: Material(
                                  color: isDark
                                      ? AppColors.gray700
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSmall,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.adminClassDetail,
                                        arguments: classItem.id,
                                      ).then((_) => _loadStudentDetail());
                                    },
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSmall,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(AppSizes.p12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.class_,
                                            color: AppColors.primary,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: AppSizes.p12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  classItem.name,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  classItem.schedule,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: isDark
                                                            ? AppColors.gray400
                                                            : AppColors.gray600,
                                                        fontSize:
                                                            AppSizes.textXs,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: AppSizes.textBase,
                                            color: isDark
                                                ? AppColors.gray400
                                                : AppColors.gray600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.p8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    fontSize: AppSizes.textSm,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.textSm,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: isDark ? AppColors.gray700 : AppColors.gray200,
          ),
      ],
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
