// ============================================================================
// CART PROVIDER
// ============================================================================
// Provider untuk state management keranjang marketplace
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepository();

  // State
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  int _cartCount = 0;

  // Getters
  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cartCount => _cartCount;

  // Selected items
  List<CartItemModel> get selectedItems =>
      _cartItems.where((item) => item.isSelected).toList();

  // Check if all items selected
  bool get isAllSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);

  // Total price of selected items
  double get totalPrice {
    return selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Total items (quantity) in cart
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Total selected items count
  int get selectedItemsCount => selectedItems.length;

  // ============================================================================
  // LOAD CART
  // ============================================================================
  Future<void> loadCart({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result = await _repository.getCartItems();

      if (result.isSuccess && result.data != null) {
        _cartItems = result.data!;
        _cartCount = _cartItems.length;
        _error = null;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Gagal memuat keranjang: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // LOAD CART COUNT (untuk badge)
  // ============================================================================
  Future<void> loadCartCount() async {
    try {
      final result = await _repository.getCartCount();

      if (result.isSuccess && result.data != null) {
        _cartCount = result.data!;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart count: $e');
      }
    }
  }

  // ============================================================================
  // ADD TO CART
  // ============================================================================
  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    _error = null;

    try {
      final result = await _repository.addToCart(
        productId: productId,
        quantity: quantity,
      );

      if (result.isSuccess) {
        // Reload cart untuk update tampilan
        await loadCart(showLoading: false);
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal menambahkan ke keranjang: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error adding to cart: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // UPDATE QUANTITY
  // ============================================================================
  Future<bool> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    _error = null;

    try {
      final result = await _repository.updateQuantity(
        cartItemId: cartItemId,
        quantity: quantity,
      );

      if (result.isSuccess) {
        // Update local state
        final index = _cartItems.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
          notifyListeners();
        }
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengubah quantity: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error updating quantity: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // INCREMENT QUANTITY
  // ============================================================================
  Future<bool> incrementQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    final newQuantity = item.quantity + 1;

    if (newQuantity > item.maxStock) {
      _error = 'Stock tidak mencukupi';
      notifyListeners();
      return false;
    }

    return await updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  // ============================================================================
  // DECREMENT QUANTITY
  // ============================================================================
  Future<bool> decrementQuantity(String cartItemId) async {
    final item = _cartItems.firstWhere((item) => item.id == cartItemId);
    final newQuantity = item.quantity - 1;

    if (newQuantity < 1) {
      _error = 'Quantity minimal 1';
      notifyListeners();
      return false;
    }

    return await updateQuantity(cartItemId: cartItemId, quantity: newQuantity);
  }

  // ============================================================================
  // TOGGLE SELECTION
  // ============================================================================
  Future<void> toggleSelection(String cartItemId) async {
    try {
      final item = _cartItems.firstWhere((item) => item.id == cartItemId);
      final newSelection = !item.isSelected;

      final result = await _repository.toggleSelection(
        cartItemId: cartItemId,
        isSelected: newSelection,
      );

      if (result.isSuccess) {
        // Update local state
        final index = _cartItems.indexWhere((item) => item.id == cartItemId);
        if (index != -1) {
          _cartItems[index] = _cartItems[index].copyWith(isSelected: newSelection);
          notifyListeners();
        }
      } else {
        _error = result.error;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling selection: $e');
      }
    }
  }

  // ============================================================================
  // SELECT ALL / DESELECT ALL
  // ============================================================================
  Future<void> toggleSelectAll() async {
    try {
      final newSelection = !isAllSelected;

      final result = await _repository.selectAll(newSelection);

      if (result.isSuccess) {
        // Update local state
        _cartItems = _cartItems
            .map((item) => item.copyWith(isSelected: newSelection))
            .toList();
        notifyListeners();
      } else {
        _error = result.error;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling select all: $e');
      }
    }
  }

  // ============================================================================
  // REMOVE FROM CART
  // ============================================================================
  Future<bool> removeFromCart(String cartItemId) async {
    _error = null;

    try {
      final result = await _repository.removeFromCart(cartItemId);

      if (result.isSuccess) {
        // Update local state
        _cartItems.removeWhere((item) => item.id == cartItemId);
        _cartCount = _cartItems.length;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal menghapus item: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error removing from cart: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // REMOVE SELECTED ITEMS
  // ============================================================================
  Future<bool> removeSelectedItems() async {
    _error = null;

    try {
      if (selectedItems.isEmpty) {
        _error = 'Tidak ada item yang dipilih';
        notifyListeners();
        return false;
      }

      final result = await _repository.removeSelectedItems();

      if (result.isSuccess) {
        // Reload cart
        await loadCart(showLoading: false);
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal menghapus item terpilih: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error removing selected items: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // CLEAR CART
  // ============================================================================
  Future<bool> clearCart() async {
    _error = null;

    try {
      final result = await _repository.clearCart();

      if (result.isSuccess) {
        _cartItems.clear();
        _cartCount = 0;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengosongkan keranjang: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error clearing cart: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // VALIDATE CART (sebelum checkout)
  // ============================================================================
  Future<Map<String, dynamic>> validateCart() async {
    try {
      final result = await _repository.validateCart();

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        return {
          'isValid': false,
          'message': result.error ?? 'Validasi gagal',
          'invalidItems': [],
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating cart: $e');
      }
      return {
        'isValid': false,
        'message': 'Error validasi: ${e.toString()}',
        'invalidItems': [],
      };
    }
  }

  // ============================================================================
  // STREAM CART (Real-time updates)
  // ============================================================================
  void listenToCart() {
    _repository.streamCartItems().listen(
      (items) {
        _cartItems = items;
        _cartCount = items.length;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error stream: ${error.toString()}';
        notifyListeners();
        if (kDebugMode) {
          print('Error stream cart: $error');
        }
      },
    );
  }

  // ============================================================================
  // CLEAR ERROR
  // ============================================================================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ============================================================================
  // GET ITEM BY ID
  // ============================================================================
  CartItemModel? getItemById(String cartItemId) {
    try {
      return _cartItems.firstWhere((item) => item.id == cartItemId);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // CHECK IF PRODUCT IN CART
  // ============================================================================
  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  // ============================================================================
  // GET CART ITEM BY PRODUCT ID
  // ============================================================================
  CartItemModel? getItemByProductId(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}

