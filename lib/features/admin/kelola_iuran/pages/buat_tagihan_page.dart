// filepath: c:\Peyimpanan Pribadi\Data D\New folder (2)\Semester 5\PBL 2025\lib\features\admin\kelola_iuran\pages\buat_tagihan_page.dart
// ============================================================================
// BUAT TAGIHAN PAGE - REDIRECT TO NEW KELOLA IURAN
// ============================================================================
// Redirect ke halaman Kelola Iuran yang baru dengan fitur lengkap
// Features: Create Iuran, Generate Tagihan, Manage Payments
// ============================================================================

import 'package:flutter/material.dart';
import '../../iuran/kelola_iuran_page.dart';

/// Wrapper class untuk redirect ke KelolaIuranPage yang baru
/// Fitur lengkap sudah ada di KelolaIuranPage:
/// - Create Iuran baru
/// - Auto-generate tagihan untuk semua warga
/// - View & manage tagihan
/// - Statistics & reporting
class BuatTagihanPage extends StatelessWidget {
  const BuatTagihanPage({super.key});

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
              'Memuat Kelola Iuran...',
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

