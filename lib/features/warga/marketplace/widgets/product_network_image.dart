// ============================================================================
// PRODUCT NETWORK IMAGE WIDGET
// ============================================================================
// Reusable widget untuk menampilkan gambar produk dari network dengan
// proper error handling untuk Azure Blob Storage expired SAS token
// ✅ AUTO FALLBACK: Coba dengan token, kalau expired coba tanpa token
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/widgets/smart_network_image.dart';

class ProductNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ SmartNetworkImage: Auto-handles expired SAS tokens
    // 1. Try original URL (with token)
    // 2. If 403 and token expired → Try without token
    // 3. If still fails → Show error placeholder

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SmartNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        // SmartNetworkImage already has built-in loading and error handling
        errorWidget: _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: const Color(0xFF2F80ED).withValues(alpha: 0.5),
            size: (height ?? 100) * 0.3,
          ),
          if (height != null && height! > 80) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Gambar tidak tersedia',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Variant untuk circular/avatar style
class ProductAvatarImage extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const ProductAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ SmartNetworkImage: Auto-handles expired SAS tokens

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF2F80ED).withValues(alpha: 0.1),
      child: ClipOval(
        child: SmartNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorWidget: Icon(
            Icons.shopping_bag_outlined,
            color: const Color(0xFF2F80ED),
            size: radius,
          ),
        ),
      ),
    );
  }
}

