import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../detail_rumah_page.dart';
import 'custom_avatar.dart';

/// Card item for displaying rumah data
class RumahCardItem extends StatelessWidget {
  final String alamat;
  final String status;
  final int index;

  const RumahCardItem({
    super.key,
    required this.alamat,
    required this.status,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CustomAvatar(
            icon: Icons.home,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alamat,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _buildDetailButton(context),
        ],
      ),
    );
  }

  Widget _buildDetailButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRumahPage(
              rumahData: {
                'alamat': '$alamat No. ${index + 1}, RT 08 RW 05',
                'status': status,
              },
            ),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2F80ED)),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(80, 36),
      ),
      child: const Text(
        'Details',
        style: TextStyle(
          color: Color(0xFF2F80ED),
          fontSize: 12,
        ),
      ),
    );
  }
}

