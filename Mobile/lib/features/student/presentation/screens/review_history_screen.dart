import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/student_app_bar.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../domain/entities/review.dart';

class ReviewHistoryScreen extends StatefulWidget {
  const ReviewHistoryScreen({super.key});

  @override
  State<ReviewHistoryScreen> createState() => _ReviewHistoryScreenState();
}

class _ReviewHistoryScreenState extends State<ReviewHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(const LoadReviewHistory());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Column(
        children: [
          const StudentAppBar(title: 'Lịch sử đánh giá', showBackButton: true),
          Expanded(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                if (state is StudentLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is ReviewHistoryLoaded) {
                  final List<Review> reviews = state.reviews;
                  if (reviews.isEmpty) return _buildEmptyState(isDark);
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<StudentBloc>().add(
                        const LoadReviewHistory(),
                      );
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return _buildReviewCardFromEntity(r, isDark);
                      },
                    ),
                  );
                }

                if (state is StudentError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: AppColors.error,
                        ),
                        SizedBox(height: 16.h),
                        Text(state.message, textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<StudentBloc>().add(
                              const LoadReviewHistory(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildEmptyState(isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80.sp,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Chưa có đánh giá nào',
            style: TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCardFromEntity(Review review, bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.courseName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                dateFormat.format(review.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < review.overallRating ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 20.sp,
                );
              }),
              SizedBox(width: 8.w),
              Text(
                '${review.overallRating}/5',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          if (review.teacherRating != null ||
              review.facilityRating != null) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 16.w,
              children: [
                if (review.teacherRating != null)
                  _buildMiniRating('Giảng viên', review.teacherRating!, isDark),
                if (review.facilityRating != null)
                  _buildMiniRating(
                    'Cơ sở vật chất',
                    review.facilityRating!,
                    isDark,
                  ),
              ],
            ),
          ],
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniRating(String label, int rating, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Icon(Icons.star, size: 14.sp, color: AppColors.warning),
        Text(
          ' $rating',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
