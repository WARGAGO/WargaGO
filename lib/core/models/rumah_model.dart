import 'package:cloud_firestore/cloud_firestore.dart';

/// Rumah Model
/// Model data untuk daftar rumah
class RumahModel {
  final String id;
  final String alamat;
  final String rt;
  final String rw;
  final String kepalaKeluarga;
  final int jumlahPenghuni;
  final String statusKepemilikan; // 'Milik Sendiri', 'Sewa', 'Kontrak', 'Lainnya'
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RumahModel({
    required this.id,
    required this.alamat,
    this.rt = '',
    this.rw = '',
    this.kepalaKeluarga = '',
    this.jumlahPenghuni = 0,
    this.statusKepemilikan = 'Milik Sendiri',
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
  });

  // From Firestore
  factory RumahModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RumahModel(
      id: doc.id,
      alamat: data['alamat'] ?? '',
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      kepalaKeluarga: data['kepalaKeluarga'] ?? '',
      jumlahPenghuni: data['jumlahPenghuni'] ?? 0,
      statusKepemilikan: data['statusKepemilikan'] ?? 'Milik Sendiri',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // From Map
  factory RumahModel.fromMap(Map<String, dynamic> map, String id) {
    return RumahModel(
      id: id,
      alamat: map['alamat'] ?? '',
      rt: map['rt'] ?? '',
      rw: map['rw'] ?? '',
      kepalaKeluarga: map['kepalaKeluarga'] ?? '',
      jumlahPenghuni: map['jumlahPenghuni'] ?? 0,
      statusKepemilikan: map['statusKepemilikan'] ?? 'Milik Sendiri',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'kepalaKeluarga': kepalaKeluarga,
      'jumlahPenghuni': jumlahPenghuni,
      'statusKepemilikan': statusKepemilikan,
      'createdBy': createdBy,
    };
  }

  // To Firestore - with timestamps
  Map<String, dynamic> toFirestore() {
    return {
      'alamat': alamat,
      'rt': rt,
      'rw': rw,
      'kepalaKeluarga': kepalaKeluarga,
      'jumlahPenghuni': jumlahPenghuni,
      'statusKepemilikan': statusKepemilikan,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with
  RumahModel copyWith({
    String? alamat,
    String? rt,
    String? rw,
    String? kepalaKeluarga,
    int? jumlahPenghuni,
    String? statusKepemilikan,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RumahModel(
      id: id,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      kepalaKeluarga: kepalaKeluarga ?? this.kepalaKeluarga,
      jumlahPenghuni: jumlahPenghuni ?? this.jumlahPenghuni,
      statusKepemilikan: statusKepemilikan ?? this.statusKepemilikan,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted address
  String get formattedAddress {
    if (rt.isEmpty && rw.isEmpty) return alamat;
    return '$alamat, RT $rt/RW $rw';
  }
}
