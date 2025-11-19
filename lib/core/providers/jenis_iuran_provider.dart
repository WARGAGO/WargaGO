import 'package:flutter/material.dart';
import 'package:jawara/core/services/jenis_iuran_service.dart';
import 'package:jawara/core/models/jenis_iuran_model.dart';

/// Jenis Iuran Provider
/// Provider untuk manage state data jenis iuran dengan CRUD lengkap
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya manage state jenis iuran
/// - Separation of Concerns: Business logic di service, state management di sini
class JenisIuranProvider extends ChangeNotifier {
  final JenisIuranService _jenisIuranService = JenisIuranService();

  List<JenisIuranModel> _jenisIuranList = [];
  JenisIuranModel? _selectedJenisIuran;
  bool _isLoading = false;
  String? _errorMessage;
  String _filterKategori = 'Semua'; // 'Semua', 'bulanan', 'khusus'
  String _searchQuery = '';

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<JenisIuranModel> get jenisIuranList => _getFilteredList();
  List<JenisIuranModel> get allJenisIuranList => _jenisIuranList;
  JenisIuranModel? get selectedJenisIuran => _selectedJenisIuran;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterKategori => _filterKategori;
  String get searchQuery => _searchQuery;
  int get totalJenisIuran => _jenisIuranList.length;
  int get totalBulanan => _jenisIuranList.where((j) => j.kategoriIuran == 'bulanan').length;
  int get totalKhusus => _jenisIuranList.where((j) => j.kategoriIuran == 'khusus').length;

  // ============================================================================
  // FILTERS
  // ============================================================================

  List<JenisIuranModel> _getFilteredList() {
    var filtered = _jenisIuranList;

    // Filter by kategori
    if (_filterKategori != 'Semua') {
      filtered = filtered.where((j) => j.kategoriIuran == _filterKategori).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((j) {
        return j.namaIuran.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void setFilterKategori(String kategori) {
    _filterKategori = kategori;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _filterKategori = 'Semua';
    _searchQuery = '';
    notifyListeners();
  }

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Add jenis iuran baru
  Future<bool> addJenisIuran(JenisIuranModel jenisIuran) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _jenisIuranService.createJenisIuran(jenisIuran);
      
      if (id != null) {
        // Refresh list after adding
        await fetchAllJenisIuran();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Gagal menambahkan jenis iuran';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Fetch all jenis iuran
  Future<void> fetchAllJenisIuran() async {
    print('🔄 JenisIuranProvider: fetchAllJenisIuran() called');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jenisIuranList = await _jenisIuranService.getAllJenisIuran();
      print('✅ JenisIuranProvider: Fetched ${_jenisIuranList.length} items');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ JenisIuranProvider: Error fetching data - $e');
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Stream jenis iuran (real-time)
  Stream<List<JenisIuranModel>> streamJenisIuran() {
    return _jenisIuranService.streamAllJenisIuran();
  }

  /// Get jenis iuran by ID
  Future<void> fetchJenisIuranById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedJenisIuran = await _jenisIuranService.getJenisIuranById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search jenis iuran
  Future<void> searchJenisIuran(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jenisIuranList = await _jenisIuranService.searchJenisIuran(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get jenis iuran by kategori
  Future<void> fetchJenisIuranByKategori(String kategori) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _jenisIuranList = await _jenisIuranService.getJenisIuranByKategori(kategori);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update jenis iuran
  Future<bool> updateJenisIuran(JenisIuranModel jenisIuran) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _jenisIuranService.updateJenisIuran(jenisIuran);
      
      if (success) {
        // Update local list
        final index = _jenisIuranList.indexWhere((j) => j.id == jenisIuran.id);
        if (index != -1) {
          _jenisIuranList[index] = jenisIuran;
        }
        
        // Update selected if it's the same
        if (_selectedJenisIuran?.id == jenisIuran.id) {
          _selectedJenisIuran = jenisIuran;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Gagal mengupdate jenis iuran';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete jenis iuran (soft delete)
  Future<bool> deleteJenisIuran(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _jenisIuranService.deleteJenisIuran(id);
      
      if (success) {
        // Remove from local list
        _jenisIuranList.removeWhere((j) => j.id == id);
        
        // Clear selected if it's the same
        if (_selectedJenisIuran?.id == id) {
          _selectedJenisIuran = null;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Gagal menghapus jenis iuran';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hard delete jenis iuran
  Future<bool> hardDeleteJenisIuran(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _jenisIuranService.hardDeleteJenisIuran(id);
      
      if (success) {
        // Remove from local list
        _jenisIuranList.removeWhere((j) => j.id == id);
        
        // Clear selected if it's the same
        if (_selectedJenisIuran?.id == id) {
          _selectedJenisIuran = null;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _errorMessage = 'Gagal menghapus jenis iuran';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final countByKategori = await _jenisIuranService.getCountByKategori();
      final total = await _jenisIuranService.getTotalJenisIuranCount();
      
      return {
        'total': total,
        'bulanan': countByKategori['bulanan'] ?? 0,
        'khusus': countByKategori['khusus'] ?? 0,
      };
    } catch (e) {
      return {'total': 0, 'bulanan': 0, 'khusus': 0};
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Set selected jenis iuran
  void setSelectedJenisIuran(JenisIuranModel? jenisIuran) {
    _selectedJenisIuran = jenisIuran;
    notifyListeners();
  }

  /// Clear selected jenis iuran
  void clearSelectedJenisIuran() {
    _selectedJenisIuran = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchAllJenisIuran();
  }
}

