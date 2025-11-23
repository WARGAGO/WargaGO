// ============================================================================
// KELOLA PEMASUKAN - REUSABLE WIDGETS
// ============================================================================
// Fokus UI: header, stats card, tab container
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/keuangan_constants.dart';

class KelolaPemasukanHeader extends StatelessWidget {
  const KelolaPemasukanHeader({
    super.key,
    required this.onBack,
    required this.onFilter,
    this.onExport,
  });

  final VoidCallback onBack;
  final VoidCallback onFilter;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HeaderIcon(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
            const Spacer(),
            if (onExport != null) ...[
              _HeaderIcon(
                icon: Icons.file_download_outlined,
                onTap: onExport!,
              ),
              const SizedBox(width: 12),
            ],
            _HeaderIcon(
              icon: Icons.filter_list_rounded,
              onTap: onFilter,
            ),
          ],
        ),
        const SizedBox(height: KeuanganSpacing.xxl),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: KeuanganSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Pemasukan',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau dan kelola dengan mudah',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class KelolaPemasukanStatsCard extends StatelessWidget {
  const KelolaPemasukanStatsCard({
    super.key,
    required this.totalPemasukan,
    required this.totalTransaksi,
  });

  final String totalPemasukan;
  final String totalTransaksi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.trending_up_rounded,
              label: 'Total Pemasukan',
              value: totalPemasukan,
            ),
          ),
          Container(
            width: 1.5,
            height: 40,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.receipt_long_rounded,
              label: 'Transaksi',
              value: totalTransaksi,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: KeuanganSpacing.sm),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class KelolaPemasukanTabbedContent extends StatelessWidget {
  const KelolaPemasukanTabbedContent({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.views,
    required this.onTabChange,
  });

  final TabController tabController;
  final List<PemasukanTabItem> tabs;
  final List<Widget> views;
  final VoidCallback onTabChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: TabBar(
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF6B7280),
            labelStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            onTap: (_) => onTabChange(),
            tabs: tabs
                .map(
                  (t) => Tab(
                    height: 42,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            t.label,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: views,
          ),
        ),
      ],
    );
  }
}

class PemasukanTabItem {
  const PemasukanTabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
