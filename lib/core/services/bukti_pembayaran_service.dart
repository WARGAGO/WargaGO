/// ============================================================================
/// BUKTI PEMBAYARAN SERVICE
/// ============================================================================
/// Service untuk mengelola upload bukti pembayaran iuran ke Azure Blob Storage
/// - Upload gambar ke Azure (public container)
/// - URL permanen (tidak expired seperti Firebase Storage)
/// - Integrasi dengan sistem pembayaran iuran
/// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/azure_blob_storage_service.dart';
import '../models/tagihan_model.dart';

class BuktiPembayaranService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AzureBlobStorageService _azureService;

  BuktiPembayaranService() {
    _initializeAzureService();
  }

  Future<void> _initializeAzureService() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Failed to get Firebase token');
      }

      _azureService = AzureBlobStorageService(
        firebaseToken: token,
      );

      if (kDebugMode) {
        print('✅ Azure Blob Storage Service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Azure service: $e');
      }
      rethrow;
    }
  }

  /// Upload bukti pembayaran ke Azure Blob Storage
  /// Returns: Permanent URL bukti pembayaran
  Future<String> uploadBuktiPembayaran({
    required File imageFile,
    required String userId,
    required String tagihanId,
  }) async {
    try {
      await _initializeAzureService(); // Re-initialize to get fresh token

      if (kDebugMode) {
        print('📤 Uploading bukti pembayaran...');
        print('User ID: $userId');
        print('Tagihan ID: $tagihanId');
        print('File: ${imageFile.path}');
      }

      // Generate custom filename untuk bukti pembayaran
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final customFileName = 'bukti_${tagihanId}_$timestamp';

      if (kDebugMode) {
        print('📝 Custom filename: $customFileName');
      }

      // Upload ke Azure Blob Storage (PUBLIC container)
      final uploadResponse = await _azureService.uploadImage(
        file: imageFile,
        isPrivate: false, // Public container - URL permanen
        prefixName: 'bukti_pembayaran', // Folder di Azure
        customFileName: customFileName,
      );

      if (uploadResponse == null) {
        throw Exception('Upload failed - no response');
      }

      // Get permanent URL (tanpa SAS token karena public)
      final permanentUrl = uploadResponse.blobUrl;

      if (kDebugMode) {
        print('✅ Bukti pembayaran uploaded successfully');
        print('📍 Permanent URL: $permanentUrl');
        print('📦 Blob Name: ${uploadResponse.blobName}');
      }

      return permanentUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading bukti pembayaran: $e');
      }
      rethrow;
    }
  }

  /// Proses pembayaran iuran dengan bukti transfer
  /// - Upload bukti ke Azure
  /// - Update tagihan (status + bukti)
  /// - Create record keuangan
  Future<void> prosesTagihanIuran({
    required String tagihanId,
    required File buktiImage,
    required String metodePembayaran,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        print('\n🔵 ========== PROSES PEMBAYARAN IURAN ==========');
        print('Tagihan ID: $tagihanId');
        print('User ID: $userId');
        print('Metode: $metodePembayaran');
      }

      // 1. Upload bukti pembayaran ke Azure
      final buktiUrl = await uploadBuktiPembayaran(
        imageFile: buktiImage,
        userId: userId,
        tagihanId: tagihanId,
      );

      if (kDebugMode) {
        print('✅ Step 1: Bukti uploaded - $buktiUrl');
      }

      // 2. Get tagihan data
      final tagihanDoc = await _firestore
          .collection('tagihan')
          .doc(tagihanId)
          .get();

      if (!tagihanDoc.exists) {
        throw Exception('Tagihan tidak ditemukan');
      }

      final tagihan = TagihanModel.fromMap(
        tagihanDoc.data()!,
        tagihanDoc.id,
      );

      if (kDebugMode) {
        print('✅ Step 2: Tagihan data loaded');
        print('   Jenis: ${tagihan.jenisIuranName}');
        print('   Nominal: ${tagihan.nominal}');
      }

      // 3. Update tagihan dengan bukti pembayaran
      // ⭐ UPDATED: Langsung set status "Lunas" (no verification needed)
      await _firestore
          .collection('tagihan')
          .doc(tagihanId)
          .update({
        'status': 'Lunas', // ⭐ Langsung Lunas, admin hanya monitoring
        'metodePembayaran': metodePembayaran,
        'buktiPembayaran': buktiUrl, // Permanent URL from Azure
        'tanggalBayar': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Step 3: Tagihan updated to Lunas');
      }

      // 4. Create keuangan record (pemasukan)
      await _firestore.collection('keuangan').add({
        'jenis': 'Pemasukan',
        'kategori': 'Iuran Warga',
        'subKategori': tagihan.jenisIuranName,
        'nominal': tagihan.nominal,
        'tanggal': FieldValue.serverTimestamp(),
        'keterangan':
            'Pembayaran ${tagihan.jenisIuranName} - ${tagihan.keluargaName}',
        'metodePembayaran': metodePembayaran,
        'buktiTransaksi': buktiUrl,
        'keluargaId': tagihan.keluargaId,
        'keluargaName': tagihan.keluargaName,
        'jenisIuranId': tagihan.jenisIuranId,
        'jenisIuranName': tagihan.jenisIuranName,
        'tagihanId': tagihanId,
        'periode': tagihan.periode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      if (kDebugMode) {
        print('✅ Step 4: Keuangan record created');
        print('🎉 ========== PEMBAYARAN BERHASIL & LUNAS ==========\n');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ ========== PEMBAYARAN GAGAL ==========');
        print('Error: $e\n');
      }
      rethrow;
    }
  }

  /// Delete bukti pembayaran dari Azure (jika diperlukan)
  Future<void> deleteBuktiPembayaran({
    required String blobName,
  }) async {
    try {
      await _initializeAzureService();

      await _azureService.deleteFile(
        blobName: blobName,
        isPrivate: false, // Public container
      );

      if (kDebugMode) {
        print('✅ Bukti pembayaran deleted: $blobName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting bukti pembayaran: $e');
      }
      rethrow;
    }
  }
}

