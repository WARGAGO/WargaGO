import 'package:flutter/material.dart';

class IuranWargaPage extends StatelessWidget {
  const IuranWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iuran Warga'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _wargaCard('A1', 'Budi Santoso', 'Blok A1 - Sudah Bayar', true),
          _wargaCard('B3', 'Siti Aminah', 'Blok B3 - Belum Bayar', false),
          _wargaCard('C5', 'Ahmad Yani', 'Blok C5 - Sudah Bayar', true),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Catat Pembayaran Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wargaCard(String kode, String nama, String info, bool sudahBayar) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sudahBayar ? Colors.green : Colors.orange,
          child: Text(kode, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(info),
        trailing: Text(
          'Rp 150.000',
          style: TextStyle(
            color: sudahBayar ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
