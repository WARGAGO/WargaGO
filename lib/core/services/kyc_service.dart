// ============================================================================
// KYC SERVICE
// ============================================================================
// Service untuk mengelola KYC (Know Your Customer) documents
// Uses Azure API Backend for file upload
// ============================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:jawara/core/enums/kyc_enum.dart';
import 'package:jawara/core/models/KYC/kk_model.dart';
import 'package:jawara/core/models/KYC/ktp_model.dart';
import 'package:jawara/core/models/OCR/ocr_response.dart';
import '../models/KYC/kyc_document_model.dart';
import 'azure_blob_storage_service.dart';
import 'ocr_service.dart';

class KYCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final AzureBlobStorageService _azureApiService;

  late final Future<void> _doneFuture;
  Future get initializationDone => _doneFuture;

  final OCRService _ocrService = OCRService();

  KYCService() {
    _doneFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken() ?? '';
      _azureApiService = AzureBlobStorageService(firebaseToken: token);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing KYCService: $e');
      }
      rethrow;
    }
  }

  // Collection reference
  CollectionReference get _kycCollection =>
      _firestore.collection('kyc_documents');

  // Get user KYC documents as Stream (for real-time updates)
  Stream<QuerySnapshot> getUserKYCDocuments(String userId) {
    return _kycCollection.where('userId', isEqualTo: userId).snapshots();
  }

  // Upload KYC document via Azure API with OCR
  Future<String?> uploadDocument({
    required String userId,
    required KYCDocumentType documentType,
    required File file,
    bool enableOCR = true,
    String? customBlobName,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Processing KYC document via API...');
        print('Document Type: $documentType');
      }

      // Process OCR if enabled
      List<OcrResult> ocrResults = List.empty();
      if (enableOCR) {
        if (kDebugMode) print('🔍 Processing OCR...');
        final ocrResponse = await _ocrService.recognizeText(file);
        ocrResults = ocrResponse.results;

        if (kDebugMode) {
          print('OCR results:');
          for (final result in ocrResults) {
            print('text: ${result.text}');
            print('bbox: ${result.bbox}');
          }
        }

        if (ocrResults.length < 3) {
          throw Exception('OCR Is not in target document type');
        }
      }

      final docTypeStr = KYCDocumentModel.documentTypeToString(documentType);
      final blobName = customBlobName ?? 'kyc_$docTypeStr';
      if (kDebugMode) {
        print('📝 Blob name: $blobName');
      }

      final result = (await _azureApiService.uploadImage(
        file: file,
        customFileName: blobName,
      ))?.blobUrl;
      if (result == null) {
        throw Exception('Upload failed - no result returned');
      }
      if (kDebugMode) {
        print('✅ File uploaded successfully');
        print('Blob Name: $blobName');
      }

      late final KYCDocumentModel kycDoc;
      if (documentType == KYCDocumentType.ktp) {
        final ktp = KTPModel.fromOCR(ocrResults);
        if (kDebugMode) {
          print('✅ KTP extracted successfully');
        }

        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: blobName,
          uploadedAt: DateTime.now(),
          ktpModel: ktp,
        );
      } else if (documentType == KYCDocumentType.kk) {
        final kk = KKModel.fromOCR(ocrResults);
        if (kDebugMode) {
          print(kk.toMap());
          print('✅ KK extracted successfully');
        }

        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: blobName,
          uploadedAt: DateTime.now(),
          kkModel: kk,
        );
      }

      if (kDebugMode) {
        print(kycDoc.toMap());
      }
      final docRef = await _kycCollection.add(kycDoc.toMap());

      if (kDebugMode) {
        print('✅ KYC document record created with ID: ${docRef.id}');
      }

      return docRef.id;
      // return '';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading KYC document: $e');
      }
      rethrow;
    }
  }

  // Get all KYC documents for a user
  Future<List<KYCDocumentModel>> getUserDocuments(String userId) async {
    try {
      final snapshot = await _kycCollection
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => KYCDocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user documents: $e');
      }
      return [];
    }
  }

  // Get specific document by type for a user
  Future<KYCDocumentModel?> getUserDocumentByType({
    String? userId,
    required KYCDocumentType documentType,
  }) async {
    if (userId == null) {
      final user = FirebaseAuth.instance.currentUser!;
      userId = user.uid;
    }

    try {
      final snapshot = await _kycCollection
          .where('userId', isEqualTo: userId)
          .where(
            'documentType',
            isEqualTo: KYCDocumentModel.documentTypeToString(documentType),
          )
          .orderBy('uploadedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return KYCDocumentModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting document by type: $e');
      }
      return null;
    }
  }

  // Check if user has verified KYC
  Future<bool> isUserVerified(String userId) async {
    try {
      final documents = await getUserDocuments(userId);

      // User is verified if they have at least one approved document
      return documents.any((doc) => doc.status == KYCStatus.approved);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking user verification: $e');
      }
      return false;
    }
  }

  // Get pending KYC documents (for admin)
  Future<List<KYCDocumentModel>> getPendingDocuments() async {
    try {
      final snapshot = await _kycCollection
          .where('status', isEqualTo: 'pending')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => KYCDocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting pending documents: $e');
      }
      return [];
    }
  }

  // Approve KYC document
  Future<void> approveDocument({
    required String documentId,
    required String adminId,
  }) async {
    try {
      await _kycCollection.doc(documentId).update({
        'status': 'approved',
        'verifiedAt': Timestamp.now(),
        'verifiedBy': adminId,
        'rejectionReason': null,
      });

      if (kDebugMode) {
        print('✅ Document approved: $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error approving document: $e');
      }
      rethrow;
    }
  }

  // Reject KYC document
  Future<void> rejectDocument({
    required String documentId,
    required String adminId,
    required String reason,
  }) async {
    try {
      await _kycCollection.doc(documentId).update({
        'status': 'rejected',
        'verifiedAt': Timestamp.now(),
        'verifiedBy': adminId,
        'rejectionReason': reason,
      });

      if (kDebugMode) {
        print('✅ Document rejected: $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error rejecting document: $e');
      }
      rethrow;
    }
  }

  // Delete KYC document
  Future<void> deleteDocument(String documentId) async {
    try {
      // Get document data first to delete from Azure
      final doc = await _kycCollection.doc(documentId).get();
      if (doc.exists) {
        final kycDoc = KYCDocumentModel.fromFirestore(doc);

        // Delete from Azure via API menggunakan blobName
        if (kycDoc.blobName.isNotEmpty) {
          try {
            await _azureApiService.deleteFile(
              blobName: kycDoc.blobName,
              isPrivate: true,
            );
            if (kDebugMode) {
              print('✅ File deleted from Azure: ${kycDoc.blobName}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error deleting file from Azure: $e');
            }
          }
        }
      }

      // Delete document from Firestore
      await _kycCollection.doc(documentId).delete();

      if (kDebugMode) {
        print('✅ Document deleted from Firestore: $documentId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting document: $e');
      }
      rethrow;
    }
  }

  // Generate download URL on-demand dari storage path
  // URL akan fresh setiap kali dipanggil, tidak akan expired
  Future<String?> getDocumentUrl(String documentId) async {
    try {
      final doc = await _kycCollection.doc(documentId).get();
      if (!doc.exists) {
        if (kDebugMode) print('❌ Document not found: $documentId');
        return null;
      }

      final kycDoc = KYCDocumentModel.fromFirestore(doc);

      // Generate fresh URL dari blob name
      final url = await _azureApiService.getImages(
        filenamePrefix: kycDoc.blobName,
        isPrivate: true,
      );

      if (kDebugMode) {
        print('✅ Generated fresh URL for: ${kycDoc.blobName}');
      }

      return url?.images.first.blobUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating document URL: $e');
      }
      return null;
    }
  }

  // Get document URL by KYC document model
  Future<String?> getDocumentUrlFromModel(KYCDocumentModel kycDoc) async {
    try {
      // Generate fresh URL dari blob name
      final url = await _azureApiService.getImages(
        filenamePrefix: kycDoc.blobName,
        isPrivate: true,
      );

      if (kDebugMode) {
        print('✅ Generated fresh URL for: ${kycDoc.blobName}');
      }

      return url?.images.first.blobUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating document URL: $e');
      }
      return null;
    }
  }

  // Stream of user documents
  Stream<List<KYCDocumentModel>> streamUserDocuments(String userId) {
    return _kycCollection
        .where('userId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => KYCDocumentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream of pending documents (for admin)
  Stream<List<KYCDocumentModel>> streamPendingDocuments() {
    return _kycCollection
        .where('status', isEqualTo: 'pending')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => KYCDocumentModel.fromFirestore(doc))
              .toList(),
        );
  }
}
