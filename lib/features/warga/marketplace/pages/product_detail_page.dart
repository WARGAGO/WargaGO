// ============================================================================
// PRODUCT DETAIL PAGE
// ============================================================================
// Halaman detail produk sayuran
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/product_detail_app_bar.dart';
import '../widgets/product_info_widget.dart';
import '../widgets/product_description_widget.dart';
import '../widgets/product_seller_info_widget.dart';
import '../widgets/product_bottom_bar.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;
  final String price;
  final String? imageUrl;

  const ProductDetailPage({
    super.key,
    required this.productName,
    required this.price,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          ProductDetailAppBar(imageUrl: imageUrl),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info
                ProductInfoWidget(
                  productName: productName,
                  price: price,
                ),
                
                const Divider(height: 1),
                
                // Description
                const ProductDescriptionWidget(),
                
                const Divider(height: 1),
                
                // Seller Info
                const ProductSellerInfoWidget(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ProductBottomBar(),
    );
  }
}
