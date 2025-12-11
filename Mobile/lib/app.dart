import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/auth/session_expiry_notifier.dart';
import 'core/di/injector.dart';
import 'core/routing/app_router.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/payment/domain/vnpay_models.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/student/presentation/bloc/student_bloc.dart';
import 'features/teacher/presentation/bloc/teacher_bloc.dart';
import 'features/student/presentation/bloc/cart_bloc.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<void>? _sessionExpirySubscription;
  StreamSubscription<VNPayPaymentResult>? _deepLinkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupSessionExpiryListener();
    _setupDeepLinkListener();
  }

  @override
  void dispose() {
    _sessionExpirySubscription?.cancel();
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _setupDeepLinkListener() {
    final deepLinkService = getIt<DeepLinkService>();

    _deepLinkSubscription = deepLinkService.paymentResultStream.listen((
      VNPayPaymentResult result,
    ) {
      _navigatorKey.currentState?.pushNamed(
        AppRouter.vnpayResult,
        arguments: result,
      );
    });
  }

  void _setupSessionExpiryListener() {
    final sessionExpiryNotifier = getIt<SessionExpiryNotifier>();
    _sessionExpirySubscription = sessionExpiryNotifier.sessionExpiredStream
        .listen((_) {
          
          if (!getIt.isRegistered<AuthBloc>()) return;

          final authBloc = getIt<AuthBloc>();

          
          if (!authBloc.isClosed) {
            authBloc.add(const LogoutRequested());
          }

          
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRouter.welcome,
            (route) => false,
          );
        });
  }

  Size _getAdaptiveDesignSize(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    if (width < 600) {
      return const Size(375, 812);
    }

    if (width >= 600 && width < 900) {
      return Size(width, height);
    }

    if (width >= 900 && width < 1200) {
      return Size(width, height);
    }

    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: getIt<AuthBloc>()),
        BlocProvider<SettingsBloc>(
          create: (_) => getIt<SettingsBloc>()..add(const LoadSettings()),
        ),
        
        BlocProvider<StudentBloc>.value(value: getIt<StudentBloc>()),
        BlocProvider<TeacherBloc>.value(value: getIt<TeacherBloc>()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
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
                  navigatorKey: _navigatorKey,
                  title: 'IPU - Ielts Power Up',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('vi', 'VN'),
                    Locale('en', 'US'),
                  ],
                  locale: const Locale('vi', 'VN'),
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
