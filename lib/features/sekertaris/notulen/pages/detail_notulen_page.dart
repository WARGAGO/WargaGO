import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/detail_info_card.dart';
import 'package:wargago/features/sekertaris/notulen/widgets/detail_item.dart';

/// Halaman Detail Notulen Rapat
class DetailNotulenPage extends StatelessWidget {
  final String date;
  final String time;
  final String title;
  final String location;
  final int attendees;
  final int topics;
  final int decisions;
  final bool isArchived;
  final String agenda;
  final String discussion;
  final String decisionsText;
  final String actionItems;

  const DetailNotulenPage({
    super.key,
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.attendees,
    required this.topics,
    required this.decisions,
    this.isArchived = false,
    required this.agenda,
    required this.discussion,
    required this.decisionsText,
    required this.actionItems,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Detail Notulen',
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

            // Title and Archive Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Archive Badge
                  if (isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.archive,
                            color: Colors.orange.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Diarsipkan',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isArchived) const SizedBox(height: 16),
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
                    'Informasi Rapat',
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

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Topik Pembahasan',
                          topics.toString(),
                          Icons.topic,
                          const Color(0xFF2F80ED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Keputusan',
                          decisions.toString(),
                          Icons.check_circle,
                          const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Agenda Section
                  Text(
                    'Agenda Rapat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContentSection(agenda),

                  const SizedBox(height: 24),

                  // Topics Discussion Section
                  Text(
                    'Pembahasan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContentSection(discussion),

                  const SizedBox(height: 24),

                  // Decisions Section
                  Text(
                    'Keputusan Rapat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildDecisionsList(decisionsText),

                  const SizedBox(height: 24),

                  // Action Items Section
                  Text(
                    'Tindak Lanjut',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContentSection(actionItems),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }



  List<Widget> _buildDecisionsList(String decisionsText) {
    final lines = decisionsText.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final widgets = <Widget>[];
    
    for (int i = 0; i < lines.length; i++) {
      widgets.add(_buildDecisionCard(i + 1, lines[i]));
      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    
    return widgets;
  }

  Widget _buildDecisionCard(int number, String decision) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF27AE60),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              decision,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
