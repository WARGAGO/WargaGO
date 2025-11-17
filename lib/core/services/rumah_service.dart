import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/models/rumah_model.dart';
import 'firebase_service.dart';

/// Rumah Service
/// Service khusus untuk operasi CRUD data rumah di Firestore
class RumahService {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  static const String _collection = 'rumah';

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Create rumah baru
  Future<String?> createRumah(RumahModel rumah) async {
    try {
      print('=== RumahService: createRumah ===');
      print('Creating rumah: ${rumah.alamat}');

      final data = rumah.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection(_collection).add(data);

      print('✅ Rumah created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createRumah: $e');
      rethrow;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get all rumah
  Future<List<RumahModel>> getAllRumah() async {
    try {
      print('=== RumahService: getAllRumah ===');

      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('alamat')
          .get();

      final rumahList = querySnapshot.docs
          .map((doc) => RumahModel.fromFirestore(doc))
          .toList();

      print('✅ Found ${rumahList.length} rumah');
      return rumahList;
    } catch (e) {
      print('❌ Error getAllRumah: $e');
      return [];
    }
  }

  /// Get rumah by ID
  Future<RumahModel?> getRumahById(String id) async {
    try {
      print('=== RumahService: getRumahById ===');
      print('ID: $id');

      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        print('❌ Rumah not found');
        return null;
      }

      final rumah = RumahModel.fromFirestore(doc);
      print('✅ Rumah found: ${rumah.alamat}');
      return rumah;
    } catch (e) {
      print('❌ Error getRumahById: $e');
      return null;
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update rumah
  Future<bool> updateRumah(String id, RumahModel rumah) async {
    try {
      print('=== RumahService: updateRumah ===');
      print('ID: $id');

      final data = rumah.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(id).update(data);

      print('✅ Rumah updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updateRumah: $e');
      rethrow;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete rumah
  Future<bool> deleteRumah(String id) async {
    try {
      print('=== RumahService: deleteRumah ===');
      print('ID: $id');

      await _firestore.collection(_collection).doc(id).delete();

      print('✅ Rumah deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleteRumah: $e');
      rethrow;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get total rumah count
  Future<int> getTotalRumah() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Error getTotalRumah: $e');
      return 0;
    }
  }

  // ============================================================================
  // REALTIME STREAM
  // ============================================================================

  /// Stream all rumah (realtime)
  Stream<List<RumahModel>> streamAllRumah() {
    return _firestore
        .collection(_collection)
        .orderBy('alamat')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RumahModel.fromFirestore(doc))
          .toList();
    });
  }
}

