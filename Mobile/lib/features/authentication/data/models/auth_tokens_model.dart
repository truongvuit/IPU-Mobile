import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    super.role,
    super.userId,
  });

  
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      role: json['role']?.toString().toLowerCase(),
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      if (role != null) 'role': role,
      if (userId != null) 'userId': userId,
    };
  }
}
