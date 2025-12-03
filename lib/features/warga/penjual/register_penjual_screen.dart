// lib/pages/profile/widgets/register_penjual_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPenjualScreen extends StatelessWidget {
  final VoidCallback onSubmit;
  const RegisterPenjualScreen({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar sebagai Penjual"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cahot sebagoj peujual",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _field("Nama Lengkap"),
            _field("Nomor Telepon"),
            _field("Email"),
            _field("Alamat Toko"),
            _field("Kecamatan"),
            _field("Kota/Kabupaten"),
            const SizedBox(height: 24),
            const Text(
              "Upload KTP",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: const Color(0xFF2F80ED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Daftar Sekarang",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
