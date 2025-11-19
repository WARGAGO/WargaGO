import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tagihan_model.dart';

/// Service untuk mengelola operasi CRUD Tagihan di Firestore
class TagihanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tagihan';

  // Generate kode tagihan otomatis
  Future<String> _generateKodeTagihan() async {
    try {
      final now = DateTime.now();
      final year = now.year.toString().substring(2);
      final month = now.month.toString().padLeft(2, '0');

      // Get count untuk nomor urut
      final snapshot = await _firestore
          .collection(_collection)
          .where('kodeTagihan', isGreaterThanOrEqualTo: 'TGH$year$month')
          .where('kodeTagihan', isLessThan: 'TGH$year${month}Z')
          .get();

      final count = snapshot.docs.length + 1;
      final countStr = count.toString().padLeft(4, '0');

      return 'TGH$year$month$countStr';
    } catch (e) {
      debugPrint('Error generating kode tagihan: $e');
      return 'TGH${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // CREATE - Tambah tagihan baru
  Future<String> createTagihan(TagihanModel tagihan) async {
    try {
      print('\n🔵 [TagihanService] Starting createTagihan...');

      print('🔵 [TagihanService] Step 1: Generating kode tagihan...');
      final kodeTagihan = await _generateKodeTagihan();
      print('✅ [TagihanService] Generated kode: $kodeTagihan');

      print('🔵 [TagihanService] Step 2: Converting model to map...');
      final data = tagihan.toMap();
      print('✅ [TagihanService] Data map created with ${data.length} fields');

      print('🔵 [TagihanService] Step 3: Adding metadata...');
      data['kodeTagihan'] = kodeTagihan;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      print('✅ [TagihanService] Metadata added');

      print('🔵 [TagihanService] Step 4: Saving to Firestore collection "$_collection"...');
      print('   Data to save:');
      data.forEach((key, value) {
        if (key != 'periodeTanggal' && key != 'tanggalBayar') {
          print('   - $key: $value');
        } else {
          print('   - $key: [Timestamp]');
        }
      });

      print('🔵 [TagihanService] Calling Firestore add()...');
      final docRef = await _firestore.collection(_collection).add(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Firestore add() timeout after 10 seconds');
        },
      );

      print('✅ [TagihanService] Document saved with ID: ${docRef.id}');
      print('✅ [TagihanService] Kode tagihan: $kodeTagihan');
      print('✅ [TagihanService] SUCCESS! Tagihan created successfully\n');

      debugPrint('✅ Tagihan created: ${docRef.id} - $kodeTagihan');
      return docRef.id;
    } catch (e, stackTrace) {
      print('\n❌ [TagihanService] ERROR creating tagihan!');
      print('❌ [TagihanService] Error: $e');
      print('❌ [TagihanService] StackTrace:\n$stackTrace\n');
      debugPrint('❌ Error creating tagihan: $e');
      rethrow;
    }
  }

  // READ - Get semua tagihan aktif
  Stream<List<TagihanModel>> getTagihanStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('periodeTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ - Get tagihan by ID
  Future<TagihanModel?> getTagihanById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return TagihanModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting tagihan: $e');
      return null;
    }
  }

  // READ - Get tagihan by keluarga
  Stream<List<TagihanModel>> getTagihanByKeluargaStream(String keluargaId) {
    return _firestore
        .collection(_collection)
        .where('keluargaId', isEqualTo: keluargaId)
        .where('isActive', isEqualTo: true)
        .orderBy('periodeTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ - Get tagihan by jenis iuran
  Stream<List<TagihanModel>> getTagihanByJenisIuranStream(String jenisIuranId) {
    return _firestore
        .collection(_collection)
        .where('jenisIuranId', isEqualTo: jenisIuranId)
        .where('isActive', isEqualTo: true)
        .orderBy('periodeTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ - Get tagihan by status
  Stream<List<TagihanModel>> getTagihanByStatusStream(String status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status)
        .where('isActive', isEqualTo: true)
        .orderBy('periodeTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ - Get tagihan yang jatuh tempo
  Stream<List<TagihanModel>> getTagihanJatuhTempoStream() {
    final now = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'Belum Dibayar')
        .where('isActive', isEqualTo: true)
        .where('periodeTanggal', isLessThanOrEqualTo: now)
        .orderBy('periodeTanggal', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  // UPDATE - Update tagihan
  Future<void> updateTagihan(String id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(id).update(data);
      debugPrint('✅ Tagihan updated: $id');
    } catch (e) {
      debugPrint('❌ Error updating tagihan: $e');
      rethrow;
    }
  }

  // UPDATE - Tandai tagihan sebagai lunas
  Future<void> markAsLunas(
    String id, {
    required String metodePembayaran,
    String? buktiPembayaran,
    String? catatan,
  }) async {
    try {
      await updateTagihan(id, {
        'status': 'Lunas',
        'tanggalBayar': FieldValue.serverTimestamp(),
        'metodePembayaran': metodePembayaran,
        if (buktiPembayaran != null) 'buktiPembayaran': buktiPembayaran,
        if (catatan != null) 'catatan': catatan,
      });
      debugPrint('✅ Tagihan marked as Lunas: $id');
    } catch (e) {
      debugPrint('❌ Error marking tagihan as Lunas: $e');
      rethrow;
    }
  }

  // UPDATE - Update status tagihan yang terlambat
  Future<void> updateOverdueStatus() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'Belum Dibayar')
          .where('isActive', isEqualTo: true)
          .where('periodeTanggal', isLessThan: now)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': 'Terlambat',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      debugPrint('✅ Updated ${snapshot.docs.length} overdue tagihan');
    } catch (e) {
      debugPrint('❌ Error updating overdue status: $e');
      rethrow;
    }
  }

  // DELETE - Soft delete (set isActive = false)
  Future<void> deleteTagihan(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Tagihan soft deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting tagihan: $e');
      rethrow;
    }
  }

  // DELETE - Hard delete (permanent)
  Future<void> deleteTagihanPermanent(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      debugPrint('✅ Tagihan permanently deleted: $id');
    } catch (e) {
      debugPrint('❌ Error permanently deleting tagihan: $e');
      rethrow;
    }
  }

  // BULK CREATE - Buat tagihan massal untuk semua keluarga
  Future<int> createBulkTagihan({
    required String jenisIuranId,
    required String jenisIuranName,
    required double nominal,
    required String periode,
    required DateTime periodeTanggal,
    required List<Map<String, String>> keluargaList, // {id, name}
    required String createdBy,
  }) async {
    try {
      final batch = _firestore.batch();
      int count = 0;

      for (var keluarga in keluargaList) {
        final kodeTagihan = await _generateKodeTagihan();
        final docRef = _firestore.collection(_collection).doc();

        batch.set(docRef, {
          'kodeTagihan': kodeTagihan,
          'jenisIuranId': jenisIuranId,
          'jenisIuranName': jenisIuranName,
          'keluargaId': keluarga['id'],
          'keluargaName': keluarga['name'],
          'nominal': nominal,
          'periode': periode,
          'periodeTanggal': Timestamp.fromDate(periodeTanggal),
          'status': 'Belum Dibayar',
          'createdBy': createdBy,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        count++;
      }

      await batch.commit();
      debugPrint('✅ Created $count tagihan in bulk');
      return count;
    } catch (e) {
      debugPrint('❌ Error creating bulk tagihan: $e');
      rethrow;
    }
  }

  // STATISTICS - Get total tagihan
  Future<Map<String, dynamic>> getTagihanStatistics() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      double totalLunas = 0;
      double totalBelumBayar = 0;
      double totalTerlambat = 0;
      int countLunas = 0;
      int countBelumBayar = 0;
      int countTerlambat = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nominal = (data['nominal'] as num?)?.toDouble() ?? 0.0;
        final status = data['status'] ?? '';

        switch (status) {
          case 'Lunas':
            totalLunas += nominal;
            countLunas++;
            break;
          case 'Belum Dibayar':
            totalBelumBayar += nominal;
            countBelumBayar++;
            break;
          case 'Terlambat':
            totalTerlambat += nominal;
            countTerlambat++;
            break;
        }
      }

      return {
        'totalLunas': totalLunas,
        'totalBelumBayar': totalBelumBayar,
        'totalTerlambat': totalTerlambat,
        'countLunas': countLunas,
        'countBelumBayar': countBelumBayar,
        'countTerlambat': countTerlambat,
        'totalTagihan': snapshot.docs.length,
        'totalNominal': totalLunas + totalBelumBayar + totalTerlambat,
      };
    } catch (e) {
      debugPrint('❌ Error getting statistics: $e');
      return {};
    }
  }
}

