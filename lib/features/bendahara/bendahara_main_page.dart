import 'package:flutter/material.dart';
import 'package:wargago/features/bendahara/dashboard/bendahara_dashboard_page.dart';
import 'package:wargago/features/bendahara/keuangan/iuran_warga_page.dart';
import 'package:wargago/features/bendahara/keuangan/riwayat_transaksi_page.dart';
import 'package:wargago/features/bendahara/keuangan/laporan_keuangan_page.dart';
import 'package:wargago/features/bendahara/profil/bendahara_profile_page.dart';
import 'package:wargago/features/bendahara/widgets/bendahara_bottom_navbar.dart';

/// Main Page untuk Bendahara dengan Bottom Navigation
/// Menampung semua halaman utama bendahara dan navigasi antar halaman
class BendaharaMainPage extends StatefulWidget {
  const BendaharaMainPage({super.key});

  @override
  State<BendaharaMainPage> createState() => _BendaharaMainPageState();
}

class _BendaharaMainPageState extends State<BendaharaMainPage> {
  int _currentIndex = 0;

  // Fungsi untuk berpindah tab
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Daftar halaman sesuai urutan bottom navbar
    final List<Widget> _pages = [
      BendaharaDashboardPage(onNavigateToTab: _changeTab), // Index 0: Dashboard
      const IuranWargaPage(), // Index 1: Iuran Warga
      const RiwayatTransaksiPage(), // Index 2: Riwayat Transaksi
      const LaporanKeuanganPage(), // Index 3: Laporan Keuangan
      const BendaharaProfilePage(), // Index 4: Profil
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BendaharaBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
