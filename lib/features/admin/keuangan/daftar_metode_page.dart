import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'tambah_metode_pembayaran_sheet.dart';
import 'detail_metode_page.dart';
import 'edit_metode_page.dart';

class DaftarMetodePage extends StatefulWidget {
  const DaftarMetodePage({super.key});

  @override
  State<DaftarMetodePage> createState() => _DaftarMetodePageState();
}

class _DaftarMetodePageState extends State<DaftarMetodePage> {
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  int? _expandedIndex;

  // Mock data untuk metode pembayaran
  final List<Map<String, dynamic>> _mockMetode = [
    {
      'id': 1,
      'name': 'QRIS Resmi RT 08',
      'tipe': 'QRIS',
      'pemilik': 'RW 08 Karangploso',
      'catatan': 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
      'thumbnail': 'assets/icons/icon.png',
    },
    {
      'id': 2,
      'name': 'QRIS Resmi RT 08',
      'tipe': 'QRIS',
      'pemilik': 'RW 08 Karangploso',
      'catatan': 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
      'thumbnail': 'assets/icons/icon.png',
    },
    {
      'id': 3,
      'name': 'QRIS Resmi RT 08',
      'tipe': 'QRIS',
      'pemilik': 'RW 08 Karangploso',
      'catatan': 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
      'thumbnail': 'assets/icons/icon.png',
    },
    {
      'id': 4,
      'name': 'QRIS Resmi RT 08',
      'tipe': 'QRIS',
      'pemilik': 'RW 08 Karangploso',
      'catatan': 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
      'thumbnail': 'assets/icons/icon.png',
    },
    {
      'id': 5,
      'name': 'QRIS Resmi RT 08',
      'tipe': 'QRIS',
      'pemilik': 'RW 08 Karangploso',
      'catatan': 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
      'thumbnail': 'assets/icons/icon.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredMetode {
    return _mockMetode.where((metode) {
      final matchesSearch = _searchQuery.isEmpty ||
          metode['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          metode['tipe'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          metode['pemilik'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2988EA),
      body: Column(
        children: [
          _buildAppBar(),
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  _buildSearchAndFilter(),
                  Expanded(
                    child: _buildMetodeList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Daftar Metode',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 35),
      decoration: const BoxDecoration(
        color: Color(0xFF2988EA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelola Metode Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat dan kelola semua metode pembayaran yang tersedia untuk transaksi keuangan.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details Jenis luran',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Laporan',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF9CA3AF),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF6B7280),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetodeList() {
    final filteredData = _filteredMetode;

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final metode = filteredData[index];
        final isExpanded = _expandedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMetodeItem(metode, index, isExpanded),
        );
      },
    );
  }

  Widget _buildMetodeItem(Map<String, dynamic> metode, int index, bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                metode['thumbnail'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFDDEAFF),
                    child: const Icon(
                      Icons.qr_code,
                      color: Color(0xFF2988EA),
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          title: Text(
            metode['name'],
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Tipe: ',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2988EA).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      metode['tipe'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2988EA),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'A/N: ${metode['pemilik']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xFF6B7280),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            _buildDetailRow('Nama Channel', metode['name']),
            const SizedBox(height: 12),
            _buildDetailRow('Tipe Channel', metode['tipe']),
            const SizedBox(height: 12),
            _buildDetailRow('Nama Pemilik', metode['pemilik']),
            const SizedBox(height: 12),
            _buildDetailRow('Catatan', metode['catatan'], isMultiline: true),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Details Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailMetodePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2988EA),
                    side: const BorderSide(color: Color(0xFF2988EA)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Edit Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditMetodePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteDialog(metode);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMultiline = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
              height: isMultiline ? 1.5 : 1.2,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(Map<String, dynamic> metode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning,
                color: Colors.red,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus metode "${metode['name']}"?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Metode "${metode['name']}" berhasil dihapus'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2988EA),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
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
}
