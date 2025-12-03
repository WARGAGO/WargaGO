// ============================================================================
// CART SERVICE
// ============================================================================
// Service untuk handle CRUD operations keranjang marketplace
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/marketplace_product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _cartCollection = 'marketplace_cart';
  static const String _productsCollection = 'marketplace_products';

  // ============================================================================
  // CREATE - Tambah Item ke Keranjang
  // ============================================================================
  Future<String> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Get product details
      final productDoc = await _firestore
          .collection(_productsCollection)
          .doc(productId)
          .get();

      if (!productDoc.exists) {
        throw Exception('Produk tidak ditemukan');
      }

      final product = MarketplaceProductModel.fromFirestore(productDoc);

      // Validasi stock
      if (product.stock < quantity) {
        throw Exception('Stock tidak mencukupi. Stock tersedia: ${product.stock}');
      }

      // Validasi produk aktif
      if (!product.isActive) {
        throw Exception('Produk tidak aktif');
      }

      // Check if item already exists in cart
      final existingCart = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (existingCart.docs.isNotEmpty) {
        // Update quantity jika sudah ada
        final existingItem = CartItemModel.fromFirestore(existingCart.docs.first);
        final newQuantity = existingItem.quantity + quantity;

        // Validasi total quantity tidak melebihi stock
        if (newQuantity > product.stock) {
          throw Exception('Total quantity melebihi stock. Stock tersedia: ${product.stock}');
        }

        await _firestore
            .collection(_cartCollection)
            .doc(existingCart.docs.first.id)
            .update({
          'quantity': newQuantity,
          'price': product.price, // Update harga jika berubah
          'maxStock': product.stock, // Update stock info
        });

        if (kDebugMode) {
          print('✅ Cart item updated: ${existingCart.docs.first.id}');
        }

        return existingCart.docs.first.id;
      } else {
        // Tambah item baru
        final cartRef = _firestore.collection(_cartCollection).doc();
        final cartItem = CartItemModel(
          id: cartRef.id,
          userId: user.uid,
          productId: productId,
          sellerId: product.sellerId,
          productName: product.productName,
          productImage: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
          price: product.price,
          quantity: quantity,
          unit: product.unit,
          maxStock: product.stock,
          addedAt: DateTime.now(),
          isSelected: true,
        );

        await cartRef.set(cartItem.toMap());

        if (kDebugMode) {
          print('✅ Item added to cart: ${cartRef.id}');
        }

        return cartRef.id;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding to cart: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get Cart Items by User
  // ============================================================================
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .orderBy('addedAt', descending: true)
          .get();

      final cartItems = snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();

      // Update stock info for each item
      await _updateStockInfo(cartItems);

      if (kDebugMode) {
        print('✅ Cart items loaded: ${cartItems.length} items');
      }

      return cartItems;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cart items: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get Cart Count
  // ============================================================================
  Future<int> getCartCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cart count: $e');
      }
      return 0;
    }
  }

  // ============================================================================
  // UPDATE - Update Quantity
  // ============================================================================
  Future<void> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity < 1) {
        throw Exception('Quantity minimal 1');
      }

      final cartDoc = await _firestore
          .collection(_cartCollection)
          .doc(cartItemId)
          .get();

      if (!cartDoc.exists) {
        throw Exception('Cart item tidak ditemukan');
      }

      final cartItem = CartItemModel.fromFirestore(cartDoc);

      // Validasi stock
      if (quantity > cartItem.maxStock) {
        throw Exception('Quantity melebihi stock. Stock tersedia: ${cartItem.maxStock}');
      }

      await _firestore
          .collection(_cartCollection)
          .doc(cartItemId)
          .update({'quantity': quantity});

      if (kDebugMode) {
        print('✅ Cart quantity updated: $cartItemId -> $quantity');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating quantity: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Toggle Selection (untuk checkout)
  // ============================================================================
  Future<void> toggleSelection({
    required String cartItemId,
    required bool isSelected,
  }) async {
    try {
      await _firestore
          .collection(_cartCollection)
          .doc(cartItemId)
          .update({'isSelected': isSelected});

      if (kDebugMode) {
        print('✅ Cart selection toggled: $cartItemId -> $isSelected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error toggling selection: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Select All
  // ============================================================================
  Future<void> selectAll(bool isSelected) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isSelected': isSelected});
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ All cart items ${isSelected ? "selected" : "deselected"}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error selecting all: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // DELETE - Remove Item from Cart
  // ============================================================================
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore
          .collection(_cartCollection)
          .doc(cartItemId)
          .delete();

      if (kDebugMode) {
        print('✅ Item removed from cart: $cartItemId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing from cart: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // DELETE - Remove Selected Items
  // ============================================================================
  Future<void> removeSelectedItems() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .where('isSelected', isEqualTo: true)
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Selected items removed: ${snapshot.docs.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing selected items: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // DELETE - Clear Cart
  // ============================================================================
  Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final snapshot = await _firestore
          .collection(_cartCollection)
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Cart cleared: ${snapshot.docs.length} items removed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing cart: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // HELPER - Update Stock Info
  // ============================================================================
  Future<void> _updateStockInfo(List<CartItemModel> cartItems) async {
    try {
      for (final item in cartItems) {
        final productDoc = await _firestore
            .collection(_productsCollection)
            .doc(item.productId)
            .get();

        if (productDoc.exists) {
          final product = MarketplaceProductModel.fromFirestore(productDoc);

          // Update jika ada perubahan
          if (product.stock != item.maxStock || product.price != item.price) {
            await _firestore
                .collection(_cartCollection)
                .doc(item.id)
                .update({
              'maxStock': product.stock,
              'price': product.price,
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error updating stock info: $e');
      }
      // Don't throw, just log warning
    }
  }

  // ============================================================================
  // STREAM - Real-time Cart Updates
  // ============================================================================
  Stream<List<CartItemModel>> streamCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_cartCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================================
  // VALIDATION - Check Stock Before Checkout
  // ============================================================================
  Future<Map<String, dynamic>> validateCart() async {
    try {
      final cartItems = await getCartItems();
      final selectedItems = cartItems.where((item) => item.isSelected).toList();

      if (selectedItems.isEmpty) {
        return {
          'isValid': false,
          'message': 'Tidak ada item yang dipilih',
          'invalidItems': [],
        };
      }

      final List<String> invalidItems = [];

      for (final item in selectedItems) {
        final productDoc = await _firestore
            .collection(_productsCollection)
            .doc(item.productId)
            .get();

        if (!productDoc.exists) {
          invalidItems.add('${item.productName} - Produk tidak ditemukan');
          continue;
        }

        final product = MarketplaceProductModel.fromFirestore(productDoc);

        if (!product.isActive) {
          invalidItems.add('${item.productName} - Produk tidak aktif');
        } else if (product.stock < item.quantity) {
          invalidItems.add('${item.productName} - Stock tidak mencukupi (tersedia: ${product.stock})');
        }
      }

      if (invalidItems.isNotEmpty) {
        return {
          'isValid': false,
          'message': 'Beberapa item tidak valid',
          'invalidItems': invalidItems,
        };
      }

      return {
        'isValid': true,
        'message': 'Cart valid untuk checkout',
        'invalidItems': [],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error validating cart: $e');
      }
      return {
        'isValid': false,
        'message': 'Error validasi cart: ${e.toString()}',
        'invalidItems': [],
      };
    }
  }
}

