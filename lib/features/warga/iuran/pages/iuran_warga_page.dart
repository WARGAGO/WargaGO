// ============================================================================
// IURAN WARGA PAGE
// ============================================================================
// Halaman utama iuran untuk warga dengan info tagihan dan daftar iuran
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../widgets/iuran_header_card.dart';
import '../widgets/iuran_menu_grid.dart';
import '../widgets/iuran_list_section.dart';

class IuranWargaPage extends StatelessWidget {
  const IuranWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header Card - Info Iuran Belum Dibayar
            const IuranHeaderCard(
              jumlahBelumDibayar: 100000,
              jatuhTempo: '17 Nov 2025',
            ),

            const SizedBox(height: 20),

            // Menu Grid - Total Tagihan, Iuran Sampah, Laporan Kas
            const IuranMenuGrid(),

            const SizedBox(height: 24),

            // Daftar Iuran dengan Tabs
            const IuranListSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Iuran Warga',
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
          letterSpacing: -0.5,
          height: 1.2,
        ),
      ),
      centerTitle: false,
      shadowColor: Colors.black.withValues(alpha: 0.05),
    );
  }
}
