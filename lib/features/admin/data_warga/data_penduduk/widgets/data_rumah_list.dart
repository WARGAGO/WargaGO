import 'package:flutter/material.dart';
import '../widgets/rumah_card_item.dart';

/// List widget untuk menampilkan daftar data rumah
///
/// Principles:
/// - Stateless karena tidak ada state internal
/// - Data dummy untuk development (TODO: integrate with API)
/// - Menggunakan reusable RumahCardItem
class DataRumahList extends StatelessWidget {
  const DataRumahList({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real data from API/Database/Controller
    final rumahList = _getDummyData();

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
        itemCount: rumahList.length,
        itemBuilder: (context, index) {
          final rumah = rumahList[index];
          return RumahCardItem(
            alamat: rumah['alamat'] as String,
            status: rumah['status'] as String,
            index: index,
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyData() {
    // Changed from List.generate to single entry to avoid duplicate display
    return [
      {
        'alamat': 'Jl. Merbabu',
        'status': 'Tersedia',
      },
    ];
  }
}

