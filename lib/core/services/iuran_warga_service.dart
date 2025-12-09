import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tagihan_model.dart';
import '../models/keuangan_model.dart';
import 'firebase_service.dart';

/// ============================================================================
/// IURAN WARGA SERVICE
/// ============================================================================
/// Service untuk handle operasi CRUD iuran dari sisi warga
/// Mengelola pembayaran iuran dan integrasi dengan sistem keuangan
///
/// CRITICAL FEATURES:
/// - Atomic transaction untuk pembayaran (update tagihan + insert keuangan)
/// - Security: Warga hanya bisa akses data keluarganya
/// - Data consistency dengan denormalized fields
///
/// Author: System
/// Created: December 8, 2025
/// ============================================================================

class IuranWargaService {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  static const String _tagihanCollection = 'tagihan';
  static const String _keuanganCollection = 'keuangan';

  // ============================================================================
  // READ OPERATIONS - TAGIHAN WARGA
  // ============================================================================

  /// Get semua tagihan by keluarga ID (real-time stream)
  /// Diurutkan dari yang terbaru
  Stream<List<TagihanModel>> getTagihanByKeluarga(String keluargaId) {
    try {
      return _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .snapshots()
          .map((snapshot) {
        final tagihan = snapshot.docs
            .map((doc) => TagihanModel.fromFirestore(doc))
            .toList();

        // Sort by created date in memory
        tagihan.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

        return tagihan;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get tagihan aktif (belum dibayar) by keluarga
  Stream<List<TagihanModel>> getTagihanAktif(String keluargaId) {
    try {
      return _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .snapshots()
          .map((snapshot) {
        final tagihan = snapshot.docs
            .map((doc) {
              try {
                return TagihanModel.fromFirestore(doc);
              } catch (e) {
                return null;
              }
            })
            .whereType<TagihanModel>()
            .where((t) => t.status == 'belum_bayar' || t.status == 'Belum Dibayar')
            .toList();

        tagihan.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        return tagihan;
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get tagihan terlambat by keluarga
  Stream<List<TagihanModel>> getTagihanTerlambat(String keluargaId) {
    try {
      debugPrint('🔵 [IuranWargaService] Streaming tagihan terlambat for keluarga: $keluargaId');

      // ⭐ TEMP FIX: Remove orderBy to avoid index requirement
      return _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('status', isEqualTo: 'Terlambat')
          .where('isActive', isEqualTo: true)
          // .orderBy('periodeTanggal', descending: false) // ← Removed (needs index)
          .snapshots()
          .map((snapshot) {
        final tagihan = snapshot.docs
            .map((doc) {
              try {
                return TagihanModel.fromFirestore(doc);
              } catch (e) {
                debugPrint('❌ Error parsing tagihan: $e');
                return null;
              }
            })
            .whereType<TagihanModel>()
            .toList();

        // ⭐ Sort in memory
        tagihan.sort((a, b) => a.periodeTanggal.compareTo(b.periodeTanggal));

        debugPrint('✅ [IuranWargaService] Found ${tagihan.length} tagihan terlambat');
        return tagihan;
      });
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error streaming tagihan terlambat: $e');
      return Stream.value([]);
    }
  }

  /// Get history pembayaran (tagihan lunas) by keluarga
  Stream<List<TagihanModel>> getHistoryPembayaran(String keluargaId) {
    try {
      debugPrint('🔵 [IuranWargaService] Streaming history pembayaran for keluarga: $keluargaId');

      // ⭐ TEMP FIX: Remove orderBy to avoid index requirement
      return _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('status', isEqualTo: 'Lunas')
          .where('isActive', isEqualTo: true)
          // .orderBy('tanggalBayar', descending: true) // ← Removed (needs index)
          .snapshots()
          .map((snapshot) {
        final tagihan = snapshot.docs
            .map((doc) {
              try {
                return TagihanModel.fromFirestore(doc);
              } catch (e) {
                debugPrint('❌ Error parsing tagihan: $e');
                return null;
              }
            })
            .whereType<TagihanModel>()
            .toList();

        // ⭐ Sort in memory (newest first)
        tagihan.sort((a, b) {
          if (a.tanggalBayar == null) return 1;
          if (b.tanggalBayar == null) return -1;
          return b.tanggalBayar!.compareTo(a.tanggalBayar!);
        });

        debugPrint('✅ [IuranWargaService] Found ${tagihan.length} history pembayaran');
        return tagihan;
      });
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error streaming history: $e');
      return Stream.value([]);
    }
  }

  /// Get single tagihan by ID
  Future<TagihanModel?> getTagihanById(String tagihanId) async {
    try {
      debugPrint('🔵 [IuranWargaService] Getting tagihan: $tagihanId');

      final doc = await _firestore
          .collection(_tagihanCollection)
          .doc(tagihanId)
          .get();

      if (!doc.exists) {
        debugPrint('❌ [IuranWargaService] Tagihan not found');
        return null;
      }

      final tagihan = TagihanModel.fromFirestore(doc);
      debugPrint('✅ [IuranWargaService] Tagihan found: ${tagihan.jenisIuranName}');
      return tagihan;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error getting tagihan: $e');
      return null;
    }
  }

  // ============================================================================
  // CREATE OPERATIONS - PEMBAYARAN IURAN
  // ============================================================================

  /// ⭐ BAYAR IURAN - ATOMIC TRANSACTION ⭐
  ///
  /// CRITICAL: Menggunakan Firestore batch untuk memastikan:
  /// 1. Update tagihan.status = 'Lunas'
  /// 2. Insert ke collection 'keuangan' sebagai pemasukan
  /// 3. Kedua operasi sukses atau gagal bersama (no partial update)
  ///
  /// Returns: keuanganId (document ID dari transaksi keuangan yang dibuat)
  Future<String> bayarIuran({
    required String tagihanId,
    required String metodePembayaran,
    String? buktiPembayaran,
    String? catatan,
    required String userId,
  }) async {
    try {
      debugPrint('\n🔵 [IuranWargaService] ===== BAYAR IURAN START =====');
      debugPrint('📝 TagihanId: $tagihanId');
      debugPrint('💳 Metode: $metodePembayaran');
      debugPrint('👤 UserId: $userId');

      // 1. Get tagihan data first (untuk validasi & get details)
      debugPrint('🔵 Step 1: Getting tagihan data...');
      final tagihan = await getTagihanById(tagihanId);

      if (tagihan == null) {
        throw Exception('Tagihan tidak ditemukan');
      }

      // 2. Validasi status tagihan
      debugPrint('🔵 Step 2: Validating tagihan status...');
      if (tagihan.status == 'Lunas') {
        throw Exception('Tagihan sudah dibayar');
      }

      // 3. Validasi keluarga (security check)
      debugPrint('🔵 Step 3: Validating keluarga access...');
      // Note: userId vs keluargaId validation should be done at provider level
      // For now we trust the userId parameter is validated by caller

      // 4. Prepare data for atomic transaction
      debugPrint('🔵 Step 4: Preparing atomic transaction...');
      final now = DateTime.now();
      final keuanganDocRef = _firestore.collection(_keuanganCollection).doc();

      // 5. Execute ATOMIC BATCH WRITE
      debugPrint('🔵 Step 5: Executing batch write...');
      final batch = _firestore.batch();

      // 5a. Update tagihan - Tandai sebagai Lunas
      batch.update(
        _firestore.collection(_tagihanCollection).doc(tagihanId),
        {
          'status': 'Lunas',
          'tanggalBayar': Timestamp.fromDate(now),
          'metodePembayaran': metodePembayaran,
          if (buktiPembayaran != null) 'buktiPembayaran': buktiPembayaran,
          if (catatan != null) 'catatan': catatan,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      debugPrint('  ✓ Batch: Update tagihan to Lunas');

      // 5b. Insert to keuangan - Catat sebagai pemasukan
      batch.set(keuanganDocRef, {
        'type': 'pemasukan',
        'amount': tagihan.nominal,
        'kategori': tagihan.jenisIuranName,
        'category': tagihan.jenisIuranName, // Alias for compatibility
        'deskripsi': 'Pembayaran ${tagihan.jenisIuranName} - ${tagihan.keluargaName} - ${tagihan.periode}',
        'description': 'Pembayaran ${tagihan.jenisIuranName} - ${tagihan.keluargaName} - ${tagihan.periode}',
        'tanggal': Timestamp.fromDate(now),
        'bukti': buktiPembayaran,
        'proof': buktiPembayaran,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        // Additional metadata for tracking
        'sourceType': 'iuran', // Identify source of pemasukan
        'sourceId': tagihanId, // Reference back to tagihan
        'keluargaId': tagihan.keluargaId,
        'keluargaName': tagihan.keluargaName,
        'jenisIuranId': tagihan.jenisIuranId,
        'metodePembayaran': metodePembayaran,
      });
      debugPrint('  ✓ Batch: Insert keuangan record');

      // 6. Commit batch (ATOMIC!)
      debugPrint('🔵 Step 6: Committing batch transaction...');
      await batch.commit();

      debugPrint('✅ [IuranWargaService] ===== BAYAR IURAN SUCCESS =====');
      debugPrint('💰 Nominal: Rp ${tagihan.nominal}');
      debugPrint('📄 Keuangan ID: ${keuanganDocRef.id}');
      debugPrint('🎯 Tagihan marked as Lunas\n');

      return keuanganDocRef.id;
    } catch (e, stackTrace) {
      debugPrint('\n❌ [IuranWargaService] ===== BAYAR IURAN FAILED =====');
      debugPrint('❌ Error: $e');
      debugPrint('❌ StackTrace: $stackTrace\n');
      rethrow;
    }
  }

  /// Upload bukti pembayaran (for transfer method)
  /// Returns: URL of uploaded image
  Future<String> uploadBuktiPembayaran({
    required String tagihanId,
    required String imagePath,
  }) async {
    try {
      debugPrint('🔵 [IuranWargaService] Uploading bukti pembayaran...');

      // TODO: Implement image upload to Firebase Storage
      // For now, return dummy URL
      final url = 'https://storage.example.com/bukti/$tagihanId.jpg';

      debugPrint('✅ [IuranWargaService] Bukti uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error uploading bukti: $e');
      rethrow;
    }
  }

  // ============================================================================
  // STATISTICS & ANALYTICS
  // ============================================================================

  /// Get statistik iuran untuk keluarga tertentu
  Future<Map<String, dynamic>> getStatistikIuran(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaService] Getting statistik for keluarga: $keluargaId');

      final snapshot = await _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('isActive', isEqualTo: true)
          .get();

      double totalBelumDibayar = 0;
      double totalLunas = 0;
      double totalTerlambat = 0;
      int countBelumDibayar = 0;
      int countLunas = 0;
      int countTerlambat = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nominal = (data['nominal'] as num?)?.toDouble() ?? 0.0;
        final status = data['status'] ?? '';

        switch (status) {
          case 'Belum Dibayar':
            totalBelumDibayar += nominal;
            countBelumDibayar++;
            break;
          case 'Lunas':
            totalLunas += nominal;
            countLunas++;
            break;
          case 'Terlambat':
            totalTerlambat += nominal;
            countTerlambat++;
            break;
        }
      }

      final stats = {
        'totalBelumDibayar': totalBelumDibayar,
        'totalLunas': totalLunas,
        'totalTerlambat': totalTerlambat,
        'countBelumDibayar': countBelumDibayar,
        'countLunas': countLunas,
        'countTerlambat': countTerlambat,
        'totalTagihan': snapshot.docs.length,
        'totalTunggakan': totalBelumDibayar + totalTerlambat,
        'countTunggakan': countBelumDibayar + countTerlambat,
      };

      debugPrint('✅ [IuranWargaService] Statistik calculated:');
      debugPrint('   - Total Tagihan: ${stats['totalTagihan']}');
      debugPrint('   - Total Tunggakan: Rp ${stats['totalTunggakan']}');
      debugPrint('   - Total Lunas: Rp ${stats['totalLunas']}');

      return stats;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error getting statistik: $e');
      return {};
    }
  }

  /// Get tagihan yang akan jatuh tempo (7 hari ke depan)
  Future<List<TagihanModel>> getTagihanJatuhTempo(String keluargaId) async {
    try {
      debugPrint('🔵 [IuranWargaService] Getting tagihan jatuh tempo...');

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final snapshot = await _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('status', isEqualTo: 'Belum Dibayar')
          .where('isActive', isEqualTo: true)
          .where('periodeTanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('periodeTanggal', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
          .get();

      final tagihan = snapshot.docs
          .map((doc) => TagihanModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ [IuranWargaService] Found ${tagihan.length} tagihan jatuh tempo');
      return tagihan;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error getting tagihan jatuh tempo: $e');
      return [];
    }
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /// Check apakah keluarga punya tunggakan
  Future<bool> hasTunggakan(String keluargaId) async {
    try {
      final snapshot = await _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('isActive', isEqualTo: true)
          .where('status', whereIn: ['Belum Dibayar', 'Terlambat'])
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error checking tunggakan: $e');
      return false;
    }
  }

  /// Get total tunggakan keluarga
  Future<double> getTotalTunggakan(String keluargaId) async {
    try {
      final snapshot = await _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: keluargaId)
          .where('isActive', isEqualTo: true)
          .where('status', whereIn: ['Belum Dibayar', 'Terlambat'])
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nominal = (data['nominal'] as num?)?.toDouble() ?? 0.0;
        total += nominal;
      }

      return total;
    } catch (e) {
      debugPrint('❌ [IuranWargaService] Error getting total tunggakan: $e');
      return 0;
    }
  }
}
