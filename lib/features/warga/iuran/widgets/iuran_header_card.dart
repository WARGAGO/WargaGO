// ============================================================================
// IURAN HEADER CARD WIDGET
// ============================================================================
// Widget untuk menampilkan info iuran belum dibayar dengan tombol bayar
// ✅ UPDATED: Now using real data from IuranWargaProvider
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/iuran_warga_provider.dart';
import '../pages/iuran_detail_page.dart';

class IuranHeaderCard extends StatelessWidget {
  final IuranWargaProvider provider;

  const IuranHeaderCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    // Get first unpaid tagihan for detail navigation
    final firstUnpaid = provider.tagihanAktif.isNotEmpty 
        ? provider.tagihanAktif.first 
        : provider.tagihanTerlambat.isNotEmpty 
            ? provider.tagihanTerlambat.first 
            : null;

    // Calculate total unpaid
    final totalBelumDibayar = provider.totalBelumDibayar;
    final countTunggakan = provider.countTunggakan;

    return GestureDetector(
      onTap: firstUnpaid != null ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IuranDetailPage(
              tagihanId: firstUnpaid.id, // ⭐ ADDED: Pass tagihan ID
              namaIuran: firstUnpaid.jenisIuranName,
              jumlah: firstUnpaid.nominal.toInt(),
              tanggal: dateFormat.format(firstUnpaid.periodeTanggal),
              status: firstUnpaid.status,
              keterangan: firstUnpaid.catatan,
            ),
          ),
        );
      } : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2F80ED),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Iuran belum dibayar',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(totalBelumDibayar),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (countTunggakan > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF5722),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFFFFFFFF),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$countTunggakan tagihan belum dibayar',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFFFFFFFF),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Semua iuran lunas',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
