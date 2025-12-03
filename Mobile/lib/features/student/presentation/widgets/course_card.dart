import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ielts':
        return const Color(0xFF135BEC);
      case 'toeic':
        return const Color(0xFFF97316); // orange-500
      case 'giao tiếp':
        return const Color(0xFF10B981); // green-500
      default:
        return const Color(0xFF6366F1); // indigo-500
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1F2937).withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  course.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.school,
                        size: 48,
                        color: Color(0xFF135BEC),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Course Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Name
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111318),
                      fontFamily: 'Lexend',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(course.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(course.category),
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price and Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 20,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF616F89),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currencyFormat.format(course.price),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF616F89),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ],
                      ),

                      // View Detail Button
                      TextButton(
                        onPressed: onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF135BEC),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF135BEC),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

