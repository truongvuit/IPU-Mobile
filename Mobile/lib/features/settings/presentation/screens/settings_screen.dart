import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatelessWidget {
  final String userRole;
  final bool isEmbedded;

  const SettingsScreen({
    super.key,
    this.userRole = 'student',
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.welcome,
            (route) => false,
          );
        } else if (state is AuthFailure) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đăng xuất: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SettingsError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cài đặt')),
            body: Center(child: Text(state.message)),
          );
        }

        final settings = state is SettingsLoaded
            ? state.settings
            : state is SettingsUpdated
            ? state.settings
            : null;

        if (settings == null) {
          context.read<SettingsBloc>().add(const LoadSettings());
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop
                          ? 800
                          : (isTablet ? 700 : double.infinity),
                    ),
                    child: Column(
                      children: [
                        
                        Container(
                          padding: EdgeInsets.fromLTRB(
                            isDesktop
                                ? AppSizes.paddingLarge
                                : AppSizes.paddingMedium,
                            AppSizes.paddingMedium,
                            isDesktop
                                ? AppSizes.paddingLarge
                                : AppSizes.paddingMedium,
                            AppSizes.paddingSmall,
                          ),
                          child: Row(
                            children: [
                              if (!isEmbedded)
                                InkWell(
                                  onTap: () {
                                    
                                    String dashboardRoute;
                                    final role = userRole.toLowerCase();
                                    if (role == 'teacher') {
                                      dashboardRoute =
                                          AppRouter.teacherDashboard;
                                    } else if (role == 'admin' ||
                                        role == 'employee') {
                                      dashboardRoute = AppRouter.adminHome;
                                    } else {
                                      dashboardRoute =
                                          AppRouter.studentDashboard;
                                    }

                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      dashboardRoute,
                                      (route) => false,
                                    );
                                  },
                                  child: Container(
                                    width: 40.w,
                                    height: 40.w,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(right: 16.w),
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: AppSizes.iconMedium,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  'Cài đặt',
                                  textAlign: isEmbedded
                                      ? TextAlign.center
                                      : TextAlign.left,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop
                                            ? AppSizes.text3Xl
                                            : AppSizes.text2Xl,
                                      ),
                                ),
                              ),
                              if (!isEmbedded) SizedBox(width: 40.w),
                            ],
                          ),
                        ),

                        
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop
                                  ? AppSizes.paddingExtraLarge
                                  : (isTablet
                                        ? AppSizes.paddingLarge
                                        : AppSizes.paddingMedium),
                              vertical: AppSizes.paddingMedium,
                            ),
                            children: [
                              
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                ),
                                child: Text(
                                  'Giao diện',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop
                                            ? AppSizes.textXl
                                            : AppSizes.textLg,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingSmall),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                        vertical: isDesktop
                                            ? AppSizes.paddingSmall
                                            : AppSizes.paddingExtraSmall,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.dark_mode,
                                          size: AppSizes.iconMedium,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        'Chế độ tối',
                                        style: TextStyle(
                                          fontSize: AppSizes.textLg,
                                        ),
                                      ),
                                      trailing: Switch(
                                        value: settings.isDarkMode,
                                        onChanged: (value) {
                                          context.read<SettingsBloc>().add(
                                            ToggleDarkMode(value),
                                          );
                                        },
                                        activeThumbColor: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingLarge),

                              
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                ),
                                child: Text(
                                  'Tài khoản & Bảo mật',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop
                                            ? AppSizes.textXl
                                            : AppSizes.textLg,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingSmall),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    
                                    if (userRole.toLowerCase() != 'admin' &&
                                        userRole.toLowerCase() !=
                                            'employee') ...[
                                      ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: AppSizes.paddingMedium,
                                          vertical: isDesktop
                                              ? AppSizes.paddingSmall
                                              : AppSizes.paddingExtraSmall,
                                        ),
                                        leading: Container(
                                          width: 40.w,
                                          height: 40.w,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.radiusSmall,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: AppSizes.iconMedium,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        title: Text(
                                          'Thông tin cá nhân',
                                          style: TextStyle(
                                            fontSize: AppSizes.textLg,
                                          ),
                                        ),
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: AppSizes.iconSmall,
                                          color: AppColors.textSecondary,
                                        ),
                                        onTap: () {
                                          final profileRoute =
                                              userRole == 'teacher'
                                              ? AppRouter.teacherProfile
                                              : AppRouter.studentProfile;
                                          Navigator.pushNamed(
                                            context,
                                            profileRoute,
                                          );
                                        },
                                      ),
                                      Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                    ],
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                        vertical: isDesktop
                                            ? AppSizes.paddingSmall
                                            : AppSizes.paddingExtraSmall,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.lock,
                                          size: AppSizes.iconMedium,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        'Đổi mật khẩu',
                                        style: TextStyle(
                                          fontSize: AppSizes.textLg,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: AppSizes.iconSmall,
                                        color: AppColors.textSecondary,
                                      ),
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRouter.changePassword,
                                        );
                                      },
                                    ),
                                    Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                        vertical: isDesktop
                                            ? AppSizes.paddingSmall
                                            : AppSizes.paddingExtraSmall,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.logout,
                                          size: AppSizes.iconMedium,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      title: Text(
                                        'Đăng xuất',
                                        style: TextStyle(
                                          fontSize: AppSizes.textLg,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Đăng xuất'),
                                            content: const Text(
                                              'Bạn có chắc chắn muốn đăng xuất?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  
                                                  context.read<AuthBloc>().add(
                                                    const LogoutRequested(),
                                                  );
                                                },
                                                child: const Text(
                                                  'Đăng xuất',
                                                  style: TextStyle(
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingLarge),

                              
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMedium,
                                ),
                                child: Text(
                                  'Thông tin & Hỗ trợ',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop
                                            ? AppSizes.textXl
                                            : AppSizes.textLg,
                                        color: AppColors.primary,
                                      ),
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingSmall),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                        vertical: isDesktop
                                            ? AppSizes.paddingSmall
                                            : AppSizes.paddingExtraSmall,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.description,
                                          size: AppSizes.iconMedium,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        'Điều khoản dịch vụ',
                                        style: TextStyle(
                                          fontSize: AppSizes.textLg,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: AppSizes.iconSmall,
                                        color: AppColors.textSecondary,
                                      ),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRouter.settingsTerms,
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingMedium,
                                        vertical: isDesktop
                                            ? AppSizes.paddingSmall
                                            : AppSizes.paddingExtraSmall,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusSmall,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.shield,
                                          size: AppSizes.iconMedium,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      title: Text(
                                        'Chính sách bảo mật',
                                        style: TextStyle(
                                          fontSize: AppSizes.textLg,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.arrow_forward_ios,
                                        size: AppSizes.iconSmall,
                                        color: AppColors.textSecondary,
                                      ),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRouter.settingsPolicy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingExtraLarge),

                              
                              Center(
                                child: Text(
                                  'Phiên bản ứng dụng ${AppConstants.appVersion}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: AppSizes.textSm,
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      ),
    );
  }
}
