import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/detail_info_card.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/detail_item.dart';

/// Halaman Detail Agenda Kegiatan
class DetailAgendaPage extends StatelessWidget {
  final String date;
  final String time;
  final String title;
  final String location;
  final String description;
  final String status;
  final int attendees;

  const DetailAgendaPage({
    super.key,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.status,
    required this.attendees,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF27AE60);
        statusText = 'Selesai';
        statusIcon = Icons.check_circle;
        break;
      case 'today':
        statusColor = const Color(0xFFF39C12);
        statusText = 'Hari Ini';
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = const Color(0xFF2F80ED);
        statusText = 'Akan Datang';
        statusIcon = Icons.schedule;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Detail Agenda',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Title and Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date & Time Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: DetailInfoCard(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: date,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetailInfoCard(
                      icon: Icons.access_time,
                      label: 'Waktu',
                      value: time,
                      color: const Color(0xFF2F80ED),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Kegiatan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  DetailItem(
                    icon: Icons.location_on,
                    label: 'Lokasi',
                    value: location,
                  ),

                  const SizedBox(height: 16),

                  // Attendees
                  DetailItem(
                    icon: Icons.people,
                    label: 'Jumlah Peserta',
                    value: '$attendees orang',
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
