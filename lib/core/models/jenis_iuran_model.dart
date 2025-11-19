import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Jenis Iuran
/// Menyimpan informasi tentang jenis iuran yang ada di sistem
class JenisIuranModel {
  final String id;
  final String namaIuran;
  final double jumlahIuran;
  final String kategoriIuran; // 'bulanan' atau 'khusus'
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  JenisIuranModel({
    required this.id,
    required this.namaIuran,
    required this.jumlahIuran,
    required this.kategoriIuran,
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  // From Firestore
  factory JenisIuranModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JenisIuranModel(
      id: doc.id,
      namaIuran: data['namaIuran'] ?? '',
      jumlahIuran: (data['jumlahIuran'] as num?)?.toDouble() ?? 0.0,
      kategoriIuran: data['kategoriIuran'] ?? 'bulanan',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // From Map
  factory JenisIuranModel.fromMap(Map<String, dynamic> map, String id) {
    return JenisIuranModel(
      id: id,
      namaIuran: map['namaIuran'] ?? '',
      jumlahIuran: (map['jumlahIuran'] as num?)?.toDouble() ?? 0.0,
      kategoriIuran: map['kategoriIuran'] ?? 'bulanan',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'namaIuran': namaIuran,
      'jumlahIuran': jumlahIuran,
      'kategoriIuran': kategoriIuran,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  // Copy with
  JenisIuranModel copyWith({
    String? namaIuran,
    double? jumlahIuran,
    String? kategoriIuran,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return JenisIuranModel(
      id: id,
      namaIuran: namaIuran ?? this.namaIuran,
      jumlahIuran: jumlahIuran ?? this.jumlahIuran,
      kategoriIuran: kategoriIuran ?? this.kategoriIuran,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get kategori label
  String get kategoriLabel {
    return kategoriIuran == 'bulanan' ? 'Iuran Bulanan' : 'Iuran Khusus';
  }

  // Format jumlah iuran
  String get formattedJumlah {
    return 'Rp ${jumlahIuran.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

