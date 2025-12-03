// ============================================================================
// ORDER MODEL
// ============================================================================
// Model untuk pesanan marketplace
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,      // Menunggu konfirmasi penjual
  processing,   // Sedang diproses
  shipped,      // Dalam pengiriman
  completed,    // Selesai
  cancelled,    // Dibatalkan
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? '',
    );
  }
}

class OrderModel {
  final String id;
  final String orderId;           // ORD-2025-001
  final String buyerId;           // UID pembeli
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String sellerId;          // UID penjual
  final String sellerName;
  final String sellerPhone;
  final List<OrderItemModel> items;
  final double subtotal;          // Total harga items
  final double shippingCost;      // Ongkir
  final double totalAmount;       // Subtotal + ongkir
  final OrderStatus status;
  final String? notes;            // Catatan pembeli
  final String? cancelReason;     // Alasan cancel (jika ada)
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;    // Tanggal selesai

  OrderModel({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  // Status text untuk UI
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Menunggu Konfirmasi';
      case OrderStatus.processing:
        return 'Sedang Diproses';
      case OrderStatus.shipped:
        return 'Dalam Pengiriman';
      case OrderStatus.completed:
        return 'Selesai';
      case OrderStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  // Status color untuk UI
  int get statusColorValue {
    switch (status) {
      case OrderStatus.pending:
        return 0xFFF59E0B; // Orange
      case OrderStatus.processing:
        return 0xFFF59E0B; // Orange
      case OrderStatus.shipped:
        return 0xFF2F80ED; // Blue
      case OrderStatus.completed:
        return 0xFF10B981; // Green
      case OrderStatus.cancelled:
        return 0xFFEF4444; // Red
    }
  }

  // Can buyer cancel?
  bool get canCancel {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }

  // Can buyer complete (terima pesanan)?
  bool get canComplete {
    return status == OrderStatus.shipped;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'totalAmount': totalAmount,
      'status': status.name,
      'notes': notes,
      'cancelReason': cancelReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerPhone: data['buyerPhone'] ?? '',
      buyerAddress: data['buyerAddress'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shippingCost: (data['shippingCost'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      notes: data['notes'],
      cancelReason: data['cancelReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderId,
    String? buyerId,
    String? buyerName,
    String? buyerPhone,
    String? buyerAddress,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    List<OrderItemModel>? items,
    double? subtotal,
    double? shippingCost,
    double? totalAmount,
    OrderStatus? status,
    String? notes,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

