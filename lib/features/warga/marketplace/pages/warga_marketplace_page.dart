// ============================================================================
// WARGA MARKETPLACE PAGE (MAIN)
// ============================================================================
// Halaman utama marketplace dengan produk sayuran
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/marketplace_category_filter.dart';
import '../widgets/marketplace_promo_banner.dart';
import '../widgets/marketplace_product_card.dart';

class WargaMarketplacePage extends StatelessWidget {
  const WargaMarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          const MarketplaceSearchBar(),
          
          // Category Filter
          const MarketplaceCategoryFilter(),
          
          // Promo Banner
          const MarketplacePromoBanner(),
          
          // Product Grid
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Produk Sayuran',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1F2937)),
          onPressed: () {
            // TODO: Navigate to cart
          },
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4, // Demo: 4 products
      itemBuilder: (context, index) {
        return const MarketplaceProductCard(
          productName: 'Wortel',
          price: 'Rp. 10.000',
        );
      },
    );
  }
}
