import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Widget untuk memilih tanggal
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF2F80ED),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
