// filepath: lib/core/services/iuran_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/iuran_model.dart';

class IuranService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _iuranCollection => _firestore.collection('iuran');
  CollectionReference get _tagihanCollection => _firestore.collection('tagihan');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // ==================== IURAN CRUD ====================

  /// Create new iuran
  Future<String> createIuran(IuranModel iuran) async {
    try {
      final docRef = await _iuranCollection.add(iuran.toMap());
      if (kDebugMode) {
        print('✅ Iuran created: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating iuran: $e');
      }
      rethrow;
    }
  }

  /// Get all iuran (stream)
  Stream<List<IuranModel>> getAllIuran() {
    return _iuranCollection
        .orderBy('tanggalBuat', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IuranModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get iuran by status
  Stream<List<IuranModel>> getIuranByStatus(String status) {
    return _iuranCollection
        .where('status', isEqualTo: status)
        .orderBy('tanggalBuat', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IuranModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get single iuran
  Future<IuranModel?> getIuranById(String id) async {
    try {
      final doc = await _iuranCollection.doc(id).get();
      if (doc.exists) {
        return IuranModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting iuran: $e');
      }
      return null;
    }
  }

  /// Update iuran
  Future<void> updateIuran(String id, IuranModel iuran) async {
    try {
      await _iuranCollection.doc(id).update(iuran.toMap());
      if (kDebugMode) {
        print('✅ Iuran updated: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating iuran: $e');
      }
      rethrow;
    }
  }

  /// Delete iuran
  Future<void> deleteIuran(String id) async {
    try {
      // Delete iuran
      await _iuranCollection.doc(id).delete();

      // Delete all tagihan related to this iuran
      final tagihanSnapshot = await _tagihanCollection
          .where('iuranId', isEqualTo: id)
          .get();

      for (var doc in tagihanSnapshot.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('✅ Iuran deleted: $id');
        print('✅ Related tagihan deleted: ${tagihanSnapshot.docs.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting iuran: $e');
      }
      rethrow;
    }
  }

  /// Update status iuran
  Future<void> updateStatusIuran(String id, String status) async {
    try {
      await _iuranCollection.doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) {
        print('✅ Iuran status updated: $id → $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating iuran status: $e');
      }
      rethrow;
    }
  }

  // ==================== TAGIHAN CRUD ====================

  /// Generate tagihan for all approved users
  Future<int> generateTagihanForAllUsers(String iuranId) async {
    try {
      // Get iuran details
      final iuran = await getIuranById(iuranId);
      if (iuran == null) {
        throw Exception('Iuran not found');
      }

      // Get current user (admin) for createdBy
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get all approved users (warga)
      final usersSnapshot = await _usersCollection
          .where('role', isEqualTo: 'warga')
          .where('status', isEqualTo: 'approved')
          .get();

      int count = 0;
      final now = DateTime.now();
      final periode = DateFormat('MMMM yyyy', 'id_ID').format(iuran.tanggalJatuhTempo);

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data() as Map<String, dynamic>?;
        final userName = userData?['nama'] as String? ?? 'Unknown';
        final keluargaId = userData?['keluargaId'] as String?;

        if (keluargaId == null || keluargaId.isEmpty) {
          if (kDebugMode) {
            print('⚠️ Skipping user $userName - no keluargaId');
          }
          continue;
        }

        // Get keluarga name
        String keluargaName = 'Keluarga $userName';
        try {
          final keluargaDoc = await FirebaseFirestore.instance
              .collection('keluarga')
              .doc(keluargaId)
              .get();
          if (keluargaDoc.exists) {
            keluargaName = keluargaDoc.data()?['namaKepalaKeluarga'] ?? keluargaName;
          }
        } catch (e) {
          // Use default if error
        }

        // Check if tagihan already exists
        final existingTagihan = await _tagihanCollection
            .where('jenisIuranId', isEqualTo: iuranId)
            .where('keluargaId', isEqualTo: keluargaId)
            .where('periode', isEqualTo: periode)
            .get();

        if (existingTagihan.docs.isEmpty) {
          // Generate kode tagihan
          final kodeTagihan = 'TGH-${now.year}${now.month.toString().padLeft(2, '0')}-${count.toString().padLeft(3, '0')}';

          // Create new tagihan with complete structure
          final tagihanData = {
            'kodeTagihan': kodeTagihan,
            'jenisIuranId': iuranId,
            'jenisIuranName': iuran.judul,
            'keluargaId': keluargaId,
            'keluargaName': keluargaName,
            'nominal': iuran.nominal,
            'periode': periode,
            'periodeTanggal': Timestamp.fromDate(iuran.tanggalJatuhTempo),
            'status': 'Belum Dibayar', // ⭐ Kapitalisasi yang benar!
            'isActive': true,
            'createdBy': currentUser.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          await _tagihanCollection.add(tagihanData);
          count++;
        }
      }

      if (kDebugMode) {
        print('✅ Generated $count tagihan for iuran: $iuranId');
      }

      return count;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating tagihan: $e');
      }
      rethrow;
    }
  }

  /// Get tagihan by iuran
  Stream<List<TagihanModel>> getTagihanByIuran(String iuranId) {
    return _tagihanCollection
        .where('jenisIuranId', isEqualTo: iuranId) // ⭐ FIXED: Use jenisIuranId
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get tagihan by user
  Stream<List<TagihanModel>> getTagihanByUser(String userId) {
    return _tagihanCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update tagihan status
  Future<void> updateTagihanStatus(
    String tagihanId,
    String status, {
    String? metodePembayaran,
    String? buktiPembayaran,
    String? verifiedBy,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'sudah_bayar') {
        updateData['tanggalBayar'] = FieldValue.serverTimestamp();
        if (metodePembayaran != null) {
          updateData['metodePembayaran'] = metodePembayaran;
        }
        if (buktiPembayaran != null) {
          updateData['buktiPembayaran'] = buktiPembayaran;
        }
        if (verifiedBy != null) {
          updateData['verifiedBy'] = verifiedBy;
          updateData['verifiedAt'] = FieldValue.serverTimestamp();
        }
      }

      await _tagihanCollection.doc(tagihanId).update(updateData);

      if (kDebugMode) {
        print('✅ Tagihan status updated: $tagihanId → $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating tagihan status: $e');
      }
      rethrow;
    }
  }

  /// Delete tagihan
  Future<void> deleteTagihan(String tagihanId) async {
    try {
      await _tagihanCollection.doc(tagihanId).delete();
      if (kDebugMode) {
        print('✅ Tagihan deleted: $tagihanId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting tagihan: $e');
      }
      rethrow;
    }
  }

  // ==================== STATISTICS ====================

  /// Get statistics for iuran
  Future<Map<String, dynamic>> getIuranStatistics(String iuranId) async {
    try {
      final tagihanSnapshot = await _tagihanCollection
          .where('jenisIuranId', isEqualTo: iuranId) // ⭐ FIXED: Use jenisIuranId
          .where('isActive', isEqualTo: true)
          .get();

      int totalTagihan = tagihanSnapshot.docs.length;
      int sudahBayar = 0;
      int belumBayar = 0;
      int terlambat = 0;
      double totalNominal = 0;
      double totalTerbayar = 0;

      for (var doc in tagihanSnapshot.docs) {
        final tagihan = TagihanModel.fromFirestore(doc);
        totalNominal += tagihan.nominal;

        // ⭐ FIXED: Match both old and new status values
        if (tagihan.status == 'sudah_bayar' || tagihan.status == 'Lunas') {
          sudahBayar++;
          totalTerbayar += tagihan.nominal;
        } else if (tagihan.status == 'belum_bayar' || tagihan.status == 'Belum Dibayar') {
          belumBayar++;
        } else if (tagihan.status == 'terlambat' || tagihan.status == 'Terlambat') {
          terlambat++;
        }
      }

      return {
        'totalTagihan': totalTagihan,
        'sudahBayar': sudahBayar,
        'belumBayar': belumBayar,
        'terlambat': terlambat,
        'totalNominal': totalNominal,
        'totalTerbayar': totalTerbayar,
        'persentasePembayaran': totalTagihan > 0
            ? (sudahBayar / totalTagihan * 100)
            : 0.0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting iuran statistics: $e');
      }
      return {};
    }
  }
}

