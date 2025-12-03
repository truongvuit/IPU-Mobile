import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String? role;
  final String? userId;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.role,
    this.userId,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, role, userId];
}
