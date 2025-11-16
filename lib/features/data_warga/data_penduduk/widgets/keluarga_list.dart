import 'package:flutter/material.dart';
import '../widgets/keluarga_expandable_card.dart';

/// List widget untuk menampilkan daftar data keluarga
///
/// Principles:
/// - Stateless karena tidak ada state internal
/// - Data dummy untuk development (TODO: integrate with API)
/// - Menggunakan reusable KeluargaExpandableCard
class KeluargaList extends StatelessWidget {
  const KeluargaList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from API/Database/Controller
    final keluargaList = _getDummyData();

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
        itemCount: keluargaList.length,
        itemBuilder: (context, index) {
          final keluarga = keluargaList[index];
          return KeluargaExpandableCard(
            namaKepalaKeluarga: keluarga['namaKepalaKeluarga'] as String,
            alamat: keluarga['alamat'] as String,
            status: keluarga['status'] as String,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyData() {
    return List.generate(
      5,
      (index) => {
        'namaKepalaKeluarga': 'Rendha Putra Rahmadya',
        'alamat': 'Malang',
        'status': 'Aktif',
      },
    );
  }
}

