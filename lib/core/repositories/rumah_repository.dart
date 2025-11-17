import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rumah_model.dart';

/// Repository untuk CRUD Rumah
/// Handles all database operations for Rumah collection
class RumahRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rumah';

  /// Get all rumah (real-time stream)
  Stream<List<RumahModel>> getAllRumah() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RumahModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get rumah by ID
  Future<RumahModel?> getRumahById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return RumahModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getRumahById: $e');
      return null;
    }
  }

  /// Create rumah baru
  Future<String?> createRumah(RumahModel rumah) async {
    try {
      final docRef = await _firestore.collection(_collection).add(rumah.toFirestore());
      print('✅ Rumah created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createRumah: $e');
      return null;
    }
  }

  /// Update rumah
  Future<bool> updateRumah(String id, RumahModel rumah) async {
    try {
      await _firestore.collection(_collection).doc(id).update(rumah.toFirestore());
      print('✅ Rumah updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updateRumah: $e');
      return false;
    }
  }

  /// Delete rumah
  Future<bool> deleteRumah(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Rumah deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deleteRumah: $e');
      return false;
    }
  }

  /// Get count rumah
  Future<int> getCountRumah() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getCountRumah: $e');
      return 0;
    }
  }

  /// Search rumah by alamat
  Stream<List<RumahModel>> searchRumah(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('alamat')
        .snapshots()
        .map((snapshot) {
      final allRumah = snapshot.docs
          .map((doc) => RumahModel.fromFirestore(doc))
          .toList();

      // Filter by alamat
      return allRumah.where((rumah) {
        final alamatLower = rumah.alamat.toLowerCase();
        final queryLower = query.toLowerCase();
        return alamatLower.contains(queryLower);
      }).toList();
    });
  }
}

