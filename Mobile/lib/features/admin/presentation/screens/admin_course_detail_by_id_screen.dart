import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_course_bloc.dart';
import '../bloc/admin_course_event.dart';
import '../bloc/admin_course_state.dart';
import 'courses/admin_course_detail_new_screen.dart';

AppBar _buildAppBar() {
  return AppBar(
    title: Text(
      'Chi tiết khóa học',
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Lexend',
      ),
    ),
    elevation: 0,
  );
}

class AdminCourseDetailByIdScreen extends StatefulWidget {
  final String courseId;

  const AdminCourseDetailByIdScreen({super.key, required this.courseId});

  @override
  State<AdminCourseDetailByIdScreen> createState() =>
      _AdminCourseDetailByIdScreenState();
}

class _AdminCourseDetailByIdScreenState
    extends State<AdminCourseDetailByIdScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint(
      '🟢 AdminCourseDetailByIdScreen initState - courseId: ${widget.courseId}',
    );
    context.read<AdminCourseBloc>().add(LoadCourseDetail(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AdminCourseBloc, AdminCourseState>(
      builder: (context, state) {
        debugPrint(
          '🟡 AdminCourseDetailByIdScreen state: ${state.runtimeType}',
        );
        if (state is AdminCourseLoading) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AdminCourseDetailLoaded) {
          return AdminCourseDetailNewScreen(course: state.course);
        }

        if (state is AdminCourseError) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải khóa học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.neutral400
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCourseBloc>().add(
                        LoadCourseDetail(widget.courseId),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
