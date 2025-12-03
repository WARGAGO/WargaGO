// ============================================================================
// CART REPOSITORY
// ============================================================================
// Repository layer untuk cart dengan error handling & validation
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

// Result wrapper untuk error handling
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.error(this.error)
      : data = null,
        isSuccess = false;
}

class CartRepository {
  final CartService _service = CartService();

  // ============================================================================
  // CREATE - Add to Cart
  // ============================================================================
  Future<Result<String>> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      // Validation
      if (productId.trim().isEmpty) {
        return Result.error('Product ID tidak boleh kosong');
      }
      if (quantity < 1) {
        return Result.error('Quantity minimal 1');
      }
      if (quantity > 999) {
        return Result.error('Quantity maksimal 999');
      }

      final cartItemId = await _service.addToCart(
        productId: productId,
        quantity: quantity,
      );

      return Result.success(cartItemId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - addToCart: $e');
      }
      return Result.error(_getErrorMessage(e));
    }
  }

  // ============================================================================
  // READ - Get Cart Items
  // ============================================================================
  Future<Result<List<CartItemModel>>> getCartItems() async {
    try {
      final items = await _service.getCartItems();
      return Result.success(items);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getCartItems: $e');
      }
      return Result.error('Gagal memuat keranjang: ${e.toString()}');
    }
  }

  // ============================================================================
  // READ - Get Cart Count
  // ============================================================================
  Future<Result<int>> getCartCount() async {
    try {
      final count = await _service.getCartCount();
      return Result.success(count);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getCartCount: $e');
      }
      return Result.error('Gagal mendapatkan jumlah item: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE - Update Quantity
  // ============================================================================
  Future<Result<void>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      // Validation
      if (cartItemId.trim().isEmpty) {
        return Result.error('Cart Item ID tidak boleh kosong');
      }
      if (quantity < 1) {
        return Result.error('Quantity minimal 1');
      }
      if (quantity > 999) {
        return Result.error('Quantity maksimal 999');
      }

      await _service.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - updateQuantity: $e');
      }
      return Result.error(_getErrorMessage(e));
    }
  }

  // ============================================================================
  // UPDATE - Toggle Selection
  // ============================================================================
  Future<Result<void>> toggleSelection({
    required String cartItemId,
    required bool isSelected,
  }) async {
    try {
      if (cartItemId.trim().isEmpty) {
        return Result.error('Cart Item ID tidak boleh kosong');
      }

      await _service.toggleSelection(
        cartItemId: cartItemId,
        isSelected: isSelected,
      );

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - toggleSelection: $e');
      }
      return Result.error('Gagal mengubah selection: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE - Select All
  // ============================================================================
  Future<Result<void>> selectAll(bool isSelected) async {
    try {
      await _service.selectAll(isSelected);
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - selectAll: $e');
      }
      return Result.error('Gagal select all: ${e.toString()}');
    }
  }

  // ============================================================================
  // DELETE - Remove from Cart
  // ============================================================================
  Future<Result<void>> removeFromCart(String cartItemId) async {
    try {
      if (cartItemId.trim().isEmpty) {
        return Result.error('Cart Item ID tidak boleh kosong');
      }

      await _service.removeFromCart(cartItemId);
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - removeFromCart: $e');
      }
      return Result.error('Gagal menghapus item: ${e.toString()}');
    }
  }

  // ============================================================================
  // DELETE - Remove Selected Items
  // ============================================================================
  Future<Result<void>> removeSelectedItems() async {
    try {
      await _service.removeSelectedItems();
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - removeSelectedItems: $e');
      }
      return Result.error('Gagal menghapus item terpilih: ${e.toString()}');
    }
  }

  // ============================================================================
  // DELETE - Clear Cart
  // ============================================================================
  Future<Result<void>> clearCart() async {
    try {
      await _service.clearCart();
      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - clearCart: $e');
      }
      return Result.error('Gagal mengosongkan keranjang: ${e.toString()}');
    }
  }

  // ============================================================================
  // STREAM - Real-time Cart
  // ============================================================================
  Stream<List<CartItemModel>> streamCartItems() {
    return _service.streamCartItems();
  }

  // ============================================================================
  // VALIDATION - Validate Cart Before Checkout
  // ============================================================================
  Future<Result<Map<String, dynamic>>> validateCart() async {
    try {
      final validation = await _service.validateCart();
      return Result.success(validation);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - validateCart: $e');
      }
      return Result.error('Gagal validasi keranjang: ${e.toString()}');
    }
  }

  // ============================================================================
  // HELPER - Extract Error Message
  // ============================================================================
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('User tidak terautentikasi')) {
      return 'Silakan login terlebih dahulu';
    }
    if (errorString.contains('Stock tidak mencukupi')) {
      return errorString.replaceAll('Exception: ', '');
    }
    if (errorString.contains('Produk tidak ditemukan')) {
      return 'Produk tidak ditemukan atau sudah dihapus';
    }
    if (errorString.contains('Produk tidak aktif')) {
      return 'Produk tidak tersedia';
    }
    if (errorString.contains('network')) {
      return 'Koneksi internet bermasalah';
    }

    return errorString.replaceAll('Exception: ', '');
  }
}

