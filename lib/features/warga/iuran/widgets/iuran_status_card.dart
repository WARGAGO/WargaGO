// ============================================================================
// IURAN STATUS CARD WIDGET
// ============================================================================
// Widget untuk menampilkan status pembayaran iuran
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IuranStatusCard extends StatelessWidget {
  final String status;

  const IuranStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Handle Firestore status values
    switch (status) {
      case 'Lunas':
        statusColor = const Color(0xFF10B981);
        statusText = 'Lunas';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'Terlambat':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Terlambat';
        statusIcon = Icons.warning_rounded;
        break;
      case 'Belum Dibayar':
      default:
        statusColor = const Color(0xFFEF4444);
        statusText = 'Belum Dibayar';
        statusIcon = Icons.error_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: -0.3,
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
