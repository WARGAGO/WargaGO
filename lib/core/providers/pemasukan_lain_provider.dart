import 'package:flutter/foundation.dart';
import '../models/pemasukan_lain_model.dart';
import '../services/pemasukan_lain_service.dart';

/// Provider untuk mengelola state Pemasukan Lain
class PemasukanLainProvider with ChangeNotifier {
  final PemasukanLainService _service = PemasukanLainService();

  List<PemasukanLainModel> _pemasukanList = [];
  List<PemasukanLainModel> _menungguList = [];
  List<PemasukanLainModel> _terverifikasiList = [];
  List<PemasukanLainModel> _ditolakList = [];

  double _totalTerverifikasi = 0;
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'Semua'; // 'Semua', 'Menunggu', 'Terverifikasi', 'Ditolak'

  // Getters
  List<PemasukanLainModel> get pemasukanList => _pemasukanList;
  List<PemasukanLainModel> get menungguList => _menungguList;
  List<PemasukanLainModel> get terverifikasiList => _terverifikasiList;
  List<PemasukanLainModel> get ditolakList => _ditolakList;
  double get totalTerverifikasi => _totalTerverifikasi;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;

  Stream<List<PemasukanLainModel>>? _pemasukanStream;

  /// Load pemasukan lain berdasarkan status
  void loadPemasukanLain({String? status}) {
    _selectedStatus = status ?? 'Semua';

    if (_selectedStatus == 'Semua') {
      _pemasukanStream = _service.getPemasukanLainStream();
    } else {
      _pemasukanStream = _service.getPemasukanLainByStatusStream(_selectedStatus);
    }

    _pemasukanStream!.listen(
      (pemasukanList) {
        _pemasukanList = pemasukanList;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        debugPrint('❌ Error loading pemasukan lain: $error');
        notifyListeners();
      },
    );
  }

  /// Load by status
  void loadByStatus(String status) {
    _service.getPemasukanLainByStatusStream(status).listen(
      (list) {
        switch (status) {
          case 'Menunggu':
            _menungguList = list;
            break;
          case 'Terverifikasi':
            _terverifikasiList = list;
            break;
          case 'Ditolak':
            _ditolakList = list;
            break;
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error loading pemasukan by status: $error');
      },
    );
  }

  /// Load total terverifikasi
  Future<void> loadTotalTerverifikasi() async {
    try {
      _totalTerverifikasi = await _service.getTotalPemasukanTerverifikasi();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading total terverifikasi: $e');
    }
  }

  /// Create pemasukan lain
  Future<bool> createPemasukanLain(PemasukanLainModel pemasukan) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createPemasukanLain(pemasukan);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error creating pemasukan lain: $e');
      return false;
    }
  }

  /// Update pemasukan lain
  Future<bool> updatePemasukanLain(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updatePemasukanLain(id, data);
      await loadTotalTerverifikasi(); // Refresh total

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error updating pemasukan lain: $e');
      return false;
    }
  }

  /// Verifikasi pemasukan
  Future<bool> verifikasiPemasukan(String id, bool approved) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.verifikasiPemasukan(id, approved);
      await loadTotalTerverifikasi(); // Refresh total

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error verifying pemasukan: $e');
      return false;
    }
  }

  /// Delete pemasukan lain
  Future<bool> deletePemasukanLain(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deletePemasukanLain(id);
      await loadTotalTerverifikasi(); // Refresh total

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error deleting pemasukan lain: $e');
      return false;
    }
  }

  /// Get pemasukan lain by ID
  Future<PemasukanLainModel?> getPemasukanLainById(String id) async {
    try {
      return await _service.getPemasukanLainById(id);
    } catch (e) {
      debugPrint('❌ Error getting pemasukan lain by ID: $e');
      return null;
    }
  }

  /// Set filter status
  void setFilterStatus(String status) {
    _selectedStatus = status;
    loadPemasukanLain(status: status);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pemasukanStream = null;
    super.dispose();
  }
}
