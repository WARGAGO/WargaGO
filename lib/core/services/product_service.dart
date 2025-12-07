// ============================================================================
// PRODUCT SERVICE
// ============================================================================
// Service untuk CRUD operasi produk di Firestore
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:wargago/core/models/product_model.dart';
import 'package:wargago/core/services/cart_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'products';

  // ==================== CREATE ====================

  /// Tambah produk baru
  Future<String?> createProduct(ProductModel product) async {
    try {
      if (kDebugMode) {
        print('=== ProductService: createProduct START ===');
        print('Nama produk: ${product.nama}');
        print('Seller ID: ${product.sellerId}');
        print('Harga: ${product.harga}');
        print('Stok: ${product.stok}');
        print('Kategori: ${product.kategori}');
        print('Jumlah gambar: ${product.imageUrls.length}');
      }

      // Create document reference with auto-generated ID
      final docRef = _firestore.collection(_collectionName).doc();

      // Create product with the generated ID
      final newProduct = product.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(newProduct.toMap());

      if (kDebugMode) {
        print('✅ Product created successfully with ID: ${docRef.id}');
        print('=== ProductService: createProduct END ===\n');
      }

      return docRef.id;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error creating product: $e');
        print('StackTrace: $stackTrace');
      }
      return null;
    }
  }

  // ==================== READ ====================

  /// Get produk by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(productId).get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('❌ Product with ID "$productId" not found');
        }
        return null;
      }

      return ProductModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting product by ID: $e');
      }
      return null;
    }
  }

  /// Get semua produk (dengan pagination opsional)
  Future<List<ProductModel>> getAllProducts({
    int? limit,
    DocumentSnapshot? startAfter,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName);

      // Filter hanya produk aktif
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      // Order by created date (newest first)
      query = query.orderBy('createdAt', descending: true);

      // Pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting all products: $e');
      }
      return [];
    }
  }

  /// Get produk by seller ID
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();

      if (kDebugMode) {
        print('✅ Loaded ${products.length} products for seller');
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products by seller: $e');
        print('   Trying fallback query without orderBy...');
      }

      // Fallback: Query without orderBy to avoid index requirement
      try {
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('sellerId', isEqualTo: sellerId)
            .get();

        final products = querySnapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();

        // Sort client-side
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (kDebugMode) {
          print('✅ Fallback query successful: ${products.length} products');
        }

        return products;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Fallback query also failed: $fallbackError');
        }
        return [];
      }
    }
  }

  /// Get produk by kategori
  Future<List<ProductModel>> getProductsByCategory(
    String kategori, {
    int? limit,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('kategori', isEqualTo: kategori);

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting products by category: $e');
      }
      return [];
    }
  }

  /// Search produk by name
  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      // Note: Firestore doesn't support full-text search
      // This is a simple implementation using text matching
      // For better search, consider using Algolia or ElasticSearch

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final keyword2 = keyword.toLowerCase();

      return querySnapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .where((product) => product.nama.toLowerCase().contains(keyword2))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching products: $e');
      }
      return [];
    }
  }

  // ==================== UPDATE ====================

  /// Update produk
  Future<bool> updateProduct(ProductModel product) async {
    try {
      if (kDebugMode) {
        print('=== ProductService: updateProduct START ===');
        print('Product ID: ${product.id}');
      }

      final updatedProduct = product.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(product.id)
          .update(updatedProduct.toMap());

      if (kDebugMode) {
        print('✅ Product updated successfully');
        print('=== ProductService: updateProduct END ===\n');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating product: $e');
      }
      return false;
    }
  }

  /// Update stok produk
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).update({
        'stok': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating stock: $e');
      }
      return false;
    }
  }

  /// Toggle status aktif produk
  Future<bool> toggleProductStatus(String productId, bool isActive) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).update({
        'isActive': isActive,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling product status: $e');
      }
      return false;
    }
  }

  // ==================== DELETE ====================

  /// Hapus produk (soft delete - set isDeleted = true)
  Future<bool> softDeleteProduct(String productId) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).update({
        'isDeleted': true,
        'isActive': false, // Also set inactive for safety
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (kDebugMode) {
        print('✅ Product soft deleted successfully');
        print('   Product ID: $productId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error soft deleting product: $e');
      }
      return false;
    }
  }

  /// Hapus produk permanent (hard delete)
  Future<bool> hardDeleteProduct(String productId) async {
    try {
      if (kDebugMode) {
        print('=== ProductService: hardDeleteProduct START ===');
        print('Product ID: $productId');
      }

      // Step 1: Remove product from all user carts
      try {
        final cartService = CartService();
        await cartService.removeProductFromAllCarts(productId);

        if (kDebugMode) {
          print('✅ Product removed from all carts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error removing product from carts: $e');
        }
        // Continue with deletion even if cart cleanup fails
      }

      // Step 2: Delete the product document
      await _firestore.collection(_collectionName).doc(productId).delete();

      if (kDebugMode) {
        print('✅ Product hard deleted successfully from Firestore');
        print('=== ProductService: hardDeleteProduct END ===\n');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error hard deleting product: $e');
      }
      return false;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch delete multiple products
  Future<bool> batchDeleteProducts(List<String> productIds) async {
    try {
      if (kDebugMode) {
        print('=== ProductService: batchDeleteProducts START ===');
        print('Deleting ${productIds.length} products');
      }

      // Step 1: Remove products from all user carts
      try {
        final cartService = CartService();
        for (final productId in productIds) {
          await cartService.removeProductFromAllCarts(productId);
        }

        if (kDebugMode) {
          print('✅ Products removed from all carts');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error removing products from carts: $e');
        }
        // Continue with deletion even if cart cleanup fails
      }

      // Step 2: Delete the product documents
      final batch = _firestore.batch();

      for (final productId in productIds) {
        final docRef = _firestore.collection(_collectionName).doc(productId);
        batch.delete(docRef);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Batch delete successful');
        print('=== ProductService: batchDeleteProducts END ===\n');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error batch deleting products: $e');
      }
      return false;
    }
  }

  /// Batch update product status
  Future<bool> batchUpdateProductStatus(
    List<String> productIds,
    bool isActive,
  ) async {
    try {
      final batch = _firestore.batch();
      final now = Timestamp.fromDate(DateTime.now());

      for (final productId in productIds) {
        final docRef = _firestore.collection(_collectionName).doc(productId);
        batch.update(docRef, {
          'isActive': isActive,
          'updatedAt': now,
        });
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Batch update status successful: ${productIds.length} products');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error batch updating product status: $e');
      }
      return false;
    }
  }

  // ==================== VALIDATION & CHECKS ====================

  /// Check if product exists
  Future<bool> productExists(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(productId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking product existence: $e');
      }
      return false;
    }
  }

  /// Validate product before order
  Future<Map<String, dynamic>> validateProductForOrder(
    String productId,
    int quantity,
  ) async {
    try {
      final product = await getProductById(productId);

      if (product == null) {
        return {
          'isValid': false,
          'message': 'Produk tidak ditemukan',
          'code': 'PRODUCT_NOT_FOUND',
        };
      }

      if (!product.isActive) {
        return {
          'isValid': false,
          'message': 'Produk tidak aktif',
          'code': 'PRODUCT_INACTIVE',
        };
      }

      if (product.stok < quantity) {
        return {
          'isValid': false,
          'message': 'Stok tidak mencukupi (tersedia: ${product.stok})',
          'code': 'INSUFFICIENT_STOCK',
          'availableStock': product.stok,
        };
      }

      return {
        'isValid': true,
        'product': product,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating product: $e');
      }
      return {
        'isValid': false,
        'message': 'Error validasi produk: $e',
        'code': 'VALIDATION_ERROR',
      };
    }
  }

  /// Decrease stock (for order processing)
  Future<bool> decreaseStock(String productId, int quantity) async {
    try {
      if (kDebugMode) {
        print('=== ProductService: decreaseStock START ===');
        print('Product ID: $productId, Quantity: $quantity');
      }

      // Use transaction to ensure atomic operation
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collectionName).doc(productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Produk tidak ditemukan');
        }

        final currentStock = snapshot.data()?['stok'] as int? ?? 0;

        if (currentStock < quantity) {
          throw Exception('Stok tidak mencukupi');
        }

        final newStock = currentStock - quantity;

        transaction.update(docRef, {
          'stok': newStock,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      if (kDebugMode) {
        print('✅ Stock decreased successfully');
        print('=== ProductService: decreaseStock END ===\n');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error decreasing stock: $e');
      }
      return false;
    }
  }

  /// Increase stock (for order cancellation/return)
  Future<bool> increaseStock(String productId, int quantity) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collectionName).doc(productId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Produk tidak ditemukan');
        }

        final currentStock = snapshot.data()?['stok'] as int? ?? 0;
        final newStock = currentStock + quantity;

        transaction.update(docRef, {
          'stok': newStock,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      });

      if (kDebugMode) {
        print('✅ Stock increased successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error increasing stock: $e');
      }
      return false;
    }
  }

  // ==================== STATISTICS ====================

  /// Get seller statistics
  Future<Map<String, dynamic>> getSellerStatistics(String sellerId) async {
    try {
      final products = await getProductsBySeller(sellerId);

      final totalProducts = products.length;
      final activeProducts = products.where((p) => p.isActive).length;
      final inactiveProducts = products.where((p) => !p.isActive).length;
      final totalStock = products.fold<int>(0, (total, p) => total + p.stok);
      final outOfStock = products.where((p) => p.stok == 0).length;

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'inactiveProducts': inactiveProducts,
        'totalStock': totalStock,
        'outOfStock': outOfStock,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting seller statistics: $e');
      }
      return {
        'totalProducts': 0,
        'activeProducts': 0,
        'inactiveProducts': 0,
        'totalStock': 0,
        'outOfStock': 0,
      };
    }
  }

  // ==================== STREAM (REAL-TIME) ====================

  /// Stream produk by seller (untuk real-time updates)
  Stream<List<ProductModel>> streamProductsBySeller(String sellerId) {
    return _firestore
        .collection(_collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream all active products
  Stream<List<ProductModel>> streamActiveProducts({int? limit}) {
    Query query = _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }
}

