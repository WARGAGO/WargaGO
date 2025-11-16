import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/app_bottom_navigation.dart';
import 'tambah_data_warga_page.dart';
import 'tambah_data_rumah_page.dart';
import 'widgets/custom_data_penduduk_tab_bar.dart';
import 'widgets/custom_gradient_fab.dart';
import 'widgets/data_warga_list.dart';
import 'widgets/keluarga_list.dart';
import 'widgets/data_rumah_list.dart';

/// Data Penduduk Page - Main page for managing resident data
///
/// Clean Code Principles Applied:
/// - Single Responsibility: Hanya mengatur layout dan navigasi tab
/// - Widget Reusability: Semua komponen dipecah ke widget terpisah
/// - < 110 baris kode (Clean!)
/// - No business logic: Hanya UI dan interaksi user
class DataWargaPage extends StatefulWidget {
  const DataWargaPage({super.key});

  @override
  State<DataWargaPage> createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          CustomDataPendudukTabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DataWargaList(),
                KeluargaList(),
                DataRumahList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Data Penduduk',
        style: GoogleFonts.poppins(
          color: const Color(0xFF1F2937),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    // Hide FAB on Keluarga tab (index 1)
    if (_tabController.index == 1) return null;

    return CustomGradientFAB(
      onPressed: () => _handleFABPressed(),
    );
  }

  void _handleFABPressed() {
    final isWargaTab = _tabController.index == 0;
    final isRumahTab = _tabController.index == 2;

    if (isWargaTab) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TambahDataWargaPage()),
      );
    } else if (isRumahTab) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TambahDataRumahPage()),
      );
    }
  }
}

