import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wargago/core/models/laporan_keuangan_model.dart';
import 'package:wargago/core/services/laporan_keuangan_service.dart';

class LaporanKeuanganDetailPage extends StatefulWidget {
  final LaporanKeuanganModel laporan;

  const LaporanKeuanganDetailPage({
    super.key,
    required this.laporan,
  });

  @override
  State<LaporanKeuanganDetailPage> createState() => _LaporanKeuanganDetailPageState();
}

class _LaporanKeuanganDetailPageState extends State<LaporanKeuanganDetailPage>
    with SingleTickerProviderStateMixin {
  final LaporanKeuanganService _service = LaporanKeuanganService();
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Increment views
    _service.incrementViews(widget.laporan.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Summary Cards
          _buildSummaryCards(),
          // Search Bar (if has data)
          if (_hasTransactionData()) _buildSearchBar(),
          // Tabs
          if (_hasTransactionData()) _buildTabs(),
          // Content
          Expanded(
            child: _hasTransactionData()
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransactionList(widget.laporan.dataPemasukan, true),
                      _buildTransactionList(widget.laporan.dataPengeluaran, false),
                    ],
                  )
                : _buildNoDataState(),
          ),
        ],
      ),
    );
  }

  bool _hasTransactionData() {
    return widget.laporan.dataPemasukan.isNotEmpty || widget.laporan.dataPengeluaran.isNotEmpty;
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2988EA), Color(0xFF1E6FBA)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2988EA).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.laporan.judul,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 6),
                            Text(
                              widget.laporan.periode.label,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.laporan.keterangan.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white.withOpacity(0.9), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.laporan.keterangan,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final isPemasukan = widget.laporan.jenisLaporan == 'pemasukan';
    final isPengeluaran = widget.laporan.jenisLaporan == 'pengeluaran';
    final isGabungan = widget.laporan.jenisLaporan == 'gabungan';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isGabungan) ...[
            // Show all three cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard(
                  '💰',
                  'Pemasukan',
                  currencyFormat.format(widget.laporan.statistik.totalPemasukan),
                  const Color(0xFF10B981),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard(
                  '💸',
                  'Pengeluaran',
                  currencyFormat.format(widget.laporan.statistik.totalPengeluaran),
                  const Color(0xFFEF4444),
                )),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              '📊',
              'Saldo',
              currencyFormat.format(widget.laporan.statistik.saldo),
              widget.laporan.statistik.saldo >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              isLarge: true,
            ),
          ] else if (isPemasukan) ...[
            _buildSummaryCard(
              '💰',
              'Total Pemasukan',
              currencyFormat.format(widget.laporan.statistik.totalPemasukan),
              const Color(0xFF10B981),
              isLarge: true,
            ),
          ] else if (isPengeluaran) ...[
            _buildSummaryCard(
              '💸',
              'Total Pengeluaran',
              currencyFormat.format(widget.laporan.statistik.totalPengeluaran),
              const Color(0xFFEF4444),
              isLarge: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String emoji, String label, String value, Color color, {bool isLarge = false}) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isLarge ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isLarge ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: isLarge ? 28 : 24),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: isLarge ? 16 : 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 12 : 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isLarge ? 24 : 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: isLarge ? TextAlign.center : TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari transaksi...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8EAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2988EA), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2988EA),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 18),
                const SizedBox(width: 6),
                Text('Pemasukan (${widget.laporan.dataPemasukan.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 18),
                const SizedBox(width: 6),
                Text('Pengeluaran (${widget.laporan.dataPengeluaran.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransaksiLaporan> transactions, bool isPemasukan) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada ${isPemasukan ? 'pemasukan' : 'pengeluaran'}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Filter by search
    var filteredList = transactions.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return item.nama.toLowerCase().contains(query) ||
          item.kategori.toLowerCase().contains(query) ||
          item.deskripsi.toLowerCase().contains(query);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(filteredList[index], isPemasukan);
      },
    );
  }

  Widget _buildTransactionCard(TransaksiLaporan transaksi, bool isPemasukan) {
    final color = isPemasukan ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPemasukan ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaksi.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaksi.kategori,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(transaksi.nominal),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (transaksi.deskripsi.isNotEmpty && transaksi.deskripsi != '-') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, size: 14, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaksi.deskripsi,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                transaksi.tanggal,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: transaksi.status == 'Terverifikasi'
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  transaksi.status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: transaksi.status == 'Terverifikasi'
                        ? const Color(0xFF10B981)
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data transaksi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan ini tidak memiliki rincian transaksi',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

