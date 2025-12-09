// ============================================================================
// KELOLA IURAN PAGE - Tab-based Dashboard (Like Kelola Pemasukan)
// ============================================================================
// Redesigned with tab layout for better organization
// Tabs: Master Jenis | Buat Tagihan | Kelola Tagihan
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/providers/jenis_iuran_provider.dart';
import 'master_jenis_iuran_page.dart';
import 'buat_tagihan_page.dart';
import 'kelola_tagihan_page.dart';

class KelolaIuranPage extends StatefulWidget {
  const KelolaIuranPage({super.key});

  @override
  State<KelolaIuranPage> createState() => _KelolaIuranPageState();
}

class _KelolaIuranPageState extends State<KelolaIuranPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  int _totalTagihan = 0;
  int _tagihanBelumBayar = 0;
  int _tagihanLunas = 0;
  double _totalTerkumpul = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadTagihanStats();
    });

    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging && mounted) {
        setState(() {}); // Refresh when tab changes
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<JenisIuranProvider>().fetchAllJenisIuran();
  }

  Future<void> _loadTagihanStats() async {
    setState(() => _loadingStats = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final tagihanSnapshot = await firestore
          .collection('tagihan')
          .where('isActive', isEqualTo: true)
          .get();

      int total = tagihanSnapshot.docs.length;
      int belumBayar = 0;
      int lunas = 0;
      double terkumpulBulanIni = 0;

      for (var doc in tagihanSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;

        if (status == 'Belum Dibayar' || status == 'Terlambat') {
          belumBayar++;
        } else if (status == 'Lunas') {
          lunas++;
          final tanggalBayar = (data['tanggalBayar'] as Timestamp?)?.toDate();
          if (tanggalBayar != null && tanggalBayar.isAfter(startOfMonth)) {
            final nominal = (data['nominal'] as num?)?.toDouble() ?? 0;
            terkumpulBulanIni += nominal;
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalTagihan = total;
          _tagihanBelumBayar = belumBayar;
          _tagihanLunas = lunas;
          _totalTerkumpul = terkumpulBulanIni;
          _loadingStats = false;
        });

        debugPrint('📊 Stats Loaded:');
        debugPrint('   Total: $total');
        debugPrint('   Belum Bayar: $belumBayar');
        debugPrint('   Lunas: $lunas');
      }
    } catch (e) {
      debugPrint('❌ Error loading tagihan stats: $e');
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return loading indicator if tab controller not ready
    if (_tabController == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'Kelola Iuran',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2988EA),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF2988EA),
            child: TabBar(
              controller: _tabController!,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Master Jenis'),
                Tab(text: 'Buat Tagihan'),
                Tab(text: 'Kelola Tagihan'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Card Section (Always visible at top)
          _buildStatsSection(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController!,
              children: const [
                MasterJenisIuranPage(),
                BuatTagihanPage(),
                KelolaTagihanPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Terkumpul Bulan Ini Card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: _buildTerkumpulCard(),
          ),

          // Quick Stats Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildQuickStatsGrid(),
          ),

          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildTerkumpulCard() {
    if (_loadingStats) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF34D399)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Terkumpul Bulan Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatCurrency(_totalTerkumpul),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_tagihanLunas lunas dari $_totalTagihan tagihan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return Consumer<JenisIuranProvider>(
      builder: (context, jenisIuranProvider, _) {
        return Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                'Total Tagihan',
                _totalTagihan.toString(),
                Icons.receipt_long_outlined,
                const Color(0xFF2988EA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                'Sudah Bayar',
                _tagihanLunas.toString(),
                Icons.check_circle_outline,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStatCard(
                'Belum Bayar',
                _tagihanBelumBayar.toString(),
                Icons.pending_actions_outlined,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}

