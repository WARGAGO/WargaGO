import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jawara/core/providers/jenis_iuran_provider.dart';

class JenisIuranTab extends StatefulWidget {
  const JenisIuranTab({super.key});

  @override
  State<JenisIuranTab> createState() => _JenisIuranTabState();
}

class _JenisIuranTabState extends State<JenisIuranTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JenisIuranProvider>().fetchAllJenisIuran();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JenisIuranProvider>(
      builder: (context, provider, child) {
        final jenisIuranList = provider.jenisIuranList;
        final isLoading = provider.isLoading;

        // Filter list based on search
        final filteredList = _searchQuery.isEmpty
            ? jenisIuranList
            : jenisIuranList.where((item) {
                return item.namaIuran
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

        return Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE8EAF2),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari jenis iuran...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF6B7280),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                      ),
                    )
                  : filteredList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchAllJenisIuran(),
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              // Jenis Iuran Bulanan Section
                              if (filteredList.any((item) => item.kategoriIuran == 'bulanan')) ...[
                                _buildSectionHeader('Jenis Iuran Bulanan',
                                  filteredList.where((item) => item.kategoriIuran == 'bulanan').length),
                                const SizedBox(height: 16),
                                ...filteredList
                                    .where((item) => item.kategoriIuran == 'bulanan')
                                    .map((item) => _buildIuranCard(item))
                                    .toList(),
                                const SizedBox(height: 24),
                              ],

                              // Jenis Iuran Khusus Section
                              if (filteredList.any((item) => item.kategoriIuran == 'khusus')) ...[
                                _buildSectionHeader('Jenis Iuran Khusus',
                                  filteredList.where((item) => item.kategoriIuran == 'khusus').length),
                                const SizedBox(height: 16),
                                ...filteredList
                                    .where((item) => item.kategoriIuran == 'khusus')
                                    .map((item) => _buildIuranCard(item))
                                    .toList(),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIuranCard(dynamic item) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8EAF2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.namaIuran.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaIuran,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.kategoriIuran == 'bulanan'
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.kategoriIuran == 'bulanan' ? 'Bulanan' : 'Khusus',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.kategoriIuran == 'bulanan'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Nominal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(item.jumlahIuran),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 64,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada jenis iuran',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba cari dengan kata kunci lain\natau tambah jenis iuran baru',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

