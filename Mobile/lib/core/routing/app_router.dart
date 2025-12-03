import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injector.dart';

// Splash
import '../../features/splash/splash_screen.dart';

// Authentication
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/verify_code_screen.dart';
import '../../features/authentication/presentation/screens/reset_password_screen.dart';
import '../../features/authentication/presentation/screens/change_password_screen.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

// Student
import '../../features/student/presentation/screens/student_dashboard_screen.dart';

import '../../features/student/presentation/screens/class_list_screen.dart';
import '../../features/student/presentation/screens/class_detail_screen.dart';
import '../../features/student/presentation/screens/course_list_screen.dart';
import '../../features/student/presentation/screens/course_detail_screen.dart';
import '../../features/student/presentation/screens/schedule_screen.dart';
import '../../features/student/presentation/screens/grades_screen.dart';
import '../../features/student/presentation/screens/profile_screen.dart';
import '../../features/student/presentation/screens/edit_profile_screen.dart';
import '../../features/student/presentation/screens/rating_screen.dart';
import '../../features/student/presentation/screens/review_history_screen.dart';
import '../../features/student/presentation/screens/learning_path_screen.dart';
import '../../features/student/presentation/bloc/student_bloc.dart';

// Teacher
import '../../features/teacher/presentation/screens/home_teacher_screen.dart';
import '../../features/teacher/presentation/screens/teacher_class_list_screen.dart';
import '../../features/teacher/presentation/screens/teacher_class_detail_screen.dart';
import '../../features/teacher/presentation/screens/teacher_attendance_screen.dart';
import '../../features/teacher/presentation/screens/teacher_schedule_screen.dart';
import '../../features/teacher/presentation/screens/teacher_profile_screen.dart';
import '../../features/teacher/presentation/screens/edit_teacher_profile_screen.dart';
import '../../features/teacher/presentation/bloc/teacher_bloc.dart';

// Admin
import '../../features/admin/presentation/screens/home_admin_screen.dart';
import '../../features/admin/presentation/screens/admin_class_list_screen.dart';
import '../../features/admin/presentation/screens/admin_class_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_edit_class_screen.dart';
import '../../features/admin/presentation/screens/admin_class_student_list_screen.dart';
import '../../features/admin/presentation/screens/admin_student_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_edit_student_screen.dart';
import '../../features/admin/presentation/screens/admin_teacher_list_screen.dart';
import '../../features/admin/presentation/screens/admin_teacher_detail_screen.dart';
import '../../features/admin/presentation/screens/admin_teacher_form_screen.dart';
import '../../features/admin/presentation/screens/quick_registration_form_screen.dart';
import '../../features/admin/presentation/screens/quick_registration_class_selection_screen.dart';
import '../../features/admin/presentation/screens/quick_registration_promotion_screen.dart';
import '../../features/admin/presentation/screens/quick_registration_payment_screen.dart';
// Removed: Reports and Classroom screens (not mobile-friendly)
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/registration_bloc.dart';
import '../../features/admin/domain/entities/admin_class.dart';
import '../../features/admin/domain/entities/admin_teacher.dart';
import '../../features/admin/domain/entities/admin_student.dart';
// Removed: admin_course.dart (unused after legacy screen deletion)
import '../../features/admin/domain/entities/course_detail.dart'; // New entity
// Removed: admin_course_detail_screen.dart (legacy)
import '../../features/admin/presentation/screens/courses/admin_course_list_screen.dart'; // New screen
import '../../features/admin/presentation/screens/courses/admin_course_detail_new_screen.dart'; // New screen
import '../../features/admin/presentation/screens/courses/admin_course_edit_screen.dart'; // New screen
import '../../features/admin/presentation/bloc/admin_course_bloc.dart'; // New bloc
import '../../features/admin/presentation/screens/admin_class_feedback_screen.dart';
import '../../features/admin/presentation/screens/promotions/promotion_list_screen.dart';
import '../../features/admin/presentation/screens/promotions/promotion_form_screen.dart';
import '../../features/admin/presentation/screens/promotions/promotion_detail_screen.dart';
import '../../features/admin/domain/entities/promotion.dart';

