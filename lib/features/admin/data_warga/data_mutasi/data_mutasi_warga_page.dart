import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Data Mutasi imports
import 'detail_data_mutasi_page.dart';
import 'tambah_data_mutasi_page.dart';
import 'models/mutasi_model.dart';
import 'repositories/mutasi_repository.dart';

class DataMutasiWargaPage extends StatefulWidget {
  const DataMutasiWargaPage({super.key});

  @override
  State<DataMutasiWargaPage> createState() => _DataMutasiWargaPageState();
}

class _DataMutasiWargaPageState extends State<DataMutasiWargaPage> {
  final MutasiRepository _repository = MutasiRepository();
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'Mutasi Masuk', 'Mutasi Keluar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER dengan Gradient Modern
            Container(
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
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: 0,
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
                      Icons.swap_horiz_rounded,
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
                          "Data Mutasi",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Riwayat perpindahan warga",
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
            ),

            // FILTER SECTION
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(4),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // LIST SECTION
            Expanded(
              child: _buildMutasiList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDataMutasiPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2F80ED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Mutasi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMutasiList() {
    return StreamBuilder<List<MutasiModel>>(
      stream: _repository.getAllMutasi(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // No data
        final allMutasi = snapshot.data ?? [];

        // Filter data berdasarkan pilihan
        List<MutasiModel> filteredData;
        if (_selectedFilter == 'Semua') {
          filteredData = allMutasi;
        } else if (_selectedFilter == 'Mutasi Masuk') {
          filteredData = allMutasi.where((item) => item.jenisMutasi == 'Mutasi Masuk').toList();
        } else if (_selectedFilter == 'Mutasi Keluar') {
          // Mutasi Keluar mencakup "Keluar Perumahan" dan "Pindah Rumah"
          filteredData = allMutasi.where((item) =>
            item.jenisMutasi == 'Keluar Perumahan' ||
            item.jenisMutasi == 'Pindah Rumah'
          ).toList();
        } else {
          filteredData = allMutasi;
        }

        if (filteredData.isEmpty) {
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
                  'Tidak ada data mutasi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'Semua'
                      ? 'Belum ada data mutasi'
                      : 'Tidak ada data $_selectedFilter',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final mutasi = filteredData[index];
            return _buildMutasiCard(mutasi);
          },
        );
      },
    );
  }

  Widget _buildMutasiCard(MutasiModel mutasi) {
    final isMasuk = mutasi.jenisMutasi == 'Mutasi Masuk';
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailDataMutasiPage(mutasiData: mutasi),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMasuk
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMasuk ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 14,
                            color: isMasuk ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isMasuk ? 'Mutasi Masuk' : 'Mutasi Keluar',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isMasuk ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(mutasi.tanggalMutasi),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Nama
                Text(
                  mutasi.nama,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                // NIK
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      mutasi.nik,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Alamat Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildAlamatRow(
                        icon: Icons.location_on_outlined,
                        label: 'Dari',
                        value: mutasi.alamatAsal,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_downward,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAlamatRow(
                        icon: Icons.location_on,
                        label: 'Ke',
                        value: mutasi.alamatTujuan,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Alasan
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Alasan: ${mutasi.alasanMutasi}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlamatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,

                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

