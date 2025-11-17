import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk data Mutasi Warga
class MutasiModel {
  final String? id;
  final String nama;
  final String nik;
  final String jenisMutasi; // 'Mutasi Masuk', 'Keluar Perumahan', 'Pindah Rumah'
  final DateTime tanggalMutasi;
  final String alamatAsal;
  final String alamatTujuan;
  final String alasanMutasi;
  final String status; // 'Pending', 'Diproses', 'Selesai'
  final String? keluargaId; // Reference ke keluarga
  final String? rumahId; // Reference ke rumah (untuk pindah rumah)
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MutasiModel({
    this.id,
    required this.nama,
    required this.nik,
    required this.jenisMutasi,
    required this.tanggalMutasi,
    required this.alamatAsal,
    required this.alamatTujuan,
    required this.alasanMutasi,
    this.status = 'Selesai',
    this.keluargaId,
    this.rumahId,
    this.createdBy = 'admin',
    this.createdAt,
    this.updatedAt,
  });

  /// Convert dari Firestore Document
  factory MutasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MutasiModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      nik: data['nik'] ?? '',
      jenisMutasi: data['jenisMutasi'] ?? '',
      tanggalMutasi: (data['tanggalMutasi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      alamatAsal: data['alamatAsal'] ?? '',
      alamatTujuan: data['alamatTujuan'] ?? '',
      alasanMutasi: data['alasanMutasi'] ?? '',
      status: data['status'] ?? 'Selesai',
      keluargaId: data['keluargaId'],
      rumahId: data['rumahId'],
      createdBy: data['createdBy'] ?? 'admin',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert ke Map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'nik': nik,
      'jenisMutasi': jenisMutasi,
      'tanggalMutasi': Timestamp.fromDate(tanggalMutasi),
      'alamatAsal': alamatAsal,
      'alamatTujuan': alamatTujuan,
      'alasanMutasi': alasanMutasi,
      'status': status,
      if (keluargaId != null) 'keluargaId': keluargaId,
      if (rumahId != null) 'rumahId': rumahId,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with
  MutasiModel copyWith({
    String? id,
    String? nama,
    String? nik,
    String? jenisMutasi,
    DateTime? tanggalMutasi,
    String? alamatAsal,
    String? alamatTujuan,
    String? alasanMutasi,
    String? status,
    String? keluargaId,
    String? rumahId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MutasiModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      jenisMutasi: jenisMutasi ?? this.jenisMutasi,
      tanggalMutasi: tanggalMutasi ?? this.tanggalMutasi,
      alamatAsal: alamatAsal ?? this.alamatAsal,
      alamatTujuan: alamatTujuan ?? this.alamatTujuan,
      alasanMutasi: alasanMutasi ?? this.alasanMutasi,
      status: status ?? this.status,
      keluargaId: keluargaId ?? this.keluargaId,
      rumahId: rumahId ?? this.rumahId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

