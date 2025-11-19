import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jawara/core/providers/jenis_iuran_provider.dart';
import 'package:jawara/core/providers/pemasukan_lain_provider.dart';
import 'tabs/jenis_iuran_tab.dart';
import 'tabs/lainnya_tab.dart';
import 'pemasukan_non_iuran_page.dart';
import 'forms/form_jenis_iuran_page.dart';
import 'widgets/kelola_pemasukan_widgets.dart';
import '../widgets/keuangan_constants.dart';

class KelolaPemasukanPage extends StatefulWidget {
  const KelolaPemasukanPage({super.key});

  @override
  State<KelolaPemasukanPage> createState() => _KelolaPemasukanPageState();
}

class _KelolaPemasukanPageState extends State<KelolaPemasukanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data from BOTH providers on init for complete stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JenisIuranProvider>().fetchAllJenisIuran();
        context.read<PemasukanLainProvider>().loadPemasukanLain();
      }
    });

    // Add listener to refresh data when tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Rebuild to update stats card
        setState(() {});
      }

      if (_tabController.index == 0 && mounted) {
        // Refresh jenis iuran data when tab is selected
        context.read<JenisIuranProvider>().fetchAllJenisIuran();
      } else if (_tabController.index == 1 && mounted) {
        // Refresh pemasukan lain data when tab is selected
        context.read<PemasukanLainProvider>().loadPemasukanLain();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDynamicStatsCard() {
    // Combine data from BOTH providers to show TOTAL of everything
    return Consumer2<JenisIuranProvider, PemasukanLainProvider>(
      builder: (context, jenisIuranProvider, pemasukanLainProvider, child) {
        final jenisIuranList = jenisIuranProvider.jenisIuranList;
        final pemasukanList = pemasukanLainProvider.pemasukanList;

        // Calculate total from Jenis Iuran
        final totalJenisIuran = jenisIuranList.fold<double>(
          0,
          (sum, item) => sum + item.jumlahIuran,
        );

        // Calculate total from Pemasukan Lain
        final totalPemasukanLain = pemasukanList.fold<double>(
          0,
          (sum, item) => sum + item.nominal,
        );

        // TOTAL KESELURUHAN = Jenis Iuran + Pemasukan Lain
        final totalKeseluruhan = totalJenisIuran + totalPemasukanLain;
        final totalItems = jenisIuranList.length + pemasukanList.length;

        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return KelolaPemasukanStatsCard(
          totalPemasukan: formatter.format(totalKeseluruhan),
          totalTransaksi: '$totalItems Items',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B82F6),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KelolaPemasukanHeader(
                      onBack: () => Navigator.pop(context),
                      onFilter: () {},
                    ),
                    const SizedBox(height: KeuanganSpacing.xxl),
                    _buildDynamicStatsCard(),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: KelolaPemasukanTabbedContent(
                tabController: _tabController,
                onTabChange: () => setState(() {}),
                tabs: const [
                  PemasukanTabItem(icon: Icons.list_alt_rounded, label: 'Iuran'),
                  PemasukanTabItem(icon: Icons.more_horiz_rounded, label: 'Lainnya'),
                ],
                views: [
                  JenisIuranTab(),
                  LainnyaTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: const Color(0xFF3B82F6),
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: Text(
            'Tambah',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog() async {
    final currentIndex = _tabController.index;

    // Jika tab Jenis Iuran (index 0), langsung buka halaman Form Jenis Iuran
    if (currentIndex == 0) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FormJenisIuranPage(),
        ),
      );

      // Refresh data setelah kembali dari form
      if (result == true && mounted) {
        // Data sudah otomatis ter-refresh dari provider saat addJenisIuran dipanggil
        // Tapi kita panggil lagi untuk memastikan
        context.read<JenisIuranProvider>().fetchAllJenisIuran();
      }
      return;
    }

    // Jika tab Lainnya (index 1), langsung buka halaman Pemasukan Non Iuran
    if (currentIndex == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PemasukanNonIuranPage(),
        ),
      );

      // Refresh data setelah kembali dari form
      if (result == true && mounted) {
        // Data akan otomatis ter-refresh karena stream di provider
        // Tapi kita panggil lagi untuk memastikan
        context.read<PemasukanLainProvider>().loadPemasukanLain();
      }
      return;
    }
  }
}