// Teacher Grades
import '../../features/teacher/presentation/screens/teacher_grades_list_screen.dart';
import '../../features/teacher/presentation/bloc/teacher_grades_bloc.dart';

// Settings
import '../../features/settings/presentation/screens/settings_screen.dart';

import '../../features/settings/presentation/screens/policy_screen.dart';
import '../../features/settings/presentation/screens/terms_screen.dart';

import '../../features/settings/presentation/bloc/settings_bloc.dart';

/// App Router - Quản lý routing cho toàn bộ app
class AppRouter {
  // Splash
  static const String splash = '/';

  // Authentication Routes
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String resetPassword = '/reset-password';

  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String studentClasses = '/student/classes';
  static const String studentClassDetail = '/student/class-detail';
  static const String studentCourses = '/student/courses';
  static const String studentCourseDetail = '/student/course-detail';
  static const String studentSchedule = '/student/schedule';
  static const String studentGrades = '/student/grades';
  static const String studentProfile = '/student/profile';
  static const String studentEditProfile = '/student/edit-profile';
  static const String studentReviewHistory = '/student/review-history';
  static const String studentLearningPath = '/student/learning-path';

  static const String studentRating = '/student/rating';

  // Teacher Routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherClasses = '/teacher/classes';
  static const String teacherClassDetail = '/teacher/class-detail';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherGrading = '/teacher/grading';
  static const String teacherSchedule = '/teacher/schedule';
  static const String teacherProfile = '/teacher/profile';

  static const String teacherEditProfile = '/teacher/edit-profile';
  static const String teacherGradesList = '/teacher/grades'; // New route

  // Admin Routes
  static const String adminHome = '/admin/home';
  static const String adminClasses = '/admin/classes';
  static const String adminClassDetail = '/admin/class-detail';
  static const String adminEditClass = '/admin/edit-class';
  static const String adminClassStudents = '/admin/class-students';
  static const String adminStudentDetail = '/admin/student-detail';
  static const String adminEditStudent = '/admin/student-edit';
  static const String adminTeachers = '/admin/teachers';
  static const String adminTeacherDetail = '/admin/teacher-detail';
  static const String adminTeacherForm = '/admin/teacher-form';
  static const String adminQuickRegistration = '/admin/quick-registration';
  static const String adminQuickRegClassSelection = '/admin/quick-reg-class';
  static const String adminQuickRegPromotion = '/admin/quick-reg-promo';
  static const String adminQuickRegPayment = '/admin/quick-reg-payment';
  // Removed: Report routes (not mobile-friendly)
  // Removed: Classroom routes (managed on web)
  static const String adminCourseDetail = '/admin/course-detail';
  static const String adminClassFeedback = '/admin/class-feedback';
  static const String adminPromotions = '/admin/promotions';
  static const String adminPromotionForm = '/admin/promotion-form';
  static const String adminPromotionDetail = '/admin/promotion-detail';

  // Admin Course Routes (New)
  static const String adminCourseList = '/admin/courses';
  static const String adminCourseEdit = '/admin/courses/edit';

