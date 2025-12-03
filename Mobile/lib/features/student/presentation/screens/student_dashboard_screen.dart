import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../widgets/student_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

import 'student_home_tab.dart';
import 'class_list_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(const LoadDashboard());
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> _pages = [
      StudentHomeTab(onOpenDrawer: _openDrawer),
      ClassListScreen(isTab: true, onMenuPressed: _openDrawer),
      ScheduleScreen(isTab: true, onMenuPressed: _openDrawer),
      ProfileScreen(isTab: true, onMenuPressed: _openDrawer),
    ];

    
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      drawer: StudentDrawer(
        onNavigate: (route) {
          Navigator.pop(context);
          if (route != AppRouter.studentDashboard) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[500],
          selectedLabelStyle: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Lớp học',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Lịch học',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
