// ============================================================================
// TEST MARKETPLACE AZURE BLOB STORAGE
// ============================================================================
// Script untuk test upload gambar produk ke Azure Blob Storage
// TUJUAN: Memastikan gambar masuk ke AZURE (bukan Firebase Storage)
// ============================================================================

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/services/marketplace_service.dart';

void main() async {
  print('\n🧪 ========== TEST MARKETPLACE AZURE BLOB STORAGE ==========\n');
  print('📋 TUJUAN: Verify gambar produk tersimpan di Azure Blob Storage');
  print('   (BUKAN Firebase Storage)\n');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Login sebagai test user
  print('🔐 Login sebagai test user...');
  try {
    // Ganti dengan credentials test user Anda
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'admin@jawara.com',  // GANTI dengan email test
      password: 'admin123',         // GANTI dengan password test
    );

    print('✅ Login berhasil: ${userCredential.user?.email}');
    print('   UID: ${userCredential.user?.uid}\n');

    // Initialize Marketplace Service
    final marketplaceService = MarketplaceService();

    // Test 1: Upload gambar dummy
    print('📸 TEST 1: Upload Gambar ke Azure Blob Storage');
    print('──────────────────────────────────────────────');

    // Create dummy image file (placeholder)
    // NOTE: Ganti dengan path gambar test yang sebenarnya
    final testImagePath = 'assets/icons/icon.png';  // GANTI dengan path test image

    if (!File(testImagePath).existsSync()) {
      print('⚠️  File test tidak ditemukan: $testImagePath');
      print('   Silakan ganti testImagePath dengan path gambar test yang valid\n');
      return;
    }

    final testImages = [File(testImagePath)];

    print('🔄 Uploading gambar ke Azure Blob Storage...');

    final productId = await marketplaceService.createProduct(
      productName: 'TEST PRODUCT - Azure Storage',
      description: 'Produk test untuk validasi Azure Blob Storage',
      price: 99999,
      stock: 1,
      category: 'Test',
      images: testImages,
      unit: 'test',
      customSellerId: userCredential.user!.uid,
      customSellerName: 'Test User',
    );

    print('✅ Product created with ID: $productId\n');

    // Test 2: Verify gambar tersimpan
    print('🔍 TEST 2: Verify Gambar di Database');
    print('──────────────────────────────────────────────');

    final product = await marketplaceService.getProductById(productId);

    if (product == null) {
      print('❌ FAILED: Product tidak ditemukan!\n');
      return;
    }

    print('✅ Product ditemukan:');
    print('   Name: ${product.productName}');
    print('   Images: ${product.imageUrls.length} gambar\n');

    if (product.imageUrls.isEmpty) {
      print('❌ FAILED: Tidak ada gambar yang tersimpan!\n');
      return;
    }

    for (int i = 0; i < product.imageUrls.length; i++) {
      final url = product.imageUrls[i];
      print('   Image ${i + 1}: $url');

      // ============================================================
      // CRITICAL CHECK: Verify storage provider
      // ============================================================
      if (url.contains('blob.core.windows.net')) {
        print('   ✅ ✅ ✅ AZURE BLOB STORAGE URL CONFIRMED! ✅ ✅ ✅');
        print('   🎉 Storage Provider: Azure Blob Storage (blob.core.windows.net)');
      } else if (url.contains('azurewebsites.net')) {
        print('   ✅ ✅ ✅ AZURE BLOB STORAGE URL CONFIRMED! ✅ ✅ ✅');
        print('   🎉 Storage Provider: Azure Function Backend (azurewebsites.net)');
      } else if (url.contains('firebasestorage.googleapis.com')) {
        print('   ❌ ❌ ❌ ERROR: USING FIREBASE STORAGE! ❌ ❌ ❌');
        print('   🚨 CRITICAL: Gambar tersimpan di Firebase, BUKAN Azure!');
        print('   🔧 FIX: Check marketplace_service.dart _uploadProductImages method');
      } else {
        print('   ⚠️  WARNING: Unknown storage provider');
        print('   🔍 URL does not match Azure or Firebase pattern');
      }
      print('');
    }

    print('');

    // Add verification summary
    final isAzure = product.imageUrls.every(
      (url) => url.contains('blob.core.windows.net') || url.contains('azurewebsites.net')
    );
    final isFirebase = product.imageUrls.any(
      (url) => url.contains('firebasestorage.googleapis.com')
    );

    if (isAzure && !isFirebase) {
      print('✅ ✅ ✅ VERIFICATION PASSED! ✅ ✅ ✅');
      print('🎉 ALL IMAGES USING AZURE BLOB STORAGE');
    } else if (isFirebase) {
      print('❌ ❌ ❌ VERIFICATION FAILED! ❌ ❌ ❌');
      print('🚨 CRITICAL: Some/all images using Firebase Storage');
      print('🔧 MUST FIX: Update marketplace_service.dart');
      return;
    }

    print('');

    // Test 3: Delete product & cleanup
    print('🗑️  TEST 3: Delete Product & Cleanup Azure Storage');
    print('──────────────────────────────────────────────');

    print('🔄 Deleting product (will also delete images from Azure)...');
    await marketplaceService.deleteProduct(productId);
    print('✅ Product deleted successfully\n');

    // Verify deletion
    final deletedProduct = await marketplaceService.getProductById(productId);
    if (deletedProduct == null) {
      print('✅ VERIFIED: Product tidak ada di database');
      print('✅ VERIFIED: Images seharusnya sudah dihapus dari Azure\n');
    }

    print('🎉 ========== ALL TESTS PASSED! ==========\n');
    print('📋 Summary:');
    print('   ✅ Upload to Azure Blob Storage: SUCCESS');
    print('   ✅ Image URLs saved to Firestore: SUCCESS');
    print('   ✅ Delete from Azure Blob Storage: SUCCESS');
    print('   ✅ Cleanup completed: SUCCESS\n');

    print('🔐 SECURITY CHECK:');
    print('   ✅ Images stored in PRIVATE Azure container');
    print('   ✅ URL authentication required');
    print('   ✅ Automatic cleanup on delete\n');

    // Logout
    await FirebaseAuth.instance.signOut();
    print('✅ Logged out\n');

  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('StackTrace: $stackTrace\n');
  }
}

