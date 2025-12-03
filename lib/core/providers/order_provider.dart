// ============================================================================
// ORDER PROVIDER
// ============================================================================
// Provider untuk state management pesanan marketplace
// ============================================================================

import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  // State
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered orders by status
  List<OrderModel> get allOrders => _orders;
  List<OrderModel> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();
  List<OrderModel> get processingOrders =>
      _orders.where((o) => o.status == OrderStatus.processing).toList();
  List<OrderModel> get shippedOrders =>
      _orders.where((o) => o.status == OrderStatus.shipped).toList();
  List<OrderModel> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();
  List<OrderModel> get cancelledOrders =>
      _orders.where((o) => o.status == OrderStatus.cancelled).toList();

  // ============================================================================
  // CREATE ORDER
  // ============================================================================
  Future<bool> createOrder({
    required List<CartItemModel> cartItems,
    required String buyerName,
    required String buyerPhone,
    required String buyerAddress,
    String? notes,
  }) async {
    _error = null;

    try {
      final result = await _repository.createOrder(
        cartItems: cartItems,
        buyerName: buyerName,
        buyerPhone: buyerPhone,
        buyerAddress: buyerAddress,
        notes: notes,
      );

      if (result.isSuccess) {
        // Reload orders
        await loadMyOrders();
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal membuat pesanan: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error creating order: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // LOAD ORDERS
  // ============================================================================
  Future<void> loadMyOrders({OrderStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getMyOrders(status: status);

      if (result.isSuccess && result.data != null) {
        _orders = result.data!;
        _error = null;
      } else {
        _error = result.error;
      }
    } catch (e) {
      _error = 'Gagal memuat pesanan: ${e.toString()}';
      if (kDebugMode) {
        print('Error loading orders: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  // GET ORDER BY ID
  // ============================================================================
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final result = await _repository.getOrderById(orderId);

      if (result.isSuccess) {
        return result.data;
      } else {
        _error = result.error;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Gagal memuat detail pesanan: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error getting order: $e');
      }
      return null;
    }
  }

  // ============================================================================
  // UPDATE ORDER STATUS (untuk seller)
  // ============================================================================
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    _error = null;

    try {
      final result = await _repository.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );

      if (result.isSuccess) {
        // Update local state
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
            completedAt: newStatus == OrderStatus.completed
                ? DateTime.now()
                : _orders[index].completedAt,
          );
          notifyListeners();
        }
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengubah status: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // CANCEL ORDER
  // ============================================================================
  Future<bool> cancelOrder({
    required String orderId,
    required String cancelReason,
  }) async {
    _error = null;

    try {
      final result = await _repository.cancelOrder(
        orderId: orderId,
        cancelReason: cancelReason,
      );

      if (result.isSuccess) {
        // Update local state
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.cancelled,
            cancelReason: cancelReason,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal membatalkan pesanan: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error cancelling order: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // COMPLETE ORDER (buyer terima pesanan)
  // ============================================================================
  Future<bool> completeOrder(String orderId) async {
    _error = null;

    try {
      final result = await _repository.completeOrder(orderId);

      if (result.isSuccess) {
        // Update local state
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = _orders[index].copyWith(
            status: OrderStatus.completed,
            completedAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal menyelesaikan pesanan: ${e.toString()}';
      notifyListeners();
      if (kDebugMode) {
        print('Error completing order: $e');
      }
      return false;
    }
  }

  // ============================================================================
  // LISTEN TO ORDERS (Real-time)
  // ============================================================================
  void listenToOrders({OrderStatus? status}) {
    _repository.streamMyOrders(status: status).listen(
      (orders) {
        _orders = orders;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error stream: ${error.toString()}';
        notifyListeners();
        if (kDebugMode) {
          print('Error stream orders: $error');
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
}

