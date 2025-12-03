import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class SkeletonWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonWidget.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = size / 2,
        shape = BoxShape.circle;

  const SkeletonWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  }) : shape = BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.gray800 : AppColors.gray200,
      highlightColor: isDark ? AppColors.gray700 : AppColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : Colors.white,
          borderRadius: shape == BoxShape.rectangle 
              ? BorderRadius.circular(borderRadius) 
              : null,
          shape: shape,
        ),
      ),
    );
  }
}
