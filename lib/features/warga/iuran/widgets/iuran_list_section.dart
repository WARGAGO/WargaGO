// ============================================================================
// IURAN LIST SECTION WIDGET
// ============================================================================
// Widget section daftar iuran dengan tabs (Semua, Lunas, Belum Lunas)
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iuran_list_item.dart';

class IuranListSection extends StatefulWidget {
  const IuranListSection({super.key});

  @override
  State<IuranListSection> createState() => _IuranListSectionState();
}

class _IuranListSectionState extends State<IuranListSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan filter button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Iuran',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
              InkWell(
                onTap: () {
                  // TODO: Implement filter
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F80ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF2F80ED),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF6B7280),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Lunas'),
              Tab(text: 'Belum Lunas'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab Bar View
        SizedBox(
          height: 400, // Fixed height untuk list
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIuranList('semua'),
              _buildIuranList('lunas'),
              _buildIuranList('belum_lunas'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIuranList(String filter) {
    // Dummy data
    final List<Map<String, dynamic>> dummyIuran = [
      {
        'nama': 'Iuran Keamanan',
        'tanggal': '6 Nov 2025',
        'status': 'belum_lunas',
      },
      {
        'nama': 'Jl. Merbabu',
        'tanggal': 'Tersedia',
        'status': 'tersedia',
      },
      {
        'nama': 'Jl. Merbabu',
        'tanggal': 'Tersedia',
        'status': 'tersedia',
      },
    ];

    // Filter berdasarkan tab
    List<Map<String, dynamic>> filteredIuran;
    if (filter == 'lunas') {
      filteredIuran = dummyIuran.where((i) => i['status'] == 'lunas').toList();
    } else if (filter == 'belum_lunas') {
      filteredIuran = dummyIuran.where((i) => i['status'] != 'lunas').toList();
    } else {
      filteredIuran = dummyIuran;
    }

    if (filteredIuran.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 60,
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredIuran.length,
      itemBuilder: (context, index) {
        final iuran = filteredIuran[index];
        return IuranListItem(
          nama: iuran['nama'],
          tanggal: iuran['tanggal'],
          status: iuran['status'],
        );
      },
    );
  }
}
