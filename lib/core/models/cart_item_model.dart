// ============================================================================
// CART ITEM MODEL
// ============================================================================
// Model untuk item di keranjang belanja marketplace
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id; // Cart item ID
  final String userId; // UID pembeli
  final String productId; // ID produk
  final String sellerId; // UID penjual
  final String productName;
  final String productImage; // URL gambar produk (first image)
  final double price;
  final int quantity; // Jumlah yang dipesan
  final String unit; // kg, pcs, ikat, dll
  final int maxStock; // Stock tersedia
  final DateTime addedAt; // Kapan ditambahkan ke cart
  final bool isSelected; // Untuk checkout (multi-select)

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.maxStock,
    required this.addedAt,
    this.isSelected = true,
  });

  // Total harga item ini
  double get totalPrice => price * quantity;

  // Check if stock sufficient
  bool get isStockSufficient => quantity <= maxStock;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'sellerId': sellerId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'maxStock': maxStock,
      'addedAt': Timestamp.fromDate(addedAt),
      'isSelected': isSelected,
    };
  }

  // Create from Firestore document
  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      unit: data['unit'] ?? 'pcs',
      maxStock: data['maxStock'] ?? 0,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSelected: data['isSelected'] ?? true,
    );
  }

  // Create from Map
  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      productName: data['productName'] ?? '',
      productImage: data['productImage'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      unit: data['unit'] ?? 'pcs',
      maxStock: data['maxStock'] ?? 0,
      addedAt: data['addedAt'] is Timestamp
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isSelected: data['isSelected'] ?? true,
    );
  }

  // Copy with method for updates
  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    String? sellerId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? unit,
    int? maxStock,
    DateTime? addedAt,
    bool? isSelected,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      maxStock: maxStock ?? this.maxStock,
      addedAt: addedAt ?? this.addedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(id: $id, productName: $productName, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CartItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

