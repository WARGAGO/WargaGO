import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/models/warga_model.dart';
import 'firebase_service.dart';

/// Warga Service
/// Service khusus untuk operasi CRUD data warga di Firestore
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya handle data warga
/// - Separation of Concerns: Pisah dari UI logic
class WargaService {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  static const String _collection = 'warga';

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Create warga baru
  Future<String?> createWarga(WargaModel warga) async {
    try {
      print('=== WargaService: createWarga ===');
      print('Creating warga: ${warga.name}');

      final data = warga.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection(_collection).add(data);

      print('✅ Warga created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createWarga: $e');
      rethrow;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get all warga
  Future<List<WargaModel>> getAllWarga() async {
    try {
      print('=== WargaService: getAllWarga ===');

      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();

      final wargaList = querySnapshot.docs
          .map((doc) => WargaModel.fromFirestore(doc))
          .toList();

      print('✅ Found ${wargaList.length} warga');
      return wargaList;
    } catch (e) {
      print('❌ Error getAllWarga: $e');
      return [];
    }
  }

  /// Get warga by ID
  Future<WargaModel?> getWargaById(String id) async {
    try {
      print('=== WargaService: getWargaById ===');
      print('ID: $id');

      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        print('❌ Warga not found');
        return null;
      }

      final warga = WargaModel.fromFirestore(doc);
      print('✅ Warga found: ${warga.name}');
      return warga;
    } catch (e) {
      print('❌ Error getWargaById: $e');
      return null;
    }
  }

  /// Search warga by name or NIK
  Future<List<WargaModel>> searchWarga(String query) async {
    try {
      print('=== WargaService: searchWarga ===');
      print('Query: $query');

      if (query.isEmpty) {
        return getAllWarga();
      }

      final queryLower = query.toLowerCase();

      // Get all warga and filter locally (Firestore doesn't support full-text search)
      final allWarga = await getAllWarga();

      final filtered = allWarga.where((warga) {
        return warga.name.toLowerCase().contains(queryLower) ||
               warga.nik.toLowerCase().contains(queryLower);
      }).toList();

      print('✅ Found ${filtered.length} matching warga');
      return filtered;
    } catch (e) {
      print('❌ Error searchWarga: $e');
      return [];
    }
  }

  /// Get warga by status (filter aktif/non-aktif)
  Future<List<WargaModel>> getWargaByStatus(String status) async {
    try {
      print('=== WargaService: getWargaByStatus ===');
      print('Status: $status');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('statusPenduduk', isEqualTo: status)
          .orderBy('name')
          .get();

      final wargaList = querySnapshot.docs
          .map((doc) => WargaModel.fromFirestore(doc))
          .toList();

      print('✅ Found ${wargaList.length} warga with status $status');
      return wargaList;
    } catch (e) {
      print('❌ Error getWargaByStatus: $e');
      return [];
    }
  }

  /// Get warga by gender
  Future<List<WargaModel>> getWargaByGender(String gender) async {
    try {
      print('=== WargaService: getWargaByGender ===');
      print('Gender: $gender');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('jenisKelamin', isEqualTo: gender)
          .orderBy('name')
          .get();

      final wargaList = querySnapshot.docs
          .map((doc) => WargaModel.fromFirestore(doc))
          .toList();

      print('✅ Found ${wargaList.length} warga with gender $gender');
      return wargaList;
    } catch (e) {
      print('❌ Error getWargaByGender: $e');
      return [];
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update warga
  Future<bool> updateWarga(String id, WargaModel warga) async {
    try {
      print('=== WargaService: updateWarga ===');
      print('ID: $id');
      print('Name: ${warga.name}');

      final data = warga.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(id).update(data);

      print('✅ Warga updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updateWarga: $e');
      rethrow;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete warga
  Future<bool> deleteWarga(String id) async {
    try {
      print('=== WargaService: deleteWarga ===');
      print('ID: $id');

      await _firestore.collection(_collection).doc(id).delete();

      print('✅ Warga deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleteWarga: $e');
      rethrow;
    }
  }

  /// Soft delete warga (ubah status jadi non-aktif)
  Future<bool> softDeleteWarga(String id) async {
    try {
      print('=== WargaService: softDeleteWarga ===');
      print('ID: $id');

      await _firestore.collection(_collection).doc(id).update({
        'statusPenduduk': 'Nonaktif',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Warga soft deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error softDeleteWarga: $e');
      rethrow;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get total warga count
  Future<int> getTotalWarga() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('❌ Error getTotalWarga: $e');
      return 0;
    }
  }

  /// Get warga count by gender
  Future<Map<String, int>> getWargaCountByGender() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      int lakiLaki = 0;
      int perempuan = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final gender = data['jenisKelamin'] ?? '';

        if (gender.toLowerCase().contains('laki')) {
          lakiLaki++;
        } else if (gender.toLowerCase().contains('perempuan')) {
          perempuan++;
        }
      }

      return {
        'laki_laki': lakiLaki,
        'perempuan': perempuan,
      };
    } catch (e) {
      print('❌ Error getWargaCountByGender: $e');
      return {'laki_laki': 0, 'perempuan': 0};
    }
  }

  // ============================================================================
  // REALTIME STREAM
  // ============================================================================

  /// Stream all warga (realtime)
  Stream<List<WargaModel>> streamAllWarga() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WargaModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Stream warga by ID (realtime)
  Stream<WargaModel?> streamWargaById(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return WargaModel.fromFirestore(doc);
    });
  }
}

