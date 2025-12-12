import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/notulen/pages/edit_notulen_page.dart';
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
        actions: [
          if (!isArchived)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNotulenPage(
                      date: date,
                      time: time,
                      title: title,
                      location: location,
                      attendees: attendees,
                    ),
                  ),
                );

                // Refresh halaman jika ada perubahan
                if (result == true && context.mounted) {
                  // TODO: Refresh data dari database
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notulen berhasil diperbarui',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFF27AE60),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
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
                  _buildContentSection(
                    '1. Pembukaan dan sambutan ketua\n'
                    '2. Laporan kegiatan bulan lalu\n'
                    '3. Pembahasan program kerja baru\n'
                    '4. Evaluasi keuangan\n'
                    '5. Lain-lain',
                  ),

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
                  _buildTopicCard(
                    'Program Kerja Q1 2025',
                    'Diskusi mengenai rencana program kerja untuk kuartal pertama 2025, termasuk alokasi anggaran dan pembagian tugas tim.',
                  ),
                  const SizedBox(height: 12),
                  _buildTopicCard(
                    'Evaluasi Keuangan',
                    'Review laporan keuangan periode November-Desember 2024 dan perencanaan anggaran untuk tahun depan.',
                  ),
                  const SizedBox(height: 12),
                  _buildTopicCard(
                    'Persiapan Acara HUT RI',
                    'Pembahasan konsep dan persiapan teknis untuk perayaan HUT RI mendatang, termasuk kepanitiaan dan anggaran.',
                  ),

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
                  _buildDecisionCard(
                    1,
                    'Menyetujui proposal program kerja dengan revisi minor pada timeline implementasi.',
                  ),
                  const SizedBox(height: 12),
                  _buildDecisionCard(
                    2,
                    'Mengalokasikan anggaran sebesar Rp 15.000.000 untuk kegiatan HUT RI.',
                  ),
                  const SizedBox(height: 12),
                  _buildDecisionCard(
                    3,
                    'Membentuk tim koordinator yang terdiri dari 5 orang untuk mengawasi pelaksanaan program.',
                  ),
                  const SizedBox(height: 12),
                  _buildDecisionCard(
                    4,
                    'Menetapkan rapat evaluasi bulanan setiap tanggal 15.',
                  ),
                  const SizedBox(height: 12),
                  _buildDecisionCard(
                    5,
                    'Menyetujui kerjasama dengan vendor untuk penyediaan perlengkapan acara.',
                  ),

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
                  _buildActionItem(
                    'Finalisasi proposal program kerja',
                    'Tim Program',
                    '15 Des 2024',
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildActionItem(
                    'Penyusunan detail anggaran acara',
                    'Bendahara',
                    '18 Des 2024',
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildActionItem(
                    'Survey vendor dan perbandingan harga',
                    'Tim Koordinator',
                    '20 Des 2024',
                    false,
                  ),

                  const SizedBox(height: 24),

                  // Attendees Section
                  Text(
                    'Daftar Hadir',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAttendeesList(),

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

  Widget _buildTopicCard(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.topic,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildActionItem(
      String task, String assignee, String deadline, bool isCompleted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? const Color(0xFF27AE60) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      assignee,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deadline,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
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

  Widget _buildAttendeesList() {
    final attendees = [
      {'name': 'Budi Santoso', 'role': 'Ketua RT 01'},
      {'name': 'Siti Aminah', 'role': 'Sekretaris'},
      {'name': 'Ahmad Yani', 'role': 'Bendahara'},
      {'name': 'Dewi Lestari', 'role': 'Ketua RT 02'},
      {'name': 'Eko Prasetyo', 'role': 'Ketua RW'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: attendees.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final attendee = attendees[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2F80ED).withValues(alpha: 0.1),
              child: Text(
                attendee['name']![0],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ),
            title: Text(
              attendee['name']!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              attendee['role']!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              Icons.check_circle,
              color: const Color(0xFF27AE60),
              size: 20,
            ),
          );
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.share,
                color: Color(0xFF2F80ED),
              ),
              title: Text(
                'Bagikan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share logic
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.download,
                color: Color(0xFF27AE60),
              ),
              title: Text(
                'Export PDF',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Export PDF logic
              },
            ),
            ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive : Icons.archive,
                color: const Color(0xFFF39C12),
              ),
              title: Text(
                isArchived ? 'Keluarkan dari Arsip' : 'Arsipkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Archive logic
              },
            ),
            if (!isArchived)
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Color(0xFFE74C3C),
                ),
                title: Text(
                  'Hapus',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE74C3C),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus Notulen?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus notulen "$title"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Kembali ke list
              // TODO: Delete logic
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: const Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
