import 'package:flutter/foundation.dart';
import '../services/dashboard_service.dart';

/// Dashboard Provider
/// Provider untuk manage state dashboard data
class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Dashboard data
  double _kasMasuk = 0;
  double _kasKeluar = 0;
  int _totalTransaksi = 0;
  int _totalKegiatan = 0;
  Map<String, int> _timeline = {};
  Map<String, dynamic> _topPJ = {};
  int _totalWarga = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  // Getters
  double get kasMasuk => _kasMasuk;
  double get kasKeluar => _kasKeluar;
  double get saldo => _kasMasuk - _kasKeluar;
  int get totalTransaksi => _totalTransaksi;
  int get totalKegiatan => _totalKegiatan;
  Map<String, int> get timeline => _timeline;
  Map<String, dynamic> get topPJ => _topPJ;
  int get totalWarga => _totalWarga;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  // Timeline getters
  int get sudahLewat => _timeline['sudah_lewat'] ?? 0;
  int get hariIni => _timeline['hari_ini'] ?? 0;
  int get akanDatang => _timeline['akan_datang'] ?? 0;

  // Top PJ getters
  String get topPJNama => _topPJ['nama'] ?? 'Belum ada';
  int get topPJJumlah => _topPJ['jumlah'] ?? 0;

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final summary = await _dashboardService.getDashboardSummary();

      _kasMasuk = summary['kasMasuk'];
      _kasKeluar = summary['kasKeluar'];
      _totalTransaksi = summary['totalTransaksi'];
      _totalKegiatan = summary['totalKegiatan'];
      _timeline = summary['timeline'];
      _topPJ = summary['topPJ'];
      _totalWarga = summary['totalWarga'];
      _recentActivities = summary['recentActivities'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Format currency (Rupiah)
  String formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}JT';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}RB';
    }
    return amount.toStringAsFixed(0);
  }

  /// Get kas masuk formatted
  String get kasMasukFormatted => formatCurrency(_kasMasuk);

  /// Get kas keluar formatted
  String get kasKeluarFormatted => formatCurrency(_kasKeluar);

  /// Get saldo formatted
  String get saldoFormatted => formatCurrency(saldo);
}

