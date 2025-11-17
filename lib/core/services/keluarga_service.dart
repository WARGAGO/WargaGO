import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/keluarga_model.dart';
import 'firebase_service.dart';

/// Keluarga Service
/// Service untuk operasi data keluarga dari Firestore
///
/// Data keluarga digenerate dari collection warga, dikelompokkan berdasarkan nomorKK
///
/// Clean Code Principles:
/// - Single Responsibility: Hanya handle data keluarga
/// - Data diambil dari warga collection dengan grouping by nomorKK
class KeluargaService {
  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  static const String _wargaCollection = 'warga';

  // ============================================================================
  // READ
  // ============================================================================

  /// Get all keluarga (grouped by nomorKK from warga collection)
  Future<List<KeluargaModel>> getAllKeluarga() async {
    try {
      print('=== KeluargaService: getAllKeluarga ===');

      // Get all warga - without orderBy to avoid index requirement
      final querySnapshot = await _firestore
          .collection(_wargaCollection)
          .get();

      print('📊 Found ${querySnapshot.docs.length} warga documents');

      // Group by nomorKK
      final Map<String, List<Map<String, dynamic>>> groupedByKK = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Check statusPenduduk
        final statusPenduduk = data['statusPenduduk']?.toString() ?? 'Aktif';
        if (statusPenduduk.toLowerCase() != 'aktif') {
          print('⚠️ Skipping warga ${data['name']} - statusPenduduk: $statusPenduduk');
          continue;
        }

        final nomorKK = data['nomorKK']?.toString() ?? '';

        // Skip if nomorKK is empty
        if (nomorKK.isEmpty || nomorKK == '-' || nomorKK.trim().isEmpty) {
          print('⚠️ Skipping warga ${data['name']} - no valid nomorKK');
          continue;
        }

        if (!groupedByKK.containsKey(nomorKK)) {
          groupedByKK[nomorKK] = [];
        }

        // Add doc id to data
        final dataWithId = Map<String, dynamic>.from(data);
        dataWithId['id'] = doc.id;
        groupedByKK[nomorKK]!.add(dataWithId);
      }

      print('👨‍👩‍👧‍👦 Grouped into ${groupedByKK.length} families');

      // Convert to KeluargaModel list
      final keluargaList = groupedByKK.entries
          .map((entry) => KeluargaModel.fromWargaGroup(
                nomorKK: entry.key,
                anggotaKeluarga: entry.value,
              ))
          .toList();

      // Sort by nama kepala keluarga
      keluargaList.sort((a, b) =>
        a.namaKepalaKeluarga.toLowerCase().compareTo(b.namaKepalaKeluarga.toLowerCase()));

      print('✅ Returning ${keluargaList.length} keluarga');
      for (var keluarga in keluargaList) {
        print('  - ${keluarga.namaKepalaKeluarga} (${keluarga.jumlahAnggota} anggota, KK: ${keluarga.nomorKK})');
      }

      return keluargaList;
    } catch (e) {
      print('❌ Error getAllKeluarga: $e');
      return [];
    }
  }

  /// Get keluarga by nomorKK
  Future<KeluargaModel?> getKeluargaByNomorKK(String nomorKK) async {
    try {
      print('=== KeluargaService: getKeluargaByNomorKK ===');
      print('Nomor KK: $nomorKK');

      if (nomorKK.isEmpty) {
        print('❌ Nomor KK is empty');
        return null;
      }

      // Get all warga with this nomorKK - remove statusPenduduk filter to avoid index requirement
      final querySnapshot = await _firestore
          .collection(_wargaCollection)
          .where('nomorKK', isEqualTo: nomorKK)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ No warga found with nomorKK: $nomorKK');
        return null;
      }

      print('📊 Found ${querySnapshot.docs.length} anggota keluarga');

      // Convert to list of maps with id, filter by statusPenduduk
      final anggotaKeluarga = querySnapshot.docs
          .where((doc) {
            final status = doc.data()['statusPenduduk']?.toString() ?? 'Aktif';
            return status.toLowerCase() == 'aktif';
          })
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return data;
          })
          .toList();

      if (anggotaKeluarga.isEmpty) {
        print('❌ No active members found for nomorKK: $nomorKK');
        return null;
      }

      final keluarga = KeluargaModel.fromWargaGroup(
        nomorKK: nomorKK,
        anggotaKeluarga: anggotaKeluarga,
      );

      print('✅ Keluarga found: ${keluarga.namaKepalaKeluarga}');
      return keluarga;
    } catch (e) {
      print('❌ Error getKeluargaByNomorKK: $e');
      return null;
    }
  }

  /// Search keluarga by kepala keluarga name
  Future<List<KeluargaModel>> searchKeluarga(String query) async {
    try {
      print('=== KeluargaService: searchKeluarga ===');
      print('Query: $query');

      if (query.isEmpty) {
        return getAllKeluarga();
      }

      final allKeluarga = await getAllKeluarga();
      final queryLower = query.toLowerCase();

      final filtered = allKeluarga.where((keluarga) {
        return keluarga.namaKepalaKeluarga.toLowerCase().contains(queryLower) ||
               keluarga.nomorKK.contains(query) ||
               keluarga.alamat.toLowerCase().contains(queryLower);
      }).toList();

      print('✅ Found ${filtered.length} matching keluarga');
      return filtered;
    } catch (e) {
      print('❌ Error searchKeluarga: $e');
      return [];
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final allKeluarga = await getAllKeluarga();

      return {
        'totalKeluarga': allKeluarga.length,
        'totalAnggota': allKeluarga.fold<int>(
          0,
          (sum, keluarga) => sum + keluarga.jumlahAnggota,
        ),
      };
    } catch (e) {
      print('❌ Error getStatistics: $e');
      return {
        'totalKeluarga': 0,
        'totalAnggota': 0,
      };
    }
  }
}

