// ============================================================================
// WARGA MARKETPLACE PAGE (MAIN)
// ============================================================================
// Halaman utama marketplace dengan produk dari Firestore + Cloud Storage
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/marketplace_provider.dart';
import '../../../../core/models/marketplace_product_model.dart';
import '../widgets/marketplace_app_bar.dart';
import '../widgets/marketplace_search_bar.dart';
import '../widgets/marketplace_location_header.dart';
import '../widgets/marketplace_special_offers.dart';
import '../widgets/marketplace_category_icons.dart';
import '../widgets/marketplace_top_stores.dart';
import '../widgets/marketplace_popular_products.dart';
import 'product_detail_page.dart';

class WargaMarketplacePage extends StatefulWidget {
  const WargaMarketplacePage({super.key});

  @override
  State<WargaMarketplacePage> createState() => _WargaMarketplacePageState();
}

class _WargaMarketplacePageState extends State<WargaMarketplacePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<MarketplaceProvider>(context, listen: false);
    await Future.wait([
      provider.loadProducts(refresh: true),
      provider.loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const MarketplaceAppBar(),
                  const SizedBox(height: 8),
                  // Location Header (Optional)
                  const MarketplaceLocationHeader(),
                  const SizedBox(height: 8),
                  // Search Bar
                  MarketplaceSearchBar(
                    onSearch: (keyword) {
                      final provider = Provider.of<MarketplaceProvider>(
                        context,
                        listen: false,
                      );
                      provider.searchProducts(keyword);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Special Offers Section
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  MarketplaceSpecialOffers(),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Categories Section (includes subcategories when Sayuran selected)
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  MarketplaceCategoryIcons(),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Top Rated Stores Section
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  MarketplaceTopStores(),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // Popular Products Section
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  MarketplacePopularProducts(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
