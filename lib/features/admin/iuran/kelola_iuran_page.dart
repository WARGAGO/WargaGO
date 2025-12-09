// filepath: lib/features/admin/iuran/kelola_iuran_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/models/iuran_model.dart';
import '../../../core/services/iuran_service.dart';
import 'tambah_iuran_page.dart';
import 'detail_iuran_page.dart';

class KelolaIuranPage extends StatefulWidget {
  const KelolaIuranPage({super.key});

  @override
  State<KelolaIuranPage> createState() => _KelolaIuranPageState();
}

class _KelolaIuranPageState extends State<KelolaIuranPage> {
  final IuranService _iuranService = IuranService();
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Aktif', 'Nonaktif'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Filter Tabs
            _buildFilterTabs(),

            // Search Bar
            _buildSearchBar(),

            // Iuran List
            Expanded(
              child: _buildIuranList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F80ED),
            Color(0xFF1E6FD9),
            Color(0xFF0F5FCC),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Iuran",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Manajemen iuran & tagihan warga",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari iuran...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _buildIuranList() {
    return StreamBuilder<List<IuranModel>>(
      stream: _selectedFilter == 'Aktif'
          ? _iuranService.getIuranByStatus('aktif')
          : _selectedFilter == 'Nonaktif'
              ? _iuranService.getIuranByStatus('nonaktif')
              : _iuranService.getAllIuran(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        List<IuranModel> iuranList = snapshot.data!;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          iuranList = iuranList.where((iuran) {
            final judulLower = iuran.judul.toLowerCase();
            final queryLower = _searchQuery.toLowerCase();
            return judulLower.contains(queryLower);
          }).toList();
        }

        if (iuranList.isEmpty) {
          return _buildEmptySearchState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: iuranList.length,
          itemBuilder: (context, index) {
            return _buildIuranCard(iuranList[index]);
          },
        );
      },
    );
  }

  Widget _buildIuranCard(IuranModel iuran) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final isAktif = iuran.status == 'aktif';

    // Category color
    Color categoryColor = const Color(0xFF2F80ED);
    IconData categoryIcon = Icons.account_balance_wallet_rounded;

    switch (iuran.kategori?.toLowerCase()) {
      case 'kebersihan':
        categoryColor = const Color(0xFF10B981);
        categoryIcon = Icons.cleaning_services_rounded;
        break;
      case 'keamanan':
        categoryColor = const Color(0xFFEF4444);
        categoryIcon = Icons.security_rounded;
        break;
      case 'pembangunan':
        categoryColor = const Color(0xFFF59E0B);
        categoryIcon = Icons.construction_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailIuranPage(iuran: iuran),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category & Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcon,
                            size: 16,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            iuran.kategori ?? 'Umum',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAktif
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAktif ? 'Aktif' : 'Nonaktif',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAktif ? const Color(0xFF10B981) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Judul
                Text(
                  iuran.judul,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),

                // Deskripsi
                Text(
                  iuran.deskripsi,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),

                // Info: Nominal, Tipe, Jatuh Tempo
                Row(
                  children: [
                    // Nominal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Nominal',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currencyFormat.format(iuran.nominal),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F80ED),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tipe
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_repeat_rounded,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tipe',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            iuran.tipe[0].toUpperCase() + iuran.tipe.substring(1),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Jatuh Tempo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Jatuh Tempo: ${dateFormat.format(iuran.tanggalJatuhTempo)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF59E0B),
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Iuran',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambah iuran baru dengan tombol + di bawah',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Iuran Tidak Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
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
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TambahIuranPage(),
          ),
        );
      },
      backgroundColor: const Color(0xFF2F80ED),
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Tambah Iuran',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

