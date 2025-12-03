import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TeacherBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        height: 64.h, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home,
              label: 'Trang chủ',
              index: 0,
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: Icons.calendar_month,
              label: 'Lịch dạy',
              index: 1,
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: Icons.school,
              label: 'Lớp học',
              index: 2,
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: Icons.person,
              label: 'Hồ sơ',
              index: 3,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.textSecondary
            : AppColors.textSecondary;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
            weight: isSelected ? 700 : 400,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

