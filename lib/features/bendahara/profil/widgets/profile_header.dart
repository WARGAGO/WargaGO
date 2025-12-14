// lib/features/bendahara/profil/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header profil untuk Bendahara
class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2F80ED).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar dengan icon bendahara
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2F80ED), Color(0xFF1E5BA8)],
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Bendahara',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
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
                      size: 16,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
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
}
