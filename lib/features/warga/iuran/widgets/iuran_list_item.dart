// filepath: c:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025\lib\features\warga\iuran\widgets\iuran_list_item.dart
// ============================================================================
// IURAN LIST ITEM WIDGET
// ============================================================================
// Widget item untuk daftar iuran dengan icon, nama, tanggal, dan action buttons
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/tagihan_model.dart';
import '../pages/iuran_detail_page.dart';

class IuranListItem extends StatelessWidget {
  final TagihanModel tagihan;

  const IuranListItem({
    super.key,
    required this.tagihan,
  });

  Color _getStatusColor() {
    switch (tagihan.status) {
      case 'Lunas':
        return const Color(0xFF10B981);
      case 'Terlambat':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFFBBF24);
    }
  }

  IconData _getStatusIcon() {
    switch (tagihan.status) {
      case 'Lunas':
        return Icons.check_circle_rounded;
      case 'Terlambat':
        return Icons.error_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IuranDetailPage(
              tagihanId: tagihan.id, // ⭐ ADDED: Pass tagihan ID
              namaIuran: tagihan.jenisIuranName,
              jumlah: tagihan.nominal.toInt(),
              tanggal: dateFormat.format(tagihan.periodeTanggal),
              status: tagihan.status,
              keterangan: tagihan.catatan,
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
                    tagihan.jenisIuranName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        tagihan.periode,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currencyFormat.format(tagihan.nominal),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tagihan.status,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

