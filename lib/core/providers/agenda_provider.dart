import 'package:flutter/foundation.dart';
import '../models/agenda_model.dart';
import '../services/agenda_service.dart';

/// Provider untuk mengelola state Agenda
class AgendaProvider with ChangeNotifier {
  final AgendaService _service = AgendaService();

  List<AgendaModel> _agendaList = [];
  List<AgendaModel> _kegiatanList = [];
  List<AgendaModel> _broadcastList = [];
  List<AgendaModel> _upcomingList = [];

  bool _isLoading = false;
  String? _error;
  String _selectedType = 'Semua'; // 'Semua', 'kegiatan', 'broadcast'

  // Getters
  List<AgendaModel> get agendaList => _agendaList;
  List<AgendaModel> get kegiatanList => _kegiatanList;
  List<AgendaModel> get broadcastList => _broadcastList;
  List<AgendaModel> get upcomingList => _upcomingList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedType => _selectedType;

  Stream<List<AgendaModel>>? _agendaStream;

  /// Load agenda berdasarkan filter
  void loadAgenda({String? type}) {
    _selectedType = type ?? 'Semua';

    if (_selectedType == 'Semua') {
      _agendaStream = _service.getAgendaStream();
    } else {
      _agendaStream = _service.getAgendaByTypeStream(_selectedType);
    }

    _agendaStream!.listen(
      (agendaList) {
        _agendaList = agendaList;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        debugPrint('❌ Error loading agenda: $error');
        notifyListeners();
      },
    );
  }

  /// Load kegiatan only
  void loadKegiatan() {
    _service.getAgendaByTypeStream('kegiatan').listen(
      (list) {
        _kegiatanList = list;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error loading kegiatan: $error');
      },
    );
  }

  /// Load broadcast only
  void loadBroadcast() {
    _service.getAgendaByTypeStream('broadcast').listen(
      (list) {
        _broadcastList = list;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error loading broadcast: $error');
      },
    );
  }

  /// Load upcoming agenda
  void loadUpcomingAgenda() {
    _service.getUpcomingAgendaStream().listen(
      (list) {
        _upcomingList = list;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Error loading upcoming agenda: $error');
      },
    );
  }

  /// Create agenda
  Future<bool> createAgenda(AgendaModel agenda) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.createAgenda(agenda);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error creating agenda: $e');
      return false;
    }
  }

  /// Update agenda
  Future<bool> updateAgenda(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.updateAgenda(id, data);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error updating agenda: $e');
      return false;
    }
  }

  /// Delete agenda (soft delete)
  Future<bool> deleteAgenda(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteAgenda(id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ Error deleting agenda: $e');
      return false;
    }
  }

  /// Get agenda by ID
  Future<AgendaModel?> getAgendaById(String id) async {
    try {
      return await _service.getAgendaById(id);
    } catch (e) {
      debugPrint('❌ Error getting agenda by ID: $e');
      return null;
    }
  }

  /// Set filter type
  void setFilterType(String type) {
    _selectedType = type;
    loadAgenda(type: type);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _agendaStream = null;
    super.dispose();
  }
}

