import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/common/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_input_field.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String emailOrPhone;

  const VerifyCodeScreen({
    super.key,
    required this.emailOrPhone,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  String _otpCode = '';
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _remainingSeconds = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleResendCode() {
    if (_remainingSeconds == 0) {
      context.read<AuthBloc>().add(
            ResendCodeRequested(emailOrPhone: widget.emailOrPhone),
          );
      _startCountdown();
    }
  }

  void _handleConfirm() {
    if (_otpCode.length == 6) {
      context.read<AuthBloc>().add(
            VerifyCodeSubmitted(
              code: _otpCode,
              emailOrPhone: widget.emailOrPhone,
            ),
          );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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
              if (state is CodeVerified) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.resetPassword,
                  arguments: {
                    'emailOrPhone': state.emailOrPhone,
                    'verificationCode': state.verificationCode,
                  },
                );
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        SizedBox(width: AppSizes.paddingSmall),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: isDesktop ? 100.w : (isTablet ? 60.w : AppSizes.paddingMedium),
                    right: isDesktop ? 100.w : (isTablet ? 60.w : AppSizes.paddingMedium),
                    top: AppSizes.paddingMedium,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingMedium,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 600 : (isTablet ? 500 : double.infinity),
                    ),
                    child: Column(
                      children: [
                        
                        _buildLogo(isDesktop),
                        SizedBox(height: isDesktop ? 40.h : AppSizes.paddingExtraLarge),

                        
                        _buildHeader(context, isDark, isDesktop),
                        SizedBox(height: isDesktop ? 40.h : AppSizes.paddingExtraLarge),

                        
                        _buildOtpInput(),
                        SizedBox(height: isDesktop ? 40.h : AppSizes.paddingExtraLarge),

                        
                        _buildConfirmButton(isDesktop),
                        SizedBox(height: AppSizes.paddingLarge),

                        
                        _buildResendSection(context, isDark),
                      ],
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

  Widget _buildLogo(bool isDesktop) {
    return Container(
      width: isDesktop ? 80.w : 64.w,
      height: isDesktop ? 80.w : 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: isDesktop ? 80.w : 64.w,
          height: isDesktop ? 80.w : 64.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isDesktop) {
    return Column(
      children: [
        Text(
          'Xác thực tài khoản',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 32.sp : 28.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Lexend',
          ),
        ),
        SizedBox(height: AppSizes.paddingSmall),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? AppSizes.textLg : AppSizes.textBase,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontFamily: 'Lexend',
            ),
            children: [
              const TextSpan(
                text: 'Một mã xác thực đã được gửi đến email ',
              ),
              TextSpan(
                text: widget.emailOrPhone,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const TextSpan(
                text: '. Vui lòng kiểm tra và nhập mã vào bên dưới.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return OtpInputField(
      length: 6,
      onChanged: (value) {
        setState(() {
          _otpCode = value;
        });
      },
      onCompleted: (value) {
        setState(() {
          _otpCode = value;
        });
      },
    );
  }

  Widget _buildConfirmButton(bool isDesktop) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isEnabled = _otpCode.length == 6;

        return AppButton(
          text: 'Xác nhận',
          onPressed: isEnabled ? _handleConfirm : null,
          isLoading: state is AuthLoading,
          width: double.infinity,
          height: isDesktop ? 56.h : 48.h,
        );
      },
    );
  }

  Widget _buildResendSection(BuildContext context, bool isDark) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: AppSizes.textSm,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          fontFamily: 'Lexend',
        ),
        children: [
          const TextSpan(text: 'Không nhận được mã? '),
          WidgetSpan(
            child: GestureDetector(
              onTap: _handleResendCode,
              child: Text(
                'Gửi lại',
                style: TextStyle(
                  fontSize: AppSizes.textSm,
                  fontWeight: FontWeight.w600,
                  color: _remainingSeconds == 0
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontFamily: 'Lexend',
                ),
              ),
            ),
          ),
          const TextSpan(text: ' sau '),
          TextSpan(
            text: _formatTime(_remainingSeconds),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}


