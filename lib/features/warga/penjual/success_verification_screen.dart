// lib/pages/profile/widgets/success_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessVerificationScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const SuccessVerificationScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), onContinue);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              "Verifikasi berhasil!",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Selamat! Akun penjual Anda telah aktif.\nSekarang Anda dapat mulai menjual produk.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 52),
                backgroundColor: const Color(0xFF2F80ED),
              ),
              child: const Text(
                "Mulai Berjualan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
