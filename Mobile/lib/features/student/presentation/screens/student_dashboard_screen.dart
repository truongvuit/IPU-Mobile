import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/student_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

import 'student_home_tab.dart';
import 'class_list_screen.dart';
import 'schedule_screen.dart';
import 'grades_screen.dart';
import 'profile_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final int initialTab;

  const StudentDashboardScreen({super.key, this.initialTab = 0});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  String _getCurrentRoute() {
    switch (_currentIndex) {
      case 0:
        return AppRouter.studentDashboard;
      case 1:
        return AppRouter.studentClasses;
      case 2:
        return AppRouter.studentSchedule;
      case 3:
        return AppRouter.studentGrades;
      case 4:
        return AppRouter.studentProfile;
      default:
        return AppRouter.studentDashboard;
    }
  }

  int _getTabIndexFromRoute(String route) {
    switch (route) {
      case AppRouter.studentDashboard:
        return 0;
      case AppRouter.studentClasses:
        return 1;
      case AppRouter.studentSchedule:
        return 2;
      case AppRouter.studentGrades:
        return 3;
      case AppRouter.studentProfile:
        return 4;
      default:
        return -1; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      StudentHomeTab(onOpenDrawer: _openDrawer),
      ClassListScreen(isTab: true, onMenuPressed: _openDrawer),
      ScheduleScreen(isTab: true, onMenuPressed: _openDrawer),
      GradesScreen(isTab: true, onMenuPressed: _openDrawer),
      ProfileScreen(isTab: true, onMenuPressed: _openDrawer),
    ];

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      drawer: StudentDrawer(
        currentRoute: _getCurrentRoute(),
        onNavigate: (route) {
          Navigator.pop(context); 
          
          final tabIndex = _getTabIndexFromRoute(route);
          if (tabIndex != -1) {
            setState(() {
              _currentIndex = tabIndex;
            });
          } else if (route == AppRouter.studentCourses) {
            
            Navigator.pushNamed(context, route);
          }
        },
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
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
              icon: Icon(Icons.grading_outlined),
              activeIcon: Icon(Icons.grading),
              label: 'Điểm số',
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
