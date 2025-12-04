// ============================================================================
// IURAN MENU GRID WIDGET
// ============================================================================
// Widget grid menu untuk navigasi fitur iuran (Total Tagihan, Iuran Sampah, Laporan Kas)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IuranMenuGrid extends StatelessWidget {
  const IuranMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMenuItem(
              icon: Icons.receipt_long_rounded,
              label: 'Total\nTagihan',
              onTap: () {
                // TODO: Navigate to total tagihan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Total Tagihan',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF2F80ED),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMenuItem(
              icon: Icons.recycling_rounded,
              label: 'Iuran\nSampah',
              onTap: () {
                // TODO: Navigate to iuran sampah
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Iuran Sampah',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF2F80ED),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMenuItem(
              icon: Icons.home_rounded,
              label: 'Laporan\nKas',
              onTap: () {
                // TODO: Navigate to laporan kas
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Laporan Kas',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF2F80ED),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2F80ED),
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
                height: 1.3,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
