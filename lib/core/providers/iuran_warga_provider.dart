import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/tagihan_model.dart';
import '../services/iuran_warga_service.dart';

/// ============================================================================
/// IURAN WARGA PROVIDER
/// ============================================================================
/// Provider untuk manage state iuran warga dengan real-time updates
///
/// Features:
/// - Real-time tagihan updates via Firestore streams
/// - Statistik iuran (tunggakan, lunas, dll)
/// - Pembayaran iuran dengan atomic transaction
/// - Error handling & loading states
///
/// Author: System
/// Created: December 8, 2025
/// ============================================================================

class IuranWargaProvider extends ChangeNotifier {
  final IuranWargaService _service = IuranWargaService();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  // Tagihan lists
  List<TagihanModel> _allTagihan = [];
  List<TagihanModel> _tagihanAktif = [];
  List<TagihanModel> _tagihanTerlambat = [];
  List<TagihanModel> _historyPembayaran = [];

  // Statistics
  Map<String, dynamic> _statistik = {};

  // UI States
  bool _isLoading = false;
  bool _isPaymentProcessing = false;
  String? _errorMessage;
  String? _successMessage;

  // Current keluarga
  String? _currentKeluargaId;

  // Stream subscriptions
  StreamSubscription<List<TagihanModel>>? _allTagihanSubscription;
  StreamSubscription<List<TagihanModel>>? _tagihanAktifSubscription;
  StreamSubscription<List<TagihanModel>>? _tagihanTerlambatSubscription;
  StreamSubscription<List<TagihanModel>>? _historySubscription;

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<TagihanModel> get allTagihan => _allTagihan;
  List<TagihanModel> get tagihanAktif => _tagihanAktif;
  List<TagihanModel> get tagihanTerlambat => _tagihanTerlambat;
  List<TagihanModel> get historyPembayaran => _historyPembayaran;
  Map<String, dynamic> get statistik => _statistik;
  bool get isLoading => _isLoading;
  bool get isPaymentProcessing => _isPaymentProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get currentKeluargaId => _currentKeluargaId;

  // Computed getters
  int get totalTagihan => _allTagihan.length;
  int get totalAktif => _tagihanAktif.length;
  int get totalTerlambat => _tagihanTerlambat.length;
  int get totalLunas => _historyPembayaran.length;

  double get totalTunggakan =>
      (_statistik['totalTunggakan'] as num?)?.toDouble() ?? 0.0;

  double get totalBelumDibayar =>
      (_statistik['totalBelumDibayar'] as num?)?.toDouble() ?? 0.0;

  int get countTunggakan =>
      (_statistik['countTunggakan'] as int?) ?? 0;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize provider dengan keluarga ID
  Future<void> initialize(String keluargaId) async {
    debugPrint('🔵 [IuranWargaProvider] Initializing with keluargaId: $keluargaId');

    _currentKeluargaId = keluargaId;

    // Load all data
    await Future.wait([
      loadAllTagihan(keluargaId),
      loadTagihanAktif(keluargaId),
      loadTagihanTerlambat(keluargaId),
      loadHistoryPembayaran(keluargaId),
      loadStatistik(keluargaId),
    ]);

    debugPrint('✅ [IuranWargaProvider] Initialization complete');
  }

  // ============================================================================
  // LOAD DATA - WITH REAL-TIME STREAMS
  // ============================================================================

  /// Load semua tagihan (dengan real-time updates)
  Future<void> loadAllTagihan(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Loading all tagihan...');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Cancel previous subscription
      await _allTagihanSubscription?.cancel();

      // Listen to real-time stream
      _allTagihanSubscription = _service.getTagihanByKeluarga(keluargaId).listen(
        (tagihan) {
          _allTagihan = tagihan;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          debugPrint('✅ [IuranWargaProvider] All tagihan updated: ${tagihan.length} items');
        },
        onError: (error) {
          _errorMessage = 'Gagal memuat data tagihan: $error';
          _isLoading = false;
          notifyListeners();
          debugPrint('❌ [IuranWargaProvider] Error loading all tagihan: $error');
        },
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat data tagihan: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [IuranWargaProvider] Exception loading all tagihan: $e');
    }
  }

