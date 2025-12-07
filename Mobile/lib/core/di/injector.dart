import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


import '../api/dio_client.dart';
import '../auth/token_store.dart';
import '../auth/session_expiry_notifier.dart';
import '../network/network_info.dart';


import '../../features/authentication/data/datasources/auth_api_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';


import '../../features/student/data/datasources/student_api_datasource.dart';
import '../../features/student/data/datasources/student_local_datasource.dart';
import '../../features/student/data/repositories/student_repository_with_api.dart';
import '../../features/student/domain/repositories/student_repository.dart';
import '../../features/student/presentation/bloc/student_bloc.dart';


import '../../features/teacher/data/datasources/teacher_api_datasource.dart';
import '../../features/teacher/data/datasources/teacher_local_datasource.dart';
import '../../features/teacher/data/repositories/teacher_repository_with_api.dart';
import '../../features/teacher/domain/repositories/teacher_repository.dart';
import '../../features/teacher/presentation/bloc/teacher_bloc.dart';


import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';


import '../../features/admin/data/datasources/admin_api_datasource.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/datasources/admin_course_data_source.dart';
import '../../features/admin/data/datasources/admin_course_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/data/repositories/admin_course_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/repositories/admin_course_repository.dart';
import '../../features/admin/domain/usecases/get_courses.dart';
import '../../features/admin/domain/usecases/get_course_by_id.dart';
import '../../features/admin/domain/usecases/update_course.dart';
import '../../features/admin/domain/usecases/delete_course.dart';
import '../../features/admin/domain/usecases/toggle_course_status.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/admin_course_bloc.dart';
import '../../features/admin/presentation/bloc/registration_bloc.dart';
import '../../features/admin/data/datasources/promotion_remote_datasource.dart';
import '../../features/admin/domain/repositories/promotion_repository.dart';
import '../../features/admin/data/repositories/promotion_repository_impl.dart';
import '../../features/admin/presentation/bloc/promotion_bloc.dart';


import '../../features/payment/data/payment_api_data_source.dart';
import '../../features/payment/data/vnpay_service.dart';


import '../services/deep_link_service.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  
  if (getIt.isRegistered<SharedPreferences>()) {
    await getIt.reset();
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  
  getIt.registerLazySingleton<TokenStore>(() => SecureTokenStore());

  
  getIt.registerLazySingleton<SessionExpiryNotifier>(
    () => SessionExpiryNotifier(),
  );

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenStore: getIt<TokenStore>(),
      sessionExpiryNotifier: getIt<SessionExpiryNotifier>(),
    ),
  );

  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  getIt.registerLazySingleton<AuthApiDataSource>(
    () => AuthApiDataSourceImpl(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
      tokenStore: getIt<TokenStore>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiDataSource: getIt<AuthApiDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<AuthBloc>(
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
    () => TeacherRepositoryWithApi(
      apiDataSource: getIt<TeacherApiDataSource>(),
      localDataSource: getIt<TeacherLocalDataSource>(),
    ),
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

  getIt.registerLazySingleton<AdminBloc>(
    () => AdminBloc(repository: getIt<AdminRepository>()),
  );

  getIt.registerLazySingleton<RegistrationBloc>(
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

  getIt.registerLazySingleton<ToggleCourseStatus>(
    () => ToggleCourseStatus(repository: getIt<AdminCourseRepository>()),
  );

  getIt.registerFactory<AdminCourseBloc>(
    () => AdminCourseBloc(
      getCourses: getIt<GetCourses>(),
      getCourseById: getIt<GetCourseById>(),
      updateCourse: getIt<UpdateCourse>(),
      deleteCourse: getIt<DeleteCourse>(),
      toggleCourseStatus: getIt<ToggleCourseStatus>(),
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
    () =>
        SettingsLocalDataSource(sharedPreferences: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt<SettingsLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(repository: getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<PaymentApiDataSource>(
    () => PaymentApiDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerLazySingleton<VNPayService>(
    () => VNPayService(paymentApiDataSource: getIt<PaymentApiDataSource>()),
  );

  
  getIt.registerLazySingleton<DeepLinkService>(() => DeepLinkService());
}
