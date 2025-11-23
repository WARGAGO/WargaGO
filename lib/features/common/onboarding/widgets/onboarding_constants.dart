// ============================================================================
// ONBOARDING CONSTANTS
// ============================================================================
// Konstanta warna, spacing, dan durasi animasi untuk fitur Onboarding
// ============================================================================

import 'package:flutter/material.dart';

class OnboardingColors {
  OnboardingColors._();

  static const Color accent = Color(0xFF2F80ED);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF3D3D3D);
  static const Color progressTrack = Color(0xFFE0E0E0);
}

class OnboardingSpacing {
  OnboardingSpacing._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class OnboardingRadius {
  OnboardingRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
}

class OnboardingDurations {
  OnboardingDurations._();

  static const Duration pageTransition = Duration(milliseconds: 600);
  static const Duration slideEntrance = Duration(milliseconds: 1200);
  static const Duration progress = Duration(milliseconds: 500);
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration arrow = Duration(milliseconds: 1500);
}

