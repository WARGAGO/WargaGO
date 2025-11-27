// ============================================================================
// PENDING SELLER MODEL
// ============================================================================
// Model untuk seller yang menunggu persetujuan admin
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Status verifikasi seller
enum SellerVerificationStatus {
  pending,    // Menunggu verifikasi
  approved,   // Disetujui
  rejected,   // Ditolak
  suspended,  // Disuspend (setelah disetujui tapi ada masalah)
}

/// Kategori produk yang akan dijual
enum ProductCategory {
  sayuran,
  buahBuahan,
  kebutuhanPokok,
  makananMinuman,
  lainnya,
}

/// Model untuk seller yang menunggu persetujuan
class PendingSellerModel {
  final String? id;
  final String userId;              // User ID dari Firebase Auth
  final String nik;                 // NIK warga
  final String namaLengkap;         // Nama lengkap penjual
  final String namaToko;            // Nama toko/lapak
  final String nomorTelepon;        // Nomor telepon yang bisa dihubungi
  final String alamatToko;          // Alamat toko (bisa rumah atau tempat lain)
  final String rt;
  final String rw;
  final String deskripsiUsaha;      // Deskripsi singkat tentang usaha
  final List<String> kategoriProduk; // Kategori produk yang akan dijual
  final String fotoKTPUrl;          // URL foto KTP
  final String fotoSelfieKTPUrl;    // URL foto selfie dengan KTP (anti-fraud)
  final String? fotoTokoUrl;        // URL foto toko (opsional)
  final SellerVerificationStatus status;
  final String? alasanPenolakan;    // Alasan jika ditolak
  final String? catatanAdmin;       // Catatan dari admin
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;       // Tanggal diverifikasi
  final String? verifiedBy;         // Admin yang memverifikasi

  // Additional verification data
  final bool? isRTApproved;         // Apakah sudah disetujui RT (opsional)
  final bool? isRWApproved;         // Apakah sudah disetujui RW (opsional)
  final String? rtApprovedBy;
  final String? rwApprovedBy;

  // Seller rating & trust score (untuk future use)
  final double? trustScore;         // Skor kepercayaan (0-100)
  final int? complaintCount;        // Jumlah komplain

  PendingSellerModel({
    this.id,
    required this.userId,
    required this.nik,
    required this.namaLengkap,
    required this.namaToko,
    required this.nomorTelepon,
    required this.alamatToko,
    this.rt = '',
    this.rw = '',
    required this.deskripsiUsaha,
    this.kategoriProduk = const [],
    required this.fotoKTPUrl,
    required this.fotoSelfieKTPUrl,
    this.fotoTokoUrl,
    this.status = SellerVerificationStatus.pending,
    this.alasanPenolakan,
    this.catatanAdmin,
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.isRTApproved,
    this.isRWApproved,
    this.rtApprovedBy,
    this.rwApprovedBy,
    this.trustScore = 100.0,
    this.complaintCount = 0,
  });

