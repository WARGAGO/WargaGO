// ============================================================================
// MARKETPLACE SERVICE
// ============================================================================
// Service untuk handle CRUD operations marketplace dengan Azure Blob Storage
// Secure cloud storage untuk gambar produk (KONSISTEN dengan KYC system)
// ============================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/marketplace_product_model.dart';
import 'azure_blob_storage_service.dart';

class MarketplaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _productsCollection = 'marketplace_products';
  static const String _azureStoragePrefix = 'marketplace/products';

  // Azure Blob Storage Service instance
  AzureBlobStorageService? _azureStorage;

  // Initialize Azure Blob Storage
  Future<void> _initAzureStorage() async {
    if (_azureStorage != null) return;

    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User tidak terautentikasi');
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Gagal mendapatkan token');
    }

    _azureStorage = AzureBlobStorageService(firebaseToken: token);
  }

  // ============================================================================
  // CREATE - Tambah Produk Baru dengan Upload Gambar
  // ============================================================================
  Future<String> createProduct({
    required String productName,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<File> images, // Multiple images
    required String unit,
    String? customSellerId,
    String? customSellerName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null && customSellerId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final sellerId = customSellerId ?? user!.uid;

      // Get seller name from Firestore if not provided
      String sellerName = customSellerName ?? '';
      if (sellerName.isEmpty) {
        final userDoc = await _firestore.collection('users').doc(sellerId).get();
        sellerName = userDoc.data()?['nama_lengkap'] ?? 'Penjual';
      }

      // Upload images to Firebase Storage
      final imageUrls = await _uploadProductImages(sellerId, images);

      if (imageUrls.isEmpty) {
        throw Exception('Gagal upload gambar produk');
      }

      // Create product document
      final productRef = _firestore.collection(_productsCollection).doc();
      final product = MarketplaceProductModel(
        id: productRef.id,
        sellerId: sellerId,
        sellerName: sellerName,
        productName: productName,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrls: imageUrls,
        unit: unit,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await productRef.set(product.toMap());

      if (kDebugMode) {
        print('✅ Produk berhasil dibuat: ${product.id}');
      }

      return productRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating product: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get All Products (dengan filter & pagination)
  // ============================================================================
  Future<List<MarketplaceProductModel>> getAllProducts({
    String? category,
    bool? isActive,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore.collection(_productsCollection);

      // STRATEGY: Simplified query to avoid index requirements during development
      // For production, enable the full query with composite indexes

      // If category is specified, use it as the only filter
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);

        // Add isActive filter
        if (isActive != null) {
          query = query.where('isActive', isEqualTo: isActive);
        }

        // Try to add orderBy with composite index
        try {
          query = query.orderBy('createdAt', descending: true);
        } catch (e) {
          // Index not ready yet, will sort client-side
          if (kDebugMode) {
            print('⚠️ Composite index not ready, will sort client-side');
          }
        }
      } else {
        // No category filter - simpler query
        // Just get all or filter by isActive only
        if (isActive != null) {
          query = query.where('isActive', isEqualTo: isActive);
        }

        // Simple orderBy (no composite index needed if no other where clause)
        query = query.orderBy('createdAt', descending: true);
      }

      // Pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();

      final products = snapshot.docs
          .map((doc) => MarketplaceProductModel.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('✅ Query success: ${products.length} products loaded');
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products: $e');
        print('🔄 Trying fallback query without orderBy...');
      }

      // FALLBACK: Query tanpa orderBy untuk avoid index requirement
      // Digunakan saat index masih building atau belum di-deploy
      try {
        Query fallbackQuery = _firestore.collection(_productsCollection);

        // Just get active products (simple where clause)
        if (isActive != null) {
          fallbackQuery = fallbackQuery.where('isActive', isEqualTo: isActive);
        }

        // No orderBy to avoid index requirement
        fallbackQuery = fallbackQuery.limit(limit * 2); // Get more to compensate for client-side filtering

        final snapshot = await fallbackQuery.get();

        // Process di client side
        final products = snapshot.docs
            .map((doc) => MarketplaceProductModel.fromFirestore(doc))
            .toList();

        // Filter by category di client side jika diperlukan
        if (category != null && category.isNotEmpty) {
          products.retainWhere((p) => p.category == category);
        }

        // Sort by createdAt di client side
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (kDebugMode) {
          print('✅ Fallback query success: ${products.length} products');
        }

        return products.take(limit).toList();
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Fallback query also failed: $fallbackError');
        }

        // ULTIMATE FALLBACK: Just get all documents without any filter
        try {
          final snapshot = await _firestore
              .collection(_productsCollection)
              .limit(limit * 3)
              .get();

          final products = snapshot.docs
              .map((doc) => MarketplaceProductModel.fromFirestore(doc))
              .toList();

          // Filter by isActive
          if (isActive != null) {
            products.retainWhere((p) => p.isActive == isActive);
          }

          // Filter by category
          if (category != null && category.isNotEmpty) {
            products.retainWhere((p) => p.category == category);
          }

          // Sort by createdAt
          products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (kDebugMode) {
            print('✅ Ultimate fallback success: ${products.length} products');
          }

          return products.take(limit).toList();
        } catch (ultimateError) {
          if (kDebugMode) {
            print('❌ All queries failed: $ultimateError');
          }
          // Return empty list instead of throwing to prevent app crash
          return [];
        }
      }
    }
  }

  // ============================================================================
  // READ - Get Products by Seller
  // ============================================================================
  Future<List<MarketplaceProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MarketplaceProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting seller products: $e');
        print('🔄 Trying fallback query...');
      }

      // FALLBACK: Query tanpa orderBy
      try {
        final snapshot = await _firestore
            .collection(_productsCollection)
            .where('sellerId', isEqualTo: sellerId)
            .get();

        // Sort di client side
        final products = snapshot.docs
            .map((doc) => MarketplaceProductModel.fromFirestore(doc))
            .toList();

        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (kDebugMode) {
          print('✅ Fallback query success: ${products.length} products');
        }

        return products;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Fallback query also failed: $fallbackError');
        }
        rethrow;
      }
    }
  }

  // ============================================================================
  // READ - Get Single Product by ID
  // ============================================================================
  Future<MarketplaceProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      return MarketplaceProductModel.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting product: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Search Products by Name
  // ============================================================================
  Future<List<MarketplaceProductModel>> searchProducts(String keyword) async {
    try {
      QuerySnapshot snapshot;

      // Try with orderBy first (requires composite index)
      try {
        snapshot = await _firestore
            .collection(_productsCollection)
            .where('isActive', isEqualTo: true)
            .orderBy('productName')
            .get();
      } catch (e) {
        // Fallback: If index not ready, get without orderBy
        if (kDebugMode) {
          print('⚠️ Composite index not ready, using fallback query');
        }
        snapshot = await _firestore
            .collection(_productsCollection)
            .where('isActive', isEqualTo: true)
            .get();
      }

      // Filter by keyword (case insensitive) - client-side filtering
      final products = snapshot.docs
          .map((doc) => MarketplaceProductModel.fromFirestore(doc))
          .where((product) =>
              product.productName.toLowerCase().contains(keyword.toLowerCase()))
          .toList();

      // Sort by name (client-side)
      products.sort((a, b) => a.productName.compareTo(b.productName));

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Update Product
  // ============================================================================
  Future<void> updateProduct({
    required String productId,
    String? productName,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<File>? newImages, // New images to add
    List<String>? removeImageUrls, // URLs of images to remove
    String? unit,
    bool? isActive,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Get existing product
      final existingProduct = await getProductById(productId);
      if (existingProduct == null) {
        throw Exception('Produk tidak ditemukan');
      }

      // Verify ownership
      if (existingProduct.sellerId != user.uid) {
        throw Exception('Anda tidak memiliki izin untuk mengupdate produk ini');
      }

      Map<String, dynamic> updates = {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (productName != null) updates['productName'] = productName;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (stock != null) updates['stock'] = stock;
      if (category != null) updates['category'] = category;
      if (unit != null) updates['unit'] = unit;
      if (isActive != null) updates['isActive'] = isActive;

      // Handle image updates
      List<String> currentImages = List<String>.from(existingProduct.imageUrls);

      // Remove old images if specified
      if (removeImageUrls != null && removeImageUrls.isNotEmpty) {
        for (final url in removeImageUrls) {
          await _deleteImageFromStorage(url);
          currentImages.remove(url);
        }
      }

      // Add new images if specified
      if (newImages != null && newImages.isNotEmpty) {
        final newUrls = await _uploadProductImages(user.uid, newImages);
        currentImages.addAll(newUrls);
      }

      updates['imageUrls'] = currentImages;

      await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .update(updates);

      if (kDebugMode) {
        print('✅ Produk berhasil diupdate: $productId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // DELETE - Delete Product
  // ============================================================================
  Future<void> deleteProduct(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Get existing product
      final existingProduct = await getProductById(productId);
      if (existingProduct == null) {
        throw Exception('Produk tidak ditemukan');
      }

      // Verify ownership
      if (existingProduct.sellerId != user.uid) {
        throw Exception('Anda tidak memiliki izin untuk menghapus produk ini');
      }

      // Delete all product images from storage
      for (final imageUrl in existingProduct.imageUrls) {
        await _deleteImageFromStorage(imageUrl);
      }

      // Delete product document
      await _firestore.collection(_productsCollection).doc(productId).delete();

      if (kDebugMode) {
        print('✅ Produk berhasil dihapus: $productId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting product: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Update Stock (after purchase)
  // ============================================================================
  Future<void> updateStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Produk tidak ditemukan');
      }

      final newStock = product.stock - quantity;
      if (newStock < 0) {
        throw Exception('Stok tidak mencukupi');
      }

      await _firestore.collection(_productsCollection).doc(productId).update({
        'stock': newStock,
        'soldCount': product.soldCount + quantity,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (kDebugMode) {
        print('✅ Stok berhasil diupdate: $productId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating stock: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // STREAM - Real-time Products Stream
  // ============================================================================
  Stream<List<MarketplaceProductModel>> getProductsStream({
    String? category,
    bool? isActive,
  }) {
    Query query = _firestore.collection(_productsCollection);

    // TEMPORARY: Simplified query tanpa orderBy untuk avoid index requirement
    // Akan di-sort di client side
    // TODO: Re-enable orderBy setelah index selesai build

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    // Comment out orderBy sementara untuk avoid index error
    // query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final products = snapshot.docs
          .map((doc) => MarketplaceProductModel.fromFirestore(doc))
          .toList();

      // Sort di client side
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return products;
    });
  }

  // ============================================================================
  // PRIVATE METHODS - Azure Blob Storage Operations
  // ============================================================================

  /// Upload multiple product images to Azure Blob Storage
  Future<List<String>> _uploadProductImages(
      String sellerId, List<File> images) async {
    final List<String> imageUrls = [];

    // Initialize Azure Storage
    await _initAzureStorage();

    for (int i = 0; i < images.length; i++) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'product_${sellerId}_${timestamp}_$i.jpg';

        // Upload to Azure Blob Storage (PRIVATE storage untuk keamanan)
        final response = await _azureStorage!.uploadImage(
          file: images[i],
          isPrivate: true,  // Private storage untuk security
          prefixName: _azureStoragePrefix,
          customFileName: fileName,
        );

        if (response != null && response.blobUrl.isNotEmpty) {
          imageUrls.add(response.blobUrl);

          if (kDebugMode) {
            print('✅ Image uploaded to Azure: $fileName');
            print('   URL: ${response.blobUrl}');
          }
        } else {
          if (kDebugMode) {
            print('❌ Upload response null for image ${i + 1}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error uploading image ${i + 1} to Azure: $e');
        }
        // Continue with other images even if one fails
      }
    }

    return imageUrls;
  }

  /// Delete image from Azure Blob Storage using URL
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      // Initialize Azure Storage
      await _initAzureStorage();

      // Extract blob name from URL
      // URL format: https://...azure.../container/marketplace/products/filename.jpg
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Get blob name (everything after container name)
      final blobName = pathSegments.sublist(1).join('/');

      if (kDebugMode) {
        print('🗑️ Deleting from Azure Blob Storage...');
        print('   Blob name: $blobName');
      }

      await _azureStorage!.deleteFile(
        blobName: blobName,
        isPrivate: true,
      );

      if (kDebugMode) {
        print('✅ Image deleted from Azure Blob Storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting image from Azure: $e');
      }
      // Don't throw error if image deletion fails
      // App should continue even if cleanup fails
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get product categories
  Future<List<String>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet()
          .toList();

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting categories: $e');
      }
      return [];
    }
  }

  /// Check if user is seller
  Future<bool> isUserSeller(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_productsCollection)
          .where('sellerId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking seller status: $e');
      }
      return false;
    }
  }
}

