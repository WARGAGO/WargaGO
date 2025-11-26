// ============================================================================
// CHECKOUT PAYMENT METHOD WIDGET
// ============================================================================
// Widget untuk menampilkan metode pembayaran
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPaymentMethod extends StatelessWidget {
  final String selectedMethod;
  final VoidCallback onTap;

  const CheckoutPaymentMethod({
    super.key,
    required this.selectedMethod,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF2F80ED),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedMethod,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}
