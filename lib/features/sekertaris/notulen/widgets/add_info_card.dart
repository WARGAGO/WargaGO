import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget info card untuk halaman tambah notulen
class AddInfoCard extends StatelessWidget {
  const AddInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F80ED).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF2F80ED),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Isi formulir di bawah untuk menambahkan notulen rapat baru',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF2F80ED),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
