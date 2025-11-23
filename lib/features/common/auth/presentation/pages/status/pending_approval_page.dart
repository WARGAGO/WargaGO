import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jawara/core/constants/app_routes.dart';

/// Halaman yang ditampilkan saat akun warga masih menunggu persetujuan admin
class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 80,
                  color: Color(0xFF2F80ED),
                ),
              ),
              const SizedBox(height: 32),

              // Judul
              Text(
                'Menunggu Persetujuan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 16),

              // Deskripsi
              Text(
                'Akun Anda sedang dalam proses verifikasi oleh admin. Kami akan memberitahu Anda setelah akun disetujui.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF8D8D8D),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Biasanya proses ini memakan waktu 1-2 hari kerja.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 48),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2F80ED),
                    side: const BorderSide(color: Color(0xFF2F80ED), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    // Logout dan kembali ke pre-auth
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.preAuth,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Keluar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

