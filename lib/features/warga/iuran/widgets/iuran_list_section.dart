// ============================================================================
// IURAN LIST SECTION WIDGET
// ============================================================================
// Widget section daftar iuran dengan tabs (Aktif, Terlambat, Lunas)
// ✅ UPDATED: Now using real data from IuranWargaProvider
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/iuran_warga_provider.dart';
import '../../../../core/models/tagihan_model.dart';
import 'iuran_list_item.dart';

class IuranListSection extends StatefulWidget {
  final IuranWargaProvider provider;
  
  const IuranListSection({
    super.key,
    required this.provider,
  });

  @override
  State<IuranListSection> createState() => _IuranListSectionState();
}

class _IuranListSectionState extends State<IuranListSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
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
        // Header
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
            tabs: [
              Tab(text: 'Aktif (${widget.provider.tagihanAktif.length})'),
              Tab(text: 'Terlambat (${widget.provider.tagihanTerlambat.length})'),
              Tab(text: 'Lunas (${widget.provider.historyPembayaran.length})'),
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
              _buildIuranList(widget.provider.tagihanAktif, 'aktif'),
              _buildIuranList(widget.provider.tagihanTerlambat, 'terlambat'),
              _buildIuranList(widget.provider.historyPembayaran, 'lunas'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIuranList(List<TagihanModel> tagihanList, String type) {
    if (tagihanList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'lunas' 
                  ? Icons.check_circle_outline
                  : Icons.inbox_rounded,
              size: 60,
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              type == 'lunas' 
                  ? 'Belum ada pembayaran'
                  : type == 'aktif'
                      ? 'Tidak ada tagihan aktif'
                      : 'Tidak ada tagihan terlambat',
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
      itemCount: tagihanList.length,
      itemBuilder: (context, index) {
        final tagihan = tagihanList[index];
        return IuranListItem(
          tagihan: tagihan,
        );
      },
    );
  }
}
