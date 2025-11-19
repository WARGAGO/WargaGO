import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/pemasukan_lain_model.dart';

class PemasukanLainService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pemasukan_lain';

  Future<String> createPemasukanLain(PemasukanLainModel pemasukan) async {
    try {
      final data = pemasukan.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      final docRef = await _firestore.collection(_collection).add(data);
      debugPrint('Pemasukan lain created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating pemasukan lain: $e');
      rethrow;
    }
  }

  Stream<List<PemasukanLainModel>> getPemasukanLainStream() {
    return _firestore.collection(_collection).where('isActive', isEqualTo: true).orderBy('tanggal', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PemasukanLainModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<PemasukanLainModel>> getPemasukanLainByStatusStream(String status) {
    return _firestore.collection(_collection).where('status', isEqualTo: status).where('isActive', isEqualTo: true).orderBy('tanggal', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PemasukanLainModel.fromFirestore(doc)).toList();
    });
  }

  Future<PemasukanLainModel?> getPemasukanLainById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return PemasukanLainModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting pemasukan lain: $e');
      return null;
    }
  }

  Future<void> updatePemasukanLain(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(id).update(data);
      debugPrint('Pemasukan lain updated: $id');
    } catch (e) {
      debugPrint('Error updating pemasukan lain: $e');
      rethrow;
    }
  }

  Future<void> verifikasiPemasukan(String id, bool approved) async {
    try {
      await _firestore.collection(_collection).doc(id).update({'status': approved ? 'Terverifikasi' : 'Ditolak', 'updatedAt': FieldValue.serverTimestamp()});
      debugPrint('Pemasukan lain verified: $id');
    } catch (e) {
      debugPrint('Error verifying pemasukan lain: $e');
      rethrow;
    }
  }

  Future<void> deletePemasukanLain(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({'isActive': false, 'updatedAt': FieldValue.serverTimestamp()});
      debugPrint('Pemasukan lain deleted: $id');
    } catch (e) {
      debugPrint('Error deleting pemasukan lain: $e');
      rethrow;
    }
  }

  Future<double> getTotalPemasukanTerverifikasi() async {
    try {
      final snapshot = await _firestore.collection(_collection).where('status', isEqualTo: 'Terverifikasi').where('isActive', isEqualTo: true).get();
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nominal = (data['nominal'] as num?)?.toDouble() ?? 0;
        total += nominal;
      }
      return total;
    } catch (e) {
      debugPrint('Error getting total pemasukan: $e');
      return 0;
    }
  }
}

