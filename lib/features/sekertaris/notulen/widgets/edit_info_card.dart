import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget info card untuk halaman edit notulen
class EditInfoCard extends StatelessWidget {
  const EditInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF39C12).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF39C12).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_note,
            color: Color(0xFFF39C12),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Perbarui informasi notulen rapat sesuai kebutuhan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFFF39C12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
