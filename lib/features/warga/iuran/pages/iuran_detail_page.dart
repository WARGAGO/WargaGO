// ============================================================================
// IURAN DETAIL PAGE
// ============================================================================
// Halaman detail ringkasan iuran dengan tombol bayar
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/iuran_status_card.dart';
import '../widgets/iuran_info_card.dart';
import '../widgets/iuran_keterangan_card.dart';
import '../widgets/iuran_payment_button.dart';

class IuranDetailPage extends StatelessWidget {
  final String namaIuran;
  final int jumlah;
  final String tanggal;
  final String status;
  final String? keterangan;

  const IuranDetailPage({
    super.key,
    required this.namaIuran,
    required this.jumlah,
    required this.tanggal,
    required this.status,
    this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Iuran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  IuranStatusCard(status: status),
                  
                  const SizedBox(height: 24),
                  
                  // Info Card
                  IuranInfoCard(
                    namaIuran: namaIuran,
                    jumlah: jumlah,
                    tanggal: tanggal,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Keterangan jika ada
                  if (keterangan != null && keterangan!.isNotEmpty)
                    IuranKeteranganCard(keterangan: keterangan!),
                ],
              ),
            ),
          ),
          
          
          // Bottom Payment Button (hanya jika belum lunas)
          if (status == 'belum_lunas')
            IuranPaymentButton(
              jumlah: jumlah,
              namaIuran: namaIuran,
              tanggal: tanggal,
            ),
        ],
      ),
    );
  }
}
