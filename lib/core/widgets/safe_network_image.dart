// ============================================================================
// SAFE NETWORK IMAGE WIDGET
// ============================================================================
// Widget untuk menampilkan network image dengan error handling
// Mengatasi SSL handshake error dan network issues
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Icon(
                Icons.image_not_supported,
                size: 32,
                color: Colors.grey[400],
              ),
            ),
      ),
    );
  }
}

/// Safe Circle Avatar dengan Network Image
class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;

  const SafeCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[200],
        child: Icon(
          fallbackIcon,
          size: radius * 0.8,
          color: iconColor ?? Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: SizedBox(
              width: radius * 0.5,
              height: radius * 0.5,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            fallbackIcon,
            size: radius * 0.8,
            color: iconColor ?? Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

/// Extension untuk cek URL valid
extension ImageUrlValidator on String {
  bool get isValidImageUrl {
    if (isEmpty) return false;

    try {
      final uri = Uri.parse(this);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return false;
      }

      // Check if URL ends with common image extensions
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png') ||
          path.endsWith('.gif') ||
          path.endsWith('.webp') ||
          contains('blob.core.windows.net') || // Azure Blob Storage
          contains('firebasestorage.googleapis.com'); // Firebase Storage
    } catch (e) {
      return false;
    }
  }
}
