import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jawara/core/constants/app_routes.dart';

/// Halaman yang ditampilkan saat akun warga ditolak oleh admin
class RejectedPage extends StatelessWidget {
  const RejectedPage({
    super.key,
    this.reason,
  });

  final String? reason;

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
                  color: const Color(0xFFEB5757).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  size: 80,
                  color: Color(0xFFEB5757),
                ),
              ),
              const SizedBox(height: 32),

              // Judul
              Text(
                'Registrasi Ditolak',
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
                'Maaf, registrasi Anda tidak dapat disetujui oleh admin.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF8D8D8D),
                ),
              ),

              if (reason != null && reason!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEB5757).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan Penolakan:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEB5757),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: const Color(0xFF5F5F5F),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Info tambahan
              Text(
                'Silakan hubungi admin jika Anda merasa ini adalah kesalahan, atau coba daftar ulang dengan data yang benar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.6,
                  color: const Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 48),

              // Tombol Daftar Ulang
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    // Logout dan kembali ke registrasi
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.wargaRegister,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Daftar Ulang'),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8D8D8D),
                    side: const BorderSide(color: Color(0xFFDDDDDD), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.preAuth,
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

