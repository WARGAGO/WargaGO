import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../edit_iuran_page.dart';

class JenisIuranTab extends StatefulWidget {
  const JenisIuranTab({super.key});

  @override
  State<JenisIuranTab> createState() => _JenisIuranTabState();
}

class _JenisIuranTabState extends State<JenisIuranTab> {
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  int? _expandedIndex;

  final List<Map<String, dynamic>> _jenisIuranList = [
    {
      'id': 1,
      'name': 'Joki by firman',
      'subtitle': 'Pendapatan Lainnya',
      'tanggal': '15 Okt 2025 14:23',
      'nik': 'Rp 11,00',
      'nominal': 'Rp 11,00',
      'kategori': 'Dana Bantuan Pemerintah',
      'verifikator': 'Admin Jawara',
    },
    {
      'id': 2,
      'name': 'Joki by firman',
      'subtitle': 'Pendapatan Lainnya',
      'tanggal': '14 Okt 2025 10:15',
      'nik': 'Rp 50.000',
      'nominal': 'Rp 50.000',
      'kategori': 'Iuran Warga',
      'verifikator': 'Admin Jawara',
    },
    {
      'id': 3,
      'name': 'Joki by firman',
      'subtitle': 'Pendapatan Lainnya',
      'tanggal': '13 Okt 2025 16:45',
      'nik': 'Rp 25.000',
      'nominal': 'Rp 25.000',
      'kategori': 'Dana Kegiatan',
      'verifikator': 'Admin Jawara',
    },
    {
      'id': 4,
      'name': 'Joki by firman',
      'subtitle': 'Pendapatan Lainnya',
      'tanggal': '12 Okt 2025 09:30',
      'nik': 'Rp 100.000',
      'nominal': 'Rp 100.000',
      'kategori': 'Donasi',
      'verifikator': 'Admin Jawara',
    },
    {
      'id': 5,
      'name': 'Joki by firman',
      'subtitle': 'Pendapatan Lainnya',
      'tanggal': '11 Okt 2025 13:20',
      'nik': 'Rp 75.000',
      'nominal': 'Rp 75.000',
      'kategori': 'Iuran Bulanan',
      'verifikator': 'Admin Jawara',
    },
  ];

  List<Map<String, dynamic>> get _filteredList {
    if (_searchQuery.isEmpty) {
      return _jenisIuranList;
    }
    return _jenisIuranList.where((item) {
      return item['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item['subtitle']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar & Date Filter
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Jenis Iuran',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.list_alt_rounded,
                          size: 12,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${_filteredList.length}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showDatePicker(),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2988EA).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: _filteredList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _filteredList.length,
                  itemBuilder: (context, index) {
                    final item = _filteredList[index];
                    final bool isExpanded = _expandedIndex == index;
                    return _buildIuranCard(item, index, isExpanded);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIuranCard(Map<String, dynamic> item, int index, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFF3B82F6).withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
              : const Color(0xFFE8EAF2),
          width: isExpanded ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 20 : 10,
            offset: Offset(0, isExpanded ? 8 : 2),
            spreadRadius: isExpanded ? -2 : 0,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Avatar dengan gradient
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2563EB),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        item['name'].toString().substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                      const Color(0xFF3B82F6).withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  item['subtitle'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
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
                        item['nominal'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3B82F6),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['tanggal'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpanded
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF6B7280),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.03),
                    const Color(0xFF3B82F6).withValues(alpha: 0.01),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE8EAF2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildModernDetailRow(
                            'Tanggal',
                            item['tanggal'],
                            Icons.calendar_today_rounded,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(height: 14),
                          _buildModernDetailRow(
                            'NIK',
                            item['nik'],
                            Icons.badge_rounded,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(height: 14),
                          _buildModernDetailRow(
                            'Kategori',
                            item['kategori'],
                            Icons.category_rounded,
                            const Color(0xFFF59E0B),
                          ),
                          const SizedBox(height: 14),
                          _buildModernDetailRow(
                            'Verifikator',
                            item['verifikator'],
                            Icons.verified_rounded,
                            const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2988EA).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditIuranPage(iuranData: item),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(
                            'Edit Iuran',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2988EA),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 48),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
            'Coba cari dengan kata kunci lain',
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
              primary: Color(0xFF3B82F6),
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

