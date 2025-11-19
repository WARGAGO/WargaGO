import 'package:flutter/foundation.dart';
import '../models/tagihan_model.dart';
import '../services/tagihan_service.dart';

/// Provider untuk mengelola state Tagihan
class TagihanProvider with ChangeNotifier {
  final TagihanService _service = TagihanService();

  List<TagihanModel> _tagihan = [];
  List<TagihanModel> get tagihan => _tagihan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, dynamic> _statistics = {};
  Map<String, dynamic> get statistics => _statistics;

  // Filter states
  String _selectedStatus = 'Semua';
  String get selectedStatus => _selectedStatus;

  String? _selectedJenisIuranId;
  String? get selectedJenisIuranId => _selectedJenisIuranId;

  String? _selectedKeluargaId;
  String? get selectedKeluargaId => _selectedKeluargaId;

  // Stream subscription
  Stream<List<TagihanModel>>? _tagihanStream;

  /// Initialize dan load data
  void initialize() {
    loadTagihan();
    loadStatistics();
  }

  /// Load semua tagihan
  void loadTagihan() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tagihanStream = _service.getTagihanStream();
      _tagihanStream!.listen(
        (data) {
          _tagihan = data;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
          debugPrint('❌ Error loading tagihan: $error');
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error initializing tagihan stream: $e');
    }
  }

  /// Load tagihan by keluarga
  void loadTagihanByKeluarga(String keluargaId) {
    _isLoading = true;
    _error = null;
    _selectedKeluargaId = keluargaId;
    notifyListeners();

    try {
      _tagihanStream = _service.getTagihanByKeluargaStream(keluargaId);
      _tagihanStream!.listen(
        (data) {
          _tagihan = data;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load tagihan by jenis iuran
  void loadTagihanByJenisIuran(String jenisIuranId) {
    _isLoading = true;
    _error = null;
    _selectedJenisIuranId = jenisIuranId;
    notifyListeners();

    try {
      _tagihanStream = _service.getTagihanByJenisIuranStream(jenisIuranId);
      _tagihanStream!.listen(
        (data) {
          _tagihan = data;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load tagihan by status
  void loadTagihanByStatus(String status) {
    _isLoading = true;
    _error = null;
    _selectedStatus = status;
    notifyListeners();

    try {
      if (status == 'Semua') {
        loadTagihan();
      } else {
        _tagihanStream = _service.getTagihanByStatusStream(status);
        _tagihanStream!.listen(
          (data) {
            _tagihan = data;
            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = error.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load tagihan jatuh tempo
  void loadTagihanJatuhTempo() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tagihanStream = _service.getTagihanJatuhTempoStream();
      _tagihanStream!.listen(
        (data) {
          _tagihan = data;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _service.getTagihanStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading statistics: $e');
    }
  }

  /// Create tagihan
  Future<bool> createTagihan(TagihanModel tagihan) async {
    try {
      print('\n🔵 [TagihanProvider] Starting createTagihan...');

      _isLoading = true;
      _error = null;
      notifyListeners();
      print('✅ [TagihanProvider] Loading state set to true');

      print('🔵 [TagihanProvider] Calling service.createTagihan()...');
      final docId = await _service.createTagihan(tagihan);
      print('✅ [TagihanProvider] Service returned document ID: $docId');

      print('🔵 [TagihanProvider] Loading statistics...');
      await loadStatistics();
      print('✅ [TagihanProvider] Statistics loaded');

      _isLoading = false;
      notifyListeners();
      print('✅ [TagihanProvider] Loading state set to false');
      print('✅ [TagihanProvider] SUCCESS! Returning true\n');
      return true;
    } catch (e, stackTrace) {
      print('\n❌ [TagihanProvider] ERROR in createTagihan!');
      print('❌ [TagihanProvider] Error: $e');
      print('❌ [TagihanProvider] StackTrace:\n$stackTrace');

      _error = e.toString();
      _isLoading = false;
      notifyListeners();

      print('❌ [TagihanProvider] Error state set, returning false\n');
      debugPrint('❌ Error creating tagihan: $e');
      return false;
    }
  }

  /// Update tagihan
  Future<bool> updateTagihan(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateTagihan(id, data);
      await loadStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error updating tagihan: $e');
      return false;
    }
  }

  /// Mark as lunas
  Future<bool> markAsLunas(
    String id, {
    required String metodePembayaran,
    String? buktiPembayaran,
    String? catatan,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.markAsLunas(
        id,
        metodePembayaran: metodePembayaran,
        buktiPembayaran: buktiPembayaran,
        catatan: catatan,
      );
      await loadStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error marking as lunas: $e');
      return false;
    }
  }

  /// Update overdue status
  Future<void> updateOverdueStatus() async {
    try {
      await _service.updateOverdueStatus();
      await loadStatistics();
    } catch (e) {
      debugPrint('❌ Error updating overdue status: $e');
    }
  }

  /// Delete tagihan
  Future<bool> deleteTagihan(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteTagihan(id);
      await loadStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error deleting tagihan: $e');
      return false;
    }
  }

  /// Create bulk tagihan
  Future<bool> createBulkTagihan({
    required String jenisIuranId,
    required String jenisIuranName,
    required double nominal,
    required String periode,
    required DateTime periodeTanggal,
    required List<Map<String, String>> keluargaList,
    required String createdBy,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createBulkTagihan(
        jenisIuranId: jenisIuranId,
        jenisIuranName: jenisIuranName,
        nominal: nominal,
        periode: periode,
        periodeTanggal: periodeTanggal,
        keluargaList: keluargaList,
        createdBy: createdBy,
      );
      await loadStatistics();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error creating bulk tagihan: $e');
      return false;
    }
  }

  /// Get filtered tagihan
  List<TagihanModel> getFilteredTagihan({
    String? status,
    String? jenisIuranId,
    String? keluargaId,
  }) {
    var filtered = _tagihan;

    if (status != null && status != 'Semua') {
      filtered = filtered.where((t) => t.status == status).toList();
    }

    if (jenisIuranId != null) {
      filtered = filtered.where((t) => t.jenisIuranId == jenisIuranId).toList();
    }

    if (keluargaId != null) {
      filtered = filtered.where((t) => t.keluargaId == keluargaId).toList();
    }

    return filtered;
  }

  /// Get tagihan by ID
  Future<TagihanModel?> getTagihanById(String id) async {
    try {
      return await _service.getTagihanById(id);
    } catch (e) {
      debugPrint('❌ Error getting tagihan by ID: $e');
      return null;
    }
  }

  /// Reset filters
  void resetFilters() {
    _selectedStatus = 'Semua';
    _selectedJenisIuranId = null;
    _selectedKeluargaId = null;
    loadTagihan();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tagihanStream = null;
    super.dispose();
  }
}

