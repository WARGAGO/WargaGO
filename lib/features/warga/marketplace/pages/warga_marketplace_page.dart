// ============================================================================
// WARGA MARKETPLACE PAGE (MAIN)
// ============================================================================
// Halaman utama marketplace dengan produk sayuran
// ============================================================================

import 'package:flutter/material.dart';
import '../widgets/marketplace_app_bar.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/marketplace_category_filter.dart';
import '../widgets/marketplace_promo_banner.dart';
import '../widgets/marketplace_product_card.dart';

class WargaMarketplacePage extends StatelessWidget {
  const WargaMarketplacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            const MarketplaceAppBar(cartCount: 2),

            const SizedBox(height: 12),

            // Search Bar
            const MarketplaceSearchBar(),

            const SizedBox(height: 8),

            // Category Filter
            const MarketplaceCategoryFilter(),

            const SizedBox(height: 12),

            // Promo Banner
            const MarketplacePromoBanner(),

            const SizedBox(height: 12),

            // Product Grid
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
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
