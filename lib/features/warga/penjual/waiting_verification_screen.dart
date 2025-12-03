// lib/pages/profile/widgets/waiting_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingVerificationScreen extends StatelessWidget {
  final VoidCallback onVerified;
  const WaitingVerificationScreen({super.key, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), onVerified);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF2F80ED),
                strokeWidth: 5,
              ),
              const SizedBox(height: 40),
              Text(
                "Pendaftaran sedang ditinjau",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "Tim kami sedang memverifikasi data Anda.\nMohon tunggu 1×24 jam.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali ke halaman utama"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
