import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk button logout
/// Button dengan styling merah untuk logout
class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE74C3C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFE74C3C).withAlpha(77),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Keluar dari Akun',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
