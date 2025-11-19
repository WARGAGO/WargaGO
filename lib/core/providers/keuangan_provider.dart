import 'package:flutter/foundation.dart';
import '../models/keuangan_model.dart';
import '../services/keuangan_service.dart';

/// Provider untuk mengelola state Keuangan
class KeuanganProvider with ChangeNotifier {
  final KeuanganService _service = KeuanganService();

  List<KeuanganModel> _transaksiList = [];
  Map<String, double> _saldo = {};
  bool _isLoading = false;
  String? _error;

  List<KeuanganModel> get transaksiList => _transaksiList;
  Map<String, double> get saldo => _saldo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadTransaksi() {
    _service.getTransaksiStream().listen((list) {
      _transaksiList = list;
      notifyListeners();
    });
  }

  Future<void> loadSaldo() async {
    _saldo = await _service.getSaldo();
    notifyListeners();
  }

  Future<bool> createTransaksi(KeuanganModel transaksi) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _service.createTransaksi(transaksi);
      await loadSaldo();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

