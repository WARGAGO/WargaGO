import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../utils/azure_blob_url_helper.dart';

/// ============================================================================
/// CLEAN AZURE SAS TOKENS FROM FIRESTORE
/// ============================================================================
/// Script untuk clean SAS token parameters dari semua imageUrls di Firestore
///
/// CARA PAKAI:
/// 1. Import file ini
/// 2. Call: await CleanAzureSasTokens.cleanAllProducts()
/// 3. Script akan update semua product imageUrls
/// ============================================================================

class CleanAzureSasTokens {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clean SAS tokens from all products in marketplace_products collection
  static Future<void> cleanAllProducts() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('🔧 CLEANING SAS TOKENS FROM PRODUCT IMAGES');
    debugPrint('=' * 70);

    try {
      // Get all products
      final productsSnapshot = await _firestore
          .collection('marketplace_products')
          .get();

      debugPrint('📊 Found ${productsSnapshot.docs.length} products');

      int updated = 0;
      int skipped = 0;
      int errors = 0;

      for (var doc in productsSnapshot.docs) {
        try {
          final data = doc.data();
          final imageUrls = List<String>.from(data['imageUrls'] ?? []);

          if (imageUrls.isEmpty) {
            skipped++;
            continue;
          }

          // Check if any URL has SAS token
          final hasSasToken = imageUrls.any((url) =>
            AzureBlobUrlHelper.hasSasToken(url)
          );

          if (!hasSasToken) {
            debugPrint('⏭️  ${doc.id}: Already clean');
            skipped++;
            continue;
          }

          // Clean SAS tokens
          final cleanUrls = AzureBlobUrlHelper.cleanUrlList(imageUrls);

          debugPrint('🧹 ${doc.id}:');
          debugPrint('   Before: ${imageUrls.first}');
          debugPrint('   After:  ${cleanUrls.first}');

          // Update Firestore
          await doc.reference.update({
            'imageUrls': cleanUrls,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          updated++;
        } catch (e) {
          debugPrint('❌ Error updating ${doc.id}: $e');
          errors++;
        }
      }

      debugPrint('\n✅ Cleaning complete!');
      debugPrint('   - Updated: $updated products');
      debugPrint('   - Skipped: $skipped products (already clean or no images)');
      debugPrint('   - Errors: $errors products');
      debugPrint('=' * 70 + '\n');

    } catch (e) {
      debugPrint('❌ Script failed: $e');
      debugPrint('=' * 70 + '\n');
    }
  }

  /// Clean SAS tokens from products collection (alternative collection name)
  static Future<void> cleanProductsCollection() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('🔧 CLEANING SAS TOKENS FROM PRODUCTS COLLECTION');
    debugPrint('=' * 70);

    try {
      final productsSnapshot = await _firestore
          .collection('products')
          .get();

      debugPrint('📊 Found ${productsSnapshot.docs.length} products');

      int updated = 0;
      int skipped = 0;

      for (var doc in productsSnapshot.docs) {
        try {
          final data = doc.data();
          final imageUrls = List<String>.from(data['imageUrls'] ?? []);

          if (imageUrls.isEmpty) {
            skipped++;
            continue;
          }

          final hasSasToken = imageUrls.any((url) =>
            AzureBlobUrlHelper.hasSasToken(url)
          );

          if (!hasSasToken) {
            skipped++;
            continue;
          }

          final cleanUrls = AzureBlobUrlHelper.cleanUrlList(imageUrls);

          debugPrint('🧹 Cleaning: ${data['productName']}');

          await doc.reference.update({
            'imageUrls': cleanUrls,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          updated++;
        } catch (e) {
          debugPrint('❌ Error: $e');
        }
      }

      debugPrint('\n✅ Complete! Updated: $updated, Skipped: $skipped');
      debugPrint('=' * 70 + '\n');

    } catch (e) {
      debugPrint('❌ Failed: $e');
    }
  }

  /// Check how many products have SAS tokens
  static Future<void> checkStatus() async {
    debugPrint('\n' + '=' * 70);
    debugPrint('📊 CHECKING SAS TOKEN STATUS');
    debugPrint('=' * 70);

    try {
      final collections = ['marketplace_products', 'products'];

      for (var collectionName in collections) {
        final snapshot = await _firestore.collection(collectionName).get();

        if (snapshot.docs.isEmpty) continue;

        int withSas = 0;
        int withoutSas = 0;
        int noImages = 0;

        for (var doc in snapshot.docs) {
          final imageUrls = List<String>.from(
            doc.data()['imageUrls'] ?? []
          );

          if (imageUrls.isEmpty) {
            noImages++;
          } else if (imageUrls.any((url) => AzureBlobUrlHelper.hasSasToken(url))) {
            withSas++;
          } else {
            withoutSas++;
          }
        }

        debugPrint('\nCollection: $collectionName');
        debugPrint('   Total: ${snapshot.docs.length}');
        debugPrint('   ⚠️  With SAS tokens: $withSas');
        debugPrint('   ✅ Without SAS tokens: $withoutSas');
        debugPrint('   📷 No images: $noImages');
      }

      debugPrint('=' * 70 + '\n');

    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}

