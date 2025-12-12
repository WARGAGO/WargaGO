import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/agenda_card.dart';

/// Halaman Agenda untuk Sekretaris
/// Menampilkan semua agenda/kegiatan dengan filter dan pencarian
class SekretarisAgendaPage extends StatefulWidget {
  const SekretarisAgendaPage({super.key});

  @override
  State<SekretarisAgendaPage> createState() => _SekretarisAgendaPageState();
}

class _SekretarisAgendaPageState extends State<SekretarisAgendaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2F80ED),
              const Color(0xFF2F80ED).withValues(alpha: 0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agenda Kegiatan',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Kelola dan pantau kegiatan',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Color(0xFF2F80ED),
                            ),
                            onPressed: () {
                              // TODO: Tambah agenda baru
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari agenda...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section with Tabs
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFF2F80ED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey.shade600,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: const [
                            Tab(text: 'Akan Datang'),
                            Tab(text: 'Hari Ini'),
                            Tab(text: 'Selesai'),
                          ],
                        ),
                      ),
                      // Tab View
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAgendaList('upcoming'),
                            _buildAgendaList('today'),
                            _buildAgendaList('completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaList(String type) {
    // Dummy data untuk contoh
    final List<Map<String, dynamic>> agendaItems = _getAgendaByType(type);

    if (agendaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada agenda',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada kegiatan untuk kategori ini',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: agendaItems.length,
      itemBuilder: (context, index) {
        final agenda = agendaItems[index];
        return AgendaCard(
          date: agenda['date'],
          time: agenda['time'],
          title: agenda['title'],
          location: agenda['location'],
          description: agenda['description'],
          status: agenda['status'],
          attendees: agenda['attendees'],
          onTap: () {
            // TODO: Detail agenda
          },
          onMenuTap: () {
            _showActionMenu(context, agenda['status']);
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAgendaByType(String type) {
    // Dummy data - nanti akan diganti dengan data dari database
    final allAgenda = [
      {
        'date': '13 Des 2025',
        'time': '09:00',
        'title': 'Rapat Koordinasi RT',
        'location': 'Balai RW',
        'description': 'Pembahasan program kerja bulan Januari 2026',
        'status': 'upcoming',
        'attendees': 15,
      },
      {
        'date': '12 Des 2025',
        'time': '09:00',
        'title': 'Rapat Koordinasi RT',
        'location': 'Balai RW',
        'description': 'Pembahasan program kerja',
        'status': 'today',
        'attendees': 12,
      },
      {
        'date': '12 Des 2025',
        'time': '13:00',
        'title': 'Pembuatan Notulen Rapat',
        'location': 'Kantor Sekretariat',
        'description': 'Dokumentasi hasil rapat',
        'status': 'today',
        'attendees': 5,
      },
      {
        'date': '12 Des 2025',
        'time': '15:30',
        'title': 'Arsip Surat Masuk',
        'location': 'Kantor Sekretariat',
        'description': 'Pengarsipan dokumen administratif',
        'status': 'completed',
        'attendees': 3,
      },
      {
        'date': '15 Des 2025',
        'time': '14:00',
        'title': 'Sosialisasi Program Baru',
        'location': 'Aula Warga',
        'description': 'Pengenalan program kesehatan warga',
        'status': 'upcoming',
        'attendees': 50,
      },
      {
        'date': '11 Des 2025',
        'time': '10:00',
        'title': 'Rapat Internal',
        'location': 'Ruang Rapat',
        'description': 'Evaluasi kinerja bulan November',
        'status': 'completed',
        'attendees': 8,
      },
    ];

    return allAgenda.where((agenda) => agenda['status'] == type).toList();
  }

  void _showActionMenu(BuildContext context, String status) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
              _buildActionItem(
                icon: Icons.visibility,
                label: 'Lihat Detail',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lihat detail
                },
              ),
              if (status != 'completed')
                _buildActionItem(
                  icon: Icons.edit,
                  label: 'Edit Agenda',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Edit agenda
                  },
                ),
              if (status != 'completed')
                _buildActionItem(
                  icon: Icons.check_circle,
                  label: 'Tandai Selesai',
                  color: const Color(0xFF27AE60),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Tandai selesai
                  },
                ),
              _buildActionItem(
                icon: Icons.delete,
                label: 'Hapus Agenda',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Hapus agenda
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.grey.shade700,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.grey.shade700,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
