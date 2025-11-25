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
import '../models/kyc_document_model.dart';
import 'azure_blob_storage_service.dart';
import 'ocr_service.dart';

class KYCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AzureBlobStorageService _azureApiService;
  final OCRService _ocrService = OCRService();

  KYCService(this._azureApiService);

  static Future<KYCService> init() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return KYCService(AzureBlobStorageService(firebaseToken: token ?? ''));
  }

  // Collection reference
  CollectionReference get _kycCollection =>
      _firestore.collection('kyc_documents');

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
        print('📤 Uploading KYC document via API...');
        print('Document Type: $documentType');
      }

      // Process OCR if enabled
      OCRResult? ocrResult;
      if (enableOCR) {
        if (kDebugMode) print('🔍 Processing OCR...');

        // OCRService.processImage automatically detects document type (KTP/KK)
        // and uses appropriate extraction strategy
        ocrResult = await _ocrService.processImage(file);

        if (ocrResult != null) {
          if (kDebugMode) {
            print(
              '✅ OCR completed - NIK: ${ocrResult.nik}, Nama: ${ocrResult.nama}',
            );
            // Check detected document type
            final detectedType = ocrResult.additionalFields?['document_type'];
            if (detectedType != null) {
              print('📄 Detected document type: $detectedType');
            }
          }
        } else {
          if (kDebugMode) print('⚠️ OCR returned null result');
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

      // Extract blob path dari result
      // Result bisa berupa URL atau path
      String finalBlobName;

      if (result.startsWith('http')) {
        // Jika result adalah URL, extract path-nya
        final uri = Uri.parse(result);
        finalBlobName = uri.pathSegments.last;
      } else {
        // Jika result sudah berupa path
        finalBlobName = blobName;
      }

      if (kDebugMode) {
        print('✅ File uploaded successfully');
        print('Blob Name: $finalBlobName');
      }

      // Create document record in Firestore dengan storage path (permanent)
      final kycDoc = KYCDocumentModel(
        userId: userId,
        documentType: documentType,
        blobName: finalBlobName, // Simpan blob name
        uploadedAt: DateTime.now(),
        ocrResult: ocrResult,
      );

      final docRef = await _kycCollection.add(kycDoc.toMap());

      if (kDebugMode) {
        print('✅ KYC document record created with ID: ${docRef.id}');
      }

      return docRef.id;
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
    required String userId,
    required KYCDocumentType documentType,
  }) async {
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
