import 'package:flutter/material.dart';
import 'package:wargago/features/sekertaris/dashboard/sekretaris_dashboard_page.dart';
import 'package:wargago/features/sekertaris/agenda/pages/sekretaris_agenda_page.dart';
import 'package:wargago/features/sekertaris/notulen/pages/sekretaris_notulen_page.dart';
import 'package:wargago/features/sekertaris/widgets/sekretaris_bottom_navbar.dart';

/// Main Page untuk Sekretaris dengan Bottom Navigation
/// Menampung semua halaman sekretaris dan navigasi antar halaman
class SekretarisMainPage extends StatefulWidget {
  const SekretarisMainPage({super.key});

  @override
  State<SekretarisMainPage> createState() => _SekretarisMainPageState();
}

class _SekretarisMainPageState extends State<SekretarisMainPage> {
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const SekretarisDashboardPage(), // Index 0: Dashboard
      const SekretarisAgendaPage(), // Index 1: Agenda
      const SekretarisNotulenPage(), // Index 2: Notulen
      _buildPlaceholderPage('Profil', Icons.person), // Index 3: Profil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SekretarisBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Placeholder page untuk halaman yang belum dibuat
  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2F80ED),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Halaman $title',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sedang dalam pengembangan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
