import 'package:flutter/material.dart';

class GradeCard extends StatelessWidget {
  final String courseName;
  final double? midtermScore;
  final double? finalScore;
  final double? averageScore;
  final String? status;
  final VoidCallback? onTap;

  const GradeCard({
    super.key,
    required this.courseName,
    this.midtermScore,
    this.finalScore,
    this.averageScore,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate status color
    Color statusColor;
    Color statusBgColor;
    if (averageScore != null) {
      if (averageScore! >= 8.0) {
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
      } else if (averageScore! >= 6.5) {
        statusColor = const Color(0xFF3B82F6);
        statusBgColor = const Color(0xFF3B82F6).withValues(alpha: 0.1);
      } else if (averageScore! >= 5.0) {
        statusColor = const Color(0xFFF59E0B);
        statusBgColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      } else {
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
      }
    } else {
      statusColor = const Color(0xFF6B7280);
      statusBgColor = const Color(0xFF6B7280).withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      courseName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Scores Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Midterm
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      label: 'Giữa kỳ',
                      score: midtermScore,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Final
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      label: 'Cuối kỳ',
                      score: finalScore,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Average
                  Expanded(
                    child: _buildScoreItem(
                      context,
                      label: 'Trung bình',
                      score: averageScore,
                      isDark: isDark,
                      isAverage: true,
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar (based on average)
            if (averageScore != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đánh giá: ${_getGradeLevel(averageScore!)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF64748B),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: averageScore! / 10,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context, {
    required String label,
    required double? score,
    required bool isDark,
    bool isAverage = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAverage
            ? const Color(0xFF135BEC).withValues(alpha: 0.1)
            : (isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(8),
        border: isAverage
            ? Border.all(
                color: const Color(0xFF135BEC).withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF64748B),
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            score != null ? score.toStringAsFixed(1) : '--',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isAverage
                  ? const Color(0xFF135BEC)
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  String _getGradeLevel(double score) {
    if (score >= 9.0) return 'Xuất sắc';
    if (score >= 8.0) return 'Giỏi';
    if (score >= 6.5) return 'Khá';
    if (score >= 5.0) return 'Trung bình';
    return 'Yếu';
  }
}

