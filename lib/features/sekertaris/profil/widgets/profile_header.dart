import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk menampilkan header profil pengguna
/// Menampilkan foto, nama, role, dan email
class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final String userEmail;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2F80ED).withAlpha(25),
            const Color(0xFF2F80ED).withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2F80ED).withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2F80ED),
                  Color(0xFF1E5BA8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F80ED).withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(userName),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    userRole,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF718096),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get user initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
