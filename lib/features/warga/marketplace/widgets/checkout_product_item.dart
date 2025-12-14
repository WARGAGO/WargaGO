// ============================================================================
// CHECKOUT PRODUCT ITEM WIDGET
// ============================================================================
// Widget untuk menampilkan item produk di checkout
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/utils/azure_blob_url_helper.dart';

class CheckoutProductItem extends StatelessWidget {
  final String storeName;
  final String productName;
  final int quantity;
  final String unit;
  final String price;
  final String imageUrl;
  final String shippingCost;
  final String shippingName;

  const CheckoutProductItem({
    super.key,
    required this.storeName,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.imageUrl,
    required this.shippingCost,
    required this.shippingName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Name with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.storefront,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                storeName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Product Details
          Row(
            children: [
              // Product Image with error handling
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl, // ✅ Keep SAS token
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon ketika image gagal load
                      return Container(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Color(0xFF10B981),
                          size: 30,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jumlah : $quantity $unit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Price
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
          
          const Divider(height: 24, color: Color(0xFFE5E7EB)),
          
          // Subtotal Produk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Produk',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Biaya Pengiriman
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shippingName,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
              Text(
                shippingCost,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: shippingCost == 'Gratis'
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1F2937),
                  fontWeight: shippingCost == 'Gratis'
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 16, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          
          // Total Keseluruhan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                _calculateTotal(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    // Parse harga produk
    int productPrice = int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));
    
    // Parse harga pengiriman
    int shippingPrice = 0;
    if (shippingCost != 'Gratis') {
      shippingPrice = int.parse(shippingCost.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    
    // Hitung total
    int total = productPrice + shippingPrice;
    
    // Format kembali ke string
    return 'Rp. ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
