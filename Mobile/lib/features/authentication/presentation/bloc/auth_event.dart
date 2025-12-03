import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String emailOrPhone;

  const ForgotPasswordRequested({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

class VerifyCodeSubmitted extends AuthEvent {
  final String code;
  final String emailOrPhone;

  const VerifyCodeSubmitted({required this.code, required this.emailOrPhone});

  @override
  List<Object?> get props => [code, emailOrPhone];
}

class ResendCodeRequested extends AuthEvent {
  final String emailOrPhone;

  const ResendCodeRequested({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String newPassword;
  final String confirmPassword;
  final String verificationCode;
  final String emailOrPhone;

  const ResetPasswordSubmitted({
    required this.newPassword,
    required this.confirmPassword,
    required this.verificationCode,
    required this.emailOrPhone,
  });

  @override
  List<Object?> get props => [
    newPassword,
    confirmPassword,
    verificationCode,
    emailOrPhone,
  ];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
