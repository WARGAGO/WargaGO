// ============================================================================
// MARKETPLACE LOCATION HEADER WIDGET
// ============================================================================
// Header dengan lokasi pengguna (opsional)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceLocationHeader extends StatelessWidget {
  final String location;

  const MarketplaceLocationHeader({
    super.key,
    this.location = 'Jakarta, Indonesia',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: const Color(0xFF2F80ED),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            location,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

