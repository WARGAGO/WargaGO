import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PenanggungJawabDetailPage extends StatefulWidget {
  const PenanggungJawabDetailPage({super.key});

  @override
  State<PenanggungJawabDetailPage> createState() =>
      _PenanggungJawabDetailPageState();
}

class _PenanggungJawabDetailPageState extends State<PenanggungJawabDetailPage> {
  String searchQuery = '';

  final List<Map<String, dynamic>> penanggungJawab = [
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '12',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
    {
      'name': 'Pak Rusdi',
      'description': 'Penanggung jawab 17 Agustus',
      'badge': '10',
    },
  ];

  List<Map<String, dynamic>> get filteredPenanggungJawab {
    if (searchQuery.isEmpty) return penanggungJawab;
    return penanggungJawab.where((item) {
      return item['name']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item['description']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Garis kecil di atas
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 16, bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header dengan judul, kalender, dan close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Penanggung Jawab',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      icon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Daftar penanggung jawab
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPenanggungJawab.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredPenanggungJawab[index];
                    return _buildPenanggungJawabItem(
                      item['name']!,
                      item['description']!,
                      item['badge']!,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPenanggungJawabItem(
    String name,
    String description,
    String badge,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFF2F80ED), size: 24),
          ),
          const SizedBox(width: 12),
          // Name and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