  /// Load tagihan aktif (belum dibayar)
  Future<void> loadTagihanAktif(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Loading tagihan aktif...');

      // Cancel previous subscription
      await _tagihanAktifSubscription?.cancel();

      // Listen to real-time stream
      _tagihanAktifSubscription = _service.getTagihanAktif(keluargaId).listen(
        (tagihan) {
          _tagihanAktif = tagihan;
          notifyListeners();
          debugPrint('✅ [IuranWargaProvider] Tagihan aktif updated: ${tagihan.length} items');
        },
        onError: (error) {
          debugPrint('❌ [IuranWargaProvider] Error loading tagihan aktif: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ [IuranWargaProvider] Exception loading tagihan aktif: $e');
    }
  }

  /// Load tagihan terlambat
  Future<void> loadTagihanTerlambat(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Loading tagihan terlambat...');

      // Cancel previous subscription
      await _tagihanTerlambatSubscription?.cancel();

      // Listen to real-time stream
      _tagihanTerlambatSubscription = _service.getTagihanTerlambat(keluargaId).listen(
        (tagihan) {
          _tagihanTerlambat = tagihan;
          notifyListeners();
          debugPrint('✅ [IuranWargaProvider] Tagihan terlambat updated: ${tagihan.length} items');
        },
        onError: (error) {
          debugPrint('❌ [IuranWargaProvider] Error loading tagihan terlambat: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ [IuranWargaProvider] Exception loading tagihan terlambat: $e');
    }
  }

  /// Load history pembayaran (tagihan lunas)
  Future<void> loadHistoryPembayaran(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Loading history pembayaran...');

      // Cancel previous subscription
      await _historySubscription?.cancel();

      // Listen to real-time stream
      _historySubscription = _service.getHistoryPembayaran(keluargaId).listen(
        (tagihan) {
          _historyPembayaran = tagihan;
          notifyListeners();
          debugPrint('✅ [IuranWargaProvider] History pembayaran updated: ${tagihan.length} items');
        },
        onError: (error) {
          debugPrint('❌ [IuranWargaProvider] Error loading history: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ [IuranWargaProvider] Exception loading history: $e');
    }
  }

  /// Load statistik iuran
  Future<void> loadStatistik(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Loading statistik...');

      final stats = await _service.getStatistikIuran(keluargaId);
      _statistik = stats;
      notifyListeners();

      debugPrint('✅ [IuranWargaProvider] Statistik loaded');
    } catch (e) {
      debugPrint('❌ [IuranWargaProvider] Error loading statistik: $e');
    }
  }

  // ============================================================================
  // PEMBAYARAN IURAN
  // ============================================================================

  /// ⭐ Bayar iuran - CRITICAL OPERATION ⭐
  Future<bool> bayarIuran({
    required String tagihanId,
    required String metodePembayaran,
    String? buktiPembayaran,
    String? catatan,
    required String userId,
  }) async {
    try {
      debugPrint('\n🔵 [IuranWargaProvider] ===== BAYAR IURAN START =====');
      debugPrint('📝 TagihanId: $tagihanId');
      debugPrint('💳 Metode: $metodePembayaran');

      // Set loading state
      _isPaymentProcessing = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Call service to process payment (atomic transaction)
      final keuanganId = await _service.bayarIuran(
        tagihanId: tagihanId,
        metodePembayaran: metodePembayaran,
        buktiPembayaran: buktiPembayaran,
        catatan: catatan,
        userId: userId,
      );

      // Success!
      _successMessage = 'Pembayaran berhasil!';
      _isPaymentProcessing = false;

      // Refresh statistik after payment
      if (_currentKeluargaId != null) {
        await loadStatistik(_currentKeluargaId!);
      }

      notifyListeners();

      debugPrint('✅ [IuranWargaProvider] ===== BAYAR IURAN SUCCESS =====');
      debugPrint('📄 Keuangan ID: $keuanganId\n');

      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Gagal melakukan pembayaran: ${e.toString()}';
      _isPaymentProcessing = false;
      notifyListeners();

      debugPrint('❌ [IuranWargaProvider] ===== BAYAR IURAN FAILED =====');
      debugPrint('❌ Error: $e');
      debugPrint('❌ StackTrace: $stackTrace\n');

      return false;
    }
  }

  /// Upload bukti pembayaran
  Future<String?> uploadBuktiPembayaran({
    required String tagihanId,
    required String imagePath,
  }) async {
    try {
      debugPrint('🔵 [IuranWargaProvider] Uploading bukti pembayaran...');

      final url = await _service.uploadBuktiPembayaran(
        tagihanId: tagihanId,
        imagePath: imagePath,
      );

      debugPrint('✅ [IuranWargaProvider] Bukti uploaded: $url');
      return url;
    } catch (e) {
      _errorMessage = 'Gagal upload bukti pembayaran: $e';
      notifyListeners();
      debugPrint('❌ [IuranWargaProvider] Error uploading bukti: $e');
      return null;
    }
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /// Get tagihan by ID from local cache
  TagihanModel? getTagihanById(String tagihanId) {
    try {
      return _allTagihan.firstWhere((t) => t.id == tagihanId);
    } catch (e) {
      return null;
    }
  }

  /// Check if has tunggakan
  bool get hasTunggakan => countTunggakan > 0;

  /// Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    if (_currentKeluargaId != null) {
      await loadStatistik(_currentKeluargaId!);
    }
  }

  // ============================================================================
  // DISPOSE
  // ============================================================================

  @override
  void dispose() {
    debugPrint('🔵 [IuranWargaProvider] Disposing...');

    // Cancel all stream subscriptions
    _allTagihanSubscription?.cancel();
    _tagihanAktifSubscription?.cancel();
    _tagihanTerlambatSubscription?.cancel();
    _historySubscription?.cancel();

    super.dispose();
  }
}
