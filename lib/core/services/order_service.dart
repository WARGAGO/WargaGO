// ============================================================================
// ORDER SERVICE
// ============================================================================
// Service untuk handle CRUD operations pesanan marketplace
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _ordersCollection = 'marketplace_orders';
  static const String _productsCollection = 'marketplace_products';

  // ============================================================================
  // CREATE - Buat Pesanan dari Cart Items
  // ============================================================================
  Future<String> createOrder({
    required List<CartItemModel> cartItems,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      // Validasi cart items tidak kosong
      if (cartItems.isEmpty) {
        throw Exception('Tidak ada item untuk dipesan');
      }

      // Group items by seller (satu order per seller)
      final Map<String, List<CartItemModel>> itemsBySeller = {};
      for (final item in cartItems) {
        if (!itemsBySeller.containsKey(item.sellerId)) {
          itemsBySeller[item.sellerId] = [];
        }
        itemsBySeller[item.sellerId]!.add(item);
      }

      // Create order untuk setiap seller
      final List<String> orderIds = [];

      for (final entry in itemsBySeller.entries) {
        final sellerId = entry.key;
        final sellerItems = entry.value;

        // Get seller info
        final sellerDoc = await _firestore.collection('users').doc(sellerId).get();
        final sellerName = sellerDoc.data()?['nama_lengkap'] ?? 'Penjual';
        final sellerPhone = sellerDoc.data()?['nomor_telepon'] ?? '-';

        // Convert cart items to order items
        final orderItems = sellerItems.map((cartItem) => OrderItemModel(
          productId: cartItem.productId,
          productName: cartItem.productName,
          productImage: cartItem.productImage,
          price: cartItem.price,
          quantity: cartItem.quantity,
          unit: cartItem.unit,
        )).toList();

        // Calculate totals
        final subtotal = orderItems.fold<double>(
          0,
          (sum, item) => sum + item.subtotal,
        );
        final shippingCost = 0.0; // TODO: Implement shipping cost calculation
        final totalAmount = subtotal + shippingCost;

        // Generate order ID (ORD-YYYY-NNNN)
        final orderId = await _generateOrderId();

        // Create order document
        final orderRef = _firestore.collection(_ordersCollection).doc();
        final order = OrderModel(
          id: orderRef.id,
          orderId: orderId,
          buyerId: user.uid,
          buyerName: buyerName,
          buyerPhone: buyerPhone,
          buyerAddress: buyerAddress,
          sellerId: sellerId,
          sellerName: sellerName,
          sellerPhone: sellerPhone,
          items: orderItems,
          subtotal: subtotal,
          shippingCost: shippingCost,
          totalAmount: totalAmount,
          status: OrderStatus.pending,
          notes: notes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await orderRef.set(order.toMap());

        // Update product stock
        await _updateProductStock(orderItems);

        orderIds.add(orderRef.id);

        if (kDebugMode) {
          print('✅ Order created: ${order.orderId} for seller: $sellerName');
        }
      }

      return orderIds.first; // Return first order ID
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating order: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get Orders by Buyer
  // ============================================================================
  Future<List<OrderModel>> getMyOrders({
    OrderStatus? status,
    int limit = 50,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      QuerySnapshot snapshot;

      // Try with orderBy first (requires composite index)
      try {
        Query query = _firestore
            .collection(_ordersCollection)
            .where('buyerId', isEqualTo: user.uid);

        // Filter by status if provided
        if (status != null) {
          query = query.where('status', isEqualTo: status.name);
        }

        query = query.orderBy('createdAt', descending: true).limit(limit);

        snapshot = await query.get();
      } catch (e) {
        // FALLBACK: If index not ready, get without orderBy
        if (kDebugMode) {
          print('⚠️ Composite index not ready for orders, using fallback query');
        }

        Query query = _firestore
            .collection(_ordersCollection)
            .where('buyerId', isEqualTo: user.uid);

        // Filter by status if provided
        if (status != null) {
          query = query.where('status', isEqualTo: status.name);
        }

        query = query.limit(limit);

        snapshot = await query.get();
      }

      // Convert to list
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Sort by createdAt (client-side) if fallback was used
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return orders;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting my orders: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get Orders by Seller (untuk penjual)
  // ============================================================================
  Future<List<OrderModel>> getSellerOrders({
    OrderStatus? status,
    int limit = 50,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      QuerySnapshot snapshot;

      // Try with orderBy first (requires composite index)
      try {
        Query query = _firestore
            .collection(_ordersCollection)
            .where('sellerId', isEqualTo: user.uid);

        if (status != null) {
          query = query.where('status', isEqualTo: status.name);
        }

        query = query.orderBy('createdAt', descending: true).limit(limit);

        snapshot = await query.get();
      } catch (e) {
        // FALLBACK: If index not ready, get without orderBy
        if (kDebugMode) {
          print('⚠️ Composite index not ready for seller orders, using fallback query');
        }

        Query query = _firestore
            .collection(_ordersCollection)
            .where('sellerId', isEqualTo: user.uid);

        if (status != null) {
          query = query.where('status', isEqualTo: status.name);
        }

        query = query.limit(limit);

        snapshot = await query.get();
      }

      // Convert to list
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Sort by createdAt (client-side) if fallback was used
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return orders;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting seller orders: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // READ - Get Single Order
  // ============================================================================
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      return OrderModel.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting order: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Update Order Status (untuk seller)
  // ============================================================================
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      final updates = {
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If completed, set completedAt
      if (newStatus == OrderStatus.completed) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update(updates);

      if (kDebugMode) {
        print('✅ Order status updated: $orderId -> ${newStatus.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating order status: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Cancel Order (buyer/seller)
  // ============================================================================
  Future<void> cancelOrder({
    required String orderId,
    required String cancelReason,
  }) async {
    try {
      // Get order first
      final orderDoc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order tidak ditemukan');
      }

      final order = OrderModel.fromFirestore(orderDoc);

      // Check if can cancel
      if (!order.canCancel) {
        throw Exception('Order tidak bisa dibatalkan (status: ${order.statusText})');
      }

      // Restore product stock
      await _restoreProductStock(order.items);

      // Update order status
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
        'status': OrderStatus.cancelled.name,
        'cancelReason': cancelReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Order cancelled: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cancelling order: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UPDATE - Complete Order (buyer terima pesanan)
  // ============================================================================
  Future<void> completeOrder(String orderId) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({
        'status': OrderStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Order completed: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing order: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // HELPER - Generate Order ID
  // ============================================================================
  Future<String> _generateOrderId() async {
    final now = DateTime.now();
    final year = now.year;

    // Get count of orders today
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayOrders = await _firestore
        .collection(_ordersCollection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final orderNumber = (todayOrders.docs.length + 1).toString().padLeft(4, '0');

    return 'ORD-$year-$orderNumber';
  }

  // ============================================================================
  // HELPER - Update Product Stock
  // ============================================================================
  Future<void> _updateProductStock(List<OrderItemModel> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore
          .collection(_productsCollection)
          .doc(item.productId);

      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
        'soldCount': FieldValue.increment(item.quantity),
      });
    }

    await batch.commit();
  }

  // ============================================================================
  // HELPER - Restore Product Stock (saat cancel)
  // ============================================================================
  Future<void> _restoreProductStock(List<OrderItemModel> items) async {
    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore
          .collection(_productsCollection)
          .doc(item.productId);

      batch.update(productRef, {
        'stock': FieldValue.increment(item.quantity),
        'soldCount': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
  }

  // ============================================================================
  // STREAM - Real-time Orders
  // ============================================================================
  Stream<List<OrderModel>> streamMyOrders({OrderStatus? status}) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection(_ordersCollection)
        .where('buyerId', isEqualTo: user.uid);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }
}

