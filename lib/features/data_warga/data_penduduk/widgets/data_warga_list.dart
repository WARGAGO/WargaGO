import 'package:flutter/material.dart';
import '../widgets/warga_expandable_card.dart';

/// List widget untuk menampilkan daftar data warga
///
/// Principles:
/// - Stateless karena tidak ada state internal
/// - Data dummy untuk development (TODO: integrate with API)
/// - Menggunakan reusable WargaExpandableCard
class DataWargaList extends StatelessWidget {
  const DataWargaList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from API/Database/Controller
    final wargaList = _getDummyData();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Colors.white],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: wargaList.length,
        itemBuilder: (context, index) {
          final warga = wargaList[index];
          return WargaExpandableCard(
            nama: warga['nama'] as String,
            nik: warga['nik'] as String,
            jenisKelamin: warga['jenisKelamin'] as String,
            namaKeluarga: warga['namaKeluarga'] as String,
            isAktif: warga['isAktif'] as bool,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyData() {
    return List.generate(
      5,
      (index) => {
        'nama': 'Rendha Putra Rahmadya',
        'nik': '3505111512040002',
        'jenisKelamin': 'Laki-laki',
        'namaKeluarga': 'Rendha Putra R.',
        'isAktif': true,
      },
    );
  }
}

