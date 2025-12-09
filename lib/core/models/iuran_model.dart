// filepath: lib/core/models/iuran_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Iuran/Tagihan
class IuranModel {
  final String id;
  final String judul;
  final String deskripsi;
  final double nominal;
  final DateTime tanggalJatuhTempo;
  final DateTime tanggalBuat;
  final String tipe; // 'bulanan', 'tahunan', 'insidental'
  final String status; // 'aktif', 'nonaktif'
  final String? kategori; // 'kebersihan', 'keamanan', 'pembangunan', dll
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IuranModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.nominal,
    required this.tanggalJatuhTempo,
    required this.tanggalBuat,
    required this.tipe,
    this.status = 'aktif',
    this.kategori,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Firestore
  factory IuranModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IuranModel(
      id: doc.id,
      judul: data['judul'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      nominal: (data['nominal'] ?? 0).toDouble(),
      tanggalJatuhTempo: (data['tanggalJatuhTempo'] as Timestamp).toDate(),
      tanggalBuat: (data['tanggalBuat'] as Timestamp).toDate(),
      tipe: data['tipe'] ?? 'bulanan',
      status: data['status'] ?? 'aktif',
      kategori: data['kategori'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'nominal': nominal,
      'tanggalJatuhTempo': Timestamp.fromDate(tanggalJatuhTempo),
      'tanggalBuat': Timestamp.fromDate(tanggalBuat),
      'tipe': tipe,
      'status': status,
      'kategori': kategori,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copy with
  IuranModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    double? nominal,
    DateTime? tanggalJatuhTempo,
    DateTime? tanggalBuat,
    String? tipe,
    String? status,
    String? kategori,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IuranModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      nominal: nominal ?? this.nominal,
      tanggalJatuhTempo: tanggalJatuhTempo ?? this.tanggalJatuhTempo,
      tanggalBuat: tanggalBuat ?? this.tanggalBuat,
      tipe: tipe ?? this.tipe,
      status: status ?? this.status,
      kategori: kategori ?? this.kategori,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model untuk Tagihan per Warga
class TagihanModel {
  final String id;
  final String iuranId;
  final String userId; // User warga
  final String? keluargaId; // ⭐ Added for compatibility with existing system
  final String userName;
  final double nominal;
  final String status; // 'belum_bayar', 'sudah_bayar', 'terlambat'
  final bool isActive; // ⭐ Added for filtering
  final String? jenisIuranName; // ⭐ Added for display
  final DateTime? tanggalBayar;
  final String? metodePembayaran;
  final String? buktiPembayaran; // URL image
  final String? verifiedBy; // Admin ID
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TagihanModel({
    required this.id,
    required this.iuranId,
    required this.userId,
    this.keluargaId,
    required this.userName,
    required this.nominal,
    this.status = 'belum_bayar',
    this.isActive = true,
    this.jenisIuranName,
    this.tanggalBayar,
    this.metodePembayaran,
    this.buktiPembayaran,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TagihanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TagihanModel(
      id: doc.id,
      iuranId: data['iuranId'] ?? '',
      userId: data['userId'] ?? '',
      keluargaId: data['keluargaId'], // ⭐ Added
      userName: data['userName'] ?? '',
      nominal: (data['nominal'] ?? 0).toDouble(),
      status: data['status'] ?? 'belum_bayar',
      isActive: data['isActive'] ?? true, // ⭐ Added
      jenisIuranName: data['jenisIuranName'], // ⭐ Added
      tanggalBayar: data['tanggalBayar'] != null
          ? (data['tanggalBayar'] as Timestamp).toDate()
          : null,
      metodePembayaran: data['metodePembayaran'],
      buktiPembayaran: data['buktiPembayaran'],
      verifiedBy: data['verifiedBy'],
      verifiedAt: data['verifiedAt'] != null
          ? (data['verifiedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iuranId': iuranId,
      'userId': userId,
      'keluargaId': keluargaId, // ⭐ Added
      'userName': userName,
      'nominal': nominal,
      'status': status,
      'isActive': isActive, // ⭐ Added
      'jenisIuranName': jenisIuranName, // ⭐ Added
      'tanggalBayar': tanggalBayar != null ? Timestamp.fromDate(tanggalBayar!) : null,
      'metodePembayaran': metodePembayaran,
      'buktiPembayaran': buktiPembayaran,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

