import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class VerificationCodeSent extends AuthState {
  final String emailOrPhone;

  const VerificationCodeSent({required this.emailOrPhone});

  @override
  List<Object?> get props => [emailOrPhone];
}

class CodeVerified extends AuthState {
  final String emailOrPhone;
  final String verificationCode;

  const CodeVerified({
    required this.emailOrPhone,
    required this.verificationCode,
  });

  @override
  List<Object?> get props => [emailOrPhone, verificationCode];
}

class PasswordResetSuccess extends AuthState {
  const PasswordResetSuccess();
}

class ResendCodeCountdown extends AuthState {
  final int remainingSeconds;

  const ResendCodeCountdown({required this.remainingSeconds});

  @override
  List<Object?> get props => [remainingSeconds];
}
