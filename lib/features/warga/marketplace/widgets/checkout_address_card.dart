// ============================================================================
// CHECKOUT ADDRESS CARD WIDGET
// ============================================================================
// Card untuk menampilkan alamat pengiriman
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutAddressCard extends StatelessWidget {
  final String recipientName;
  final String phoneNumber;
  final String address;

  const CheckoutAddressCard({
    super.key,
    required this.recipientName,
    required this.phoneNumber,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  const Color(0xFF1E6FD9).withValues(alpha: 0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF2F80ED),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      recipientName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      phoneNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
