import 'package:flutter/material.dart';

class LaporanKeuanganPage extends StatelessWidget {
  const LaporanKeuanganPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Laporan Bulan November 2025',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _row('Total Pemasukan Iuran', 'Rp 12.300.000'),
                  _row('Pengeluaran Kebersihan', 'Rp 4.500.000'),
                  _row('Pengeluaran Keamanan', 'Rp 3.200.000'),
                  const Divider(),
                  _row(
                    'Saldo Akhir Bulan',
                    'Rp 28.450.000',
                    bold: true,
                    warna: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print),
            label: const Text('Cetak Laporan PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String nilai, {bool bold = false, Color? warna}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            nilai,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: warna,
            ),
          ),
        ],
      ),
    );
  }
}
