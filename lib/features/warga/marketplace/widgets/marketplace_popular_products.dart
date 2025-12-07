// ============================================================================
// MARKETPLACE POPULAR PRODUCTS WIDGET
// ============================================================================
// Menampilkan produk yang paling banyak dibeli
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/models/marketplace_product_model.dart';
import '../pages/product_detail_page.dart';
import 'product_network_image.dart';

class MarketplacePopularProducts extends StatelessWidget {
  const MarketplacePopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Products',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('isActive', isEqualTo: true)
              .orderBy('terjual', descending: true)
              .limit(10)
              .snapshots(includeMetadataChanges: true), // Force real-time updates
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (kDebugMode) {
                print('❌ Error loading products: ${snapshot.error}');
              }
              return const SizedBox.shrink();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              if (kDebugMode) {
                print('📦 No products available in Popular Products');
              }
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Belum ada produk tersedia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }

            final products = snapshot.data!.docs;

            // Check if data is from cache or server
            final isFromCache = snapshot.data!.metadata.isFromCache;

            if (kDebugMode) {
              final source = isFromCache ? 'CACHE' : 'SERVER';
              print('🔄 Popular Products updated: ${products.length} products (Source: $source)');
              print('   Product IDs: ${products.map((p) => p.id).take(3).toList()}');
            }

            return SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final doc = products[index];

                  // Convert new products collection to old model format
                  final productData = doc.data() as Map<String, dynamic>;
                  final product = MarketplaceProductModel(
                    id: doc.id,
                    productName: productData['nama'] ?? '',
                    description: productData['deskripsi'] ?? '',
                    price: (productData['harga'] ?? 0).toDouble(),
                    stock: productData['stok'] ?? 0,
                    category: productData['kategori'] ?? '',
                    imageUrls: List<String>.from(productData['imageUrls'] ?? []),
                    sellerId: productData['sellerId'] ?? '',
                    sellerName: productData['sellerName'] ?? '',
                    unit: 'kg', // Default unit
                    isActive: productData['isActive'] ?? true,
                    soldCount: productData['terjual'] ?? 0,
                    rating: 5.0, // Default rating
                    reviewCount: 0,
                    createdAt: (productData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    updatedAt: (productData['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  );

                  return _buildPopularProductCard(context, product);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularProductCard(BuildContext context, MarketplaceProductModel product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Stack(
              children: [
                product.imageUrls.isNotEmpty
                    ? ProductNetworkImage(
                        imageUrl: product.imageUrls.first,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      )
                    : _buildPlaceholderImage(),
                // Best Seller Badge
                if (product.soldCount > 50)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Best Seller',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 12,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.soldCount} terjual',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2F80ED).withValues(alpha: 0.3),
            const Color(0xFF1E5BB8).withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.image,
        size: 40,
        color: Color(0xFF2F80ED),
      ),
    );
  }
}

