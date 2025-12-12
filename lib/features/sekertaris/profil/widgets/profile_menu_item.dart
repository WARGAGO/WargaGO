import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk menampilkan item menu di profil
/// Menampilkan icon, title, subtitle, dan arrow
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2F80ED),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF718096),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
