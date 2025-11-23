// ============================================================================
// KEUANGAN CONSTANTS
// ============================================================================
// Konstanta untuk fitur Keuangan
//
// Clean Code Principles:
// ✅ Single Responsibility - hanya menyimpan konstanta
// ✅ DRY - tidak ada duplikasi nilai
// ✅ Easy maintenance - ubah di satu tempat
// ============================================================================

import 'package:flutter/material.dart';

/// Konstanta warna untuk Keuangan
class KeuanganColors {
  KeuanganColors._();

  // Primary colors
  static const Color primary = Color(0xFF2F80ED);
  static const Color primaryLight = Color(0xFFE3F2FD);

  // Income/Expense colors
  static const Color income = Color(0xFF4CAF50);
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFFF5252);
  static const Color expenseLight = Color(0xFFFFEBEE);

  // Background colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFFA755);
  static const Color error = Color(0xFFEB5757);
  static const Color info = Color(0xFF2F80ED);
}

/// Konstanta spacing untuk Keuangan
class KeuanganSpacing {
  KeuanganSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

/// Konstanta radius untuk Keuangan
class KeuanganRadius {
  KeuanganRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
}

/// Konstanta icon size untuk Keuangan
class KeuanganIconSize {
  KeuanganIconSize._();

  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

/// Kategori pemasukan
class KeuanganKategori {
  KeuanganKategori._();

  static const List<String> pemasukan = [
    'Iuran Warga',
    'Donasi',
    'Dana Bantuan Pemerintah',
    'Pemeliharaan Fasilitas',
    'Pendapatan Lainnya',
  ];

  static const List<String> pengeluaran = [
    'Operasional',
    'Pemeliharaan',
    'Kegiatan',
    'Bantuan Sosial',
    'Lainnya',
  ];
}

/// Report types
class KeuanganReportType {
  KeuanganReportType._();

  static const String semua = 'Semua';
  static const String pemasukan = 'Pemasukan';
  static const String pengeluaran = 'Pengeluaran';

  static const List<String> types = [semua, pemasukan, pengeluaran];
}

