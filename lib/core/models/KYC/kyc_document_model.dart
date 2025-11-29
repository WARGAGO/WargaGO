import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/enums/kyc_enum.dart';
import 'package:jawara/core/models/KYC/kk_model.dart';
import 'package:jawara/core/models/KYC/ktp_model.dart';

class KYCDocumentModel {
  final String? id;
  final String userId; // Reference to user
  final KYCDocumentType documentType;

  final String blobName;

  final KYCStatus status;
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy; // Admin ID who verified
  final KTPModel? ktpModel;
  final KKModel? kkModel;
  // final FaceDetectionResult? faceDetection;
  final Map<String, dynamic>? additionalData;

  KYCDocumentModel({
    this.id,
    required this.userId,
    required this.documentType,
    required this.blobName,
    this.status = KYCStatus.pending,
    this.rejectionReason,
    required this.uploadedAt,
    this.verifiedAt,
    this.verifiedBy,
    this.ktpModel,
    this.kkModel,
    // this.faceDetection,
    this.additionalData,
  });

  factory KYCDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KYCDocumentModel.fromMap(data, doc.id);
  }

  factory KYCDocumentModel.fromMap(Map<String, dynamic> map, String id) {
    return KYCDocumentModel(
      id: id,
      userId: map['userId'] ?? '',
      documentType: documentTypeFromString(map['documentType'] ?? 'ktp'),
      blobName: map['blobName'],
      status: statusFromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: map['verifiedBy'],
      ktpModel: map['ktpModel'] != null
          ? KTPModel.fromMap(map['ktpModel'])
          : null,
      kkModel: map['kkModel'] != null ? KKModel.fromMap(map['kkModel']) : null,
      // faceDetection: map['faceDetection'] != null
      //     ? FaceDetectionResult.fromMap(map['faceDetection'])
      //     : null,
      additionalData: map['additionalData'],
    );
  }

  // Convert to Map - hanya simpan storagePath & blobName
  Map<String, dynamic> toMap() {
    final value = {
      'userId': userId,
      'documentType': documentTypeToString(documentType),
      'blobName': blobName,
      'status': statusToString(status),
      'rejectionReason': rejectionReason,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      // 'faceDetection': faceDetection?.toMap(),
      'additionalData': additionalData,
    };
    if (documentType == KYCDocumentType.ktp) {
      value['ktpModel'] = ktpModel?.toMap();
    }
    if (documentType == KYCDocumentType.kk) {
      value['kkModel'] = kkModel?.toMap();
    }
    return value;
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
}
