// ============================================================================
// AUTH CONSTANTS
// ============================================================================
// Konstanta untuk fitur authentication (Login & Register)
//
// Clean Code Principles:
// ✅ Single Responsibility - hanya menyimpan konstanta
// ✅ DRY - tidak ada duplikasi warna/nilai
// ✅ Easy maintenance - ubah di satu tempat, apply ke semua
// ============================================================================

import 'package:flutter/material.dart';

/// Konstanta warna untuk Auth
class AuthColors {
  AuthColors._(); // Private constructor

  // Primary colors
  static const Color primary = Color(0xFF2F80ED);
  static const Color primaryLight = Color(0xFFF0F7FF);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFB0B3C0);

  // Background colors
  static const Color background = Colors.white;
  static const Color backgroundBlob = Color(0x1F2F80ED); // 12% opacity
  static const Color backgroundBlobAccent = Color(0x592F80ED); // 35% opacity

  // Border colors
  static const Color border = Color(0xFFE2E4EC);
  static const Color borderFocused = Color(0xFF2F80ED);
  static const Color borderError = Colors.red;

  // Status colors
  static const Color error = Colors.red;
  static const Color success = Color(0xFF10B981);
}

/// Konstanta spacing untuk Auth
class AuthSpacing {
  AuthSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// Konstanta radius untuk Auth
class AuthRadius {
  AuthRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 26.0;
}

/// Konstanta icon size untuk Auth
class AuthIconSize {
  AuthIconSize._();

  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 54.0;
}

/// Konstanta default credentials
class AuthDefaults {
  AuthDefaults._();

  static const String defaultEmail = 'admin@jawara.com';
  static const String defaultPassword = 'admin123';
}

