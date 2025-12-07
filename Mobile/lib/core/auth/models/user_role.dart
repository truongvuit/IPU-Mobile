
enum UserRole {
  
  admin('admin', 'Quản trị viên'),

  
  
  employee('employee', 'Nhân viên'),

  
  student('student', 'Học viên'),

  
  
  teacher('teacher', 'Giảng viên');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  
  static UserRole fromString(String value) {
    final lowerValue = value.toLowerCase();
    
    if (lowerValue == 'staff') {
      return UserRole.employee;
    }
    
    if (lowerValue == 'lecturer') {
      return UserRole.teacher;
    }
    return UserRole.values.firstWhere(
      (role) => role.value.toLowerCase() == lowerValue,
      orElse: () => UserRole.student, 
    );
  }

  
  bool get hasAdminAccess => this == UserRole.admin || this == UserRole.employee;

  
  bool get isAdmin => this == UserRole.admin;

  
  bool get isEmployee => this == UserRole.employee;

  
  @Deprecated('Use isEmployee instead')
  bool get isStaff => isEmployee;
}
