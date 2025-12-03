// ============================================================================
// ORDER REPOSITORY
// ============================================================================
// Repository layer untuk orders dengan error handling & validation
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../services/order_service.dart';

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

class OrderRepository {
  final OrderService _service = OrderService();

  // ============================================================================
  // CREATE - Create Order from Cart
  // ============================================================================
  Future<Result<String>> createOrder({
    required List<CartItemModel> cartItems,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    String? notes,
  }) async {
    try {
      // Validation
      if (cartItems.isEmpty) {
        return Result.error('Tidak ada item untuk dipesan');
      }
      if (buyerName.trim().isEmpty) {
        return Result.error('Nama pembeli tidak boleh kosong');
      }
      if (buyerPhone.trim().isEmpty) {
        return Result.error('Nomor telepon tidak boleh kosong');
      }
      if (buyerAddress.trim().isEmpty) {
        return Result.error('Alamat pengiriman tidak boleh kosong');
      }

      final orderId = await _service.createOrder(
        cartItems: cartItems,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        buyerAddress: buyerAddress,
        notes: notes,
      );

      return Result.success(orderId);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - createOrder: $e');
      }
      return Result.error(_getErrorMessage(e));
    }
  }

  // ============================================================================
  // READ - Get My Orders
  // ============================================================================
  Future<Result<List<OrderModel>>> getMyOrders({
    OrderStatus? status,
    int limit = 50,
  }) async {
    try {
      final orders = await _service.getMyOrders(
        status: status,
        limit: limit,
      );
      return Result.success(orders);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getMyOrders: $e');
      }
      return Result.error('Gagal memuat pesanan: ${e.toString()}');
    }
  }

  // ============================================================================
  // READ - Get Seller Orders
  // ============================================================================
  Future<Result<List<OrderModel>>> getSellerOrders({
    OrderStatus? status,
    int limit = 50,
  }) async {
    try {
      final orders = await _service.getSellerOrders(
        status: status,
        limit: limit,
      );
      return Result.success(orders);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getSellerOrders: $e');
      }
      return Result.error('Gagal memuat pesanan: ${e.toString()}');
    }
  }

  // ============================================================================
  // READ - Get Order by ID
  // ============================================================================
  Future<Result<OrderModel?>> getOrderById(String orderId) async {
    try {
      if (orderId.trim().isEmpty) {
        return Result.error('Order ID tidak boleh kosong');
      }

      final order = await _service.getOrderById(orderId);
      return Result.success(order);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - getOrderById: $e');
      }
      return Result.error('Gagal memuat detail pesanan: ${e.toString()}');
    }
  }

  // ============================================================================
  // UPDATE - Update Order Status
  // ============================================================================
  Future<Result<void>> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    try {
      if (orderId.trim().isEmpty) {
        return Result.error('Order ID tidak boleh kosong');
      }

      await _service.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - updateOrderStatus: $e');
      }
      return Result.error(_getErrorMessage(e));
    }
  }

  // ============================================================================
  // UPDATE - Cancel Order
  // ============================================================================
  Future<Result<void>> cancelOrder({
    required String orderId,
    required String cancelReason,
  }) async {
    try {
      if (orderId.trim().isEmpty) {
        return Result.error('Order ID tidak boleh kosong');
      }
      if (cancelReason.trim().isEmpty) {
        return Result.error('Alasan pembatalan tidak boleh kosong');
      }

      await _service.cancelOrder(
        orderId: orderId,
        cancelReason: cancelReason,
      );

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - cancelOrder: $e');
      }
      return Result.error(_getErrorMessage(e));
    }
  }

  // ============================================================================
  // UPDATE - Complete Order
  // ============================================================================
  Future<Result<void>> completeOrder(String orderId) async {
    try {
      if (orderId.trim().isEmpty) {
        return Result.error('Order ID tidak boleh kosong');
      }

      await _service.completeOrder(orderId);

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('Repository Error - completeOrder: $e');
      }
      return Result.error('Gagal menyelesaikan pesanan: ${e.toString()}');
    }
  }

  // ============================================================================
  // STREAM - Real-time Orders
  // ============================================================================
  Stream<List<OrderModel>> streamMyOrders({OrderStatus? status}) {
    return _service.streamMyOrders(status: status);
  }

  // ============================================================================
  // HELPER - Extract Error Message
  // ============================================================================
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('User tidak terautentikasi')) {
      return 'Silakan login terlebih dahulu';
    }
    if (errorString.contains('tidak bisa dibatalkan')) {
      return errorString.replaceAll('Exception: ', '');
    }
    if (errorString.contains('tidak ditemukan')) {
      return 'Pesanan tidak ditemukan';
    }
    if (errorString.contains('network')) {
      return 'Koneksi internet bermasalah';
    }

    return errorString.replaceAll('Exception: ', '');
  }
}

