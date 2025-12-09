// ============================================================================
// IURAN MENU GRID WIDGET
// ============================================================================
// Widget grid menu untuk navigasi fitur iuran dengan statistik real
// ✅ UPDATED: Now using real data from IuranWargaProvider
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/iuran_warga_provider.dart';

class IuranMenuGrid extends StatelessWidget {
  final IuranWargaProvider provider;
  
  const IuranMenuGrid({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildMenuItem(
              icon: Icons.receipt_long_rounded,
              label: 'Total Tagihan',
              value: '${provider.totalTagihan}',
              color: const Color(0xFF2F80ED),
              onTap: () {
                // TODO: Navigate to total tagihan
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMenuItem(
              icon: Icons.pending_actions_rounded,
              label: 'Belum Dibayar',
              value: '${provider.countTunggakan}',
              color: const Color(0xFFEF4444),
              onTap: () {
                // TODO: Navigate to unpaid list
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMenuItem(
              icon: Icons.check_circle_rounded,
              label: 'Lunas',
              value: '${provider.totalLunas}',
              color: const Color(0xFF10B981),
              onTap: () {
                // TODO: Navigate to paid list
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
    required String value,
    required Color color,
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
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
