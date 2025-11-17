import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/keluarga_model.dart';

/// Repository untuk CRUD Keluarga
class KeluargaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'warga'; // Keluarga diambil dari grouping warga

  /// Get all keluarga (grouped by nomorKK)
  Stream<List<KeluargaModel>> getAllKeluarga() {
    return _firestore
        .collection(_collection)
        .where('nomorKK', isNotEqualTo: '')
        .snapshots()
        .map((snapshot) {
      // Group warga by nomorKK
      final Map<String, List<Map<String, dynamic>>> groupedByKK = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        final nomorKK = data['nomorKK']?.toString() ?? '';

        if (nomorKK.isNotEmpty) {
          if (!groupedByKK.containsKey(nomorKK)) {
            groupedByKK[nomorKK] = [];
          }
          groupedByKK[nomorKK]!.add(data);
        }
      }

      // Convert to KeluargaModel list
      return groupedByKK.entries.map((entry) {
        return KeluargaModel.fromWargaGroup(
          nomorKK: entry.key,
          anggotaKeluarga: entry.value,
        );
      }).toList();
    });
  }

  /// Get keluarga by nomorKK
  Future<KeluargaModel?> getKeluargaByNomorKK(String nomorKK) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('nomorKK', isEqualTo: nomorKK)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final anggotaKeluarga = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return KeluargaModel.fromWargaGroup(
        nomorKK: nomorKK,
        anggotaKeluarga: anggotaKeluarga,
      );
    } catch (e) {
      print('❌ Error getKeluargaByNomorKK: $e');
      return null;
    }
  }

  /// Get count keluarga
  Future<int> getCountKeluarga() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('nomorKK', isNotEqualTo: '')
          .get();

      // Count unique nomorKK
      final uniqueKK = <String>{};
      for (var doc in snapshot.docs) {
        final nomorKK = doc.data()['nomorKK']?.toString() ?? '';
        if (nomorKK.isNotEmpty) {
          uniqueKK.add(nomorKK);
        }
      }

      return uniqueKK.length;
    } catch (e) {
      print('❌ Error getCountKeluarga: $e');
      return 0;
    }
  }
}

