import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                String route;
                final role = state.user.role.toLowerCase();
                if (role == 'teacher') {
                  route = AppRouter.teacherDashboard;
                } else if (role == 'admin' || role == 'employee') {
                  
                  
                  route = AppRouter.adminHome;
                } else {
                  route = AppRouter.studentDashboard;
                }
                Navigator.pushReplacementNamed(context, route);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: isDesktop
                        ? 100.w
                        : (isTablet ? 60.w : AppSizes.paddingMedium),
                    right: isDesktop
                        ? 100.w
                        : (isTablet ? 60.w : AppSizes.paddingMedium),
                    top: AppSizes.paddingMedium,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                        AppSizes.paddingMedium,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop
                          ? 500
                          : (isTablet ? 450 : double.infinity),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          _buildLogoIcon(isDesktop),
                          SizedBox(
                            height: isDesktop
                                ? AppSizes.paddingExtraLarge
                                : AppSizes.paddingLarge,
                          ),

                          
                          _buildHeader(context, isDark, isDesktop),
                          SizedBox(
                            height: isDesktop
                                ? 40.h
                                : AppSizes.paddingExtraLarge,
                          ),

                          
                          _buildFormFields(isDark),
                          SizedBox(height: AppSizes.paddingMedium),

                          
                          _buildOptionsRow(context, isDark),
                          SizedBox(
                            height: isDesktop
                                ? 40.h
                                : AppSizes.paddingExtraLarge,
                          ),

                          
                          _buildLoginButton(isDesktop),
                          SizedBox(height: AppSizes.paddingExtraLarge),

                          
                          _buildVersionText(context, isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoIcon(bool isDesktop) {
    return Container(
      width: isDesktop ? 96.w : 80.w,
      height: isDesktop ? 96.w : 80.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: isDesktop ? 96.w : 80.w,
          height: isDesktop ? 96.w : 80.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop) {
    return Column(
      children: [
        Text(
          'Chào mừng trở lại!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 40.sp : 32.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Lexend',
            height: 1.2,
          ),
        ),
        SizedBox(height: AppSizes.paddingSmall),
        Text(
          'Đăng nhập để tiếp tục học tập',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(bool isDark) {
    return Column(
      children: [
        
        AppTextField(
          label: 'Email hoặc Số điện thoại',
          hintText: 'Nhập email hoặc số điện thoại',
          controller: _emailController,
          keyboardType: TextInputType.text,
          inputFormatters: [InputValidators.blockDangerousChars],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email hoặc số điện thoại';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.paddingMedium),

        
        AppTextField(
          label: 'Mật khẩu',
          hintText: 'Nhập mật khẩu của bạn',
          controller: _passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsRow(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
              ),
            ),
            SizedBox(width: AppSizes.paddingSmall),
            Text(
              'Ghi nhớ đăng nhập',
              style: TextStyle(
                fontSize: AppSizes.textSm,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontFamily: 'Lexend',
              ),
            ),
          ],
        ),

        
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRouter.forgotPassword);
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(
              fontSize: AppSizes.textSm,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              fontFamily: 'Lexend',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isDesktop) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AppButton(
          text: 'Đăng nhập',
          onPressed: _handleLogin,
          isLoading: state is AuthLoading,
          width: double.infinity,
          height: isDesktop ? 56.h : 48.h,
        );
      },
    );
  }

  Widget _buildVersionText(BuildContext context, bool isDark) {
    return Text(
      'Phiên bản 1.0.0',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: AppSizes.textSm,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        fontFamily: 'Lexend',
      ),
    );
  }
}
