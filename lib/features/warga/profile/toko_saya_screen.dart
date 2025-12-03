// lib/pages/profile/toko_saya_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ubah_informasi_toko_screen.dart';

import '../penjual/register_penjual_screen.dart';
import '../penjual/waiting_verification_screen.dart';
import '../penjual/success_verification_screen.dart';
import '../penjual/produk_saya_screen.dart';

class TokoSayaScreen extends StatefulWidget {
  const TokoSayaScreen({super.key});

  @override
  State<TokoSayaScreen> createState() => _TokoSayaScreenState();
}

class _TokoSayaScreenState extends State<TokoSayaScreen> {
  // Ganti nilai ini untuk simulasi status penjual:
  // 0 = Belum daftar sama sekali
  // 1 = Sedang ditinjau
  // 2 = Baru diverifikasi (tampil success)
  // 3 = Sudah aktif → tampil profil toko + list produk (seperti yang sudah kamu punya)
  int sellerStatus = 0;

  void goToNextStep() => setState(() => sellerStatus++);

  @override
  Widget build(BuildContext context) {
    // === ALUR PENJUAL SAYUR (Persis seperti gambar) ===
    if (sellerStatus == 0) {
      return RegisterPenjualScreen(onSubmit: goToNextStep);
    }
    if (sellerStatus == 1) {
      return WaitingVerificationScreen(onVerified: goToNextStep);
    }
    if (sellerStatus == 2) {
      return SuccessVerificationScreen(onContinue: goToNextStep);
    }

    // === JIKA SUDAH AKTIF → TAMPILKAN HALAMAN ASLI YANG SUDAH ADA ===
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Akun Toko Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/300?img=68',
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Sayur Mas Yanto',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Sayuran segar dan premiummm',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('Edit Profil Toko', style: GoogleFonts.poppins()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UbahInformasiTokoScreen(),
              ),
            ),
          ),
          // === TAMBAHAN: Tombol ke List Produk ===
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('Produk Saya', style: GoogleFonts.poppins()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProdukSayaScreen()),
              );
            },
          ),
          const Spacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F80ED),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProdukSayaScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
