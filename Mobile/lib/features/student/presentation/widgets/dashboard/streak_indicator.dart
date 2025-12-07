import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  final int streakDays;
  final bool isDark;

  const StreakIndicator({
    super.key,
    required this.streakDays,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays ngày',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.orange[200] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}
