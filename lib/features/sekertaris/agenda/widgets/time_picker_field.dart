import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget untuk memilih waktu
class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay selectedTime;
  final VoidCallback onTap;

  const TimePickerField({
    super.key,
    required this.label,
    required this.selectedTime,
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
                  Icons.access_time,
                  size: 20,
                  color: Color(0xFF2F80ED),
                ),
                const SizedBox(width: 12),
                Text(
                  selectedTime.format(context),
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
