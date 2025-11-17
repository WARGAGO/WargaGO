import 'package:flutter/material.dart';
import '../models/keluarga_model.dart';
import '../services/keluarga_service.dart';

/// Keluarga Provider
/// Provider untuk manage state data keluarga
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya manage keluarga state
/// - Uses ChangeNotifier for reactive UI updates
class KeluargaProvider with ChangeNotifier {
  final KeluargaService _keluargaService = KeluargaService();

  List<KeluargaModel> _keluargaList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<KeluargaModel> get keluargaList => _keluargaList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  int get totalKeluarga => _keluargaList.length;

  // ============================================================================
  // FETCH DATA
  // ============================================================================

  /// Fetch all keluarga from Firebase
  Future<void> fetchKeluarga() async {
    try {
      print('=== KeluargaProvider: fetchKeluarga ===');
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _keluargaList = await _keluargaService.getAllKeluarga();

      _isLoading = false;
      print('✅ Loaded ${_keluargaList.length} keluarga');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetchKeluarga: $e');
      _isLoading = false;
      _errorMessage = 'Gagal memuat data keluarga: $e';
      notifyListeners();
    }
  }

  /// Search keluarga
  Future<void> searchKeluarga(String query) async {
    try {
      print('=== KeluargaProvider: searchKeluarga ===');
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _keluargaList = await _keluargaService.searchKeluarga(query);

      _isLoading = false;
      print('✅ Search found ${_keluargaList.length} keluarga');
      notifyListeners();
    } catch (e) {
      print('❌ Error searchKeluarga: $e');
      _isLoading = false;
      _errorMessage = 'Gagal mencari data keluarga: $e';
      notifyListeners();
    }
  }

  /// Get keluarga by nomorKK
  Future<KeluargaModel?> getKeluargaByNomorKK(String nomorKK) async {
    try {
      print('=== KeluargaProvider: getKeluargaByNomorKK ===');
      return await _keluargaService.getKeluargaByNomorKK(nomorKK);
    } catch (e) {
      print('❌ Error getKeluargaByNomorKK: $e');
      return null;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchKeluarga();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}

