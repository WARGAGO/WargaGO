import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/widgets/app_bottom_navigation.dart';
import 'package:jawara/core/providers/warga_provider.dart';
import 'package:jawara/core/providers/keluarga_provider.dart';
import 'package:jawara/core/providers/rumah_provider.dart';
import 'data_penduduk/data_penduduk_page.dart';
import 'data_mutasi/data_mutasi_warga_page.dart';
import 'data_mutasi/repositories/mutasi_repository.dart';
import 'terima_warga/repositories/pending_warga_repository.dart';
import 'kelola_pengguna/kelola_pengguna_page.dart';
import 'terima_warga/terima_warga_page.dart';
import 'package:jawara/features/admin/core_pages/kyc_verification_page.dart';

class DataWargaMainPage extends StatefulWidget {
  final int initialIndex;

  const DataWargaMainPage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DataWargaMainPage> createState() => _DataWargaMainPageState();
}

class _DataWargaMainPageState extends State<DataWargaMainPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final MutasiRepository _mutasiRepo = MutasiRepository();
  final PendingWargaRepository _pendingRepo = PendingWargaRepository();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    // Load data from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WargaProvider>().loadWarga();
      context.read<KeluargaProvider>().fetchKeluarga();
      context.read<RumahProvider>().loadRumah();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<WargaProvider, KeluargaProvider, RumahProvider>(
      builder: (context, wargaProvider, keluargaProvider, rumahProvider, child) {
        // Calculate statistics
        final totalWarga = wargaProvider.totalWarga;
        final totalKeluarga = keluargaProvider.totalKeluarga;
        final totalRumah = rumahProvider.totalRumah;
        final totalLakiLaki = wargaProvider.allWargaList
            .where((w) => w.jenisKelamin.toLowerCase() == 'laki-laki')
            .length;
        final totalPerempuan = wargaProvider.allWargaList
            .where((w) => w.jenisKelamin.toLowerCase() == 'perempuan')
            .length;

        // Debug logging
        print('=== DATA WARGA MAIN PAGE DEBUG ===');
        print('Total Warga: $totalWarga');
        print('Total Keluarga: $totalKeluarga');
        print('Total Rumah: $totalRumah');
        print('Total Laki-laki: $totalLakiLaki');
        print('Total Perempuan: $totalPerempuan');
        print('Is Loading: ${wargaProvider.isLoading}');
        print('================================');

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF5F7FA),
                  Color(0xFFFFFFFF),
                ],
              ),
            ),
            child: Column(
              children: [
                // HEADER
                _buildModernHeader(),

                // CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Row 1: Data Penduduk & Data Mutasi
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHorizontalCard(
                                    context,
                                    title: 'Data Penduduk',
                                    subtitle: 'Kelola data warga',
                                    icon: Icons.groups_3_rounded,
                                    gradientColors: const [
                                      Color(0xFF2F80ED),
                                      Color(0xFF1E6FD9),
                                    ],
                                    total: wargaProvider.isLoading ? '...' : totalWarga.toString(),
                                    label: 'Total Warga',
                                    trend: wargaProvider.isLoading ? '...' : 'Aktif: ${wargaProvider.totalAktif}',
                                    trendUp: true,
                                    delay: 0,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const DataWargaPage(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Data Mutasi Card with StreamBuilder
                                Expanded(
                                  child: StreamBuilder<List<dynamic>>(
                                    stream: _mutasiRepo.getAllMutasi(),
                                    builder: (context, snapshot) {
                                      final totalMutasi = snapshot.hasData ? snapshot.data!.length : 0;
                                      final totalStr = totalMutasi.toString();

                                      return _buildHorizontalCard(
                                        context,
                                        title: 'Data Mutasi',
                                        subtitle: 'Riwayat perpindahan',
                                        icon: Icons.swap_horizontal_circle_rounded,
                                        gradientColors: const [
                                          Color(0xFF3B8FFF),
                                          Color(0xFF2F80ED),
                                        ],
                                        total: totalStr,
                                        label: 'Total Mutasi',
                                        trend: totalMutasi > 0 ? '+${totalMutasi}' : '-',
                                        trendUp: true,
                                        delay: 100,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DataMutasiWargaPage(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: Kelola Pengguna & Terima Warga
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHorizontalCard(
                                    context,
                                    title: 'Kelola Pengguna',
                                    subtitle: 'Manajemen akun user',
                                    icon: Icons.admin_panel_settings_rounded,
                                    gradientColors: const [
                                      Color(0xFF1E6FD9),
                                      Color(0xFF0F5FCC),
                                    ],
                                    total: totalWarga.toString(), // Same as warga for now
                                    label: 'Total User',
                                    trend: '-',
                                    trendUp: true,
                                    delay: 200,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const KelolaPenggunaPage(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Terima Warga Card with StreamBuilder
                                Expanded(
                                  child: StreamBuilder<List<dynamic>>(
                                    stream: _pendingRepo.getAllPendingWarga(),
                                    builder: (context, snapshot) {
                                      final totalPending = snapshot.hasData ? snapshot.data!.length : 0;
                                      final totalStr = totalPending.toString();

                                      return _buildHorizontalCard(
                                        context,
                                        title: 'Terima Warga',
                                        subtitle: 'Persetujuan pendaftar',
                                        icon: Icons.person_add_alt_1_rounded,
                                        gradientColors: const [
                                          Color(0xFF5BA3FF),
                                          Color(0xFF3B8FFF),
                                        ],
                                        total: totalStr,
                                        label: 'Menunggu',
                                        trend: totalPending > 0 ? 'New' : '-',
                                        trendUp: false,
                                        delay: 300,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const TerimaWargaPage(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: Verifikasi KYC
                            Row(
                              children: [
                                Expanded(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('kyc_documents')
                                        .where('status', isEqualTo: 'pending')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      final pendingKYC = snapshot.hasData ? snapshot.data!.docs.length : 0;

                                      return _buildHorizontalCard(
                                        context,
                                        title: 'Verifikasi KYC',
                                        subtitle: 'Approve dokumen warga',
                                        icon: Icons.verified_user_rounded,
                                        gradientColors: const [
                                          Color(0xFFFF9800),
                                          Color(0xFFF57C00),
                                        ],
                                        total: pendingKYC.toString(),
                                        label: 'Pending KYC',
                                        trend: pendingKYC > 0 ? '${pendingKYC} Baru' : 'Semua OK',
                                        trendUp: pendingKYC == 0,
                                        delay: 400,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const KYCVerificationPage(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Placeholder card atau card lain bisa ditambahkan di sini
                                Expanded(
                                  child: Container(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // STATISTIK
                            _buildStatisticsSection(
                              totalLakiLaki: totalLakiLaki,
                              totalPerempuan: totalPerempuan,
                              totalKeluarga: totalKeluarga,
                              totalRumah: totalRumah,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
        );
      },
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + 20,
            24,
            32,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(const Color(0xFF2F80ED), const Color(0xFF3B8FFF),
                    _pulseController.value * 0.2)!,
                const Color(0xFF1E6FD9),
                const Color(0xFF0F5FCC),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x662F80ED), // 0.4 opacity = 0x66
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF), // white with 0.25 opacity
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0x66FFFFFF), // white with 0.4 opacity
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.dashboard_customize_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data Warga",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33FFFFFF), // white with 0.2 opacity
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Management Center",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  Widget _buildHorizontalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required String total,
    required String label,
    required String trend,
    required bool trendUp,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp value to ensure it's within valid range
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(50 * (1 - clampedValue), 0),
          child: Opacity(
            opacity: clampedValue,
            child: child,
          ),
        );
      },
      child: _HorizontalCardWidget(
        title: title,
        subtitle: subtitle,
        icon: icon,
        gradientColors: gradientColors,
        total: total,
        label: label,
        trend: trend,
        trendUp: trendUp,
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatisticsSection({
    required int totalLakiLaki,
    required int totalPerempuan,
    required int totalKeluarga,
    required int totalRumah,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Clamp value to ensure it's within valid range
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - clampedValue)),
          child: Opacity(
            opacity: clampedValue,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F000000), // black with 0.06 opacity
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Statistik Ringkas",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        "Data demografi real-time dari Firebase",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.male_rounded,
                    value: totalLakiLaki.toString(),
                    label: 'Laki-laki',
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.female_rounded,
                    value: totalPerempuan.toString(),
                    label: 'Perempuan',
                    color: const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.family_restroom_rounded,
                    value: totalKeluarga.toString(),
                    label: 'Keluarga',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.house_rounded,
                    value: totalRumah.toString(),
                    label: 'Rumah',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    // Use Color.withValues for opacity since withOpacity is deprecated
    final backgroundColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Horizontal Card Widget - Simplified without shimmer
class _HorizontalCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String total;
  final String label;
  final String trend;
  final bool trendUp;
  final VoidCallback onTap;

  const _HorizontalCardWidget({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.total,
    required this.label,
    required this.trend,
    required this.trendUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pre-calculate colors with opacity using withValues
    final borderColor = gradientColors[0].withValues(alpha: 0.15);
    final shadowColor = gradientColors[0].withValues(alpha: 0.25);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0x0D000000), // black with 0.05 opacity
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Content - Box/Square layout with vertical structure
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -30,
                        right: -30,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x1AFFFFFF), // white with 0.1 opacity
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -25,
                        left: -25,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x14FFFFFF), // white with 0.08 opacity
                          ),
                        ),
                      ),

                      // Main content
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon at right side with title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      // Title
                                      Text(
                                        title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                          height: 1.2,
                                          shadows: const [
                                            Shadow(
                                              color: Color(0x33000000), // black with 0.2 opacity
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Icon at right
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0x40FFFFFF), // white with 0.25 opacity
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0x66FFFFFF), // white with 0.4 opacity
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Number section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          total,
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            height: 1,
                                            shadows: const [
                                              Shadow(
                                                color: Color(0x33000000), // black with 0.2 opacity
                                                offset: Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        label,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xE6FFFFFF), // white with 0.9 opacity
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Trend badge
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x40FFFFFF), // white with 0.25 opacity
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0x4DFFFFFF), // white with 0.3 opacity
                                        width: 1,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            trendUp
                                                ? Icons.trending_up_rounded
                                                : Icons.fiber_new_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            trend,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

