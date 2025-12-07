// ============================================================================
// SELLER SERVICE
// ============================================================================
// Service layer untuk seller management
// ============================================================================

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pending_seller_model.dart';
import '../repositories/pending_seller_repository.dart';
import 'azure_blob_storage_service.dart';
import '../configs/url_pcvk_api.dart';

class SellerService {
  final PendingSellerRepository _repository = PendingSellerRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AzureBlobStorageService? _azureStorage;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Initialize Azure Storage
  Future<void> _initAzureStorage() async {
    if (_azureStorage == null && currentUser != null) {
      final token = await currentUser!.getIdToken();
      if (token != null) {
        _azureStorage = AzureBlobStorageService(firebaseToken: token);
      }
    }
  }

  /// Check if user is already registered as seller
  Future<PendingSellerModel?> checkUserSellerStatus() async {
    if (currentUser == null) return null;
    return await _repository.getSellerByUserId(currentUser!.uid);
  }

  /// Submit seller registration
  Future<String?> submitSellerRegistration({
    required String namaLengkap,
    required String nik,
    required String namaToko,
    required String nomorTelepon,
    required String alamatToko,
    required String rt,
    required String rw,
    required String deskripsiUsaha,
    required List<String> kategoriProduk,
    required File fotoKTP,
    required File fotoSelfieKTP,
    File? fotoToko,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Initialize Azure Storage
      await _initAzureStorage();
      if (_azureStorage == null) {
        throw Exception('Gagal menginisialisasi Azure Storage');
      }

      // Check if already registered
      final existingSeller = await checkUserSellerStatus();
      if (existingSeller != null) {
        // Jika status REJECTED, izinkan daftar ulang (update existing document)
        if (existingSeller.status != SellerVerificationStatus.rejected) {
          throw Exception('User sudah terdaftar sebagai seller dengan status: ${existingSeller.status}');
        }
        print('ℹ️ User pernah ditolak, mendaftar ulang dengan update document...');
      }

      print('📤 Uploading KTP image...');
      // Upload images to Azure
      final ktpUrl = await _uploadImageToAzure(
        fotoKTP,
        prefixName: 'seller_documents/${currentUser!.uid}',
        customFileName: 'ktp_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      print('📤 Uploading Selfie KTP image...');
      final selfieUrl = await _uploadImageToAzure(
        fotoSelfieKTP,
        prefixName: 'seller_documents/${currentUser!.uid}',
        customFileName: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      String? tokoUrl;
      if (fotoToko != null) {
        print('📤 Uploading Toko image...');
        tokoUrl = await _uploadImageToAzure(
          fotoToko,
          prefixName: 'seller_documents/${currentUser!.uid}',
          customFileName: 'toko_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      if (ktpUrl == null || selfieUrl == null) {
        throw Exception('Gagal mengupload dokumen');
      }

      print('✅ All images uploaded successfully');
      print('KTP URL: $ktpUrl');
      print('Selfie URL: $selfieUrl');
      if (tokoUrl != null) print('Toko URL: $tokoUrl');

      // Create pending seller model
      final pendingSeller = PendingSellerModel(
        userId: currentUser!.uid,
        nik: nik,
        namaLengkap: namaLengkap,
        namaToko: namaToko,
        nomorTelepon: nomorTelepon,
        alamatToko: alamatToko,
        rt: rt,
        rw: rw,
        deskripsiUsaha: deskripsiUsaha,
        kategoriProduk: kategoriProduk,
        fotoKTPUrl: ktpUrl,
        fotoSelfieKTPUrl: selfieUrl,
        fotoTokoUrl: tokoUrl,
        createdAt: DateTime.now(),
      );

      // Save to repository
      return await _repository.createPendingSeller(pendingSeller);
    } catch (e) {
      print('❌ Error submitSellerRegistration: $e');
      rethrow;
    }
  }

  /// Upload image to Azure Blob Storage
  Future<String?> _uploadImageToAzure(
    File file, {
    required String prefixName,
    required String customFileName,
  }) async {
    try {
      if (_azureStorage == null) {
        print('⚠️ Azure Storage not initialized, initializing...');
        await _initAzureStorage();
      }

      if (_azureStorage == null) {
        print('❌ Azure Storage initialization failed');
        throw Exception('Gagal menginisialisasi Azure Storage. Pastikan PCVK API berjalan di ${UrlPCVKAPI.baseUrl}');
      }

      print('📡 Uploading to PCVK API: ${UrlPCVKAPI.baseUrl}');

      final response = await _azureStorage!.uploadImage(
        file: file,
        isPrivate: true, // Private untuk dokumen verifikasi
        prefixName: prefixName,
        customFileName: customFileName,
      );

      if (response != null) {
        print('✅ Image uploaded: ${response.blobUrl}');
        return response.blobUrl;
      }

      print('⚠️ Upload response is null');
      return null;
    } catch (e, stackTrace) {
      print('❌ Error uploading image to Azure: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ PCVK API URL: ${UrlPCVKAPI.baseUrl}');
      print('❌ PCVK API HTTPS: ${UrlPCVKAPI.isSSL}');
      rethrow; // Re-throw untuk di-catch di level atas
    }
  }

  /// Get all pending sellers (admin only)
  Stream<List<PendingSellerModel>> getPendingSellers() {
    return _repository.getAllPendingSellers();
  }

  /// Get sellers by status (admin only)
  Stream<List<PendingSellerModel>> getSellersByStatus(
      SellerVerificationStatus status) {
    return _repository.getSellersByStatus(status);
  }

  /// Approve seller (admin only)
  Future<bool> approveSeller(
    String sellerId, {
    String? catatanAdmin,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      return await _repository.approveSeller(
        sellerId,
        currentUser!.uid,
        catatanAdmin: catatanAdmin,
      );
    } catch (e) {
      print('❌ Error approveSeller: $e');
      return false;
    }
  }

  /// Reject seller (admin only)
  Future<bool> rejectSeller(
    String sellerId,
    String alasanPenolakan,
  ) async {
    try {
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      return await _repository.rejectSeller(
        sellerId,
        currentUser!.uid,
        alasanPenolakan,
      );
    } catch (e) {
      print('❌ Error rejectSeller: $e');
      return false;
    }
  }

  /// Suspend seller (admin only)
  Future<bool> suspendSeller(
    String userId,
    String alasan,
  ) async {
    try {
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      return await _repository.suspendSeller(
        userId,
        currentUser!.uid,
        alasan,
      );
    } catch (e) {
      print('❌ Error suspendSeller: $e');
      return false;
    }
  }

  /// Reactivate seller (admin only)
  Future<bool> reactivateSeller(String userId) async {
    try {
      if (currentUser == null) {
        throw Exception('User tidak terautentikasi');
      }

      return await _repository.reactivateSeller(
        userId,
        currentUser!.uid,
      );
    } catch (e) {
      print('❌ Error reactivateSeller: $e');
      return false;
    }
  }

  /// Get seller statistics (admin only)
  Future<Map<String, int>> getStatistics() async {
    return await _repository.getStatistics();
  }

  /// Delete pending seller (admin only)
  Future<bool> deletePendingSeller(String sellerId) async {
    return await _repository.deletePendingSeller(sellerId);
  }
}