  // Settings Routes
  static const String settings = '/settings';
  static const String settingsPolicy = '/settings/policy';
  static const String settingsTerms = '/settings/terms';
  static const String changePassword = '/change-password';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      // ============ Splash ============
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: routeSettings,
        );

      // ============ Authentication Routes ============
      case welcome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: const WelcomeScreen(),
          ),
          settings: routeSettings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: const LoginScreen(),
          ),
          settings: routeSettings,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: const ForgotPasswordScreen(),
          ),
          settings: routeSettings,
        );

      case verifyCode:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final emailOrPhone = args?['emailOrPhone'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: VerifyCodeScreen(emailOrPhone: emailOrPhone),
          ),
          settings: routeSettings,
        );

      case resetPassword:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final emailOrPhone = args?['emailOrPhone'] as String? ?? '';
        final verificationCode = args?['verificationCode'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AuthBloc>(),
            child: ResetPasswordScreen(
              emailOrPhone: emailOrPhone,
              verificationCode: verificationCode,
            ),
          ),
          settings: routeSettings,
        );

      // ============ Student Routes ============
      case studentDashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const StudentDashboardScreen(),
          ),
          settings: routeSettings,
        );

      case studentClasses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const ClassListScreen(),
          ),
          settings: routeSettings,
        );

      case studentClassDetail:
        final classId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: ClassDetailScreen(classId: classId),
          ),
          settings: routeSettings,
        );

      case studentCourses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const CourseListScreen(),
          ),
          settings: routeSettings,
        );

      case studentCourseDetail:
        final courseId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: CourseDetailScreen(courseId: courseId),
          ),
          settings: routeSettings,
        );

      case studentSchedule:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const ScheduleScreen(),
          ),
          settings: routeSettings,
        );

      case studentGrades:
        final className = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: GradesScreen(initialFilter: className),
          ),
          settings: routeSettings,
        );

      case studentProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const ProfileScreen(),
          ),
          settings: routeSettings,
        );

      case studentEditProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const EditProfileScreen(),
          ),
          settings: routeSettings,
        );

      case studentRating:
        final courseId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: RatingScreen(courseId: courseId),
          ),
          settings: routeSettings,
        );

      case studentReviewHistory:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const ReviewHistoryScreen(),
          ),
          settings: routeSettings,
        );

      case studentLearningPath:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<StudentBloc>(),
            child: const LearningPathScreen(),
          ),
          settings: routeSettings,
        );

      // ============ Teacher Routes ============
      case teacherDashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: const HomeTeacherScreen(),
          ),
          settings: routeSettings,
        );

      case teacherClasses:
        final mode = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: TeacherClassListScreen(mode: mode, showScaffold: true),
          ),
          settings: routeSettings,
        );

      case teacherClassDetail:
        final classId = routeSettings.arguments as String?;
        if (classId == null || classId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Lỗi: Không tìm thấy ID lớp học')),
            ),
            settings: routeSettings,
          );
        }
        // Create new BLoC instance for root navigator
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: TeacherClassDetailScreen(classId: classId),
          ),
          settings: routeSettings,
        );

      case teacherAttendance:
        final classId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: TeacherAttendanceScreen(classId: classId),
          ),
          settings: routeSettings,
        );
      case teacherSchedule:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: const TeacherScheduleScreen(),
          ),
          settings: routeSettings,
        );

      case teacherProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: const TeacherProfileScreen(),
          ),
          settings: routeSettings,
        );

      case teacherEditProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherBloc>(),
            child: const EditTeacherProfileScreen(),
          ),
          settings: routeSettings,
        );

      case teacherGradesList:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TeacherGradesBloc>(),
            child: TeacherGradesListScreen(
              classId: args['classId'],
              className: args['className'],
            ),
          ),
          settings: routeSettings,
        );

      // ============ Admin Routes ============
      case adminHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: const HomeAdminScreen(),
          ),
          settings: routeSettings,
        );

      case adminClasses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: const AdminClassListScreen(),
          ),
          settings: routeSettings,
        );

      case adminClassDetail:
        final classId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminClassDetailScreen(classId: classId),
          ),
          settings: routeSettings,
        );

      case adminEditClass:
        final classInfo = routeSettings.arguments as AdminClass;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminEditClassScreen(classInfo: classInfo),
          ),
          settings: routeSettings,
        );

      case adminClassStudents:
        final classId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminClassStudentListScreen(classId: classId),
          ),
          settings: routeSettings,
        );

      case adminStudentDetail:
        final studentId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminStudentDetailScreen(studentId: studentId),
          ),
          settings: routeSettings,
        );

      case adminEditStudent:
        final student = routeSettings.arguments as AdminStudent;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminEditStudentScreen(student: student),
          ),
          settings: routeSettings,
        );

      case adminTeachers:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: const AdminTeacherListScreen(),
          ),
          settings: routeSettings,
        );

      case adminTeacherDetail:
        final teacher = routeSettings.arguments as AdminTeacher;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminTeacherDetailScreen(teacher: teacher),
          ),
          settings: routeSettings,
        );

      case adminTeacherForm:
        final teacher = routeSettings.arguments as AdminTeacher?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminTeacherFormScreen(teacher: teacher),
          ),
          settings: routeSettings,
        );

      case adminQuickRegistration:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<RegistrationBloc>(),
            child: const QuickRegistrationFormScreen(),
          ),
          settings: routeSettings,
        );

      case adminQuickRegClassSelection:
        // Share BLoC from previous screen (QuickRegistrationFormScreen)
        return MaterialPageRoute(
          builder: (context) {
            // Try to get existing BLoC from context
            try {
              final bloc = context.read<RegistrationBloc>();
              return BlocProvider.value(
                value: bloc,
                child: const QuickRegistrationClassSelectionScreen(),
              );
            } catch (e) {
              // If no BLoC found, create new one
              return BlocProvider(
                create: (_) => getIt<RegistrationBloc>(),
                child: const QuickRegistrationClassSelectionScreen(),
              );
            }
          },
          settings: routeSettings,
        );

      case adminQuickRegPromotion:
        // Share BLoC from previous screen
        return MaterialPageRoute(
          builder: (context) {
            try {
              final bloc = context.read<RegistrationBloc>();
              return BlocProvider.value(
                value: bloc,
                child: const QuickRegistrationPromotionScreen(),
              );
            } catch (e) {
              return BlocProvider(
                create: (_) => getIt<RegistrationBloc>(),
                child: const QuickRegistrationPromotionScreen(),
              );
            }
          },
          settings: routeSettings,
        );

      case adminQuickRegPayment:
        // Share BLoC from previous screen
        return MaterialPageRoute(
          builder: (context) {
            try {
              final bloc = context.read<RegistrationBloc>();
              return BlocProvider.value(
                value: bloc,
                child: const QuickRegistrationPaymentScreen(),
              );
            } catch (e) {
              return BlocProvider(
                create: (_) => getIt<RegistrationBloc>(),
                child: const QuickRegistrationPaymentScreen(),
              );
            }
          },
          settings: routeSettings,
        );

      // Removed: Report and Classroom route handlers

      case adminCourseDetail:
        final course = routeSettings.arguments as CourseDetail;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminCourseBloc>(),
            child: AdminCourseDetailNewScreen(course: course),
          ),
          settings: routeSettings,
        );

      case adminCourseList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminCourseBloc>(),
            child: const AdminCourseListScreen(),
          ),
          settings: routeSettings,
        );

      case adminCourseEdit:
        final course = routeSettings.arguments as CourseDetail;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminCourseBloc>(),
            child: AdminCourseEditScreen(course: course),
          ),
          settings: routeSettings,
        );

      case adminClassFeedback:
        final classId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminBloc>(),
            child: AdminClassFeedbackScreen(classId: classId),
          ),
          settings: routeSettings,
        );

      case adminPromotions:
        return MaterialPageRoute(
          builder: (_) => const PromotionListScreen(),
          settings: routeSettings,
        );

      case adminPromotionForm:
        final promotion = routeSettings.arguments as Promotion?;
        return MaterialPageRoute(
          builder: (_) => PromotionFormScreen(promotion: promotion),
          settings: routeSettings,
        );

      case adminPromotionDetail:
        final promotionId = routeSettings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PromotionDetailScreen(promotionId: promotionId),
          settings: routeSettings,
        );

      case AppRouter.settings:
        // Get userRole from arguments, default to 'student'
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final userRole = args?['userRole'] as String? ?? 'student';
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SettingsBloc>(),
            child: SettingsScreen(userRole: userRole),
          ),
          settings: routeSettings,
        );

      case settingsTerms:
        return MaterialPageRoute(
          builder: (_) => const TermsScreen(),
          settings: routeSettings,
        );
      case settingsPolicy:
        return MaterialPageRoute(
          builder: (_) => const PolicyScreen(),
          settings: routeSettings,
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
          settings: routeSettings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy route ${routeSettings.name}'),
            ),
          ),
          settings: routeSettings,
        );
    }
  }
}
