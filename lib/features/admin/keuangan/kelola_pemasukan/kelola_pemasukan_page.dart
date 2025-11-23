import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/providers/jenis_iuran_provider.dart';
import 'package:jawara/core/providers/pemasukan_lain_provider.dart';
import 'package:jawara/core/widgets/export_dialog.dart';
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
  int _rebuildKey = 0; // Add key to force rebuild

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data from BOTH providers on init for complete stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final jenisIuranProvider = context.read<JenisIuranProvider>();
        final pemasukanLainProvider = context.read<PemasukanLainProvider>();

        // Add listeners to force rebuild when data changes
        jenisIuranProvider.addListener(_onDataChanged);
        pemasukanLainProvider.addListener(_onDataChanged);

        // Initial data load
        jenisIuranProvider.fetchAllJenisIuran();
        pemasukanLainProvider.loadPemasukanLain();
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

  void _onDataChanged() {
    if (mounted) {
      setState(() {
        _rebuildKey++; // Increment key to force rebuild
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners before dispose
    try {
      context.read<JenisIuranProvider>().removeListener(_onDataChanged);
      context.read<PemasukanLainProvider>().removeListener(_onDataChanged);
    } catch (e) {
      // Ignore if already disposed
    }
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDynamicStatsCard() {
    // Combine data from BOTH providers to show TOTAL of everything
    return Consumer2<JenisIuranProvider, PemasukanLainProvider>(
      key: ValueKey('stats_card_$_rebuildKey'), // Force rebuild with key
      builder: (context, jenisIuranProvider, pemasukanLainProvider, child) {
        // Use ALL data lists (unfiltered) to get accurate totals
        final jenisIuranList = jenisIuranProvider.allJenisIuranList;
        final pemasukanList = pemasukanLainProvider.allPemasukanList; // ✅ Changed to allPemasukanList

        print('🔄 Stats Card Rebuild: Jenis Iuran=${jenisIuranList.length}, Pemasukan Lain=${pemasukanList.length}');

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

        print('💰 Total Calculation: Jenis Iuran=Rp ${totalJenisIuran.toStringAsFixed(0)}, Pemasukan Lain=Rp ${totalPemasukanLain.toStringAsFixed(0)}, TOTAL=Rp ${totalKeseluruhan.toStringAsFixed(0)}');

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
                      onExport: _showExportDialog,
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

  void _showExportDialog() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get FRESH data directly from Firestore to ensure accuracy
      // Get all active jenis_iuran
      final jenisIuranSnapshot = await FirebaseFirestore.instance
          .collection('jenis_iuran')
          .where('isActive', isEqualTo: true)
          .get();

      // Get all active pemasukan_lain
      final pemasukanLainSnapshot = await FirebaseFirestore.instance
          .collection('pemasukan_lain')
          .where('isActive', isEqualTo: true)
          .get();

      // Convert data to export format
      final exportData = <Map<String, dynamic>>[];

      // Add Jenis Iuran data
      for (var doc in jenisIuranSnapshot.docs) {
        final data = doc.data();
        exportData.add({
          'tanggal': data['createdAt'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format((data['createdAt'] as Timestamp).toDate())
              : '-',
          'name': data['nama_iuran'] ?? '-',
          'category': 'Iuran',
          'nominal': 'Rp ${NumberFormat('#,###').format((data['jumlah_iuran'] as num?)?.toDouble() ?? 0)}',
          'penerima': '-',
          'deskripsi': 'Jenis Iuran: ${data['nama_iuran'] ?? '-'}',
          'status': 'Aktif',
        });
      }

      // Add Pemasukan Lain data
      for (var doc in pemasukanLainSnapshot.docs) {
        final data = doc.data();
        exportData.add({
          'tanggal': data['tanggal'] != null
              ? DateFormat('dd/MM/yyyy HH:mm').format((data['tanggal'] as Timestamp).toDate())
              : '-',
          'name': data['name'] ?? '-',
          'category': data['category'] ?? '-',
          'nominal': 'Rp ${NumberFormat('#,###').format((data['nominal'] as num?)?.toDouble() ?? 0)}',
          'penerima': data['createdBy'] ?? '-',
          'deskripsi': data['deskripsi'] ?? '-',
          'status': data['status'] ?? 'Aktif',
        });
      }

      // Close loading
      if (mounted) Navigator.pop(context);

      if (exportData.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak ada data untuk di-export', style: GoogleFonts.poppins()),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show export dialog
      if (mounted) {
        ExportDialog.show(
          context: context,
          data: exportData,
          title: 'Laporan_Pemasukan',
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
