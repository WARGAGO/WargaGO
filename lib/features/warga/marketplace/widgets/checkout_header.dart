// ============================================================================
// CHECKOUT HEADER WIDGET
// ============================================================================
// Header untuk halaman checkout dengan back button
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutHeader extends StatelessWidget {
  const CheckoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Ringkasan Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
