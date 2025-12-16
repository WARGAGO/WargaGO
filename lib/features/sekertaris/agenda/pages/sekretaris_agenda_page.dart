import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/features/sekertaris/agenda/widgets/agenda_card.dart';
import 'package:wargago/features/sekertaris/agenda/pages/tambah_agenda_page.dart';
import 'package:wargago/features/sekertaris/agenda/pages/detail_agenda_page.dart';
import 'package:wargago/features/sekertaris/agenda/pages/edit_agenda_page.dart';
import 'package:wargago/features/sekertaris/agenda/models/agenda_model.dart';

/// Halaman Agenda untuk Sekretaris
class SekretarisAgendaPage extends StatefulWidget {
  const SekretarisAgendaPage({super.key});

  @override
  State<SekretarisAgendaPage> createState() => _SekretarisAgendaPageState();
}

class _SekretarisAgendaPageState extends State<SekretarisAgendaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // State Management - List lokal untuk menyimpan data Agenda
  final List<AgendaModel> _agendaList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }
  
  // Load data awal (dummy data untuk demo)
  void _loadInitialData() {
    _agendaList.addAll([
      AgendaModel(
        id: '1',
        date: '13 Des 2025',
        time: '09:00',
        title: 'Rapat Koordinasi RT',
        location: 'Balai RW',
        description: 'Pembahasan program kerja bulan Januari 2026',
        status: 'upcoming',
        attendees: 15,
      ),
      AgendaModel(
        id: '2',
        date: '12 Des 2025',
        time: '09:00',
        title: 'Rapat Koordinasi RT',
        location: 'Balai RW',
        description: 'Pembahasan program kerja',
        status: 'today',
        attendees: 12,
      ),
      AgendaModel(
        id: '3',
        date: '12 Des 2025',
        time: '13:00',
        title: 'Pembuatan Notulen Rapat',
        location: 'Kantor Sekretariat',
        description: 'Dokumentasi hasil rapat',
        status: 'today',
        attendees: 5,
      ),
      AgendaModel(
        id: '4',
        date: '12 Des 2025',
        time: '15:30',
        title: 'Arsip Surat Masuk',
        location: 'Kantor Sekretariat',
        description: 'Pengarsipan dokumen administratif',
        status: 'completed',
        attendees: 3,
      ),
      AgendaModel(
        id: '5',
        date: '15 Des 2025',
        time: '14:00',
        title: 'Sosialisasi Program Baru',
        location: 'Aula Warga',
        description: 'Pengenalan program kesehatan warga',
        status: 'upcoming',
        attendees: 50,
      ),
      AgendaModel(
        id: '6',
        date: '11 Des 2025',
        time: '10:00',
        title: 'Rapat Internal',
        location: 'Ruang Rapat',
        description: 'Evaluasi kinerja bulan November',
        status: 'completed',
        attendees: 8,
      ),
    ]);
  }
  
  // Method untuk menambah agenda baru
  void _addAgenda(AgendaModel agenda) {
    setState(() {
      _agendaList.add(agenda);
    });
  }
  
  // Method untuk update agenda
  void _updateAgenda(String id, AgendaModel updatedAgenda) {
    setState(() {
      final index = _agendaList.indexWhere((agenda) => agenda.id == id);
      if (index != -1) {
        _agendaList[index] = updatedAgenda;
      }
    });
  }
  
  // Method untuk menghapus agenda
  void _deleteAgenda(String id) {
    setState(() {
      _agendaList.removeWhere((agenda) => agenda.id == id);
    });
  }
  
  // Method untuk mengubah status agenda
  void _updateAgendaStatus(String id, String newStatus) {
    setState(() {
      final index = _agendaList.indexWhere((agenda) => agenda.id == id);
      if (index != -1) {
        _agendaList[index] = _agendaList[index].copyWith(status: newStatus);
      }
    });
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
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TambahAgendaPage(),
                                ),
                              );
                              // Terima data dari form tambah dan tambahkan ke state
                              if (result != null && result is AgendaModel) {
                                _addAgenda(result);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Agenda berhasil ditambahkan',
                                          style: GoogleFonts.poppins(),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF27AE60),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
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
    // Filter agenda berdasarkan tipe dan pencarian
    List<AgendaModel> filteredAgenda = _agendaList
        .where((agenda) => agenda.status == type)
        .toList();
    
    // Filter berdasarkan pencarian
    if (_searchController.text.isNotEmpty) {
      filteredAgenda = filteredAgenda.where((agenda) =>
        agenda.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        agenda.location.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    if (filteredAgenda.isEmpty) {
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
              _searchController.text.isNotEmpty 
                  ? 'Agenda tidak ditemukan'
                  : 'Tidak ada agenda',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Belum ada kegiatan untuk kategori ini',
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
      itemCount: filteredAgenda.length,
      itemBuilder: (context, index) {
        final agenda = filteredAgenda[index];
        return AgendaCard(
          date: agenda.date,
          time: agenda.time,
          title: agenda.title,
          location: agenda.location,
          description: agenda.description,
          status: agenda.status,
          attendees: agenda.attendees,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailAgendaPage(
                  date: agenda.date,
                  time: agenda.time,
                  title: agenda.title,
                  location: agenda.location,
                  description: agenda.description,
                  status: agenda.status,
                  attendees: agenda.attendees,
                ),
              ),
            );
            if (result != null && result is Map<String, dynamic>) {
              // Handle hasil dari detail page (edit/delete)
              if (result['action'] == 'delete') {
                _deleteAgenda(agenda.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Agenda berhasil dihapus',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF27AE60),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (result['action'] == 'update') {
                // Update data dari edit
                _updateAgenda(agenda.id, result['data']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Agenda berhasil diperbarui',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF27AE60),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
          onMenuTap: () {
            _showActionMenu(context, agenda);
          },
        );
      },
    );
  }

  void _showActionMenu(BuildContext context, AgendaModel agenda) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Pilih Aksi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Action Items
            if (agenda.status != 'completed')
              _buildActionCard(
                icon: Icons.edit_rounded,
                label: 'Edit Agenda',
                subtitle: 'Ubah informasi agenda',
                color: const Color(0xFF2F80ED),
                onTap: () async {
                  Navigator.pop(context);
                  // Navigate ke edit page dengan data lengkap
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAgendaPage(
                        id: agenda.id,
                        date: agenda.date,
                        time: agenda.time,
                        title: agenda.title,
                        location: agenda.location,
                        description: agenda.description,
                        status: agenda.status,
                        attendees: agenda.attendees,
                      ),
                    ),
                  );
                  
                  // Terima data yang sudah diedit dan update state
                  if (result != null && result is AgendaModel) {
                    _updateAgenda(agenda.id, result);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'Agenda berhasil diperbarui',
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF27AE60),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            if (agenda.status != 'completed') const SizedBox(height: 12),
            
            if (agenda.status != 'completed')
              _buildActionCard(
                icon: Icons.check_circle_rounded,
                label: 'Tandai Selesai',
                subtitle: 'Tandai agenda sebagai selesai',
                color: const Color(0xFF27AE60),
                onTap: () {
                  Navigator.pop(context);
                  _showCompleteConfirmation(context, agenda);
                },
              ),
            
            if (agenda.status != 'completed') const SizedBox(height: 16),
            if (agenda.status != 'completed')
              Divider(color: Colors.grey.shade200, height: 1),
            if (agenda.status != 'completed') const SizedBox(height: 16),
            
            _buildActionCard(
              icon: Icons.delete_rounded,
              label: 'Hapus Agenda',
              subtitle: 'Hapus permanen dari sistem',
              color: const Color(0xFFE74C3C),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, agenda);
              },
            ),
            
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteConfirmation(BuildContext context, AgendaModel agenda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF27AE60),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tandai Selesai?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Agenda "${agenda.title}" akan ditandai sebagai selesai. Anda masih bisa melihatnya di tab Selesai.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update status agenda menggunakan state management
              _updateAgendaStatus(agenda.id, 'completed');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Agenda berhasil ditandai selesai',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Tandai Selesai',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AgendaModel agenda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Color(0xFFE74C3C),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hapus Agenda?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus agenda ini?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFE74C3C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan!',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Hapus agenda menggunakan state management
              _deleteAgenda(agenda.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Agenda berhasil dihapus',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF27AE60),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
