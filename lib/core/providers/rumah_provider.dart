import 'package:flutter/material.dart';
import 'package:jawara/core/services/rumah_service.dart';
import 'package:jawara/core/models/rumah_model.dart';

/// Rumah Provider
/// Provider untuk manage state data rumah dengan CRUD lengkap
class RumahProvider extends ChangeNotifier {
  final RumahService _rumahService = RumahService();

  List<RumahModel> _rumahList = [];
  RumahModel? _selectedRumah;
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<RumahModel> get rumahList => _rumahList;
  RumahModel? get selectedRumah => _selectedRumah;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalRumah => _rumahList.length;

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Add rumah baru
  Future<bool> addRumah(RumahModel rumah) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _rumahService.createRumah(rumah);
      if (id != null) {
        await loadRumah(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal menambahkan rumah';
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

  /// Load all rumah
  Future<void> loadRumah() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rumahList = await _rumahService.getAllRumah();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading rumah: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update rumah
  Future<bool> updateRumah(String id, RumahModel rumah) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _rumahService.updateRumah(id, rumah);
      if (success) {
        await loadRumah(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal mengupdate rumah';
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

  /// Delete rumah
  Future<bool> deleteRumah(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _rumahService.deleteRumah(id);
      if (success) {
        await loadRumah(); // Reload data
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Gagal menghapus rumah';
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

  /// Select rumah
  void selectRumah(RumahModel rumah) {
    _selectedRumah = rumah;
    notifyListeners();
  }

  /// Clear selection
  void clearSelection() {
    _selectedRumah = null;
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

