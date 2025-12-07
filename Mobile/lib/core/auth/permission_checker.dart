import 'models/user_role.dart';
import 'models/permission.dart';


class PermissionChecker {
  
  static final Map<UserRole, Set<Permission>> _rolePermissions = {
    
    
    
    UserRole.admin: {
      
      Permission.viewDashboard,

      
      Permission.viewClasses,
      Permission.createClass,
      Permission.editClass,
      Permission.deleteClass,

      
      Permission.viewStudents,
      Permission.createStudent,
      Permission.editStudent,
      Permission.deleteStudent,

      
      Permission.viewTeachers,
      Permission.createTeacher,
      Permission.editTeacher,
      Permission.deleteTeacher,

      
      Permission.quickRegistration,
      Permission.viewBasicReports,
      Permission.viewFinancialReports,
      Permission.exportData,

      
      Permission.manageStaff,
      Permission.systemSettings,
    },

    
    
    
    
    UserRole.employee: {
      
      Permission.viewDashboard,

      
      Permission.viewClasses,
      Permission.editClass,

      
      Permission.viewStudents,
      Permission.editStudent,

      
      Permission.viewTeachers,

      
      Permission.quickRegistration,
      Permission.viewBasicReports, 
      

      
    },

    
    
    
    UserRole.teacher: {
      Permission.viewDashboard,
      Permission.viewAssignedClasses,
      Permission.viewClasses,
      Permission.viewStudents, 
      Permission.manageAttendance,
      Permission.manageGrades,
      Permission.uploadMaterials,
    },

    
    
    
    UserRole.student: {
      Permission.viewOwnGrades,
      Permission.viewOwnSchedule,
      Permission.rateTeacher,
      Permission.viewClasses, 
    },
  };

  
  
  static bool hasPermission(UserRole role, Permission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  
  
  static bool hasAnyPermission(UserRole role, List<Permission> permissions) {
    return permissions.any((p) => hasPermission(role, p));
  }

  
  
  static bool hasAllPermissions(UserRole role, List<Permission> permissions) {
    return permissions.every((p) => hasPermission(role, p));
  }

  
  
  static Set<Permission> getPermissions(UserRole role) {
    return _rolePermissions[role] ?? {};
  }

  
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      
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
