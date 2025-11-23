import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Full page untuk menampilkan semua log aktivitas
class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  String _filterType = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Data Warga',
    'Keuangan',
    'Agenda',
    'Sistem'
  ];

  // Mock data - nanti bisa diganti dengan data dari database/API
  final List<Map<String, dynamic>> _allActivities = [
    {
      'no': 1,
      'deskripsi': 'Menambah data warga baru',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(hours: 2)),
      'tipe': 'Data Warga',
      'icon': Icons.person_add_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'no': 2,
      'deskripsi': 'Menambah pemasukan Rp 500.000',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(hours: 3)),
      'tipe': 'Keuangan',
      'icon': Icons.add_card_rounded,
      'color': Color(0xFF2F80ED),
    },
    {
      'no': 3,
      'deskripsi': 'Mengedit metode pembayaran DANA',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(hours: 5)),
      'tipe': 'Keuangan',
      'icon': Icons.edit_rounded,
      'color': Color(0xFFFFA755),
    },
    {
      'no': 4,
      'deskripsi': 'Membuat kegiatan "Kerja Bakti"',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(days: 1)),
      'tipe': 'Agenda',
      'icon': Icons.event_rounded,
      'color': Color(0xFF7C6FFF),
    },
    {
      'no': 5,
      'deskripsi': 'Menghapus data warga',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(days: 2)),
      'tipe': 'Data Warga',
      'icon': Icons.delete_rounded,
      'color': Color(0xFFEB5757),
    },
    {
      'no': 6,
      'deskripsi': 'Mengupdate profil admin',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(days: 3)),
      'tipe': 'Sistem',
      'icon': Icons.settings_rounded,
      'color': Color(0xFF6B7280),
    },
    {
      'no': 7,
      'deskripsi': 'Menambah pengeluaran untuk listrik',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(days: 4)),
      'tipe': 'Keuangan',
      'icon': Icons.remove_circle_rounded,
      'color': Color(0xFFEB5757),
    },
    {
      'no': 8,
      'deskripsi': 'Broadcast notifikasi ke semua warga',
      'aktor': 'Admin Diana',
      'tanggal': DateTime.now().subtract(const Duration(days: 5)),
      'tipe': 'Agenda',
      'icon': Icons.campaign_rounded,
      'color': Color(0xFF2F80ED),
    },
  ];

  List<Map<String, dynamic>> get _filteredActivities {
    if (_filterType == 'Semua') {
      return _allActivities;
    }
    return _allActivities.where((act) => act['tipe'] == _filterType).toList();
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2F80ED),
                Color(0xFF1E6FD9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A2F80ED),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Log Aktivitas',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter berdasarkan:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A7C89),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((option) {
                      final isSelected = _filterType == option;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(option),
                          onSelected: (selected) {
                            setState(() {
                              _filterType = option;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF2F80ED).withValues(alpha: 0.15),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF2F80ED)
                                : const Color(0xFF7A7C89),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2F80ED)
                                  : const Color(0xFFE8EAF2),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Activities List
          Expanded(
            child: _filteredActivities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada aktivitas',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _filteredActivities[index];
                      return _ActivityLogItem(
                        no: activity['no'],
                        deskripsi: activity['deskripsi'],
                        aktor: activity['aktor'],
                        tanggal: activity['tanggal'],
                        timeAgo: _getTimeAgo(activity['tanggal']),
                        icon: activity['icon'],
                        color: activity['color'],
                        isLast: index == _filteredActivities.length - 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogItem extends StatelessWidget {
  const _ActivityLogItem({
    required this.no,
    required this.deskripsi,
    required this.aktor,
    required this.tanggal,
    required this.timeAgo,
    required this.icon,
    required this.color,
    required this.isLast,
  });

  final int no;
  final String deskripsi;
  final String aktor;
  final DateTime tanggal;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8EAF2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$no',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deskripsi,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: const Color(0xFF7A7C89),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          aktor,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A7C89),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: const Color(0xFF7A7C89),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(tanggal),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A7C89),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

