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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ForgotPasswordRequested(
              emailOrPhone: _emailOrPhoneController.text.trim(),
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
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is VerificationCodeSent) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.verifyCode,
                  arguments: {
                    'emailOrPhone': state.emailOrPhone,
                  },
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
                            bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLarge,
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

                                _buildEmailOrPhoneInput(isDark),
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
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeadline(BuildContext context, bool isDark, bool isDesktop) {
    return Text(
      'Quên Mật Khẩu',
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
      'Nhập email hoặc số điện thoại đã đăng ký của bạn để chúng tôi có thể gửi cho bạn mã đặt lại mật khẩu.',
      style: TextStyle(
        fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        fontFamily: 'Lexend',
        height: 1.5,
      ),
    );
  }

  Widget _buildEmailOrPhoneInput(bool isDark) {
    return CustomTextField(
      label: 'Email hoặc số điện thoại',
      hintText: 'Nhập email hoặc số điện thoại',
      controller: _emailOrPhoneController,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(
        Icons.alternate_email,
        color: AppColors.textSecondary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập email hoặc số điện thoại';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      width: double.infinity,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthButton(
            text: 'Gửi mã xác nhận',
            onPressed: _handleSubmit,
            isLoading: state is AuthLoading,
            width: double.infinity,
            height: isDesktop ? 56.h : 48.h,
          );
        },
      ),
    );
  }
}

