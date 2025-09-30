import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutx_core/flutx_core.dart';
import '../shimmer/shimmer_loader.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData? errorIcon;
  final Color? errorIconColor;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorIcon = Icons.error,
    this.errorIconColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    // DPrint.log("Attempting to load image from URL: $imageUrl");

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        httpHeaders: {
          'Cache-Control': 'max-age=86400',
          'Accept': 'image/*', // Explicitly request image content
        },
        placeholder: (context, url) => ShimmerLoader(
          isLoading: true,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          DPrint.log('Image load failed - URL: $url');
          DPrint.log('Error details: $error');

          // Attempt to load with Image.network for better error reporting
          return _buildFallbackImage(url);
        },
      ),
    );
  }

  Widget _buildFallbackImage(String url) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        DPrint.log('Fallback Image.network error: $error');
        DPrint.log('Stack trace: $stackTrace');
        return Container(
          color: Colors.grey.shade200,
          child: Icon(errorIcon, color: errorIconColor),
        );
      },
    );
  }
}
