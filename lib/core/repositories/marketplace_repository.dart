// ============================================================================
// MARKETPLACE REPOSITORY
// ============================================================================
// Repository layer untuk marketplace dengan error handling
// ============================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/marketplace_product_model.dart';
import '../services/marketplace_service.dart';

class MarketplaceRepository {
  final MarketplaceService _service = MarketplaceService();

  // ============================================================================
  // CREATE
  // ============================================================================
  Future<Result<String>> createProduct({
    required String productName,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<File> images,
    required String unit,
    String? customSellerId,
    String? customSellerName,
  }) async {
    try {
      // Validation
      if (productName.trim().isEmpty) {
        return Result.error('Nama produk tidak boleh kosong');
      }
      if (description.trim().isEmpty) {
        return Result.error('Deskripsi produk tidak boleh kosong');
      }
      if (price <= 0) {
        return Result.error('Harga harus lebih dari 0');
      }
      if (stock < 0) {
        return Result.error('Stok tidak boleh negatif');
      }
      if (images.isEmpty) {
        return Result.error('Minimal 1 gambar produk');
      }
      if (images.length > 5) {
        return Result.error('Maksimal 5 gambar produk');
      }

      final productId = await _service.createProduct(
        productName: productName,
        description: description,
        price: price,
        stock: stock,
        category: category,
        images: images,
        unit: unit,
        customSellerId: customSellerId,
        customSellerName: customSellerName,
      );

      return Result.success(productId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - createProduct: $e');
      }
      return Result.error('Gagal menambahkan produk: ${e.toString()}');
    }
  }

  // ============================================================================
  // READ
  // ============================================================================
  Future<Result<List<MarketplaceProductModel>>> getAllProducts({
    String? category,
    bool? isActive,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      final products = await _service.getAllProducts(
        category: category,
        isActive: isActive,
        limit: limit,
        lastDocument: lastDocument,
      );
      return Result.success(products);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getAllProducts: $e');
      }
      return Result.error('Gagal memuat produk: ${e.toString()}');
    }
  }

  Future<Result<List<MarketplaceProductModel>>> getProductsBySeller(
      String sellerId) async {
    try {
      final products = await _service.getProductsBySeller(sellerId);
      return Result.success(products);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getProductsBySeller: $e');
      }
      return Result.error('Gagal memuat produk penjual: ${e.toString()}');
    }
  }

  Future<Result<MarketplaceProductModel>> getProductById(String productId) async {
    try {
      final product = await _service.getProductById(productId);
      if (product == null) {
        return Result.error('Produk tidak ditemukan');
      }
      return Result.success(product);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getProductById: $e');
      }
      return Result.error('Gagal memuat detail produk: ${e.toString()}');
    }
  }

  Future<Result<List<MarketplaceProductModel>>> searchProducts(
      String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return Result.success([]);
      }
      final products = await _service.searchProducts(keyword);
      return Result.success(products);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - searchProducts: $e');
      }
      return Result.error('Gagal mencari produk: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE
  // ============================================================================
  Future<Result<void>> updateProduct({
    required String productId,
    String? productName,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<File>? newImages,
    List<String>? removeImageUrls,
    String? unit,
    bool? isActive,
  }) async {
    try {
      // Validation
      if (price != null && price <= 0) {
        return Result.error('Harga harus lebih dari 0');
      }
      if (stock != null && stock < 0) {
        return Result.error('Stok tidak boleh negatif');
      }

      await _service.updateProduct(
        productId: productId,
        productName: productName,
        description: description,
        price: price,
        stock: stock,
        category: category,
        newImages: newImages,
        removeImageUrls: removeImageUrls,
        unit: unit,
        isActive: isActive,
      );

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - updateProduct: $e');
      }
      return Result.error('Gagal mengupdate produk: ${e.toString()}');
    }
  }

  Future<Result<void>> updateStock(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        return Result.error('Jumlah pembelian harus lebih dari 0');
      }

      await _service.updateStock(productId, quantity);
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - updateStock: $e');
      }
      return Result.error('Gagal mengupdate stok: ${e.toString()}');
    }
  }

  // ============================================================================
  // DELETE
  // ============================================================================
  Future<Result<void>> deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - deleteProduct: $e');
      }
      return Result.error('Gagal menghapus produk: ${e.toString()}');
    }
  }

  // ============================================================================
  // STREAM
  // ============================================================================
  Stream<List<MarketplaceProductModel>> getProductsStream({
    String? category,
    bool? isActive,
  }) {
    return _service.getProductsStream(
      category: category,
      isActive: isActive,
    );
  }

  // ============================================================================
  // UTILITY
  // ============================================================================
  Future<Result<List<String>>> getCategories() async {
    try {
      final categories = await _service.getCategories();
      return Result.success(categories);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getCategories: $e');
      }
      return Result.error('Gagal memuat kategori: ${e.toString()}');
    }
  }

  Future<Result<bool>> isUserSeller(String userId) async {
    try {
      final isSeller = await _service.isUserSeller(userId);
      return Result.success(isSeller);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - isUserSeller: $e');
      }
      return Result.success(false);
    }
  }
}

// ============================================================================
// RESULT CLASS - For better error handling
// ============================================================================
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  factory Result.error(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }
}

