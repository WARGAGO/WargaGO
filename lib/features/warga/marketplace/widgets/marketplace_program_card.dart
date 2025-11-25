// ============================================================================
// MARKETPLACE PROGRAM CARD WIDGET
// ============================================================================
// Card untuk menampilkan program dukungan penjual
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceProgramCard extends StatelessWidget {
  const MarketplaceProgramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Program Dukungan Penjual',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        _buildFeatureItem(
          icon: Icons.store,
          title: 'Jual tanpa biaya awal',
          description: 'Buka lapak dan mulai tawarkan sayuranmu tanpa biaya apa pun.',
        ),
        
        const SizedBox(height: 20),
        
        _buildFeatureItem(
          icon: Icons.crop_free,
          title: 'Deteksi Kategori Sayur Otomatis',
          description: 'Unggah foto sayuranmu, dan sistem otomatis menentukan kategori sayuran.',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2F80ED),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
