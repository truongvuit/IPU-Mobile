import 'models/user_role.dart';
import 'models/permission.dart';

/// Permission checker - Maps roles to their allowed permissions
class PermissionChecker {
  /// Map of roles to their permissions
  static final Map<UserRole, Set<Permission>> _rolePermissions = {
    // ====================================================================
    // ADMIN - Full access to everything
    // ====================================================================
    UserRole.admin: {
      // Dashboard & Profile
      Permission.viewDashboard,

      // Class Management
      Permission.viewClasses,
      Permission.createClass,
      Permission.editClass,
      Permission.deleteClass,

      // Student Management
      Permission.viewStudents,
      Permission.createStudent,
      Permission.editStudent,
      Permission.deleteStudent,

      // Teacher Management
      Permission.viewTeachers,
      Permission.createTeacher,
      Permission.editTeacher,
      Permission.deleteTeacher,

      // Registration & Reports
      Permission.quickRegistration,
      Permission.viewBasicReports,
      Permission.viewFinancialReports,
      Permission.exportData,

      // System
      Permission.manageStaff,
      Permission.systemSettings,
    },

    // ====================================================================
    // EMPLOYEE - Limited admin access
    // Cannot: Delete anything, Create teachers, View financial reports
    // ====================================================================
    UserRole.employee: {
      // Dashboard & Profile
      Permission.viewDashboard,

      // Class Management (no delete, no create)
      Permission.viewClasses,
      Permission.editClass,

      // Student Management (no delete, no create)
      Permission.viewStudents,
      Permission.editStudent,

      // Teacher Management (view only, cannot create/edit/delete)
      Permission.viewTeachers,

      // Registration & Reports
      Permission.quickRegistration,
      Permission.viewBasicReports, // Can view basic reports only
      // NOTE: viewFinancialReports is EXCLUDED for employee

      // NO exportData permission for employee
    },

    // ====================================================================
    // TEACHER - Teaching features only
    // ====================================================================
    UserRole.teacher: {
      Permission.viewDashboard,
      Permission.viewAssignedClasses,
      Permission.viewClasses,
      Permission.viewStudents, // Can view students in their classes
      Permission.manageAttendance,
      Permission.manageGrades,
      Permission.uploadMaterials,
    },

    // ====================================================================
    // STUDENT - Student portal features only
    // ====================================================================
    UserRole.student: {
      Permission.viewOwnGrades,
      Permission.viewOwnSchedule,
      Permission.rateTeacher,
      Permission.viewClasses, // Can view available classes to enroll
    },
  };

  /// Check if a role has a specific permission
  /// Returns true if the role has the permission, false otherwise
  static bool hasPermission(UserRole role, Permission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  /// Check if a role has ANY of the given permissions
  /// Returns true if the role has at least one of the permissions
  static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
    return permissions.any((p) => hasPermission(role, p));
  }

  /// Check if a role has ALL of the given permissions
  /// Returns true only if the role has all of the permissions
  static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  /// Get all permissions for a role
  /// Returns a set of permissions that the role has
  static Set<Permission> getPermissions(UserRole role) {
    return _rolePermissions[role] ?? {};
  }

  /// Get a human-readable description of what a permission allows
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      // Admin Only
      case Permission.createClass:
        return 'Tạo lớp học mới';
      case Permission.deleteClass:
        return 'Xóa lớp học';
      case Permission.createTeacher:
        return 'Tạo giảng viên mới';
      case Permission.deleteTeacher:
        return 'Xóa giảng viên';
      case Permission.deleteStudent:
        return 'Xóa học viên';
      case Permission.viewFinancialReports:
        return 'Xem báo cáo doanh thu';
      case Permission.manageStaff:
        return 'Quản lý nhân viên';
      case Permission.systemSettings:
        return 'Cài đặt hệ thống';
      case Permission.exportData:
        return 'Xuất dữ liệu Excel/PDF';

      // Shared
      case Permission.viewDashboard:
        return 'Xem dashboard';
      case Permission.viewClasses:
        return 'Xem danh sách lớp học';
      case Permission.editClass:
        return 'Chỉnh sửa lớp học';
      case Permission.viewStudents:
        return 'Xem danh sách học viên';
      case Permission.editStudent:
        return 'Chỉnh sửa học viên';
      case Permission.viewTeachers:
        return 'Xem danh sách giảng viên';
      case Permission.quickRegistration:
        return 'Đăng ký nhanh';
      case Permission.viewBasicReports:
        return 'Xem báo cáo cơ bản';

      default:
        return permission.toString();
    }
  }
}
