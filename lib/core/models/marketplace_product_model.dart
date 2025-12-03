// ============================================================================
// MARKETPLACE PRODUCT MODEL
// ============================================================================
// Model untuk produk marketplace dengan support multiple images
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceProductModel {
  final String id;
  final String sellerId; // UID penjual
  final String sellerName; // Nama penjual
  final String productName;
  final String description;
  final double price;
  final int stock;
  final String category; // sayuran, buah, sembako, dll
  final String? subcategory; // Subcategory (e.g., "Sayur Daun", "Sayur Akar", dll)
  final List<String> imageUrls; // Multiple images URLs from storage
  final String unit; // kg, pcs, ikat, dll
  final bool isActive; // Produk aktif/non-aktif
  final DateTime createdAt;
  final DateTime updatedAt;
  final int soldCount; // Jumlah terjual
  final double rating; // Rating produk (0-5)
  final int reviewCount; // Jumlah review

  MarketplaceProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.productName,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.subcategory,
    required this.imageUrls,
    required this.unit,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.soldCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'productName': productName,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'subcategory': subcategory,
      'imageUrls': imageUrls,
      'unit': unit,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'soldCount': soldCount,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // Create from Firestore DocumentSnapshot
  factory MarketplaceProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketplaceProductModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      productName: data['productName'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      unit: data['unit'] ?? 'kg',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      soldCount: data['soldCount'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  // Create from Map
  factory MarketplaceProductModel.fromMap(Map<String, dynamic> data) {
    return MarketplaceProductModel(
      id: data['id'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      productName: data['productName'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      category: data['category'] ?? '',
      subcategory: data['subcategory'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      unit: data['unit'] ?? 'kg',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      soldCount: data['soldCount'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  // CopyWith method for easy updates
  MarketplaceProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? productName,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? subcategory,
    List<String>? imageUrls,
    String? unit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? soldCount,
    double? rating,
    int? reviewCount,
  }) {
    return MarketplaceProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrls: imageUrls ?? this.imageUrls,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      soldCount: soldCount ?? this.soldCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  String toString() {
    return 'MarketplaceProductModel(id: $id, productName: $productName, price: $price, stock: $stock, category: $category)';
  }
}

