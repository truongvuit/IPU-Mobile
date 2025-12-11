import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import 'skeleton_widget.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final bool isAvatar;
  final String? defaultAsset;
  final String? cacheKey;

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
    this.isAvatar = false,
    this.defaultAsset,
    this.cacheKey,
  });

  
  String _normalizeImageUrl(String url) {
    if (url.isEmpty) return '';

    
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    
    final baseUrl = AppConstants.baseUrl;

    
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }

    
    
    if (!url.contains('/')) {
      return '$baseUrl/files/$url';
    }

    return '$baseUrl/$url';
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = _normalizeImageUrl(imageUrl);

    if (normalizedUrl.isEmpty) {
      return _buildDefaultImage();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: normalizedUrl,
        cacheKey: cacheKey ?? normalizedUrl,
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
    
    double? iconSize;
    if (width != null &&
        height != null &&
        width!.isFinite &&
        height!.isFinite) {
      iconSize = (width! < height! ? width! * 0.5 : height! * 0.5);
    } else if (width != null && width!.isFinite) {
      iconSize = width! * 0.5;
    } else if (height != null && height!.isFinite) {
      iconSize = height! * 0.5;
    }
    
    iconSize = (iconSize ?? 48).clamp(24, 96);

    return Container(
      width: width,
      height: height,
      color: AppColors.neutral200,
      child: Icon(
        isAvatar ? Icons.person : Icons.error_outline,
        color: AppColors.neutral500,
        size: iconSize,
      ),
    );
  }
}
