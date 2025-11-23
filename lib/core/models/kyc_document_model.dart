// ============================================================================
// KYC DOCUMENT MODEL - UPDATED
// ============================================================================
// Model untuk dokumen KYC (Know Your Customer)
// Digunakan untuk verifikasi identitas warga
//
// PERBAIKAN v2.0:
// - Simpan storagePath & blobName (permanent) bukan URL (yang bisa expired)
// - URL di-generate on-demand saat dibutuhkan
// - Support backward compatibility untuk data lama
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum KYCDocumentType {
  ktp,
  kk,
  akteKelahiran,
}

enum KYCStatus {
  pending,
  approved,
  rejected,
}

// Helper class for OCR results
class OCRResult {
  final String? nik;
  final String? nama;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? alamat;
  final Map<String, dynamic>? additionalFields;

  OCRResult({
    this.nik,
    this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.alamat,
    this.additionalFields,
  });

  factory OCRResult.fromMap(Map<String, dynamic> map) {
    return OCRResult(
      nik: map['nik'],
      nama: map['nama'],
      tempatLahir: map['tempatLahir'],
      tanggalLahir: map['tanggalLahir'],
      alamat: map['alamat'],
      additionalFields: map['additionalFields'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nama': nama,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir,
      'alamat': alamat,
      'additionalFields': additionalFields,
    };
  }
}

// Helper class for Face Detection results
class FaceDetectionResult {
  final bool faceDetected;
  final double? confidence;
  final String? quality;

  FaceDetectionResult({
    required this.faceDetected,
    this.confidence,
    this.quality,
  });

  factory FaceDetectionResult.fromMap(Map<String, dynamic> map) {
    return FaceDetectionResult(
      faceDetected: map['faceDetected'] ?? false,
      confidence: map['confidence']?.toDouble(),
      quality: map['quality'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faceDetected': faceDetected,
      'confidence': confidence,
      'quality': quality,
    };
  }
}

class KYCDocumentModel {
  final String? id;
  final String userId; // Reference to user
  final KYCDocumentType documentType;

  // ✅ PERBAIKAN: Simpan path & blob name permanent, bukan URL yang bisa expired
  final String storagePath; // Path blob di Azure Storage (permanent)
  final String blobName; // Nama blob yang di-custom

  final KYCStatus status;
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy; // Admin ID who verified
  final OCRResult? ocrResult;
  final FaceDetectionResult? faceDetection;
  final Map<String, dynamic>? additionalData;

  KYCDocumentModel({
    this.id,
    required this.userId,
    required this.documentType,
    required this.storagePath,
    required this.blobName,
    this.status = KYCStatus.pending,
    this.rejectionReason,
    required this.uploadedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.ocrResult,
    this.faceDetection,
    this.additionalData,
  });

  // From Firestore
  factory KYCDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KYCDocumentModel.fromMap(data, doc.id);
  }

  // Convert from Map with backward compatibility
  factory KYCDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    // Support old data yang masih pakai documentUrl
    final storagePath = map['storagePath'] ?? map['documentUrl'] ?? '';
    final blobName = map['blobName'] ?? _extractBlobNameFromUrl(storagePath);

    return KYCDocumentModel(
      id: id,
      userId: map['userId'] ?? '',
      documentType: documentTypeFromString(map['documentType'] ?? 'ktp'),
      storagePath: storagePath,
      blobName: blobName,
      status: statusFromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: map['verifiedBy'],
      ocrResult: map['ocrResult'] != null
          ? OCRResult.fromMap(map['ocrResult'])
          : null,
      faceDetection: map['faceDetection'] != null
          ? FaceDetectionResult.fromMap(map['faceDetection'])
          : null,
      additionalData: map['additionalData'],
    );
  }

  // Helper untuk extract blob name dari URL (untuk backward compatibility)
  static String _extractBlobNameFromUrl(String urlOrPath) {
    if (urlOrPath.isEmpty) return '';

    try {
      final uri = Uri.parse(urlOrPath);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (e) {
      // Jika bukan URL, return as is
    }

    return urlOrPath;
  }

  // Convert to Map - hanya simpan storagePath & blobName
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'documentType': documentTypeToString(documentType),
      'storagePath': storagePath, // Path permanent di Azure
      'blobName': blobName, // Nama blob yang di-custom
      // ❌ documentUrl TIDAK disimpan lagi karena akan expired
      'status': statusToString(status),
      'rejectionReason': rejectionReason,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      'ocrResult': ocrResult?.toMap(),
      'faceDetection': faceDetection?.toMap(),
      'additionalData': additionalData,
    };
  }

  // Helper methods for enum conversion
  static KYCDocumentType documentTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'ktp':
        return KYCDocumentType.ktp;
      case 'kk':
      case 'kartu_keluarga':
        return KYCDocumentType.kk;
      case 'akte_kelahiran':
      case 'aktekelahiran':
        return KYCDocumentType.akteKelahiran;
      default:
        return KYCDocumentType.ktp;
    }
  }

  static String documentTypeToString(KYCDocumentType type) {
    switch (type) {
      case KYCDocumentType.ktp:
        return 'ktp';
      case KYCDocumentType.kk:
        return 'kk';
      case KYCDocumentType.akteKelahiran:
        return 'akte_kelahiran';
    }
  }

  static KYCStatus statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return KYCStatus.pending;
      case 'approved':
        return KYCStatus.approved;
      case 'rejected':
        return KYCStatus.rejected;
      default:
        return KYCStatus.pending;
    }
  }

  static String statusToString(KYCStatus status) {
    switch (status) {
      case KYCStatus.pending:
        return 'pending';
      case KYCStatus.approved:
        return 'approved';
      case KYCStatus.rejected:
        return 'rejected';
    }
  }

  // Get document type display name
  String get documentTypeName {
    switch (documentType) {
      case KYCDocumentType.ktp:
        return 'KTP';
      case KYCDocumentType.kk:
        return 'Kartu Keluarga';
      case KYCDocumentType.akteKelahiran:
        return 'Akte Kelahiran';
    }
  }

  // Copy with method
  KYCDocumentModel copyWith({
    String? id,
    String? userId,
    KYCDocumentType? documentType,
    String? storagePath,
    String? blobName,
    KYCStatus? status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    OCRResult? ocrResult,
    FaceDetectionResult? faceDetection,
    Map<String, dynamic>? additionalData,
  }) {
    return KYCDocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      storagePath: storagePath ?? this.storagePath,
      blobName: blobName ?? this.blobName,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      ocrResult: ocrResult ?? this.ocrResult,
      faceDetection: faceDetection ?? this.faceDetection,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
