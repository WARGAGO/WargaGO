import 'package:cloud_firestore/cloud_firestore.dart';

/// Keluarga Model
/// Model untuk data keluarga yang dikelompokkan berdasarkan Nomor KK
class KeluargaModel {
  final String nomorKK;
  final String namaKepalaKeluarga;
  final String alamat;
  final String rt;
  final String rw;
  final String status;
  final int jumlahAnggota;
  final List<String> anggotaIds; // List of warga IDs in this family
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KeluargaModel({
    required this.nomorKK,
    required this.namaKepalaKeluarga,
    required this.alamat,
    this.rt = '',
    this.rw = '',
    this.status = 'Aktif',
    this.jumlahAnggota = 0,
    this.anggotaIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Create from grouped warga data
  factory KeluargaModel.fromWargaGroup({
    required String nomorKK,
    required List<Map<String, dynamic>> anggotaKeluarga,
  }) {
    // Find kepala keluarga
    final kepalaKeluarga = anggotaKeluarga.firstWhere(
      (w) => (w['peranKeluarga']?.toString().toLowerCase() ?? '').contains('kepala'),
      orElse: () => anggotaKeluarga.first,
    );

    return KeluargaModel(
      nomorKK: nomorKK,
      namaKepalaKeluarga: kepalaKeluarga['name']?.toString() ?? '-',
      alamat: kepalaKeluarga['alamat']?.toString() ?? '-',
      rt: kepalaKeluarga['rt']?.toString() ?? '',
      rw: kepalaKeluarga['rw']?.toString() ?? '',
      status: 'Aktif',
      jumlahAnggota: anggotaKeluarga.length,
      anggotaIds: anggotaKeluarga
          .map((w) => w['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(),
      createdAt: kepalaKeluarga['createdAt'] != null
          ? (kepalaKeluarga['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: kepalaKeluarga['updatedAt'] != null
          ? (kepalaKeluarga['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomorKK': nomorKK,
      'namaKepalaKeluarga': namaKepalaKeluarga,
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'status': status,
      'jumlahAnggota': jumlahAnggota,
      'anggotaIds': anggotaIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get full address string
  String get fullAddress {
    if (rt.isEmpty || rw.isEmpty) {
      return alamat;
    }
    return '$alamat, RT $rt RW $rw';
  }

  @override
  String toString() {
    return 'KeluargaModel(nomorKK: $nomorKK, kepala: $namaKepalaKeluarga, anggota: $jumlahAnggota)';
  }
}

