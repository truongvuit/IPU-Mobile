import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/routing/app_router.dart';
import '../authentication/presentation/bloc/auth_bloc.dart';
import '../authentication/presentation/bloc/auth_event.dart';
import '../authentication/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    
    context.read<AuthBloc>().add(const CheckAuthStatus());
  }

  void _navigateBasedOnState(AuthState state) {
    if (!mounted) return;

    if (state is AuthSuccess) {
      final role = state.user.role.toLowerCase();
      if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRouter.studentDashboard);
      } else if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
      } else if (role == 'admin' || role == 'employee') {
        Navigator.pushReplacementNamed(context, AppRouter.adminHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.welcome);
      }
    } else if (state is AuthUnauthenticated || state is AuthFailure) {
      Navigator.pushReplacementNamed(context, AppRouter.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        
        if (state is AuthSuccess ||
            state is AuthUnauthenticated ||
            state is AuthFailure) {
          _navigateBasedOnState(state);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: isDesktop ? 140.sp : (isTablet ? 120.sp : 100.sp),
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: isDesktop
                        ? AppSizes.paddingExtraLarge
                        : AppSizes.paddingLarge,
                  ),
                  Text(
                    'IPU - IELTS Power Up',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isDesktop ? 36.sp : (isTablet ? 30.sp : 24.sp),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 60.h : 48.h),
                  SizedBox(
                    width: isDesktop ? 48.w : 40.w,
                    height: isDesktop ? 48.w : 40.w,
                    child: CircularProgressIndicator(
                      strokeWidth: isDesktop ? 4.w : 3.w,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