  /// From Firestore
  factory PendingSellerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingSellerModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      nik: data['nik'] ?? '',
      namaLengkap: data['namaLengkap'] ?? '',
      namaToko: data['namaToko'] ?? '',
      nomorTelepon: data['nomorTelepon'] ?? '',
      alamatToko: data['alamatToko'] ?? '',
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      deskripsiUsaha: data['deskripsiUsaha'] ?? '',
      kategoriProduk: List<String>.from(data['kategoriProduk'] ?? []),
      fotoKTPUrl: data['fotoKTPUrl'] ?? '',
      fotoSelfieKTPUrl: data['fotoSelfieKTPUrl'] ?? '',
      fotoTokoUrl: data['fotoTokoUrl'],
      status: _statusFromString(data['status'] ?? 'pending'),
      alasanPenolakan: data['alasanPenolakan'],
      catatanAdmin: data['catatanAdmin'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: data['verifiedBy'],
      isRTApproved: data['isRTApproved'],
      isRWApproved: data['isRWApproved'],
      rtApprovedBy: data['rtApprovedBy'],
      rwApprovedBy: data['rwApprovedBy'],
      trustScore: (data['trustScore'] as num?)?.toDouble() ?? 100.0,
      complaintCount: data['complaintCount'] ?? 0,
    );
  }

  /// To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'nik': nik,
      'namaLengkap': namaLengkap,
      'namaToko': namaToko,
      'nomorTelepon': nomorTelepon,
      'alamatToko': alamatToko,
      'rt': rt,
      'rw': rw,
      'deskripsiUsaha': deskripsiUsaha,
      'kategoriProduk': kategoriProduk,
      'fotoKTPUrl': fotoKTPUrl,
      'fotoSelfieKTPUrl': fotoSelfieKTPUrl,
      'fotoTokoUrl': fotoTokoUrl,
      'status': _statusToString(status),
      'alasanPenolakan': alasanPenolakan,
      'catatanAdmin': catatanAdmin,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      'isRTApproved': isRTApproved,
      'isRWApproved': isRWApproved,
      'rtApprovedBy': rtApprovedBy,
      'rwApprovedBy': rwApprovedBy,
      'trustScore': trustScore,
      'complaintCount': complaintCount,
    };
  }

  /// Copy with
  PendingSellerModel copyWith({
    String? id,
    String? userId,
    String? nik,
    String? namaLengkap,
    String? namaToko,
    String? nomorTelepon,
    String? alamatToko,
    String? rt,
    String? rw,
    String? deskripsiUsaha,
    List<String>? kategoriProduk,
    String? fotoKTPUrl,
    String? fotoSelfieKTPUrl,
    String? fotoTokoUrl,
    SellerVerificationStatus? status,
    String? alasanPenolakan,
    String? catatanAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    bool? isRTApproved,
    bool? isRWApproved,
    String? rtApprovedBy,
    String? rwApprovedBy,
    double? trustScore,
    int? complaintCount,
  }) {
    return PendingSellerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nik: nik ?? this.nik,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      namaToko: namaToko ?? this.namaToko,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      alamatToko: alamatToko ?? this.alamatToko,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      deskripsiUsaha: deskripsiUsaha ?? this.deskripsiUsaha,
      kategoriProduk: kategoriProduk ?? this.kategoriProduk,
      fotoKTPUrl: fotoKTPUrl ?? this.fotoKTPUrl,
      fotoSelfieKTPUrl: fotoSelfieKTPUrl ?? this.fotoSelfieKTPUrl,
      fotoTokoUrl: fotoTokoUrl ?? this.fotoTokoUrl,
      status: status ?? this.status,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      isRTApproved: isRTApproved ?? this.isRTApproved,
      isRWApproved: isRWApproved ?? this.isRWApproved,
      rtApprovedBy: rtApprovedBy ?? this.rtApprovedBy,
      rwApprovedBy: rwApprovedBy ?? this.rwApprovedBy,
      trustScore: trustScore ?? this.trustScore,
      complaintCount: complaintCount ?? this.complaintCount,
    );
  }

  // Helper methods untuk konversi status
  static SellerVerificationStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return SellerVerificationStatus.approved;
      case 'rejected':
        return SellerVerificationStatus.rejected;
      case 'suspended':
        return SellerVerificationStatus.suspended;
      default:
        return SellerVerificationStatus.pending;
    }
  }

  static String _statusToString(SellerVerificationStatus status) {
    switch (status) {
      case SellerVerificationStatus.approved:
        return 'approved';
      case SellerVerificationStatus.rejected:
        return 'rejected';
      case SellerVerificationStatus.suspended:
        return 'suspended';
      default:
        return 'pending';
    }
  }

  // Helper untuk mendapatkan label status dalam Bahasa Indonesia
  String get statusLabel {
    switch (status) {
      case SellerVerificationStatus.pending:
        return 'Menunggu Verifikasi';
      case SellerVerificationStatus.approved:
        return 'Disetujui';
      case SellerVerificationStatus.rejected:
        return 'Ditolak';
      case SellerVerificationStatus.suspended:
        return 'Disuspend';
    }
  }

  // Helper untuk mendapatkan kategori produk yang di-format
  String get kategoriProdukString {
    if (kategoriProduk.isEmpty) return 'Belum ditentukan';
    return kategoriProduk.join(', ');
  }

  // Validasi kelengkapan data
  bool get isDataComplete {
    return namaLengkap.isNotEmpty &&
        namaToko.isNotEmpty &&
        nomorTelepon.isNotEmpty &&
        alamatToko.isNotEmpty &&
        deskripsiUsaha.isNotEmpty &&
        kategoriProduk.isNotEmpty &&
        fotoKTPUrl.isNotEmpty &&
        fotoSelfieKTPUrl.isNotEmpty;
  }
}

/// Helper untuk kategori produk
class ProductCategoryHelper {
  static const Map<String, String> categoryLabels = {
    'sayuran': 'Sayuran',
    'buah-buahan': 'Buah-buahan',
    'kebutuhan-pokok': 'Kebutuhan Pokok',
    'makanan-minuman': 'Makanan & Minuman',
    'lainnya': 'Lainnya',
  };

  static String getLabel(String category) {
    return categoryLabels[category] ?? category;
  }

  static List<String> getAllCategories() {
    return categoryLabels.keys.toList();
  }

  static List<Map<String, String>> getCategoriesWithLabels() {
    return categoryLabels.entries
        .map((e) => {'value': e.key, 'label': e.value})
        .toList();
  }
}

