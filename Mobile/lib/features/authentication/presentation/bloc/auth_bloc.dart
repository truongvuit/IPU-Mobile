import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  Timer? _resendTimer;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyCodeSubmitted>(_onVerifyCodeSubmitted);
    on<ResendCodeRequested>(_onResendCodeRequested);
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );

      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(AuthFailure(message: 'Đã xảy ra lỗi: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.logout();

      
      if (!isClosed) {
        result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (_) => emit(const AuthUnauthenticated()),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(AuthFailure(message: 'Đã xảy ra lỗi khi đăng xuất: $e'));
      }
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      
      final result = await authRepository.forgotPassword(
        email: event.emailOrPhone,
      );

      result.fold((failure) => emit(AuthFailure(message: failure.message)), (
        _,
      ) {
        emit(VerificationCodeSent(emailOrPhone: event.emailOrPhone));
        _startResendCountdown(emit);
      });
    } catch (e) {
      emit(AuthFailure(message: 'Đã xảy ra lỗi: $e'));
    }
  }

  Future<void> _onVerifyCodeSubmitted(
    VerifyCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      
      final result = await authRepository.verifyResetCode(code: event.code);

      result.fold((failure) => emit(AuthFailure(message: failure.message)), (
        isValid,
      ) {
        if (isValid) {
          emit(
            CodeVerified(
              emailOrPhone: event.emailOrPhone,
              verificationCode: event.code,
            ),
          );
        } else {
          emit(const AuthFailure(message: 'Mã xác thực không hợp lệ'));
        }
      });
    } catch (e) {
      emit(AuthFailure(message: 'Mã xác thực không chính xác'));
    }
  }

  Future<void> _onResendCodeRequested(
    ResendCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await authRepository.resendCode(email: event.emailOrPhone);

      result.fold((failure) => emit(AuthFailure(message: failure.message)), (
        _,
      ) {
        emit(VerificationCodeSent(emailOrPhone: event.emailOrPhone));
        _startResendCountdown(emit);
      });
    } catch (e) {
      emit(AuthFailure(message: 'Không thể gửi lại mã'));
    }
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.newPassword != event.confirmPassword) {
      emit(const AuthFailure(message: 'Mật khẩu không trùng khớp'));
      return;
    }

    if (!_isPasswordStrong(event.newPassword)) {
      emit(
        const AuthFailure(
          message: 'Mật khẩu phải đáp ứng đủ các yêu cầu bảo mật',
        ),
      );
      return;
    }

    emit(const AuthLoading());

    try {
      
      final result = await authRepository.resetPassword(
        code: event.verificationCode,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (_) => emit(const PasswordResetSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: 'Đã xảy ra lỗi khi đặt lại mật khẩu'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await authRepository.getCurrentUser();

      result.fold((failure) => emit(const AuthUnauthenticated()), (user) {
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      });
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!_isPasswordStrong(event.newPassword)) {
      emit(
        const AuthFailure(
          message: 'Mật khẩu mới phải đáp ứng đủ các yêu cầu bảo mật',
        ),
      );
      return;
    }

    emit(const AuthLoading());

    try {
      final result = await authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (_) => emit(const PasswordResetSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: 'Đã xảy ra lỗi khi đổi mật khẩu: $e'));
    }
  }

  void _startResendCountdown(Emitter<AuthState> emit) {
    _resendTimer?.cancel();
    int remainingSeconds = 60;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSeconds--;

      if (remainingSeconds <= 0) {
        timer.cancel();
      } else {
        emit(ResendCodeCountdown(remainingSeconds: remainingSeconds));
      }
    });
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;

    if (!password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]'))) {
      return false;
    }

    if (!password.contains(RegExp(r'\d'))) {
      return false;
    }

    return true;
  }
}
