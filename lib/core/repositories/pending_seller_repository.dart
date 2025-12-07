// ============================================================================
// PENDING SELLER REPOSITORY
// ============================================================================
// Repository untuk CRUD Pending Seller (Kelola Lapak)
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pending_seller_model.dart';

class PendingSellerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pending_sellers';
  final String _approvedCollection = 'approved_sellers';

  /// Get all pending sellers (real-time stream)
  Stream<List<PendingSellerModel>> getAllPendingSellers() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      final pendingList = snapshot.docs
          .map((doc) => PendingSellerModel.fromFirestore(doc))
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

  /// Get all sellers by status (untuk admin melihat history)
  Stream<List<PendingSellerModel>> getSellersByStatus(
      SellerVerificationStatus status) {
    String statusString;
    switch (status) {
      case SellerVerificationStatus.approved:
        statusString = 'approved';
        break;
      case SellerVerificationStatus.rejected:
        statusString = 'rejected';
        break;
      case SellerVerificationStatus.suspended:
        statusString = 'suspended';
        break;
      default:
        statusString = 'pending';
    }

    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: statusString)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PendingSellerModel.fromFirestore(doc))
          .toList();

      list.sort((a, b) {
        if (a.updatedAt == null && b.updatedAt == null) return 0;
        if (a.updatedAt == null) return 1;
        if (b.updatedAt == null) return -1;
        return b.updatedAt!.compareTo(a.updatedAt!);
      });

      return list;
    });
  }

  /// Get pending seller by ID
  Future<PendingSellerModel?> getPendingSellerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return PendingSellerModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getPendingSellerById: $e');
      return null;
    }
  }

  /// Get seller by user ID (untuk check apakah user sudah daftar)
  Future<PendingSellerModel?> getSellerByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PendingSellerModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getSellerByUserId: $e');
      return null;
    }
  }

  /// Get count pending sellers
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

  /// Create pending seller (untuk pendaftaran seller baru)
  /// Atau update jika user pernah rejected
  Future<String?> createPendingSeller(PendingSellerModel seller) async {
    try {
      // Check apakah user sudah pernah daftar
      final existingSeller = await getSellerByUserId(seller.userId);

      if (existingSeller != null) {
        // Jika status REJECTED, izinkan update (daftar ulang)
        if (existingSeller.status == SellerVerificationStatus.rejected) {
          print('ℹ️ Updating rejected seller registration...');

          // Update document yang sudah ada dengan data baru
          final querySnapshot = await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: seller.userId)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final docId = querySnapshot.docs.first.id;

            // Update dengan data baru dan reset status ke pending
            await _firestore.collection(_collection).doc(docId).update({
              ...seller.toFirestore(),
              'status': 'pending', // Reset ke pending untuk review ulang
              'alasanPenolakan': null, // Clear alasan penolakan
              'rejectedBy': null,
              'rejectedAt': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            print('✅ Rejected seller registration updated: $docId');
            return docId;
          }
        } else {
          print('⚠️ User sudah terdaftar dengan status: ${existingSeller.status}');
          return null;
        }
      }

      // User belum pernah daftar, create document baru
      final docRef =
          await _firestore.collection(_collection).add(seller.toFirestore());
      print('✅ Pending seller created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error createPendingSeller: $e');
      return null;
    }
  }

  /// Update pending seller data
  Future<bool> updatePendingSeller(
      String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Pending seller updated: $id');
      return true;
    } catch (e) {
      print('❌ Error updatePendingSeller: $e');
      return false;
    }
  }

  /// Approve seller (verifikasi disetujui)
  Future<bool> approveSeller(String id, String approvedBy,
      {String? catatanAdmin}) async {
    try {
      // Validation
      if (id.isEmpty || approvedBy.isEmpty) {
        print('❌ Invalid parameters');
        return false;
      }

      final seller = await getPendingSellerById(id);
      if (seller == null) {
        print('❌ Seller tidak ditemukan');
        return false;
      }

      // Check if already approved
      final existingApproved = await _firestore
          .collection(_approvedCollection)
          .doc(seller.userId)
          .get();
      if (existingApproved.exists) {
        print('⚠️ Seller sudah disetujui sebelumnya');
        return false;
      }

      // Use batch for atomic operation
      final batch = _firestore.batch();

      // Update status di pending_sellers
      batch.update(_firestore.collection(_collection).doc(id), {
        'status': 'approved',
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': approvedBy,
        'catatanAdmin': catatanAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Pindahkan ke approved_sellers collection
      batch.set(_firestore.collection(_approvedCollection).doc(seller.userId), {
        'userId': seller.userId,
        'nik': seller.nik,
        'namaLengkap': seller.namaLengkap,
        'namaToko': seller.namaToko,
        'nomorTelepon': seller.nomorTelepon,
        'alamatToko': seller.alamatToko,
        'rt': seller.rt,
        'rw': seller.rw,
        'deskripsiUsaha': seller.deskripsiUsaha,
        'kategoriProduk': seller.kategoriProduk,
        'fotoKTPUrl': seller.fotoKTPUrl,
        'fotoSelfieKTPUrl': seller.fotoSelfieKTPUrl,
        'fotoTokoUrl': seller.fotoTokoUrl,
        'status': 'active',
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': approvedBy,
        'trustScore': seller.trustScore ?? 100.0,
        'complaintCount': seller.complaintCount ?? 0,
        'totalProducts': 0,
        'totalSales': 0,
        'rating': 5.0,
        'createdAt': seller.createdAt != null
            ? Timestamp.fromDate(seller.createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit batch
      await batch.commit();

      // Update user role (separate transaction karena beda collection)
      await _updateUserRole(seller.userId, isSeller: true);

      print('✅ Seller approved: $id');
      return true;
    } catch (e) {
      print('❌ Error approveSeller: $e');
      return false;
    }
  }

  /// Reject seller (verifikasi ditolak)
  Future<bool> rejectSeller(
      String id, String rejectedBy, String alasanPenolakan) async {
    try {
      // Validation
      if (id.isEmpty || rejectedBy.isEmpty || alasanPenolakan.isEmpty) {
        print('❌ Invalid parameters');
        return false;
      }

      // Check if seller exists
      final seller = await getPendingSellerById(id);
      if (seller == null) {
        print('❌ Seller tidak ditemukan');
        return false;
      }

      await _firestore.collection(_collection).doc(id).update({
        'status': 'rejected',
        'alasanPenolakan': alasanPenolakan,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': rejectedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Seller rejected: $id');
      return true;
    } catch (e) {
      print('❌ Error rejectSeller: $e');
      return false;
    }
  }

  /// Suspend seller (suspend seller yang sudah disetujui)
  Future<bool> suspendSeller(
      String userId, String suspendedBy, String alasan) async {
    try {
      // Validation
      if (userId.isEmpty || suspendedBy.isEmpty || alasan.isEmpty) {
        print('❌ Invalid parameters');
        return false;
      }

      // Check if seller exists in approved collection
      final approvedDoc =
          await _firestore.collection(_approvedCollection).doc(userId).get();
      if (!approvedDoc.exists) {
        print('❌ Seller tidak ditemukan di approved sellers');
        return false;
      }

      // Use batch for atomic operation
      final batch = _firestore.batch();

      // Update di approved_sellers
      batch.update(_firestore.collection(_approvedCollection).doc(userId), {
        'status': 'suspended',
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedBy': suspendedBy,
        'suspendReason': alasan,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update juga di pending_sellers jika ada
      final pendingSeller = await getSellerByUserId(userId);
      if (pendingSeller != null && pendingSeller.id != null) {
        batch.update(_firestore.collection(_collection).doc(pendingSeller.id!), {
          'status': 'suspended',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update user role
      await _updateUserRole(userId, isSeller: false);

      print('✅ Seller suspended: $userId');
      return true;
    } catch (e) {
      print('❌ Error suspendSeller: $e');
      return false;
    }
  }

  /// Reactivate seller (aktifkan kembali seller yang disuspend)
  Future<bool> reactivateSeller(String userId, String reactivatedBy) async {
    try {
      await _firestore.collection(_approvedCollection).doc(userId).update({
        'status': 'active',
        'reactivatedAt': FieldValue.serverTimestamp(),
        'reactivatedBy': reactivatedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user role
      await _updateUserRole(userId, isSeller: true);

      print('✅ Seller reactivated: $userId');
      return true;
    } catch (e) {
      print('❌ Error reactivateSeller: $e');
      return false;
    }
  }

  /// Delete pending seller
  Future<bool> deletePendingSeller(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      print('✅ Pending seller deleted: $id');
      return true;
    } catch (e) {
      print('❌ Error deletePendingSeller: $e');
      return false;
    }
  }

  /// Get approved sellers (untuk dashboard admin)
  Stream<List<Map<String, dynamic>>> getApprovedSellers() {
    return _firestore
        .collection(_approvedCollection)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Update user role (helper method)
  Future<void> _updateUserRole(String userId, {required bool isSeller}) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final currentRoles =
            List<String>.from(userDoc.data()?['roles'] ?? ['warga']);

        if (isSeller && !currentRoles.contains('seller')) {
          currentRoles.add('seller');
        } else if (!isSeller && currentRoles.contains('seller')) {
          currentRoles.remove('seller');
        }

        await _firestore.collection('users').doc(userId).update({
          'roles': currentRoles,
          'isSeller': isSeller,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Error updating user role: $e');
    }
  }

  /// Update trust score
  Future<bool> updateTrustScore(String userId, double newScore) async {
    try {
      await _firestore.collection(_approvedCollection).doc(userId).update({
        'trustScore': newScore,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Error updateTrustScore: $e');
      return false;
    }
  }

  /// Increment complaint count
  Future<bool> incrementComplaintCount(String userId) async {
    try {
      await _firestore.collection(_approvedCollection).doc(userId).update({
        'complaintCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('❌ Error incrementComplaintCount: $e');
      return false;
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      // Parallel fetch untuk performance
      final results = await Future.wait([
        _firestore
            .collection(_collection)
            .where('status', isEqualTo: 'pending')
            .get(),
        _firestore
            .collection(_approvedCollection)
            .where('status', isEqualTo: 'active')
            .get(),
        _firestore
            .collection(_collection)
            .where('status', isEqualTo: 'rejected')
            .get(),
        _firestore
            .collection(_approvedCollection)
            .where('status', isEqualTo: 'suspended')
            .get(),
      ]);

      return {
        'pending': results[0].docs.length,
        'approved': results[1].docs.length,
        'rejected': results[2].docs.length,
        'suspended': results[3].docs.length,
      };
    } catch (e) {
      print('❌ Error getStatistics: $e');
      // Return default values on error
      return {
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'suspended': 0,
      };
    }
  }
}

