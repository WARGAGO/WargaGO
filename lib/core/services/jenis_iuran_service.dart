import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/models/jenis_iuran_model.dart';
import 'firebase_service.dart';

/// Jenis Iuran Service
/// Service khusus untuk operasi CRUD jenis iuran di Firestore
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya handle data jenis iuran
/// - Separation of Concerns: Pisah dari UI logic
class JenisIuranService {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  static const String _collection = 'jenis_iuran';

  // ============================================================================
  // CREATE
  // ============================================================================

  /// Create jenis iuran baru
  Future<String?> createJenisIuran(JenisIuranModel jenisIuran) async {
    try {
      print('=== JenisIuranService: createJenisIuran ===');
      print('Creating jenis iuran: ${jenisIuran.namaIuran}');

      final data = jenisIuran.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection(_collection).add(data);

      print('✅ Jenis iuran created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createJenisIuran: $e');
      rethrow;
    }
  }

  // ============================================================================
  // READ
  // ============================================================================

  /// Get all jenis iuran
  Future<List<JenisIuranModel>> getAllJenisIuran() async {
    try {
      print('=== JenisIuranService: getAllJenisIuran ===');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      final jenisIuranList = querySnapshot.docs
          .map((doc) => JenisIuranModel.fromFirestore(doc))
          .toList();

      // Sort locally
      jenisIuranList.sort((a, b) => a.namaIuran.compareTo(b.namaIuran));

      print('✅ Found ${jenisIuranList.length} jenis iuran');
      for (var item in jenisIuranList) {
        print('   - ${item.namaIuran} (Rp ${item.jumlahIuran})');
      }
      return jenisIuranList;
    } catch (e) {
      print('❌ Error getAllJenisIuran: $e');
      return [];
    }
  }

  /// Stream all jenis iuran
  Stream<List<JenisIuranModel>> streamAllJenisIuran() {
    try {
      print('=== JenisIuranService: streamAllJenisIuran ===');

      return _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => JenisIuranModel.fromFirestore(doc))
            .toList();

        // Sort locally
        list.sort((a, b) => a.namaIuran.compareTo(b.namaIuran));

        return list;
      });
    } catch (e) {
      print('❌ Error streamAllJenisIuran: $e');
      return Stream.value([]);
    }
  }

  /// Get jenis iuran by ID
  Future<JenisIuranModel?> getJenisIuranById(String id) async {
    try {
      print('=== JenisIuranService: getJenisIuranById ===');
      print('ID: $id');

      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        print('❌ Jenis iuran not found');
        return null;
      }

      final jenisIuran = JenisIuranModel.fromFirestore(doc);
      print('✅ Jenis iuran found: ${jenisIuran.namaIuran}');
      return jenisIuran;
    } catch (e) {
      print('❌ Error getJenisIuranById: $e');
      return null;
    }
  }

  /// Search jenis iuran by name
  Future<List<JenisIuranModel>> searchJenisIuran(String query) async {
    try {
      print('=== JenisIuranService: searchJenisIuran ===');
      print('Query: $query');

      if (query.isEmpty) {
        return getAllJenisIuran();
      }

      final queryLower = query.toLowerCase();
      final allJenisIuran = await getAllJenisIuran();

      return allJenisIuran.where((jenisIuran) {
        return jenisIuran.namaIuran.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      print('❌ Error searchJenisIuran: $e');
      return [];
    }
  }

  /// Get jenis iuran by kategori
  Future<List<JenisIuranModel>> getJenisIuranByKategori(String kategori) async {
    try {
      print('=== JenisIuranService: getJenisIuranByKategori ===');
      print('Kategori: $kategori');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('kategoriIuran', isEqualTo: kategori)
          .get();

      final jenisIuranList = querySnapshot.docs
          .map((doc) => JenisIuranModel.fromFirestore(doc))
          .toList();

      // Sort locally
      jenisIuranList.sort((a, b) => a.namaIuran.compareTo(b.namaIuran));

      print('✅ Found ${jenisIuranList.length} jenis iuran for kategori $kategori');
      return jenisIuranList;
    } catch (e) {
      print('❌ Error getJenisIuranByKategori: $e');
      return [];
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================

  /// Update jenis iuran
  Future<bool> updateJenisIuran(JenisIuranModel jenisIuran) async {
    try {
      print('=== JenisIuranService: updateJenisIuran ===');
      print('Updating jenis iuran: ${jenisIuran.id}');

      final data = jenisIuran.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(jenisIuran.id)
          .update(data);

      print('✅ Jenis iuran updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updateJenisIuran: $e');
      return false;
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================

  /// Delete jenis iuran (soft delete)
  Future<bool> deleteJenisIuran(String id) async {
    try {
      print('=== JenisIuranService: deleteJenisIuran ===');
      print('Deleting jenis iuran: $id');

      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Jenis iuran deleted (soft delete)');
      return true;
    } catch (e) {
      print('❌ Error deleteJenisIuran: $e');
      return false;
    }
  }

  /// Hard delete jenis iuran
  Future<bool> hardDeleteJenisIuran(String id) async {
    try {
      print('=== JenisIuranService: hardDeleteJenisIuran ===');
      print('Hard deleting jenis iuran: $id');

      await _firestore.collection(_collection).doc(id).delete();

      print('✅ Jenis iuran hard deleted');
      return true;
    } catch (e) {
      print('❌ Error hardDeleteJenisIuran: $e');
      return false;
    }
  }

  // ============================================================================
  // STATISTICS
  // ============================================================================

  /// Get total jenis iuran count
  Future<int> getTotalJenisIuranCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getTotalJenisIuranCount: $e');
      return 0;
    }
  }

  /// Get count by kategori
  Future<Map<String, int>> getCountByKategori() async {
    try {
      final bulananSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('kategoriIuran', isEqualTo: 'bulanan')
          .count()
          .get();

      final khususSnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('kategoriIuran', isEqualTo: 'khusus')
          .count()
          .get();

      return {
        'bulanan': bulananSnapshot.count ?? 0,
        'khusus': khususSnapshot.count ?? 0,
      };
    } catch (e) {
      print('❌ Error getCountByKategori: $e');
      return {'bulanan': 0, 'khusus': 0};
    }
  }
}
