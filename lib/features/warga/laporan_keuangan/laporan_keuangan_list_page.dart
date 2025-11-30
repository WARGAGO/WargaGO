import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wargago/core/models/laporan_keuangan_model.dart';
import 'package:wargago/core/services/laporan_keuangan_service.dart';
import 'package:wargago/features/warga/laporan_keuangan/laporan_keuangan_detail_page.dart';

class LaporanKeuanganListPage extends StatefulWidget {
  const LaporanKeuanganListPage({super.key});

  @override
  State<LaporanKeuanganListPage> createState() => _LaporanKeuanganListPageState();
}

class _LaporanKeuanganListPageState extends State<LaporanKeuanganListPage> {
  final LaporanKeuanganService _service = LaporanKeuanganService();
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _searchQuery = '';
  String _filterJenis = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Filter
          _buildFilter(),
          // List
          Expanded(
            child: StreamBuilder<List<LaporanKeuanganModel>>(
              stream: _service.getLaporanStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final laporanList = snapshot.data ?? [];

                if (laporanList.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter
                var filteredList = laporanList.where((laporan) {
                  // Filter by search
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    if (!laporan.judul.toLowerCase().contains(query) &&
                        !laporan.keterangan.toLowerCase().contains(query)) {
                      return false;
                    }
                  }

                  // Filter by jenis
                  if (_filterJenis != 'Semua' && laporan.jenisLaporan != _filterJenis.toLowerCase()) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return _buildEmptyState(isFiltered: true);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildLaporanCard(filteredList[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2988EA),
            Color(0xFF1E6FBA),
            Color(0xFF0F52BA),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2988EA).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Decorative circles background
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button & Title with icon badge
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(14),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Icon badge with animation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Keuangan',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: Colors.white.withValues(alpha: 0.95),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Transparansi RT',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.95),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Modern search bar with shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari laporan keuangan...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF2988EA),
                            size: 22,
                          ),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                color: Colors.grey[400],
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Semua'),
          const SizedBox(width: 8),
          _buildFilterChip('Pemasukan'),
          const SizedBox(width: 8),
          _buildFilterChip('Pengeluaran'),
          const SizedBox(width: 8),
          _buildFilterChip('Gabungan'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterJenis == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterJenis = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF2988EA).withValues(alpha: 0.2),
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? const Color(0xFF2988EA) : Colors.grey[700],
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF2988EA) : Colors.grey[300]!,
        width: 1.5,
      ),
    );
  }

  Widget _buildLaporanCard(LaporanKeuanganModel laporan) {
    final isPemasukan = laporan.jenisLaporan == 'pemasukan';
    final isPengeluaran = laporan.jenisLaporan == 'pengeluaran';
    final isGabungan = laporan.jenisLaporan == 'gabungan';

    Color jenisColor;
    IconData jenisIcon;
    String jenisLabel;
    LinearGradient cardGradient;

    if (isPemasukan) {
      jenisColor = const Color(0xFF10B981);
      jenisIcon = Icons.trending_up_rounded;
      jenisLabel = 'Pemasukan';
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          const Color(0xFF10B981).withValues(alpha: 0.03),
        ],
      );
    } else if (isPengeluaran) {
      jenisColor = const Color(0xFFEF4444);
      jenisIcon = Icons.trending_down_rounded;
      jenisLabel = 'Pengeluaran';
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          const Color(0xFFEF4444).withValues(alpha: 0.03),
        ],
      );
    } else {
      jenisColor = const Color(0xFF2988EA);
      jenisIcon = Icons.insert_chart_rounded;
      jenisLabel = 'Gabungan';
      cardGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          const Color(0xFF2988EA).withValues(alpha: 0.03),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LaporanKeuanganDetailPage(laporan: laporan),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: jenisColor.withValues(alpha: 0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: jenisColor.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative corner gradient
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          jenisColor.withValues(alpha: 0.08),
                          jenisColor.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          // Modern icon badge
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  jenisColor,
                                  jenisColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: jenisColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(jenisIcon, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  laporan.judul,
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    // Jenis badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: jenisColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: jenisColor.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        jenisLabel,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: jenisColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Periode badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 12,
                                            color: const Color(0xFF6B7280),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            laporan.periode.label,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Arrow icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: jenisColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: jenisColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Stats with modern design
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (isGabungan || isPemasukan) ...[
                              _buildStatRow(
                                '💰',
                                'Total Pemasukan',
                                currencyFormat.format(laporan.statistik.totalPemasukan),
                                const Color(0xFF10B981),
                                isLarge: isGabungan,
                              ),
                              if (isGabungan) const SizedBox(height: 12),
                            ],
                            if (isGabungan || isPengeluaran) ...[
                              _buildStatRow(
                                '💸',
                                'Total Pengeluaran',
                                currencyFormat.format(laporan.statistik.totalPengeluaran),
                                const Color(0xFFEF4444),
                                isLarge: isGabungan,
                              ),
                              if (isGabungan) const SizedBox(height: 12),
                            ],
                            if (isGabungan) ...[
                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFE5E7EB),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              _buildStatRow(
                                '📊',
                                'Saldo Akhir',
                                currencyFormat.format(laporan.statistik.saldo),
                                laporan.statistik.saldo >= 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                isBold: true,
                                isLarge: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Footer info
                      Row(
                        children: [
                          // Date badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('d MMM yyyy', 'id_ID').format(laporan.createdAt),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Views badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  jenisColor.withValues(alpha: 0.15),
                                  jenisColor.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: jenisColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  size: 14,
                                  color: jenisColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${laporan.viewsCount} views',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: jenisColor,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildStatRow(String emoji, String label, String value, Color color, {bool isBold = false, bool isLarge = false}) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: isLarge ? 22 : 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isLarge ? 13 : 12,
              color: const Color(0xFF6B7280),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: color,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({bool isFiltered = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off_rounded : Icons.description_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'Tidak ada hasil' : 'Belum ada laporan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'Coba ubah filter atau kata kunci'
                : 'Laporan keuangan akan muncul di sini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

