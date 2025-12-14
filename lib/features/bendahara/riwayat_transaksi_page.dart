import 'package:flutter/material.dart';

class RiwayatTransaksiPage extends StatelessWidget {
  const RiwayatTransaksiPage({super.key});

  String formatRupiah(int nominal) {
    String str = nominal.toString();
    String result = '';
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }

  String formatTanggal(String isoDate) {
    DateTime date = DateTime.parse(isoDate);
    List<String> bulan = [
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
      'tanggal': '2025-11-18',
      'keterangan': 'Iuran Warga - Budi Santoso',
      'nominal': 150000,
      'tipe': 'masuk',
    },
    {
      'tanggal': '2025-11-15',
      'keterangan': 'Bayar Satpam Bulanan',
      'nominal': 3200000,
      'tipe': 'keluar',
    },
    {
      'tanggal': '2025-11-10',
      'keterangan': 'Iuran Warga - Siti Aminah',
      'nominal': 150000,
      'tipe': 'masuk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (ctx, i) {
          var item = data[i];
          bool masuk = item['tipe'] == 'masuk';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: masuk ? Colors.green : Colors.red,
                child: Icon(
                  masuk ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
              title: Text(item['keterangan']),
              subtitle: Text(formatTanggal(item['tanggal'])),
              trailing: Text(
                '${masuk ? '+' : '-'}Rp ${formatRupiah(item['nominal'])}',
                style: TextStyle(
                  color: masuk ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
