// ============================================================================
// PRODUCT DETAIL APP BAR WIDGET
// ============================================================================
// SliverAppBar untuk halaman detail produk
// ============================================================================

import 'package:flutter/material.dart';

class ProductDetailAppBar extends StatelessWidget {
  final String? imageUrl;

  const ProductDetailAppBar({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1F2937), size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: const Color(0xFFF3F4F6),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
