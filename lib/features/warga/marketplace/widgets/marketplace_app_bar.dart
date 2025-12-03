// ============================================================================
// MARKETPLACE APP BAR WIDGET
// ============================================================================
// Custom app bar untuk halaman marketplace dengan badge keranjang
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../pages/cart_page.dart';
import '../pages/my_orders_page.dart';

class MarketplaceAppBar extends StatefulWidget {
  const MarketplaceAppBar({super.key});

  @override
  State<MarketplaceAppBar> createState() => _MarketplaceAppBarState();
}

class _MarketplaceAppBarState extends State<MarketplaceAppBar> {
  @override
  void initState() {
    super.initState();
    // Load cart count saat app bar ditampilkan
    Future.microtask(() {
      context.read<CartProvider>().loadCartCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Produk Sayuran',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          Row(
            children: [
              _buildOrdersButton(context),
              const SizedBox(width: 8),
              _buildCartButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyOrdersPage()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.receipt_long_outlined,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
                if (cart.cartCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          cart.cartCount > 9 ? '9+' : '${cart.cartCount}',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

