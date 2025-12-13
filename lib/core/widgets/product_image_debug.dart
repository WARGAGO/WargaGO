// ============================================================================
// PRODUCT IMAGE WIDGET
// ============================================================================
// Widget untuk display gambar produk dengan proper error handling
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductImageDebug extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImageDebug({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFF3F4F6),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null;

            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2F80ED),
                  ),
                  value: progress,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: height * 0.35,
                    color: const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gambar\ntidak\ntersedia',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: height * 0.08,
                      color: const Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

