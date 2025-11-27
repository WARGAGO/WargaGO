// ============================================================================
// PROFILE MENU SECTION WIDGET
// ============================================================================
// Menu navigasi untuk settings, FAQ, about, logout
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMenuSection extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onFAQTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

  const ProfileMenuSection({
    super.key,
    required this.onSettingsTap,
    required this.onFAQTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_rounded,
            title: 'Pengaturan',
            subtitle: 'Kelola pengaturan aplikasi',
            gradient: const LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
            ),
            onTap: onSettingsTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_rounded,
            title: 'FAQ',
            subtitle: 'Panduan & pertanyaan umum',
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
            ),
            onTap: onFAQTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_rounded,
            title: 'Tentang Aplikasi',
            subtitle: 'Informasi versi & developer',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            onTap: onAboutTap,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Keluar dari akun admin',
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
            onTap: onLogoutTap,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isLast ? 24 : 0),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        height: 1,
      ),
    );
  }
}

