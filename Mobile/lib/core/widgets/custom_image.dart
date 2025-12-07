import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import 'skeleton_widget.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final bool isAvatar;
  final String? defaultAsset;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.isAvatar = false,
    this.defaultAsset,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildDefaultImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => SkeletonWidget(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
        ),
        errorWidget: (context, url, error) => _buildDefaultImage(),
      ),
    );
  }

  Widget _buildDefaultImage() {
    final assetPath =
        defaultAsset ?? (isAvatar ? 'assets/images/avatar-default.png' : null);

    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget();
          },
        ),
      );
    }

    
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral200,
      child: Icon(
        isAvatar ? Icons.person : Icons.error_outline,
        color: AppColors.neutral500,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : null,
      ),
    );
  }
}
