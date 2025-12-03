import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/injector.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/teacher/presentation/bloc/teacher_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Size _getAdaptiveDesignSize(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    // Mobile
    if (width < 600) {
      return const Size(375, 812);
    }

    // Tablet Portrait
    if (width >= 600 && width < 900) {
      return Size(width, height);
    }

    // Tablet Landscape / Small Desktop
    if (width >= 900 && width < 1200) {
      return Size(width, height);
    }

    // Desktop - Use actual size for full responsive
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const CheckAuthStatus()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider<StudentBloc>(create: (_) => getIt<StudentBloc>()),
        BlocProvider<TeacherBloc>(create: (_) => getIt<TeacherBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          bool? prevDarkMode;
          bool? currDarkMode;

          if (previous is SettingsLoaded) {
            prevDarkMode = previous.settings.isDarkMode;
          } else if (previous is SettingsUpdated) {
            prevDarkMode = previous.settings.isDarkMode;
          }

          if (current is SettingsLoaded) {
            currDarkMode = current.settings.isDarkMode;
          } else if (current is SettingsUpdated) {
            currDarkMode = current.settings.isDarkMode;
          }

          if (prevDarkMode == null || currDarkMode == null) {
            return true;
          }

          final shouldRebuild = prevDarkMode != currDarkMode;
          return shouldRebuild;
        },
        builder: (context, state) {
          ThemeMode themeMode = ThemeMode.system;
          if (state is SettingsLoaded || state is SettingsUpdated) {
            final settings = state is SettingsLoaded
                ? state.settings
                : (state as SettingsUpdated).settings;
            themeMode = settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
          } else {
            themeMode = ThemeMode.system;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final designSize = _getAdaptiveDesignSize(constraints);

              return ScreenUtilInit(
                designSize: designSize,
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (_, __) => MaterialApp(
                  title: 'IPU - Ielts Power Up',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  onGenerateRoute: AppRouter.onGenerateRoute,
                  initialRoute: AppRouter.splash,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
