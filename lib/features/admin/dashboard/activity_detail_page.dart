import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ActivityDetailPage extends StatefulWidget {
  const ActivityDetailPage({super.key});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  int selectedIndex = 0;

  final List<DateTime> dates = List.generate(
    10,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  final List<List<Map<String, dynamic>>> activities = [
    [
      {'time': '12.00', 'type': 'Kegiatan Kampung', 'title': 'Kegiatan 17 Agustus 2026', 'color': Colors.green},
      {'time': '10.00', 'type': 'Kegiatan Kelompok', 'title': 'Senam Ibu-Ibu PKK', 'color': Colors.green},
    ],
    [
      {'time': '09.00', 'type': 'Kegiatan Edukasi', 'title': 'Penyuluhan Posyandu', 'color': Colors.red},
    ],
    [
      {'time': '08.30', 'type': 'Kegiatan Sosial', 'title': 'Gotong Royong', 'color': Colors.green},
      {'time': '15.00', 'type': 'Kegiatan Edukasi', 'title': 'Workshop Digital', 'color': Colors.green},
    ],
    [
      {'time': '07.00', 'type': 'Kegiatan Olahraga', 'title': 'Senam Pagi', 'color': Colors.red},
    ],
    [
      {'time': '10.00', 'type': 'Kegiatan Desa', 'title': 'Musyawarah Warga', 'color': Colors.red},
    ],
    [
      {'time': '10.00', 'type': 'Kegiatan Desa', 'title': 'Musyawarah Warga', 'color': Colors.red},
    ],
    // Tambahan untuk index 6-9 (agar tidak RangeError)
    [
      {'time': '14.00', 'type': 'Kegiatan Kebersihan', 'title': 'Kerja Bakti', 'color': Colors.green},
    ],
    [
      {'time': '16.00', 'type': 'Kegiatan Olahraga', 'title': 'Voli RT', 'color': Colors.green},
    ],
    [
      {'time': '09.30', 'type': 'Kegiatan Edukasi', 'title': 'Kelas Komputer', 'color': Colors.red},
    ],
    [
      {'time': '11.00', 'type': 'Kegiatan Sosial', 'title': 'Kunjungan Warga', 'color': Colors.green},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Garis kecil di atas
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Judul dan ikon kalender
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Kegiatan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),

                // Baris tanggal
                SizedBox(
                  height: 70,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final day = DateFormat('EEE', 'en_US').format(date); // Mon, Tue
                      final dateNum = DateFormat('d').format(date);
                      final isSelected = index == selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2F80ED) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dateNum,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                day,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Daftar Kegiatan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Daftar kegiatan berdasarkan tanggal yang dipilih dengan safety check
                if (selectedIndex >= 0 && selectedIndex < activities.length)
                  ...activities[selectedIndex].map((item) => _buildActivityItem(
                        item['time'],
                        item['type'],
                        item['title'],
                        item['color'],
                      ))
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Tidak ada kegiatan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(String time, String type, String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: color, size: 18),
        ],
      ),
    );
  }
}
