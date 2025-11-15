// Clean Architecture - Presentation Layer
// - Fokus ke tampilan & interaksi user saja (tanpa logic bisnis berat)
// - Menggunakan StatefulWidget untuk state management
// - Widget dipecah menjadi komponen kecil yang reusable
// - Responsif dan clean code

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_pengeluaran_page.dart';
import 'widgets/pengeluaran_header.dart';
import 'widgets/pengeluaran_search_bar.dart';
import 'widgets/pengeluaran_card.dart';
import 'widgets/pengeluaran_empty_state.dart';

class KelolaPengeluaranPage extends StatefulWidget {
  const KelolaPengeluaranPage({super.key});

  @override
  State<KelolaPengeluaranPage> createState() => _KelolaPengeluaranPageState();
}

class _KelolaPengeluaranPageState extends State<KelolaPengeluaranPage> {
  // State variables
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  int? _expandedIndex;

  final List<Map<String, dynamic>> _pengeluaranList = [
    {
      'id': 1,
      'name': 'Pembelian Alat Kebersihan',
      'category': 'Operasional',
      'nominal': 'Rp 500.000',
      'date': '20 Oktober 2025',
      'status': 'Terverifikasi',
      'description': 'Pembelian sapu, pel, dan pembersih lantai untuk kebersihan lingkungan',
      'recipient': 'Toko Makmur Jaya',
      'color': const Color(0xFFEB5757),
    },
    {
      'id': 2,
      'name': 'Perbaikan Jalan',
      'category': 'Infrastruktur',
      'nominal': 'Rp 2.500.000',
      'date': '18 Oktober 2025',
      'status': 'Terverifikasi',
      'description': 'Perbaikan jalan utama dan penambalan lubang',
      'recipient': 'CV. Karya Mandiri',
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 3,
      'name': 'Listrik dan Air',
      'category': 'Utilitas',
      'nominal': 'Rp 750.000',
      'date': '15 Oktober 2025',
      'status': 'Menunggu',
      'description': 'Pembayaran tagihan listrik dan air untuk fasilitas umum',
      'recipient': 'PLN & PDAM',
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 4,
      'name': 'Kegiatan 17 Agustus',
      'category': 'Kegiatan',
      'nominal': 'Rp 1.200.000',
      'date': '10 Agustus 2025',
      'status': 'Terverifikasi',
      'description': 'Pembelian hadiah dan konsumsi untuk lomba 17 Agustus',
      'recipient': 'Panitia HUT RI',
      'color': const Color(0xFF8B5CF6),
    },
  ];

  // Filtered list based on search query
  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) {
      return _pengeluaranList;
    }
    return _pengeluaranList.where((item) {
      return item['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['category']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2988EA),
      body: Column(
        children: [
          PengeluaranHeader(
            totalItems: _pengeluaranList.length,
            totalAmount: 'Rp 4.950.000',
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  PengeluaranSearchBar(
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onDateTap: _showDatePicker,
                    filteredCount: _filteredList.length,
                  ),
                  Expanded(
                    child: _filteredList.isEmpty
                        ? const PengeluaranEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              final isExpanded = _expandedIndex == index;
                              return PengeluaranCard(
                                item: item,
                                isExpanded: isExpanded,
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                onDelete: () => _showDeleteConfirmation(item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2988EA).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToTambahPengeluaran,
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: Text(
          'Tambah',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2988EA),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> item) {
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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hapus Data?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item['name']}"? Data yang sudah dihapus tidak dapat dikembalikan.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete logic here - nanti akan dipanggil service
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTambahPengeluaran() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahPengeluaranPage(),
      ),
    );
  }
}

