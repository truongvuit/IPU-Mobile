import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/student_class.dart';

class ClassCard extends StatelessWidget {
  final StudentClass studentClass;
  final VoidCallback? onTap;
  final bool showAction;
  final bool compact;

  const ClassCard({
    super.key,
    required this.studentClass,
    this.onTap,
    this.showAction = true,
    this.compact = false,
  });

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Use compact layout on mobile by default
    final useCompact = compact || isMobile;

    if (useCompact) {
      return _buildCompactCard(context, isDark);
    }
    return _buildFullCard(context, isDark);
  }

  Widget _buildCompactCard(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 280),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Class Image - smaller for compact view
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                height: 90,
                child: Image.network(
                  studentClass.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.class_,
                        size: 32,
                        color: Color(0xFF135BEC),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Class Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Class Name
                    Text(
                      studentClass.courseName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'Lexend',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Time and Room
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(studentClass.startTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontFamily: 'Lexend',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          studentClass.isOnline ? Icons.videocam : Icons.location_on,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            studentClass.isOnline ? 'Online' : studentClass.room,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Teacher Name
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            studentClass.teacherName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, bool isDark) {
    return Container(
      constraints: const BoxConstraints(minWidth: 280),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                studentClass.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.class_,
                      size: 48,
                      color: Color(0xFF135BEC),
                    ),
                  );
                },
              ),
            ),
          ),

          // Class Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class Name
                Text(
                  studentClass.courseName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'Lexend',
                  ),
                ),
                const SizedBox(height: 8),

                // Time and Location
                Text(
                  '${_formatTime(studentClass.startTime)} - ${studentClass.room} - ${studentClass.teacherName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontFamily: 'Lexend',
                  ),
                ),

                if (showAction) ...[
                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: studentClass.isOnline
                            ? const Color(0xFF135BEC).withValues(alpha: 0.2)
                            : const Color(0xFF135BEC),
                        foregroundColor: const Color(0xFF135BEC),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: studentClass.isOnline
                              ? const Color(0xFF135BEC)
                              : Colors.white,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

