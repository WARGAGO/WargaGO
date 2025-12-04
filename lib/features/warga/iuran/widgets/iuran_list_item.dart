// ============================================================================
// IURAN LIST ITEM WIDGET
// ============================================================================
// Widget item untuk daftar iuran dengan icon, nama, tanggal, dan action buttons
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/iuran_detail_page.dart';

class IuranListItem extends StatelessWidget {
  final String nama;
  final String tanggal;
  final String status; // 'lunas', 'belum_lunas', 'tersedia'

  const IuranListItem({
    super.key,
    required this.nama,
    required this.tanggal,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IuranDetailPage(
              namaIuran: nama,
              jumlah: 100000, // TODO: Pass real data
              tanggal: tanggal,
              status: status,
              keterangan: 'Iuran wajib untuk keamanan lingkungan RT/RW',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(),
                size: 24,
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _getStatusTextColor(),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.edit_rounded,
                color: const Color(0xFF2F80ED),
                onTap: () {
                  // TODO: Edit iuran
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Edit $nama',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFF2F80ED),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_rounded,
                color: const Color(0xFFEF4444),
                onTap: () {
                  // TODO: Delete iuran
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hapus $nama',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 19,
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'lunas':
        return Icons.check_circle_rounded;
      case 'belum_lunas':
        return Icons.account_balance_wallet_rounded;
      case 'tersedia':
        return Icons.location_on_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'lunas':
        return const Color(0xFF10B981);
      case 'belum_lunas':
        return const Color(0xFF2F80ED);
      case 'tersedia':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case 'lunas':
        return const Color(0xFF10B981);
      case 'tersedia':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
