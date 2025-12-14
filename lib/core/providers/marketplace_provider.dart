// ============================================================================
// MARKETPLACE PROVIDER
// ============================================================================
// Provider untuk state management marketplace
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wargago/core/services/azure_blob_storage_service.dart';
import '../models/marketplace_product_model.dart';
import '../repositories/marketplace_repository.dart';

class MarketplaceProvider extends ChangeNotifier {
  final MarketplaceRepository _repository = MarketplaceRepository();

  // State
  List<MarketplaceProductModel> _products = [];
  List<MarketplaceProductModel> _myProducts = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Semua';
  String _selectedSubcategory = ''; // Sub-kategori sayuran
  String _searchKeyword = '';
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  // Getters
  List<MarketplaceProductModel> get products => _products;
  List<MarketplaceProductModel> get myProducts => _myProducts;
  List<String> get categories => ['Semua', ..._categories];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get selectedSubcategory => _selectedSubcategory;
  String get searchKeyword => _searchKeyword;
  bool get hasMore => _hasMore;

  // Filtered products based on category, subcategory, and search
  List<MarketplaceProductModel> get filteredProducts {
    var filtered = _products;

    // Filter by category
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((product) {
        return _categoryMatches(product.category, _selectedCategory);
      }).toList();

      if (kDebugMode) {
        print('🔍 Filtering by category: $_selectedCategory');
        print('   Total products before filter: ${_products.length}');
        print('   Products found after filter: ${filtered.length}');

        if (_products.isNotEmpty) {
          final allCategories = _products
              .map((p) => p.category)
              .toSet()
              .toList();
          print('   All available categories: $allCategories');
        }

        if (filtered.isNotEmpty) {
          print('   Sample matched products:');
          for (var p in filtered.take(3)) {
            print('     - ${p.productName} (category: ${p.category})');
          }
        } else {
          print('   ⚠��� No products matched! Checking why:');
          for (var p in _products.take(3)) {
            final matches = _categoryMatches(p.category, _selectedCategory);
            print('     - ${p.productName} (${p.category}) → Match: $matches');
          }
        }
      }
    }

