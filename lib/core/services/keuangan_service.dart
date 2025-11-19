import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/keuangan_model.dart';
class KeuanganService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'keuangan';
  Future<String> createTransaksi(KeuanganModel transaksi) async {
    try {
      final data = transaksi.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(_collection).add(data);
      debugPrint('Transaksi created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
  Stream<List<KeuanganModel>> getTransaksiStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KeuanganModel.fromFirestore(doc))
          .toList();
    });
  }
  Stream<List<KeuanganModel>> getTransaksiByTypeStream(String type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .where('isActive', isEqualTo: true)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => KeuanganModel.fromFirestore(doc))
          .toList();
    });
  }
  Future<KeuanganModel?> getTransaksiById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return KeuanganModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
  Future<void> updateTransaksi(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(id).update(data);
      debugPrint('Updated: $id');
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
  Future<void> deleteTransaksi(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Deleted: $id');
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
  Future<Map<String, double>> getSaldo() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      double totalPemasukan = 0;
      double totalPengeluaran = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final type = data['type'] as String?;
        if (type == 'pemasukan') {
          totalPemasukan += amount;
        } else if (type == 'pengeluaran') {
          totalPengeluaran += amount;
        }
      }
      return {
        'pemasukan': totalPemasukan,
        'pengeluaran': totalPengeluaran,
        'saldo': totalPemasukan - totalPengeluaran,
      };
    } catch (e) {
      debugPrint('Error: $e');
      return {
        'pemasukan': 0,
        'pengeluaran': 0,
        'saldo': 0,
      };
    }
  }
  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      double totalPemasukan = 0;
      double totalPengeluaran = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final type = data['type'] as String?;
        if (type == 'pemasukan') {
          totalPemasukan += amount;
        } else if (type == 'pengeluaran') {
          totalPengeluaran += amount;
        }
      }
      return {
        'pemasukan': totalPemasukan,
        'pengeluaran': totalPengeluaran,
        'saldo': totalPemasukan - totalPengeluaran,
      };
    } catch (e) {
      debugPrint('Error: $e');
      return {
        'pemasukan': 0,
        'pengeluaran': 0,
        'saldo': 0,
      };
    }
  }
}
