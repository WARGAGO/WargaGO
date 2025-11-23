import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mutasi_model.dart';

/// Repository untuk CRUD Mutasi
class MutasiRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'mutasi';

  /// Get all mutasi (real-time stream)
  Stream<List<MutasiModel>> getAllMutasi() {
    return _firestore
        .collection(_collection)
        .orderBy('tanggalMutasi', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MutasiModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get mutasi by jenis (Masuk/Keluar)
  Stream<List<MutasiModel>> getMutasiByJenis(String jenisMutasi) {
    return _firestore
        .collection(_collection)
        .where('jenisMutasi', isEqualTo: jenisMutasi)
        .orderBy('tanggalMutasi', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MutasiModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get mutasi by ID
  Future<MutasiModel?> getMutasiById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return MutasiModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getMutasiById: $e');
      return null;
    }
  }

  /// Create mutasi baru
  Future<String?> createMutasi(MutasiModel mutasi) async {
    try {
      final docRef = await _firestore.collection(_collection).add(mutasi.toFirestore());
      print('✅ Mutasi created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createMutasi: $e');
      return null;
    }
  }

  /// Update mutasi
  Future<bool> updateMutasi(String id, MutasiModel mutasi) async {
    try {
      await _firestore.collection(_collection).doc(id).update(mutasi.toFirestore());
      print('✅ Mutasi updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updateMutasi: $e');
      return false;
    }
  }

  /// Delete mutasi
  Future<bool> deleteMutasi(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Mutasi deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleteMutasi: $e');
      return false;
    }
  }

  /// Get count mutasi masuk
  Future<int> getCountMutasiMasuk() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('jenisMutasi', isEqualTo: 'Mutasi Masuk')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getCountMutasiMasuk: $e');
      return 0;
    }
  }

  /// Get count mutasi keluar
  Future<int> getCountMutasiKeluar() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('jenisMutasi', whereIn: ['Keluar Perumahan', 'Pindah Rumah'])
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getCountMutasiKeluar: $e');
      return 0;
    }
  }

  /// Search mutasi by nama or NIK
  Stream<List<MutasiModel>> searchMutasi(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('nama')
        .snapshots()
        .map((snapshot) {
      final allMutasi = snapshot.docs
          .map((doc) => MutasiModel.fromFirestore(doc))
          .toList();

      // Filter by nama or NIK
      return allMutasi.where((mutasi) {
        final namaLower = mutasi.nama.toLowerCase();
        final nikLower = mutasi.nik.toLowerCase();
        final queryLower = query.toLowerCase();
        return namaLower.contains(queryLower) || nikLower.contains(queryLower);
      }).toList();
    });
  }
}

