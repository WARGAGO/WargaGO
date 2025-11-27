// ============================================================================
// PROFILE INFO CARD WIDGET
// ============================================================================
// Card yang menampilkan informasi personal admin
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProfileInfoCard extends StatelessWidget {
  final Map<String, dynamic>? adminData;

  const ProfileInfoCard({
    super.key,
    required this.adminData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Informasi Personal',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildInfoRow(
            icon: Icons.badge_rounded,
            label: 'Nama Lengkap',
            value: adminData?['nama'] ?? '-',
            color: const Color(0xFF2F80ED),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.cake_rounded,
            label: 'Tanggal Lahir',
            value: _formatDate(adminData?['tanggalLahir']),
            color: const Color(0xFFFFA500),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.location_city_rounded,
            label: 'Tempat Lahir',
            value: adminData?['tempatLahir'] ?? '-',
            color: const Color(0xFF10B981),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.phone_rounded,
            label: 'Nomor Telepon',
            value: adminData?['nomorTelepon'] ?? '-',
            color: const Color(0xFF7C6FFF),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            icon: Icons.home_rounded,
            label: 'Alamat',
            value: adminData?['alamat'] ?? '-',
            color: const Color(0xFFEF4444),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            color: const Color(0xFFE5E7EB),
            thickness: 1,
            height: 1,
          ),
        ],
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '1 Januari 1990';

    try {
      if (date is DateTime) {
        return DateFormat('d MMMM yyyy', 'id_ID').format(date);
      } else if (date is String) {
        final parsedDate = DateTime.tryParse(date);
        if (parsedDate != null) {
          return DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);
        }
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return date.toString();
  }
}

