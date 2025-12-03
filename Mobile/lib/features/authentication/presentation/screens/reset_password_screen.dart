import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_strength_indicator.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String emailOrPhone;
  final String verificationCode;

  const ResetPasswordScreen({
    super.key,
    required this.emailOrPhone,
    required this.verificationCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _passwordValue = '';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ResetPasswordSubmitted(
              newPassword: _newPasswordController.text,
              confirmPassword: _confirmPasswordController.text,
              verificationCode: widget.verificationCode,
              emailOrPhone: widget.emailOrPhone,
            ),
          );
    }
  }

  bool _isPasswordValid() {
    final password = _newPasswordController.text;
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'\d'));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final isDesktop = constraints.maxWidth >= 1024;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is PasswordResetSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đặt lại mật khẩu thành công!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 600 : (isTablet ? 500 : double.infinity),
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(context, isDark),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(
                            left: isDesktop ? 100.w : (isTablet ? 60.w : AppSizes.paddingMedium),
                            right: isDesktop ? 100.w : (isTablet ? 60.w : AppSizes.paddingMedium),
                            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingMedium,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: isDesktop ? AppSizes.paddingExtraLarge : AppSizes.paddingLarge),

                                _buildHeadline(context, isDark, isDesktop),
                                SizedBox(height: AppSizes.paddingSmall),

                                _buildBodyText(context, isDark, isDesktop),
                                SizedBox(height: AppSizes.paddingLarge),

                                _buildPasswordFields(isDark),
                                SizedBox(height: AppSizes.paddingLarge),

                                PasswordStrengthIndicator(password: _passwordValue),
                                SizedBox(height: AppSizes.paddingExtraLarge),
                              ],
                            ),
                          ),
                        ),
                      ),

                      _buildSubmitButton(isDesktop),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.paddingMedium).copyWith(bottom: AppSizes.paddingSmall),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context, bool isDark, bool isDesktop) {
    return Text(
      'Tạo Mật Khẩu Mới',
      style: TextStyle(
        fontSize: isDesktop ? 40.sp : 32.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'Lexend',
        height: 1.2,
      ),
    );
  }

  Widget _buildBodyText(BuildContext context, bool isDark, bool isDesktop) {
    return Text(
      'Vui lòng nhập mật khẩu mới cho tài khoản của bạn. Mật khẩu phải đáp ứng các yêu cầu bảo mật dưới đây.',
      style: TextStyle(
        fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        fontFamily: 'Lexend',
        height: 1.5,
      ),
    );
  }

  Widget _buildPasswordFields(bool isDark) {
    return Column(
      children: [
        CustomTextField(
          label: 'Mật khẩu mới',
          hintText: 'Nhập mật khẩu mới',
          controller: _newPasswordController,
          obscureText: true,
          showPasswordToggle: true,
          onChanged: (value) {
            setState(() {
              _passwordValue = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu mới';
            }
            if (value.length < 8) {
              return 'Mật khẩu phải có ít nhất 8 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.paddingMedium),

        CustomTextField(
          label: 'Xác nhận mật khẩu mới',
          hintText: 'Nhập lại mật khẩu mới',
          controller: _confirmPasswordController,
          obscureText: true,
          showPasswordToggle: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _newPasswordController.text) {
              return 'Mật khẩu không trùng khớp';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium).copyWith(top: AppSizes.paddingExtraLarge),
      width: double.infinity,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthButton(
            text: 'Xác Nhận',
            onPressed: _isPasswordValid() ? _handleSubmit : null,
            isLoading: state is AuthLoading,
            width: double.infinity,
            height: isDesktop ? 56.h : 48.h,
          );
        },
      ),
    );
  }
}


