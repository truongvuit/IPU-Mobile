/// User roles in the language learning center system
enum UserRole {
  /// Administrator - Full access to all features
  admin('admin', 'Quản trị viên'),

  /// Employee - Limited admin access (cannot delete, limited reports)
  /// Maps to EMPLOYEE role in database
  employee('employee', 'Nhân viên'),

  /// Student - Access to student portal
  student('student', 'Học viên'),

  /// Teacher - Access to teaching features
  /// Maps to TEACHER role in database
  teacher('teacher', 'Giảng viên');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Convert string to UserRole enum
  static UserRole fromString(String value) {
    final lowerValue = value.toLowerCase();
    // Handle legacy 'staff' mapping to 'employee'
    if (lowerValue == 'staff') {
      return UserRole.employee;
    }
    // Handle 'lecturer' mapping to 'teacher'
    if (lowerValue == 'lecturer') {
      return UserRole.teacher;
    }
    return UserRole.values.firstWhere(
      (role) => role.value.toLowerCase() == lowerValue,
      orElse: () => UserRole.student, // Default to student if unknown
    );
  }

  /// Check if role is admin or employee (has admin UI access)
  bool get hasAdminAccess => this == UserRole.admin || this == UserRole.employee;

  /// Check if role is admin (full access)
  bool get isAdmin => this == UserRole.admin;

  /// Check if role is employee (limited admin access)
  bool get isEmployee => this == UserRole.employee;

  /// Legacy: Check if role is staff (alias for isEmployee)
  @Deprecated('Use isEmployee instead')
  bool get isStaff => isEmployee;
}
