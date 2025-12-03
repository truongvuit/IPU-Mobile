import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/teacher_bottom_nav_bar.dart';
import '../widgets/teacher_drawer.dart';
import 'teacher_dashboard_screen.dart';
import 'teacher_schedule_screen.dart';
import 'teacher_class_list_screen.dart';
import 'teacher_profile_screen.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';



class HomeTeacherScreen extends StatefulWidget {
  const HomeTeacherScreen({super.key});

  @override
  State<HomeTeacherScreen> createState() => _HomeTeacherScreenState();
}

class _HomeTeacherScreenState extends State<HomeTeacherScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    
    context.read<TeacherBloc>().add(LoadTeacherDashboard());
    context.read<TeacherBloc>().add(LoadTeacherProfile());
  }

  void onTabTapped(int index) {
    if (_currentIndex == index) {
      
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
      });

      
      switch (index) {
        case 0: 
          context.read<TeacherBloc>().add(LoadTeacherDashboard());
          break;
        case 1: 
          context.read<TeacherBloc>().add(LoadWeekSchedule(DateTime.now()));
          break;
        case 2: 
          context.read<TeacherBloc>().add(LoadMyClasses());
          break;
        case 3: 
          context.read<TeacherBloc>().add(LoadTeacherProfile());
          break;
      }
    }
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          const TeacherDashboardScreen(),
          const TeacherScheduleScreen(),
          const TeacherClassListScreen(),
          const TeacherProfileScreen(),
        ][index];
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          final routeName = routeSettings.name ?? '/';
          final routeBuilder = _routeBuilders(context, index)[routeName];

          if (routeBuilder == null) {
            return MaterialPageRoute(
              builder: (context) => const SizedBox.shrink(),
              settings: routeSettings,
            );
          }

          return MaterialPageRoute(
            builder: routeBuilder,
            settings: routeSettings,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is TeacherError) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF9FAFB),
        drawer: TeacherDrawerWidget(
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
          ],
        ),
        bottomNavigationBar: TeacherBottomNavBar(
          currentIndex: _currentIndex,
          onTap: onTabTapped,
        ),
      ),
    );
  }
}
