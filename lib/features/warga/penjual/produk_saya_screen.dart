// ============================================================================
// SELLER DASHBOARD - PRODUK SAYA (FULLY DYNAMIC)
// ============================================================================
// Modern seller dashboard dengan real-time statistics dari backend
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:wargago/core/services/azure_blob_storage_service.dart';
import 'package:wargago/core/services/product_service.dart';
import 'package:wargago/core/models/product_model.dart';
import 'tambah_produk_screen.dart';
import 'kelola_produk_screen.dart';
import '../marketplace/pages/seller_orders_page.dart';

class ProdukSayaScreen extends StatefulWidget {
  const ProdukSayaScreen({super.key});

  @override
  State<ProdukSayaScreen> createState() => _ProdukSayaScreenState();
}

class _ProdukSayaScreenState extends State<ProdukSayaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: Hari ini, 1: Minggu ini, 2: Bulan ini

  final ProductService _productService = ProductService();
  bool _isLoading = true;

  // Real-time stream
  StreamSubscription<List<ProductModel>>? _productsSubscription;

  // Dynamic data dari backend (akan di-load dari Firestore)
  List<ProductModel> _products = [];

  // Statistics data (akan di-calculate dari real data)
  Map<String, dynamic> _statistics = {
    'todaySales': 0, // Real data: belum ada orders
    'todayOrders': 0, // Real data: belum ada orders
    'totalProducts': 0, // Real data dari ProductService
    'activeProducts': 0, // Real data dari ProductService
    'totalRevenue': 0, // Real data: dari orders (future)
    'totalProfit': 0, // Real data: dari orders (future)
    'totalOrders': 0, // Real data: dari orders (future)
    'lowStockItems': 0, // Real data dari ProductService
    'totalStock': 0, // Real data dari ProductService
  };

  // Chart data untuk 7 hari terakhir (akan di-populate dari real orders)
  final List<Map<String, dynamic>> _salesData = [
    {'day': 'Sen', 'sales': 0},
    {'day': 'Sel', 'sales': 0},
    {'day': 'Rab', 'sales': 0},
    {'day': 'Kam', 'sales': 0},
    {'day': 'Jum', 'sales': 0},
    {'day': 'Sab', 'sales': 0},
    {'day': 'Min', 'sales': 0},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _setupRealtimeListener();
    _loadStatistics();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _productsSubscription?.cancel();
    super.dispose();
  }

  /// Setup real-time listener untuk products
  void _setupRealtimeListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _productsSubscription = _productService
        .streamProductsBySeller(currentUser.uid)
        .listen(
          (products) async {
            if (mounted) {
              AzureBlobStorageService azureBlobStorageService =
                  AzureBlobStorageService(firebaseToken: 'xxx');
              final azureImages = await azureBlobStorageService.getImages(
                uid: currentUser.uid,
                filenamePrefix: 'products/',
                isPrivate: false,
              );
              if (azureImages != null) {
                for (var product in products) {
                  product.updateUrls(azureImages);
                }
              }

              setState(() {
                _products = products;
                _isLoading = false;
              });
              // Auto-reload statistics saat produk berubah
              _loadStatistics();
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            debugPrint('Error loading products: $error');
          },
        );
  }

  /// Load statistics dari backend API
  Future<void> _loadStatistics() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get real statistics from backend
      final stats = await _productService.getSellerStatistics(currentUser.uid);

      if (mounted) {
        setState(() {
          _statistics = {
            // Product statistics (REAL dari backend!)
            'totalProducts': stats['totalProducts'] ?? 0,
            'activeProducts': stats['activeProducts'] ?? 0,
            'lowStockItems': stats['outOfStock'] ?? 0,
            'totalStock': stats['totalStock'] ?? 0,

            // Sales statistics (akan diisi dari orders - future enhancement)
            // Untuk sekarang set ke 0 karena belum ada order system
            'todaySales': 0, // Belum ada orders
            'todayOrders': 0, // Belum ada orders
            'totalRevenue': 0, // Belum ada orders
            'totalProfit': 0, // Belum ada orders
            'totalOrders': 0, // Belum ada orders
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  /// Manual refresh
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadStatistics();
    // Stream will auto-reload products
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  late final ScrollController _scrollController;
  Color _statusBarColor = Colors.transparent;

  void _onScroll() {
    // final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = 50;

    final newColor = currentScroll > threshold
        ? Color(0xFF2F80ED)
        : Colors.transparent;

    if (_statusBarColor != newColor) {
      setState(() {
        _statusBarColor = newColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF2F80ED),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar dengan gradient
            _buildAppBar(),

            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? _buildLoadingState()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Period Selector
                        _buildPeriodSelector(),

                        const SizedBox(height: 20),

                        // Statistics Cards (REAL DATA!)
                        _buildStatisticsCards(),

                        const SizedBox(height: 24),

                        // Sales Chart
                        _buildSalesChart(),

                        const SizedBox(height: 24),

                        // Quick Actions
                        _buildQuickActions(),

                        const SizedBox(height: 24),

                        // Products Section (REAL DATA!)
                        _buildProductsSection(),

                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F80ED)),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data dashboard...',
              style: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // App Bar dengan gradient + LIVE Indicator
  Widget _buildAppBar() {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: _statusBarColor,
        statusBarIconBrightness: _statusBarColor == Colors.white
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
      automaticallyImplyLeading: true,
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2F80ED), // Biru app
                Color(0xFF1E6FD9), // Biru lebih gelap
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard Penjual',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // LIVE indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF10B981),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LIVE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kelola toko dan produk Anda',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Refresh Data',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Period Selector (Hari ini, Minggu ini, Bulan ini)
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildPeriodChip('Hari Ini', 0),
          const SizedBox(width: 8),
          _buildPeriodChip('Minggu Ini', 1),
          const SizedBox(width: 8),
          _buildPeriodChip('Bulan Ini', 2),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)], // Biru app
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(
                        0xFF2F80ED,
                      ).withValues(alpha: 0.3), // Biru
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  // Statistics Cards (REAL DATA FROM BACKEND!)
  Widget _buildStatisticsCards() {
    final todaySales = _statistics['todaySales'] ?? 0;
    final todayOrders = _statistics['todayOrders'] ?? 0;
    final totalProducts = _statistics['totalProducts'] ?? 0;
    final activeProducts = _statistics['activeProducts'] ?? 0;
    final lowStockItems = _statistics['lowStockItems'] ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            'Penjualan Hari Ini',
            todaySales > 0 ? 'Rp ${_formatCurrency(todaySales)}' : 'Rp 0',
            Icons.trending_up,
            const Color(0xFF2F80ED), // Biru app
            todaySales > 0 ? '+12.5%' : 'Belum ada penjualan',
            false, // Don't show percentage when 0
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Pesanan Hari Ini',
            '$todayOrders',
            Icons.shopping_cart,
            const Color(0xFF2F80ED), // Biru app
            todayOrders > 0 ? '+$todayOrders pesanan' : 'Belum ada pesanan',
            false,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Total Produk',
            '$totalProducts',
            Icons.inventory_2,
            const Color(0xFF2F80ED), // Biru app
            '$activeProducts aktif',
            false,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Stok Habis',
            '$lowStockItems',
            Icons.warning_amber,
            lowStockItems > 0
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981),
            lowStockItems > 0 ? 'Perlu restock' : 'Stok aman',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool showPercentage,
  ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (showPercentage)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF2F80ED,
                    ).withValues(alpha: 0.1), // Biru
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        size: 12,
                        color: Color(0xFF2F80ED), // Biru
                      ),
                      const SizedBox(width: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2F80ED), // Biru
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          if (!showPercentage) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Sales Chart (akan berisi data real saat order system sudah ada)
  Widget _buildSalesChart() {
    // Calculate total sales (akan 0 jika belum ada orders)
    final totalSales = _salesData.fold<int>(
      0,
      (sum, item) => sum + (item['sales'] as int),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafik Penjualan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalSales > 0
                          ? '7 hari terakhir'
                          : 'Belum ada data penjualan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: totalSales > 0
                        ? const Color(0xFF2F80ED).withValues(alpha: 0.1)
                        : const Color(0xFF6B7280).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    totalSales > 0
                        ? 'Rp ${_formatCurrency(totalSales)}'
                        : 'Rp 0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: totalSales > 0
                          ? const Color(0xFF2F80ED)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: totalSales > 0
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 800000,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Rp ${_formatCurrency(rod.toY.toInt())}',
                                GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _salesData.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _salesData[value.toInt()]['day'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 200000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xFFE5E7EB),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _salesData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (data['sales'] as int).toDouble(),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2F80ED),
                                    Color(0xFF1E6FD9),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : _buildEmptyChartState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bar_chart,
              size: 48,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Data Penjualan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Grafik akan muncul setelah ada transaksi',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          // Row 1: Kelola Produk & Lihat Pesanan
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Kelola Produk',
                  Icons.inventory_2,
                  const Color(0xFF2F80ED), // Biru app
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KelolaProdukScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Lihat Pesanan',
                  Icons.receipt_long,
                  const Color(0xFF10B981), // Green
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerOrdersPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Laporan Penjualan
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Laporan Penjualan',
                  Icons.bar_chart,
                  const Color(0xFFF59E0B), // Orange
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              // Empty space for symmetry or add another button later
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Products Section (REAL DATA FROM BACKEND!)
  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Produk',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KelolaProdukScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text('Kelola', style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Show real products or empty state
        _products.isEmpty
            ? _buildEmptyProductsState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _products.length > 3
                    ? 3
                    : _products.length, // Show max 3
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _buildRealProductCard(product);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyProductsState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 48,
                color: Color(0xFF2F80ED),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Produk',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk pertama Anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build product card from real ProductModel
  Widget _buildRealProductCard(ProductModel product) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (!product.isActive) {
      statusColor = const Color(0xFF6B7280);
      statusText = 'Tidak Aktif';
      statusIcon = Icons.pause_circle;
    } else if (product.stok == 0) {
      statusColor = const Color(0xFFEF4444);
      statusText = 'Habis';
      statusIcon = Icons.cancel;
    } else if (product.stok < 10) {
      statusColor = const Color(0xFFF59E0B);
      statusText = 'Stok Menipis';
      statusIcon = Icons.warning;
    } else {
      statusColor = const Color(0xFF2F80ED);
      statusText = 'Aktif';
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const KelolaProdukScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.local_grocery_store,
                                  color: Color(0xFF2F80ED),
                                  size: 36,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.local_grocery_store,
                          color: Color(0xFF2F80ED),
                          size: 36,
                        ),
                ),
                const SizedBox(width: 16),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.nama,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${_formatCurrency(product.harga.toInt())}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.inventory_2_outlined,
                            'Stok: ${product.stok}',
                            const Color(0xFF2F80ED),
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.category_outlined,
                            product.kategori,
                            const Color(0xFF2F80ED),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.4), // Biru
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahProdukScreen()),
          );
        },
        backgroundColor: const Color(0xFF2F80ED), // Biru app
        icon: const Icon(Icons.add, size: 24),
        label: Text(
          'Tambah Produk',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Helper untuk format currency
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
