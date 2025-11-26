// ============================================================================
// CHECKOUT BOTTOM BAR WIDGET
// ============================================================================
// Bottom bar untuk total harga dan button checkout
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutBottomBar extends StatelessWidget {
  final String totalPrice;
  final VoidCallback onCheckout;

  const CheckoutBottomBar({
    super.key,
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            
            // Checkout Button with gradient
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2F80ED),
                    Color(0xFF1E6FD9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Buat Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
