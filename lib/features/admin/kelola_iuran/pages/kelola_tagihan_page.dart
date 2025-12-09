// filepath: c:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025\lib\features\admin\kelola_iuran\pages\kelola_tagihan_page.dart
// ============================================================================
// KELOLA TAGIHAN PAGE - REDIRECT TO NEW KELOLA IURAN
// ============================================================================
// Redirect ke halaman Kelola Iuran yang baru dengan fitur lengkap
// Tab-based view untuk monitor tagihan (Aktif/Terlambat/Lunas)
// ============================================================================

import 'package:flutter/material.dart';
import '../../iuran/kelola_iuran_page.dart';

/// Wrapper class untuk redirect ke KelolaIuranPage yang baru
/// Di halaman baru, bisa lihat detail per iuran dan filter tagihan by status
class KelolaTagihanPage extends StatelessWidget {
  const KelolaTagihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto redirect ke halaman baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const KelolaIuranPage(),
        ),
      );
    });

    // Show loading while redirecting
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat Kelola Tagihan...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

