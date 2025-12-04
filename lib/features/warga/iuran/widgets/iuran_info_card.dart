// ============================================================================
// IURAN INFO CARD WIDGET
// ============================================================================
// Widget untuk menampilkan ringkasan informasi iuran
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class IuranInfoCard extends StatelessWidget {
  final String namaIuran;
  final int jumlah;
  final String tanggal;

  const IuranInfoCard({
    super.key,
    required this.namaIuran,
    required this.jumlah,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Iuran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildInfoRow('Jenis Iuran', namaIuran),
          const SizedBox(height: 16),
          _buildInfoRow('Jumlah Tagihan', currencyFormat.format(jumlah)),
          const SizedBox(height: 16),
          _buildInfoRow('Jatuh Tempo', tanggal),
          const SizedBox(height: 16),
          _buildInfoRow('Periode', 'November 2025'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
