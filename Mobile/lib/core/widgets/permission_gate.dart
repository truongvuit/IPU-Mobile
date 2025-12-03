import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/models/permission.dart';
import '../auth/models/user_role.dart';
import '../auth/permission_checker.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/bloc/auth_state.dart';

class PermissionGate extends StatelessWidget {
  final Permission requiredPermission;

  final Widget child;

  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.requiredPermission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          final userRole = _extractUserRole(state.user.role);

          if (PermissionChecker.hasPermission(userRole, requiredPermission)) {
            return child;
          }
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }

  UserRole _extractUserRole(String role) {
    return UserRole.fromString(role);
  }
}

class PermissionBuilder extends StatelessWidget {
  final Permission requiredPermission;

  final Widget Function(BuildContext context, bool hasPermission) builder;

  const PermissionBuilder({
    super.key,
    required this.requiredPermission,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool hasPermission = false;

        if (state is AuthSuccess) {
          final userRole = _extractUserRole(state.user.role);
          hasPermission = PermissionChecker.hasPermission(
            userRole,
            requiredPermission,
          );
        }

        return builder(context, hasPermission);
      },
    );
  }

  UserRole _extractUserRole(String role) {
    return UserRole.fromString(role);
  }
}

class MultiPermissionGate extends StatelessWidget {
  final List<Permission> requiredPermissions;

  final bool requireAll;

  final Widget child;

  final Widget? fallback;

  const MultiPermissionGate({
    super.key,
    required this.requiredPermissions,
    this.requireAll = true,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool hasPermission = false;

        if (state is AuthSuccess) {
          final userRole = _extractUserRole(state.user.role);

          if (requireAll) {
            hasPermission = PermissionChecker.hasAllPermissions(
              userRole,
              requiredPermissions,
            );
          } else {
            hasPermission = PermissionChecker.hasAnyPermission(
              userRole,
              requiredPermissions,
            );
          }
        }

        if (hasPermission) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }

  UserRole _extractUserRole(String role) {
    return UserRole.fromString(role);
  }
}

extension PermissionContext on BuildContext {
  UserRole? get currentUserRole {
    final authState = read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      return UserRole.fromString(authState.user.role);
    }
    return null;
  }

  bool hasPermission(Permission permission) {
    final role = currentUserRole;
    if (role == null) return false;
    return PermissionChecker.hasPermission(role, permission);
  }

  bool get isAdmin => currentUserRole?.isAdmin ?? false;

  bool get isEmployee => currentUserRole?.isEmployee ?? false;

  bool get hasAdminAccess => currentUserRole?.hasAdminAccess ?? false;
}
