// ============================================================================
// KELOLA LAPAK PAGE
// ============================================================================
// Halaman admin untuk mengelola dan memverifikasi pendaftaran seller/lapak
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/pending_seller_model.dart';
import '../../../core/repositories/pending_seller_repository.dart';
import 'pages/detail_seller_page.dart';

class KelolaLapakPage extends StatefulWidget {
  const KelolaLapakPage({super.key});

  @override
  State<KelolaLapakPage> createState() => _KelolaLapakPageState();
}

class _KelolaLapakPageState extends State<KelolaLapakPage>
    with TickerProviderStateMixin {
  final PendingSellerRepository _repository = PendingSellerRepository();
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;

  Map<String, int> _statistics = {
    'pending': 0,
    'approved': 0,
    'rejected': 0,
    'suspended': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Header animation
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Stats animation
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
    );

    _loadStatistics();
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _statsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final stats = await _repository.getStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        body: Column(
          children: [
            // Header
            _buildHeader(),

            // Statistics Cards
            _buildStatisticsCards(),

            // Tab Bar
            _buildTabBar(),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSellerList(SellerVerificationStatus.pending),
                  _buildApprovedSellersList(),
                  _buildSellerList(SellerVerificationStatus.rejected),
                  _buildSellerList(SellerVerificationStatus.suspended),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_headerAnimation),
      child: FadeTransition(
        opacity: _headerAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9), Color(0xFF1557B0)],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: const Color(0xFF1557B0).withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 80,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Animated icon container
                          Hero(
                            tag: 'kelola_lapak_icon',
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.store_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kelola Lapak',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Verifikasi & Kelola Penjual',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Refresh button dengan ripple effect
                          Material(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                _loadStatistics();
                                _statsAnimationController.reset();
                                _statsAnimationController.forward();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return ScaleTransition(
      scale: _statsAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        transform: Matrix4.translationValues(0, -8, 0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Menunggu',
                _statistics['pending'] ?? 0,
                Icons.pending_actions_rounded,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFA500),
                    Color(0xFFFF8C00),
                    Color(0xFFFF7700),
                  ],
                ),
                0,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                'Disetujui',
                _statistics['approved'] ?? 0,
                Icons.check_circle_rounded,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                    Color(0xFF047857),
                  ],
                ),
                1,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                'Ditolak',
                _statistics['rejected'] ?? 0,
                Icons.cancel_rounded,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEF4444),
                    Color(0xFFDC2626),
                    Color(0xFFB91C1C),
                  ],
                ),
                2,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                'Suspend',
                _statistics['suspended'] ?? 0,
                Icons.block_rounded,
                const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6B7280),
                    Color(0xFF4B5563),
                    Color(0xFF374151),
                  ],
                ),
                3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    int count,
    IconData icon,
    Gradient gradient,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon dengan glow effect
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  // Animated counter
                  TweenAnimationBuilder<int>(
                    duration: Duration(milliseconds: 800 + (index * 100)),
                    tween: IntTween(begin: 0, end: count),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.98),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9), Color(0xFF1557B0)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFF1557B0).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        splashBorderRadius: BorderRadius.circular(14),
        overlayColor: WidgetStateProperty.all(
          const Color(0xFF2F80ED).withValues(alpha: 0.1),
        ),
        tabs: [
          Tab(height: 44, child: Center(child: Text('Pending'))),
          Tab(height: 44, child: Center(child: Text('Aktif'))),
          Tab(height: 44, child: Center(child: Text('Ditolak'))),
          Tab(height: 44, child: Center(child: Text('Suspend'))),
        ],
      ),
    );
  }

  Widget _buildSellerList(SellerVerificationStatus status) {
    return StreamBuilder<List<PendingSellerModel>>(
      stream: _repository.getSellersByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final sellers = snapshot.data ?? [];

        if (sellers.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadStatistics();
          },
          color: const Color(0xFF2F80ED),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              return _buildSellerCard(sellers[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildApprovedSellersList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _repository.getApprovedSellers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final sellers = snapshot.data ?? [];

        if (sellers.isEmpty) {
          return _buildEmptyState(SellerVerificationStatus.approved);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadStatistics();
          },
          color: const Color(0xFF2F80ED),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              return _buildApprovedSellerCard(sellers[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSellerCard(PendingSellerModel seller) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailSellerPage(seller: seller),
                      ),
                    ).then((_) => _loadStatistics());
                  },
                  splashColor: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  highlightColor: const Color(
                    0xFF2F80ED,
                  ).withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar dengan glow effect
                            Hero(
                              tag: 'seller_${seller.id}',
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2F80ED),
                                      Color(0xFF1E6FD9),
                                      Color(0xFF1557B0),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF2F80ED,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.store_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seller.namaToko,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1F2937),
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 16,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          seller.namaLengkap,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusBadge(seller.status),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFF8F9FD),
                                const Color(0xFFF8F9FD).withValues(alpha: 0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.category_rounded,
                                seller.kategoriProdukString,
                                const Color(0xFF2F80ED),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                '${seller.alamatToko} (RT ${seller.rt}/RW ${seller.rw})',
                                const Color(0xFF10B981),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.phone_rounded,
                                seller.nomorTelepon,
                                const Color(0xFFFFA500),
                              ),
                              if (seller.createdAt != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.calendar_today_rounded,
                                  _formatDate(seller.createdAt!),
                                  const Color(0xFF7C6FFF),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovedSellerCard(Map<String, dynamic> seller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FD)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller['namaToko'] ?? 'Nama Toko',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        seller['namaLengkap'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Aktif',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Trust Score',
                      '${seller['trustScore']?.toStringAsFixed(0) ?? '100'}%',
                      Icons.verified_user_rounded,
                      const LinearGradient(
                        colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: const Color(0xFFE5E7EB),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Rating',
                      '${seller['rating']?.toStringAsFixed(1) ?? '5.0'}',
                      Icons.star_rounded,
                      const LinearGradient(
                        colors: [Color(0xFFFFA500), Color(0xFFFF8C00)],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: const Color(0xFFE5E7EB),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Produk',
                      '${seller['totalProducts'] ?? 0}',
                      Icons.inventory_rounded,
                      const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(SellerVerificationStatus status) {
    Color startColor;
    Color endColor;
    IconData icon;
    String label;

    switch (status) {
      case SellerVerificationStatus.pending:
        startColor = const Color(0xFFFFA500);
        endColor = const Color(0xFFFF8C00);
        icon = Icons.pending_actions_rounded;
        label = 'Pending';
        break;
      case SellerVerificationStatus.approved:
        startColor = const Color(0xFF10B981);
        endColor = const Color(0xFF059669);
        icon = Icons.check_circle_rounded;
        label = 'Disetujui';
        break;
      case SellerVerificationStatus.rejected:
        startColor = const Color(0xFFEF4444);
        endColor = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        label = 'Ditolak';
        break;
      case SellerVerificationStatus.suspended:
        startColor = const Color(0xFF6B7280);
        endColor = const Color(0xFF4B5563);
        icon = Icons.block_rounded;
        label = 'Suspend';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: startColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(SellerVerificationStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case SellerVerificationStatus.pending:
        message = 'Belum ada pendaftaran seller yang menunggu verifikasi';
        icon = Icons.pending_actions_rounded;
        break;
      case SellerVerificationStatus.approved:
        message = 'Belum ada seller yang disetujui';
        icon = Icons.store_rounded;
        break;
      case SellerVerificationStatus.rejected:
        message = 'Belum ada seller yang ditolak';
        icon = Icons.cancel_rounded;
        break;
      case SellerVerificationStatus.suspended:
        message = 'Belum ada seller yang disuspend';
        icon = Icons.block_rounded;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
