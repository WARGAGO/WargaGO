// lib/features/bendahara/keuangan/riwayat_transaksi_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//
class RiwayatTransaksiPage extends StatelessWidget {
  const RiwayatTransaksiPage({super.key});

  String formatRupiah(int nominal) {
    final str = nominal.toString().split('').reversed.join();
    final result = <String>[];
    for (int i = 0; i < str.length; i += 3) {
      result.add(str.substring(i, i + 3 > str.length ? str.length : i + 3));
    }
    return 'Rp ${result.reversed.join('.')}';
  }

  String formatTanggal(String isoDate) {
    final date = DateTime.parse(isoDate);
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  final List<Map<String, dynamic>> data = const [
    {
      'tanggal': '2025-12-10',
      'keterangan': 'Iuran Warga - Budi Santoso',
      'nominal': 150000,
      'tipe': 'masuk',
    },
    {
      'tanggal': '2025-12-05',
      'keterangan': 'Bayar Satpam Bulanan',
      'nominal': 3200000,
      'tipe': 'keluar',
    },
    {
      'tanggal': '2025-12-01',
      'keterangan': 'Iuran Warga - Siti Aminah',
      'nominal': 150000,
      'tipe': 'masuk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F80ED), Color(0xFF1E5BA8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Riwayat Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: data.length,
                    itemBuilder: (ctx, i) {
                      final item = data[i];
                      final masuk = item['tipe'] == 'masuk';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: masuk
                                  ? const Color(0xFF27AE60)
                                  : Colors.red,
                              child: Icon(
                                masuk
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['keterangan'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    formatTanggal(item['tanggal']),
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${masuk ? '+' : '-'} ${formatRupiah(item['nominal'])}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: masuk
                                    ? const Color(0xFF27AE60)
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
