import 'package:flutter/material.dart';
import 'package:jawara/core/services/warga_service.dart';
import 'package:jawara/core/models/warga_model.dart';

/// Warga Provider
/// Provider untuk manage state data warga dengan CRUD lengkap
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya manage state warga
/// - Separation of Concerns: Business logic di service, state management di sini
class WargaProvider extends ChangeNotifier {
  final WargaService _wargaService = WargaService();

  List<WargaModel> _wargaList = [];
  WargaModel? _selectedWarga;
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'Semua'; // 'Semua', 'Aktif', 'Nonaktif'
  String _filterGender = 'Semua'; // 'Semua', 'Laki-laki', 'Perempuan'
  String _searchQuery = '';

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<WargaModel> get wargaList => _getFilteredList();
  List<WargaModel> get allWargaList => _wargaList;
  WargaModel? get selectedWarga => _selectedWarga;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;
  String get filterGender => _filterGender;
  String get searchQuery => _searchQuery;
  int get totalWarga => _wargaList.length;
  int get totalAktif => _wargaList.where((w) => w.isActive).length;
  int get totalNonaktif => _wargaList.where((w) => !w.isActive).length;

  // ============================================================================
  // FILTERS
  // ============================================================================

  List<WargaModel> _getFilteredList() {
    var filtered = _wargaList;

    // Filter by status
    if (_filterStatus != 'Semua') {
      filtered = filtered.where((w) => w.statusPenduduk == _filterStatus).toList();
    }

    // Filter by gender
    if (_filterGender != 'Semua') {
      filtered = filtered.where((w) => w.jenisKelamin == _filterGender).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((w) {
        return w.name.toLowerCase().contains(query) ||
               w.nik.toLowerCase().contains(query) ||
               w.namaKeluarga.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterGender(String gender) {
    _filterGender = gender;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = 'Semua';
    _filterGender = 'Semua';
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Add warga baru
  Future<bool> addWarga(WargaModel warga) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _wargaService.createWarga(warga);
      if (id != null) {
        await loadWarga(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal menambahkan warga';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Load all warga
  Future<void> loadWarga() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wargaList = await _wargaService.getAllWarga();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading warga: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load warga by ID
  Future<void> loadWargaById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedWarga = await _wargaService.getWargaById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading warga: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search warga
  Future<void> searchWarga(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wargaList = await _wargaService.searchWarga(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error searching warga: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update warga
  Future<bool> updateWarga(String id, WargaModel warga) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _wargaService.updateWarga(id, warga);
      if (success) {
        await loadWarga(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal mengupdate warga';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete warga (hard delete)
  Future<bool> deleteWarga(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _wargaService.deleteWarga(id);
      if (success) {
        await loadWarga(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal menghapus warga';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soft delete warga (ubah status jadi nonaktif)
  Future<bool> softDeleteWarga(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _wargaService.softDeleteWarga(id);
      if (success) {
        await loadWarga(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal menonaktifkan warga';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // SELECTION
  // ============================================================================

  /// Select warga
  void selectWarga(WargaModel warga) {
    _selectedWarga = warga;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedWarga = null;
    notifyListeners();
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
