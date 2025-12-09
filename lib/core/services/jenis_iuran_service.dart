import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wargago/core/models/jenis_iuran_model.dart';
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

  /// Create jenis iuran baru + Auto Generate Tagihan untuk semua warga
  Future<String?> createJenisIuran(JenisIuranModel jenisIuran) async {
    try {
      print('=== JenisIuranService: createJenisIuran ===');
      print('Creating jenis iuran: ${jenisIuran.namaIuran}');

      final data = jenisIuran.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection(_collection).add(data);
      final jenisIuranId = docRef.id;

      print('✅ Jenis iuran created with ID: $jenisIuranId');

      // 🆕 AUTO-GENERATE TAGIHAN untuk semua warga
      await _autoGenerateTagihanForAllWarga(jenisIuranId, jenisIuran);

      return jenisIuranId;
    } catch (e) {
      print('❌ Error createJenisIuran: $e');
      rethrow;
    }
  }

  /// Auto-generate tagihan untuk semua keluarga
  Future<void> _autoGenerateTagihanForAllWarga(
    String jenisIuranId,
    JenisIuranModel jenisIuran,
  ) async {
    try {
      print('🔄 Auto-generating tagihan for all keluarga...');

      // Get all data_penduduk yang punya keluargaId
      final pendudukSnapshot = await _firestore
          .collection('data_penduduk')
          .where('status', isEqualTo: 'Terverifikasi')
          .get();

      // Collect unique keluargaId
      final Set<String> keluargaIds = {};
      for (var doc in pendudukSnapshot.docs) {
        final keluargaId = doc.data()['keluargaId'] as String?;
        if (keluargaId != null && keluargaId.isNotEmpty) {
          keluargaIds.add(keluargaId);
        }
      }

      print('📊 Found ${keluargaIds.length} unique keluarga to bill');

      // Generate tagihan untuk setiap keluarga
      final batch = _firestore.batch();
      int count = 0;

      for (final keluargaId in keluargaIds) {
        final tagihanRef = _firestore.collection('tagihan').doc();

        // Calculate deadline based on kategori
        final now = DateTime.now();
        final deadline = jenisIuran.kategoriIuran == 'bulanan'
            ? DateTime(now.year, now.month + 1, 0) // End of next month
            : DateTime(now.year, now.month, now.day + 30); // 30 days from now

        final tagihanData = {
          'jenisIuranId': jenisIuranId,
          'jenisIuranNama': jenisIuran.namaIuran,
          'keluargaId': keluargaId,
          'nominal': jenisIuran.jumlahIuran,
          'status': 'Belum Dibayar',
          'periodeTanggal': Timestamp.fromDate(now),
          'deadline': Timestamp.fromDate(deadline),
          'tanggalBayar': null,
          'metodePembayaran': null,
          'buktiPembayaran': null,
          'catatan': 'Auto-generated dari jenis iuran: ${jenisIuran.namaIuran}',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        batch.set(tagihanRef, tagihanData);
        count++;

        // Commit in batches of 500 (Firestore limit)
        if (count % 500 == 0) {
          await batch.commit();
          print('✅ Committed batch of 500 tagihan');
        }
      }

      // Commit remaining
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('✅ Successfully generated $count tagihan for all keluarga!');
    } catch (e) {
      print('❌ Error auto-generating tagihan: $e');
      // Don't throw - jenis iuran already created, tagihan generation is bonus
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
