import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/tagihan_model.dart';

/// ============================================================================
/// IURAN WARGA SERVICE V2 - WITH AUTO-FIX
/// ============================================================================
/// Enhanced version with automatic problem detection and fixing
/// ============================================================================

class IuranWargaServiceV2 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tagihanCollection = 'tagihan';

  /// Get tagihan dengan auto-fix untuk masalah umum
  Stream<List<TagihanModel>> getTagihanByKeluargaRobust(String keluargaId) async* {
    try {
      // ⭐ FIX 1: Trim whitespace
      final cleanKeluargaId = keluargaId.trim();
      debugPrint('🔍 Searching tagihan for keluargaId: "$cleanKeluargaId"');

      // ⭐ FIX 2: Try exact match first (NO orderBy to avoid index issues)
      final exactMatchStream = _firestore
          .collection(_tagihanCollection)
          .where('keluargaId', isEqualTo: cleanKeluargaId)
          .where('isActive', isEqualTo: true)
          .snapshots();

      await for (var snapshot in exactMatchStream) {
        debugPrint('📊 Exact match found: ${snapshot.docs.length} documents');

        if (snapshot.docs.isNotEmpty) {
          // Success! Return the tagihan
          final tagihan = snapshot.docs
              .map((doc) {
                try {
                  return TagihanModel.fromFirestore(doc);
                } catch (e) {
                  debugPrint('❌ Error parsing ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<TagihanModel>()
              .toList();

          // Sort in memory
          tagihan.sort((a, b) => b.periodeTanggal.compareTo(a.periodeTanggal));

          yield tagihan;
        } else {
          // ⭐ FIX 3: No exact match - try auto-fix
          debugPrint('⚠️  No exact match - running auto-fix...');

          final suggestedId = await _findMatchingKeluargaId(cleanKeluargaId);

          if (suggestedId != null && suggestedId != cleanKeluargaId) {
            debugPrint('💡 Found similar keluargaId: "$suggestedId"');
            debugPrint('   User has: "$cleanKeluargaId"');
            debugPrint('   Suggested: "$suggestedId"');

            // Try with suggested ID
            final suggestedSnapshot = await _firestore
                .collection(_tagihanCollection)
                .where('keluargaId', isEqualTo: suggestedId)
                .where('isActive', isEqualTo: true)
                .get();

            if (suggestedSnapshot.docs.isNotEmpty) {
              debugPrint('✅ Found ${suggestedSnapshot.docs.length} tagihan with suggested ID!');

              final tagihan = suggestedSnapshot.docs
                  .map((doc) {
                    try {
                      return TagihanModel.fromFirestore(doc);
                    } catch (e) {
                      return null;
                    }
                  })
                  .whereType<TagihanModel>()
                  .toList();

              tagihan.sort((a, b) => b.periodeTanggal.compareTo(a.periodeTanggal));

              yield tagihan;
            } else {
              yield [];
            }
          } else {
            yield [];
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in getTagihanByKeluargaRobust: $e');
      yield [];
    }
  }

  /// Find matching keluargaId dengan case-insensitive & whitespace handling
  Future<String?> _findMatchingKeluargaId(String userKeluargaId) async {
    try {
      // Get sample of tagihan
      final allTagihan = await _firestore
          .collection(_tagihanCollection)
          .limit(50)
          .get();

      final uniqueKeluargaIds = <String>{};

      for (var doc in allTagihan.docs) {
        final id = doc.data()['keluargaId'] as String?;
        if (id != null && id.isNotEmpty) {
          uniqueKeluargaIds.add(id);
        }
      }

      debugPrint('📋 Available keluargaIds: $uniqueKeluargaIds');

      // Try case-insensitive match
      for (var id in uniqueKeluargaIds) {
        if (id.toLowerCase() == userKeluargaId.toLowerCase()) {
          debugPrint('💡 Found case-insensitive match: "$id"');
          return id;
        }
      }

      // Try trimmed match
      for (var id in uniqueKeluargaIds) {
        if (id.trim() == userKeluargaId.trim()) {
          debugPrint('💡 Found trimmed match: "$id"');
          return id;
        }
      }

      // Try contains match (partial)
      for (var id in uniqueKeluargaIds) {
        if (id.contains(userKeluargaId) || userKeluargaId.contains(id)) {
          debugPrint('💡 Found partial match: "$id"');
          return id;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error finding matching ID: $e');
      return null;
    }
  }

  /// Get tagihan aktif dengan auto-fix
  Stream<List<TagihanModel>> getTagihanAktifRobust(String keluargaId) async* {
    await for (var allTagihan in getTagihanByKeluargaRobust(keluargaId)) {
      final aktif = allTagihan
          .where((t) => t.status == 'Belum Dibayar')
          .toList();

      // Sort by date (oldest first)
      aktif.sort((a, b) => a.periodeTanggal.compareTo(b.periodeTanggal));

      yield aktif;
    }
  }

  /// Get tagihan terlambat dengan auto-fix
  Stream<List<TagihanModel>> getTagihanTerlambatRobust(String keluargaId) async* {
    await for (var allTagihan in getTagihanByKeluargaRobust(keluargaId)) {
      final terlambat = allTagihan
          .where((t) => t.status == 'Terlambat')
          .toList();

      terlambat.sort((a, b) => a.periodeTanggal.compareTo(b.periodeTanggal));

      yield terlambat;
    }
  }

  /// Get history pembayaran dengan auto-fix
  Stream<List<TagihanModel>> getHistoryPembayaranRobust(String keluargaId) async* {
    await for (var allTagihan in getTagihanByKeluargaRobust(keluargaId)) {
      final lunas = allTagihan
          .where((t) => t.status == 'Lunas')
          .toList();

      // Sort by payment date (newest first)
      lunas.sort((a, b) {
        if (a.tanggalBayar == null) return 1;
        if (b.tanggalBayar == null) return -1;
        return b.tanggalBayar!.compareTo(a.tanggalBayar!);
      });

      yield lunas;
    }
  }
}

