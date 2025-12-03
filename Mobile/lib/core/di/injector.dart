import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import '../api/dio_client.dart';

// Authentication
import '../../features/authentication/data/datasources/auth_api_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

// Student
import '../../features/student/data/datasources/student_api_datasource.dart';
import '../../features/student/data/datasources/student_local_datasource.dart';
import '../../features/student/data/repositories/student_repository_with_api.dart';
import '../../features/student/domain/repositories/student_repository.dart';
import '../../features/student/presentation/bloc/student_bloc.dart';

// Teacher
import '../../features/teacher/data/datasources/teacher_api_datasource.dart';
import '../../features/teacher/data/datasources/teacher_local_datasource.dart';
import '../../features/teacher/data/repositories/teacher_repository_with_api.dart';
import '../../features/teacher/domain/repositories/teacher_repository.dart';
import '../../features/teacher/presentation/bloc/teacher_bloc.dart';

// Settings
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

// Admin
import '../../features/admin/data/datasources/admin_api_datasource.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/datasources/admin_course_data_source.dart';
import '../../features/admin/data/datasources/admin_course_remote_datasource.dart';
// import '../../features/admin/data/repositories/admin_repository_mock.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/data/repositories/admin_course_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/repositories/admin_course_repository.dart';
import '../../features/admin/domain/usecases/get_courses.dart';
import '../../features/admin/domain/usecases/get_course_by_id.dart';
import '../../features/admin/domain/usecases/update_course.dart';
import '../../features/admin/domain/usecases/delete_course.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/admin_course_bloc.dart';
import '../../features/admin/presentation/bloc/registration_bloc.dart';
import '../../features/admin/data/datasources/promotion_remote_datasource.dart';
import '../../features/admin/domain/repositories/promotion_repository.dart';
import '../../features/admin/data/repositories/promotion_repository_impl.dart';
import '../../features/admin/presentation/bloc/promotion_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(sharedPreferences: sharedPreferences),
  );

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  getIt.registerLazySingleton<AuthApiDataSource>(
    () => AuthApiDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () =>
        AuthLocalDataSourceImpl(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiDataSource: getIt<AuthApiDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<StudentLocalDataSource>(
    () => StudentLocalDataSource(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<StudentApiDataSource>(
    () => StudentApiDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryWithApi(
      apiDataSource: getIt<StudentApiDataSource>(),
      localDataSource: getIt<StudentLocalDataSource>(),
    ),
  );

  getIt.registerFactory<StudentBloc>(
    () => StudentBloc(repository: getIt<StudentRepository>()),
  );

  getIt.registerLazySingleton<TeacherLocalDataSource>(
    () => TeacherLocalDataSource(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<TeacherApiDataSource>(
    () => TeacherApiDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<TeacherRepository>(
    () =>
        TeacherRepositoryWithApi(apiDataSource: getIt<TeacherApiDataSource>()),
  );

  getIt.registerFactory<TeacherBloc>(
    () => TeacherBloc(repository: getIt<TeacherRepository>()),
  );

  getIt.registerLazySingleton<AdminApiDataSource>(
    () => AdminRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(dataSource: getIt<AdminApiDataSource>()),
  );

  getIt.registerFactory<AdminBloc>(
    () => AdminBloc(repository: getIt<AdminRepository>()),
  );

  getIt.registerFactory<RegistrationBloc>(
    () => RegistrationBloc(adminRepository: getIt<AdminRepository>()),
  );

  getIt.registerLazySingleton<AdminCourseDataSource>(
    () => AdminCourseRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AdminCourseRepository>(
    () => AdminCourseRepositoryImpl(dataSource: getIt<AdminCourseDataSource>()),
  );

  getIt.registerLazySingleton<GetCourses>(
    () => GetCourses(repository: getIt<AdminCourseRepository>()),
  );

  getIt.registerLazySingleton<GetCourseById>(
    () => GetCourseById(repository: getIt<AdminCourseRepository>()),
  );

  getIt.registerLazySingleton<UpdateCourse>(
    () => UpdateCourse(repository: getIt<AdminCourseRepository>()),
  );
  getIt.registerLazySingleton<DeleteCourse>(
    () => DeleteCourse(repository: getIt<AdminCourseRepository>()),
  );

  getIt.registerFactory<AdminCourseBloc>(
    () => AdminCourseBloc(
      getCourses: getIt<GetCourses>(),
      getCourseById: getIt<GetCourseById>(),
      updateCourse: getIt<UpdateCourse>(),
      deleteCourse: getIt<DeleteCourse>(),
    ),
  );

  getIt.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(
      remoteDataSource: getIt<PromotionRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<PromotionBloc>(
    () => PromotionBloc(repository: getIt<PromotionRepository>()),
  );

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSource(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(repository: getIt<SettingsRepository>()),
  );
}