    // Filter by subcategory (for vegetables)
    if (_selectedSubcategory.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.productName.toLowerCase().contains(
                  _selectedSubcategory.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _selectedSubcategory.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by search keyword
    if (_searchKeyword.isNotEmpty) {
      filtered = filtered
          .where(
            (product) => product.productName.toLowerCase().contains(
              _searchKeyword.toLowerCase(),
            ),
          )
          .toList();
    }

    return filtered;
  }

  // Helper method to check if categories match (supports variations)
  bool _categoryMatches(String productCategory, String selectedCategory) {
    final prodCat = productCategory.toLowerCase().trim();
    final selCat = selectedCategory.toLowerCase().trim();

    // Direct exact match
    if (prodCat == selCat) {
      return true;
    }

    // Normalize variations: "Sayuran" ↔ "Sayur"
    final normalizedProd = prodCat.replaceAll('sayuran ', 'sayur ');
    final normalizedSel = selCat.replaceAll('sayuran ', 'sayur ');

    if (normalizedProd == normalizedSel) {
      return true;
    }

    // Also try the reverse: "Sayur" → "Sayuran"
    final reverseProd = prodCat.replaceAll('sayur ', 'sayuran ');
    final reverseSel = selCat.replaceAll('sayur ', 'sayuran ');

    if (reverseProd == reverseSel) {
      return true;
    }

    // Check if one contains the other (for partial matches)
    if (prodCat.contains(selCat) || selCat.contains(prodCat)) {
      // But make sure it's a meaningful match, not just substring
      final words1 = prodCat.split(' ');
      final words2 = selCat.split(' ');

      // Check if all significant words match
      final intersection = words1
          .where((w) => words2.contains(w) && w.length > 2)
          .toList();
      if (intersection.length >= 2) {
        return true;
      }
    }

    return false;
  }

  // ============================================================================
  // LOAD PRODUCTS
  // ============================================================================
  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _products.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final blobStorage = AzureBlobStorageService(firebaseToken: 'xxx');
    final azureImages = await blobStorage.getImages(
      filenamePrefix: 'products/',
      isPrivate: false,
    );

    try {
      final result = await _repository.getAllProducts(
        isActive: true,
        limit: 20,
        lastDocument: _lastDocument,
      );

      if (result.isSuccess && result.data != null) {
        if (refresh) {
          _products = result.data!;
        } else {
          _products.addAll(result.data!);
        }

        if (azureImages != null) {
          for (var product in _products) {
            product.updateUrls(azureImages);
          }
        }

        // Check if there are more products to load
        _hasMore = result.data!.length >= 20;

        // Update last document for pagination
        if (result.data!.isNotEmpty) {
          // Note: You'll need to modify getAllProducts to return DocumentSnapshot
          // For now, we'll assume no pagination
        }
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Gagal memuat produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading products: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // LOAD MY PRODUCTS (Seller)
  // ============================================================================
  Future<void> loadMyProducts(String sellerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getProductsBySeller(sellerId);

      if (result.isSuccess && result.data != null) {
        _myProducts = result.data!;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Gagal memuat produk Anda: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading my products: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // LOAD CATEGORIES
  // ============================================================================
  Future<void> loadCategories() async {
    try {
      final result = await _repository.getCategories();

      if (result.isSuccess && result.data != null) {
        _categories = result.data!;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
    }
  }

  // ============================================================================
  // SEARCH PRODUCTS
  // ============================================================================
  Future<void> searchProducts(String keyword) async {
    _searchKeyword = keyword;
    notifyListeners();

    if (keyword.trim().isEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.searchProducts(keyword);

      if (result.isSuccess && result.data != null) {
        _products = result.data!;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Gagal mencari produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error searching products: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // SET CATEGORY FILTER
  // ============================================================================
  void setCategory(String category) {
    _selectedCategory = category;

    if (kDebugMode) {
      print('📂 Category changed to: $category');
      print('   Total products: ${_products.length}');
      print('   Filtered products: ${filteredProducts.length}');

      // Show product categories for debugging
      if (_products.isNotEmpty) {
        final uniqueCategories = _products
            .map((p) => p.category)
            .toSet()
            .toList();
        print('   Available categories in products: $uniqueCategories');
      }
    }

    notifyListeners();
  }

  // ============================================================================
  // CREATE PRODUCT
  // ============================================================================
  Future<bool> createProduct({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createProduct(
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

      if (result.isSuccess) {
        // Reload products
        await loadProducts(refresh: true);
        return true;
      } else {
        _error = result.error;
        return false;
      }
    } catch (e) {
      _error = 'Gagal menambahkan produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error creating product: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // UPDATE PRODUCT
  // ============================================================================
  Future<bool> updateProduct({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.updateProduct(
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

      if (result.isSuccess) {
        // Reload products
        await loadProducts(refresh: true);
        return true;
      } else {
        _error = result.error;
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengupdate produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error updating product: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // DELETE PRODUCT
  // ============================================================================
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.deleteProduct(productId);

      if (result.isSuccess) {
        // Remove from local list
        _products.removeWhere((p) => p.id == productId);
        _myProducts.removeWhere((p) => p.id == productId);
        return true;
      } else {
        _error = result.error;
        return false;
      }
    } catch (e) {
      _error = 'Gagal menghapus produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error deleting product: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // GET PRODUCT BY ID
  // ============================================================================
  Future<MarketplaceProductModel?> getProductById(String productId) async {
    final blobStorage = AzureBlobStorageService(firebaseToken: 'xxx');
    final azureImages = await blobStorage.getImages(
      filenamePrefix: 'products/',
      isPrivate: false,
    );

    try {
      final result = await _repository.getProductById(productId);

      if (result.isSuccess && result.data != null) {
        if (azureImages != null) {
          result.data!.updateUrls(azureImages);
        }
        return result.data;
      } else {
        _error = result.error;
        return null;
      }
    } catch (e) {
      _error = 'Gagal memuat detail produk: ${e.toString()}';
      if (kDebugMode) {
        print('Error getting product: $e');
      }
      return null;
    }
  }

  // ============================================================================
  // CLEAR ERROR
  // ============================================================================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================================
  // RESET
  // ============================================================================
  void reset() {
    _products.clear();
    _myProducts.clear();
    _categories.clear();
    _isLoading = false;
    _error = null;
    _selectedCategory = 'Semua';
    _searchKeyword = '';
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();
  }
}
