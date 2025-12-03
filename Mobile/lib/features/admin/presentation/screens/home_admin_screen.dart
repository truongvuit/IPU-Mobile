import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_dashboard_screen.dart';
import 'admin_class_list_screen.dart';
import 'admin_teacher_list_screen.dart';
import 'admin_student_list_screen.dart';
import 'admin_profile_screen.dart';
import '../widgets/admin_drawer.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminDashboardScreen(),
      const AdminClassListScreen(),
      const AdminTeacherListScreen(),
      const AdminStudentListScreen(),
      const AdminProfileScreen(isTab: true),
    ];

    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDataForTab(0);
      }
    });
  }

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      _loadDataForTab(index);
    }
  }

  void _loadDataForTab(int index) {
    final bloc = context.read<AdminBloc>();
    switch (index) {
      case 0:
        
        bloc.add(const LoadAdminDashboard());
        break;
      case 1:
        
        bloc.add(const LoadClassList());
        break;
      case 2:
        
        bloc.add(const LoadTeacherList());
        break;
      case 3:
        
        bloc.add(const LoadStudentList());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompact = MediaQuery.of(context).size.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,

        drawer: AdminDrawer(
          currentIndex: _selectedIndex,
          onTabSelected: _onTabSelected,
        ),

        body: IndexedStack(index: _selectedIndex, children: _screens),

        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'admin_home_fab',
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.adminQuickRegistration);
          },
          backgroundColor: AppColors.success,
          icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
          label: Text(
            'Đăng ký',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? AppColors.gray400 : AppColors.gray600,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            selectedFontSize: isCompact ? 10.sp : AppSizes.textXs,
            unselectedFontSize: isCompact ? 10.sp : AppSizes.textXs,
            iconSize: isCompact ? 22.sp : 24.sp,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Tổng quan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.class_outlined),
                activeIcon: Icon(Icons.class_),
                label: 'Lớp học',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Giảng viên',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Học viên',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
