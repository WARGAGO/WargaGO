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
import 'package:wargago/core/enums/kyc_enum.dart';
import 'package:wargago/core/models/KYC/kk_model.dart';
import 'package:wargago/core/models/KYC/ktp_model.dart';
import 'package:wargago/core/models/OCR/ocr_response.dart';
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
      // Ensure initialization is complete
      await _doneFuture;

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
      final customFileName = customBlobName ?? 'kyc_$docTypeStr';
      if (kDebugMode) {
        print('📝 Custom file name: $customFileName');
      }

      final uploadResponse = await _azureApiService.uploadImage(
        file: file,
        customFileName: customFileName,
      );

      if (uploadResponse == null) {
        throw Exception('Upload failed - no result returned');
      }

      // Use actual blob name from Azure response, not custom filename
      final actualBlobName = uploadResponse.blobName;

      if (kDebugMode) {
        print('✅ File uploaded successfully');
        print('Actual Blob Name: $actualBlobName');
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
          blobName: actualBlobName,
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
          blobName: actualBlobName,
          uploadedAt: DateTime.now(),
          kkModel: kk,
        );
      } else {
        // For other document types (akteKelahiran, etc.) without OCR extraction
        if (kDebugMode) {
          print('✅ Document uploaded (no OCR extraction for this type)');
        }

        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: actualBlobName,
          uploadedAt: DateTime.now(),
          additionalData: enableOCR && ocrResults.isNotEmpty
              ? {'ocrResults': ocrResults.map((r) => r.toJson()).toList()}
              : null,
        );
      }

      if (kDebugMode) {
        print(kycDoc.toMap());
      }
      final docRef = await _kycCollection.add(kycDoc.toMap());

      // Update user status to 'pending' after successful upload
      await _firestore.collection('users').doc(userId).update({
        'status': 'pending',
        'updatedAt': Timestamp.now(),
      });

      if (kDebugMode) {
        print('✅ KYC document record created with ID: ${docRef.id}');
        print('✅ User status updated to pending');
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

  // Upload KYC document with pre-confirmed data (untuk KTP yang sudah di-konfirmasi user)
  Future<String?> uploadDocumentWithData({
    required String userId,
    required KYCDocumentType documentType,
    required File file,
    KTPModel? ktpData,
    KKModel? kkData,
    String? customBlobName,
  }) async {
    try {
      // Ensure initialization is complete
      await _doneFuture;

      if (kDebugMode) {
        print('📤 Processing KYC document with confirmed data via API...');
        print('Document Type: $documentType');
      }

      final docTypeStr = KYCDocumentModel.documentTypeToString(documentType);
      final customFileName = customBlobName ?? 'kyc_$docTypeStr';
      if (kDebugMode) {
        print('📝 Custom file name: $customFileName');
      }

      final uploadResponse = await _azureApiService.uploadImage(
        file: file,
        customFileName: customFileName,
      );

      if (uploadResponse == null) {
        throw Exception('Upload failed - no result returned');
      }

      // Use actual blob name from Azure response
      final actualBlobName = uploadResponse.blobName;

      if (kDebugMode) {
        print('✅ File uploaded successfully');
        print('Actual Blob Name: $actualBlobName');
      }

      late final KYCDocumentModel kycDoc;
      if (documentType == KYCDocumentType.ktp && ktpData != null) {
        if (kDebugMode) {
          print('✅ Using confirmed KTP data');
          print('NIK: ${ktpData.nik}');
          print('Nama: ${ktpData.nama}');
        }

        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: actualBlobName,
          uploadedAt: DateTime.now(),
          ktpModel: ktpData,
        );
      } else if (documentType == KYCDocumentType.kk && kkData != null) {
        if (kDebugMode) {
          print('✅ Using confirmed KK data');
        }

        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: actualBlobName,
          uploadedAt: DateTime.now(),
          kkModel: kkData,
        );
      } else {
        // Fallback: upload without specific data
        kycDoc = KYCDocumentModel(
          userId: userId,
          documentType: documentType,
          blobName: actualBlobName,
          uploadedAt: DateTime.now(),
        );
      }

      if (kDebugMode) {
        print('KYC Document data:');
        print(kycDoc.toMap());
      }
      final docRef = await _kycCollection.add(kycDoc.toMap());

      // Update user status to 'pending' after successful upload
      await _firestore.collection('users').doc(userId).update({
        'status': 'pending',
        'updatedAt': Timestamp.now(),
      });

      if (kDebugMode) {
        print('✅ KYC document record created with ID: ${docRef.id}');
        print('✅ User status updated to pending');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading KYC document with data: $e');
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
      // Get document first to get user ID
      final doc = await _kycCollection.doc(documentId).get();
      if (!doc.exists) {
        throw Exception('Document not found');
      }

      final kycDoc = KYCDocumentModel.fromFirestore(doc);

      // Update KYC document status
      await _kycCollection.doc(documentId).update({
        'status': 'approved',
        'verifiedAt': Timestamp.now(),
        'verifiedBy': adminId,
        'rejectionReason': null,
      });

      if (kDebugMode) {
        print('✅ Document approved: $documentId');
      }

      // Check if required KYC documents are now approved
      // ⭐ UPDATED: Only KTP is required, KK is optional
      final userDocs = await _kycCollection
          .where('userId', isEqualTo: kycDoc.userId)
          .get();

      bool hasApprovedKTP = false;
      bool hasApprovedKK = false;

      for (var doc in userDocs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final docType = data['documentType'] as String?;
        final status = data['status'] as String?;

        if (docType == 'ktp' && status == 'approved') {
          hasApprovedKTP = true;
        } else if (docType == 'kk' && status == 'approved') {
          hasApprovedKK = true;
        }
      }

      // ⭐ UPDATED: Update user status to 'approved' if KTP is approved (KK is optional)
      if (hasApprovedKTP) {
        await _firestore.collection('users').doc(kycDoc.userId).update({
          'status': 'approved',
          'updatedAt': Timestamp.now(),
        });

        if (kDebugMode) {
          print('✅ KTP approved - User status updated to approved: ${kycDoc.userId}');
          if (hasApprovedKK) {
            print('   (KK also approved)');
          } else {
            print('   (KK optional - not required)');
          }
        }
      } else {
        // Keep status as 'pending' if KTP is not approved yet
        await _firestore.collection('users').doc(kycDoc.userId).update({
          'status': 'pending',
          'updatedAt': Timestamp.now(),
        });

        if (kDebugMode) {
          print('⏳ KTP not approved yet - User status remains pending: ${kycDoc.userId}');
          print('   KTP approved: $hasApprovedKTP (required), KK approved: $hasApprovedKK (optional)');
        }
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
      // Get document first to get user ID
      final doc = await _kycCollection.doc(documentId).get();
      if (!doc.exists) {
        throw Exception('Document not found');
      }

      final kycDoc = KYCDocumentModel.fromFirestore(doc);

      // Update KYC document status
      await _kycCollection.doc(documentId).update({
        'status': 'rejected',
        'verifiedAt': Timestamp.now(),
        'verifiedBy': adminId,
        'rejectionReason': reason,
      });

      // Update user status to 'rejected' (or 'unverified' to allow re-upload)
      await _firestore.collection('users').doc(kycDoc.userId).update({
        'status': 'unverified', // Set to unverified so user can re-upload
        'updatedAt': Timestamp.now(),
      });

      if (kDebugMode) {
        print('✅ Document rejected: $documentId');
        print('✅ User status updated to unverified: ${kycDoc.userId}');
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
      // Ensure initialization is complete
      await _doneFuture;

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
      // Ensure initialization is complete
      await _doneFuture;

      final doc = await _kycCollection.doc(documentId).get();
      if (!doc.exists) {
        if (kDebugMode) print('❌ Document not found: $documentId');
        return null;
      }

      final kycDoc = KYCDocumentModel.fromFirestore(doc);

      if (kDebugMode) {
        print('🔍 Fetching URL for blob: ${kycDoc.blobName}');
        print('   User ID: ${kycDoc.userId}');
      }

      // Strategy 1: Try with exact blob name first
      var url = await _azureApiService.getImages(
        uid: kycDoc.userId,
        filenamePrefix: kycDoc.blobName,
        isPrivate: true,
      );

      if (kDebugMode) {
        print('✅ API Response received (exact match)');
        print('   Images count: ${url?.images.length ?? 0}');
      }

      // Strategy 2: If not found, try with filename only
      if (url == null || url.images.isEmpty) {
        String filenameOnly = kycDoc.blobName;
        if (filenameOnly.contains('/')) {
          filenameOnly = filenameOnly.split('/').last;
        }
        if (filenameOnly.contains('.')) {
          filenameOnly = filenameOnly.split('.').first;
        }

        if (kDebugMode) {
          print('🔄 Trying fallback search with: $filenameOnly');
        }

        url = await _azureApiService.getImages(
          uid: kycDoc.userId,
          filenamePrefix: filenameOnly,
          isPrivate: true,
        );

        if (kDebugMode) {
          print('✅ API Response received (fallback)');
          print('   Images count: ${url?.images.length ?? 0}');
        }
      }

      // Check if images list is not empty
      if (url != null && url.images.isNotEmpty) {
        if (kDebugMode) {
          print('✅ Found image: ${url.images.first.blobName}');
        }
        return url.images.first.blobUrl;
      } else {
        if (kDebugMode) {
          print('⚠️ No images found for blob: ${kycDoc.blobName}');
        }
        return null;
      }
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
      // Ensure initialization is complete
      await _doneFuture;

      if (kDebugMode) {
        print('🔍 Fetching URL for blob: ${kycDoc.blobName}');
        print('   User ID: ${kycDoc.userId}');
      }

      // Strategy 1: Try with exact blob name first
      var url = await _azureApiService.getImages(
        uid: kycDoc.userId,
        filenamePrefix: kycDoc.blobName,
        isPrivate: true,
      );

      if (kDebugMode) {
        print('✅ API Response received (exact match)');
        print('   Images count: ${url?.images.length ?? 0}');
      }

      // Strategy 2: If not found, try with filename only (remove user_id/ prefix if present)
      if (url == null || url.images.isEmpty) {
        // Extract filename from full path (e.g., "user_id/kyc_ktp.webp" -> "kyc_ktp")
        String filenameOnly = kycDoc.blobName;
        if (filenameOnly.contains('/')) {
          filenameOnly = filenameOnly.split('/').last;
        }
        // Remove extension
        if (filenameOnly.contains('.')) {
          filenameOnly = filenameOnly.split('.').first;
        }

        if (kDebugMode) {
          print('🔄 Trying fallback search with: $filenameOnly');
        }

        url = await _azureApiService.getImages(
          uid: kycDoc.userId,
          filenamePrefix: filenameOnly,
          isPrivate: true,
        );

        if (kDebugMode) {
          print('✅ API Response received (fallback)');
          print('   Images count: ${url?.images.length ?? 0}');
        }
      }

      if (url != null && url.images.isNotEmpty) {
        if (kDebugMode) {
          print('✅ Found image: ${url.images.first.blobName}');
        }
        return url.images.first.blobUrl;
      } else {
        if (kDebugMode) {
          print('⚠️ No images found for blob: ${kycDoc.blobName}');
          print('   This might mean:');
          print('   1. File was deleted from Azure');
          print('   2. Blob name mismatch');
          print('   3. User ID mismatch');
          print('   💡 Tip: Ask user to re-upload document');
        }
        return null;
      }
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
