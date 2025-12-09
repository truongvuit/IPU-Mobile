import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../domain/entities/course.dart';
import 'class_selection_bottom_sheet.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.isHorizontal = false,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ielts':
        return const Color(0xFF135BEC);
      case 'toeic':
        return const Color(0xFFF97316);
      case 'giao tiếp':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isHorizontal
        ? _buildHorizontalCard(context)
        : _buildVerticalCard(context);
  }

  /// Horizontal layout - image as leading (for mobile list view)
  Widget _buildHorizontalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final classCount = course.availableClasses.length;

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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Leading Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImage(imageUrl: course.imageUrl, fit: BoxFit.cover),
                      // Class count badge
                      if (classCount > 0)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$classCount lớp',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      Text(
                        course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111318),
                          fontFamily: 'Lexend',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Category + Level chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            course.category,
                            _getCategoryColor(course.category),
                          ),
                          if (course.level.isNotEmpty)
                            _buildChip(course.level, const Color(0xFF6366F1)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF616F89),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              currencyFormat.format(course.price),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF135BEC),
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                          // Quick action button
                          if (classCount > 0)
                            GestureDetector(
                              onTap: () => ClassSelectionBottomSheet.show(
                                context,
                                course,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF135BEC),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Xem lớp',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Lexend',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
          fontFamily: 'Lexend',
        ),
      ),
    );
  }

  /// Vertical layout - original card design (for tablet/desktop grid)
  Widget _buildVerticalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final classCount = course.availableClasses.length;

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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    CustomImage(
                      imageUrl: course.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Class count badge
                    if (classCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.class_outlined,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$classCount lớp',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 8),

                    // Category + Level row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              course.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            course.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(course.category),
                              fontFamily: 'Lexend',
                            ),
                          ),
                        ),
                        if (course.level.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              course.level,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6366F1),
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 18,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF616F89),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currencyFormat.format(course.price),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111318),
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF135BEC),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(color: Color(0xFF135BEC)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Chi tiết',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Lexend',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: classCount > 0
                                ? () => ClassSelectionBottomSheet.show(
                                    context,
                                    course,
                                  )
                                : null,
                            icon: const Icon(Icons.class_outlined, size: 16),
                            label: Text(
                              classCount > 0 ? 'Xem lớp' : 'Hết lớp',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Lexend',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF135BEC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
