// ============================================================================
// CHECKOUT SHIPPING OPTION WIDGET
// ============================================================================
// Widget untuk memilih opsi pengiriman
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutShippingOption extends StatelessWidget {
  final String selectedOption;
  final Function(String) onChanged;

  const CheckoutShippingOption({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Opsi Pengiriman',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          Row(
            children: [
              Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF2F80ED),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF2F80ED),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
