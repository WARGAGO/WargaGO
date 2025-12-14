// lib/features/bendahara/keuangan/iuran_warga_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IuranWargaPage extends StatelessWidget {
  const IuranWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F80ED), Color(0xFF1E5BA8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Iuran Warga',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _wargaCard('A1', 'Budi Santoso', 'Blok A1', true),
                      _wargaCard('B3', 'Siti Aminah', 'Blok B3', false),
                      _wargaCard('C5', 'Ahmad Yani', 'Blok C5', true),
                      _wargaCard('D2', 'Rina Melati', 'Blok D2', false),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to form pencatatan pembayaran
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(
                            'Catat Pembayaran Baru',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F80ED),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wargaCard(String kode, String nama, String blok, bool sudahBayar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: sudahBayar
                ? const Color(0xFF27AE60)
                : Colors.orange,
            child: Text(
              kode,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  blok,
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp 150.000',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sudahBayar ? const Color(0xFF27AE60) : Colors.red,
                ),
              ),
              Text(
                sudahBayar ? 'Lunas' : 'Belum Bayar',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: sudahBayar ? const Color(0xFF27AE60) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
