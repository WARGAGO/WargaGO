import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pending_warga_model.dart';

/// Repository untuk CRUD Pending Warga (Terima Warga)
class PendingWargaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pending_warga';

  /// Get all pending warga (real-time stream)
  Stream<List<PendingWargaModel>> getAllPendingWarga() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      // Convert to list and sort in memory to avoid composite index requirement
      final pendingList = snapshot.docs
          .map((doc) => PendingWargaModel.fromFirestore(doc))
          .toList();

      // Sort by createdAt descending (newest first)
      pendingList.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return pendingList;
    });
  }

  /// Get pending warga by ID
  Future<PendingWargaModel?> getPendingWargaById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return PendingWargaModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getPendingWargaById: $e');
      return null;
    }
  }

  /// Get count pending warga
  Future<int> getCountPending() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getCountPending: $e');
      return 0;
    }
  }

  /// Create pending warga (untuk pendaftaran warga baru)
  Future<String?> createPendingWarga(PendingWargaModel warga) async {
    try {
      final docRef = await _firestore.collection(_collection).add(warga.toFirestore());
      print('✅ Pending warga created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createPendingWarga: $e');
      return null;
    }
  }

  /// Approve pending warga (pindahkan ke collection 'warga')
  Future<bool> approvePendingWarga(String id, String approvedBy) async {
    try {
      // Get pending warga data
      final pendingWarga = await getPendingWargaById(id);
      if (pendingWarga == null) {
        throw Exception('Pending warga tidak ditemukan');
      }

      // Add to 'warga' collection
      await _firestore.collection('warga').add({
        'name': pendingWarga.name,
        'nik': pendingWarga.nik,
        'jenisKelamin': pendingWarga.jenisKelamin,
        'tanggalLahir': Timestamp.fromDate(pendingWarga.tanggalLahir),
        'tempatLahir': pendingWarga.tempatLahir,
        'agama': pendingWarga.agama,
        'statusPerkawinan': pendingWarga.statusPerkawinan,
        'pekerjaan': pendingWarga.pekerjaan,
        'kewarganegaraan': pendingWarga.kewarganegaraan,
        'golonganDarah': pendingWarga.golonganDarah,
        'alamat': pendingWarga.alamat,
        'rt': pendingWarga.rt,
        'rw': pendingWarga.rw,
        'nomorKK': pendingWarga.nomorKK,
        'peranKeluarga': pendingWarga.hubunganKeluarga,
        'pendidikan': pendingWarga.pendidikan,
        'noTelepon': pendingWarga.noTelepon,
        'email': pendingWarga.email,
        'status': 'aktif',
        'fotoUrl': pendingWarga.fotoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': approvedBy,
      });

      // Update status di pending_warga collection
      await _firestore.collection(_collection).doc(id).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': approvedBy,
      });

      print('✅ Pending warga approved: $id');
      return true;
    } catch (e) {
      print('❌ Error approvePendingWarga: $e');
      return false;
    }
  }

  /// Reject pending warga
  Future<bool> rejectPendingWarga(String id, String alasanPenolakan, String rejectedBy) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'status': 'rejected',
        'alasanPenolakan': alasanPenolakan,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': rejectedBy,
      });

      print('✅ Pending warga rejected: $id');
      return true;
    } catch (e) {
      print('❌ Error rejectPendingWarga: $e');
      return false;
    }
  }

  /// Delete pending warga
  Future<bool> deletePendingWarga(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Pending warga deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deletePendingWarga: $e');
      return false;
    }
  }

  /// Search pending warga by nama or NIK
  Stream<List<PendingWargaModel>> searchPendingWarga(String query) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      final allPending = snapshot.docs
          .map((doc) => PendingWargaModel.fromFirestore(doc))
          .toList();

      // Filter by nama or NIK
      return allPending.where((warga) {
        final namaLower = warga.name.toLowerCase();
        final nikLower = warga.nik.toLowerCase();
        final queryLower = query.toLowerCase();
        return namaLower.contains(queryLower) || nikLower.contains(queryLower);
      }).toList();
    });
  }

  /// Get history (approved & rejected)
  Stream<List<PendingWargaModel>> getHistory() {
    return _firestore
        .collection(_collection)
        .where('status', whereIn: ['approved', 'rejected'])
        .snapshots()
        .map((snapshot) {
      // Convert to list and sort in memory to avoid composite index requirement
      final history = snapshot.docs
          .map((doc) => PendingWargaModel.fromFirestore(doc))
          .toList();

      // Sort by approvedAt descending (newest first)
      history.sort((a, b) {
        if (a.approvedAt == null && b.approvedAt == null) return 0;
        if (a.approvedAt == null) return 1;
        if (b.approvedAt == null) return -1;
        return b.approvedAt!.compareTo(a.approvedAt!);
      });

      return history;
    });
  }
}

