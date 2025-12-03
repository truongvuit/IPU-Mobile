import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/skeleton_widget.dart';
import '../../domain/entities/admin_feedback.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminClassFeedbackScreen extends StatefulWidget {
  final String classId;

  const AdminClassFeedbackScreen({super.key, required this.classId});

  @override
  State<AdminClassFeedbackScreen> createState() =>
      _AdminClassFeedbackScreenState();
}

class _AdminClassFeedbackScreenState extends State<AdminClassFeedbackScreen> {
  int? _selectedStarFilter; 

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadClassFeedbacks(widget.classId));
  }

  
  Map<String, dynamic> _calculateStats(List<AdminFeedback> feedbacks) {
    if (feedbacks.isEmpty) {
      return {
        'total': 0,
        'average': 0.0,
        'avgTeacher': 0.0,
        'avgFacility': 0.0,
        'avgOverall': 0.0,
        'starCounts': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }

    double sumRating = 0;
    double sumTeacher = 0;
    double sumFacility = 0;
    double sumOverall = 0;
    int countTeacher = 0;
    int countFacility = 0;
    int countOverall = 0;
    Map<int, int> starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final fb in feedbacks) {
      sumRating += fb.rating;

      
      int stars = fb.rating.round().clamp(1, 5);
      starCounts[stars] = (starCounts[stars] ?? 0) + 1;

      if (fb.teacherRating != null && fb.teacherRating! > 0) {
        sumTeacher += fb.teacherRating!;
        countTeacher++;
      }
      if (fb.facilityRating != null && fb.facilityRating! > 0) {
        sumFacility += fb.facilityRating!;
        countFacility++;
      }
      if (fb.overallRating != null && fb.overallRating! > 0) {
        sumOverall += fb.overallRating!;
        countOverall++;
      }
    }

    return {
      'total': feedbacks.length,
      'average': sumRating / feedbacks.length,
      'avgTeacher': countTeacher > 0 ? sumTeacher / countTeacher : 0.0,
      'avgFacility': countFacility > 0 ? sumFacility / countFacility : 0.0,
      'avgOverall': countOverall > 0 ? sumOverall / countOverall : 0.0,
      'starCounts': starCounts,
    };
  }

  
  List<AdminFeedback> _filterFeedbacks(List<AdminFeedback> feedbacks) {
    if (_selectedStarFilter == null) return feedbacks;
    return feedbacks.where((fb) {
      int stars = fb.rating.round().clamp(1, 5);
      return stars == _selectedStarFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Phản hồi học viên')),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return _buildLoadingSkeleton();
          }

          if (state is AdminError) {
            return _buildErrorState(state.message);
          }

          if (state is ClassFeedbacksLoaded) {
            final allFeedbacks = state.feedbacks;

            if (allFeedbacks.isEmpty) {
              return _buildEmptyState(theme, isDark);
            }

            final stats = _calculateStats(allFeedbacks);
            final filteredFeedbacks = _filterFeedbacks(allFeedbacks);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminBloc>().add(
                  LoadClassFeedbacks(widget.classId),
                );
              },
              child: CustomScrollView(
                slivers: [
                  
                  SliverToBoxAdapter(
                    child: _buildStatsSection(theme, isDark, stats),
                  ),
                  
                  SliverToBoxAdapter(
                    child: _buildStarFilter(theme, isDark, stats),
                  ),
                  
                  if (filteredFeedbacks.isEmpty)
                    SliverFillRemaining(
                      child: _buildNoFilterResult(theme, isDark),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.p8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final feedback = filteredFeedbacks[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSizes.p12),
                            child: _FeedbackCard(
                              feedback: feedback,
                              isDark: isDark,
                            ),
                          );
                        }, childCount: filteredFeedbacks.length),
                      ),
                    ),
                ],
              ),
            );
          }

          return _buildEmptyState(theme, isDark);
        },
      ),
    );
  }

  
  Widget _buildStatsSection(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> stats,
  ) {
    final avgRating = (stats['average'] as double);
    final total = stats['total'] as int;
    final avgTeacher = (stats['avgTeacher'] as double);
    final avgFacility = (stats['avgFacility'] as double);
    final avgOverall = (stats['avgOverall'] as double);

    return Container(
      margin: EdgeInsets.all(AppSizes.paddingMedium),
      padding: EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê đánh giá',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.p16),
          Row(
            children: [
              
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.warning,
                          size: 18.sp,
                        );
                      }),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$total đánh giá',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSizes.p16),
              
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildRatingBar(
                      theme,
                      isDark,
                      'Giảng viên',
                      avgTeacher,
                      Icons.person,
                    ),
                    SizedBox(height: AppSizes.p8),
                    _buildRatingBar(
                      theme,
                      isDark,
                      'Cơ sở vật chất',
                      avgFacility,
                      Icons.business,
                    ),
                    SizedBox(height: AppSizes.p8),
                    _buildRatingBar(
                      theme,
                      isDark,
                      'Hài lòng chung',
                      avgOverall,
                      Icons.favorite,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildRatingBar(
    ThemeData theme,
    bool isDark,
    String label,
    double rating,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
        SizedBox(
          width: 80.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rating / 5,
              backgroundColor: isDark ? AppColors.gray700 : AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 6,
            ),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildStarFilter(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> stats,
  ) {
    final starCounts = stats['starCounts'] as Map<int, int>;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc theo số sao',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                
                _buildFilterChip(
                  theme,
                  isDark,
                  label: 'Tất cả',
                  count: stats['total'],
                  isSelected: _selectedStarFilter == null,
                  onTap: () {
                    setState(() {
                      _selectedStarFilter = null;
                    });
                  },
                ),
                SizedBox(width: 8),
                
                ...List.generate(5, (index) {
                  final star = 5 - index;
                  final count = starCounts[star] ?? 0;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      theme,
                      isDark,
                      label: '$star',
                      count: count,
                      isSelected: _selectedStarFilter == star,
                      showStar: true,
                      onTap: () {
                        setState(() {
                          _selectedStarFilter = star;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: AppSizes.p8),
        ],
      ),
    );
  }

  
  Widget _buildFilterChip(
    ThemeData theme,
    bool isDark, {
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    bool showStar = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.gray600 : AppColors.gray300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStar) ...[
              Icon(
                Icons.star,
                size: 14.sp,
                color: isSelected ? Colors.white : AppColors.warning,
              ),
              SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.gray300 : AppColors.gray700),
              ),
            ),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : (isDark ? AppColors.gray700 : AppColors.gray200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.gray400 : AppColors.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildNoFilterResult(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_list_off,
            size: 48.sp,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          SizedBox(height: AppSizes.p12),
          Text(
            'Không có đánh giá nào',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStarFilter = null;
              });
            },
            child: const Text('Xem tất cả'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppSizes.p12),
        child: SkeletonWidget.rectangular(height: 120.h),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: AppSizes.p16),
          Text(message, textAlign: TextAlign.center),
          SizedBox(height: AppSizes.p16),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(LoadClassFeedbacks(widget.classId));
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64.sp,
            color: isDark ? AppColors.gray600 : AppColors.gray400,
          ),
          SizedBox(height: AppSizes.p16),
          Text(
            'Chưa có phản hồi nào',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            'Học viên chưa gửi đánh giá cho lớp học này',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.gray500 : AppColors.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  final AdminFeedback feedback;
  final bool isDark;

  const _FeedbackCard({required this.feedback, required this.isDark});

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final feedback = widget.feedback;
    final isDark = widget.isDark;

    return Container(
      padding: EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: feedback.studentAvatar != null
                    ? NetworkImage(feedback.studentAvatar!)
                    : null,
                child: feedback.studentAvatar == null
                    ? Text(
                        feedback.studentName.isNotEmpty
                            ? feedback.studentName.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.studentName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      dateFormat.format(feedback.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: AppColors.warning, size: 14.sp),
                      SizedBox(width: 4),
                      Text(
                        feedback.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.warning,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetailedRatings(theme, isDark, feedback),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          
          if (feedback.comment.isNotEmpty) ...[
            SizedBox(height: AppSizes.p12),
            Text(
              feedback.comment,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRatings(
    ThemeData theme,
    bool isDark,
    AdminFeedback feedback,
  ) {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.p12),
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800.withOpacity(0.5) : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Column(
        children: [
          _buildRatingRow(
            theme,
            isDark,
            icon: Icons.person,
            label: 'Giảng viên',
            rating: feedback.teacherRating,
          ),
          SizedBox(height: 8),
          _buildRatingRow(
            theme,
            isDark,
            icon: Icons.business,
            label: 'Cơ sở vật chất',
            rating: feedback.facilityRating,
          ),
          SizedBox(height: 8),
          _buildRatingRow(
            theme,
            isDark,
            icon: Icons.favorite,
            label: 'Hài lòng chung',
            rating: feedback.overallRating,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required double? rating,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
        
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1;
            final ratingValue = rating ?? 0;
            return Icon(
              starValue <= ratingValue ? Icons.star : Icons.star_border,
              color: AppColors.warning,
              size: 14.sp,
            );
          }),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(
            rating != null ? rating.toStringAsFixed(0) : '-',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
