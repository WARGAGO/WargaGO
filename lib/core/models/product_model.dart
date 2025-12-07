// ============================================================================
// PRODUCT MODEL
// ============================================================================
// Model untuk produk sayuran di marketplace
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId; // UID seller (warga)
  final String sellerName; // Nama seller
  final String nama;
  final String deskripsi;
  final double harga;
  final int stok;
  final double berat; // dalam kg
  final String kategori;
  final List<String> imageUrls; // Max 3 gambar
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive; // Status aktif/nonaktif
  final bool isDeleted; // Status sudah dihapus atau belum
  final int terjual; // Jumlah produk yang sudah terjual

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.berat,
    required this.kategori,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isDeleted = false,
    this.terjual = 0,
  });

  // Factory constructor from Firestore document
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      stok: map['stok'] ?? 0,
      berat: (map['berat'] ?? 0).toDouble(),
      kategori: map['kategori'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      isDeleted: map['isDeleted'] ?? false, // Default false for existing products
      terjual: map['terjual'] ?? 0,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'berat': berat,
      'kategori': kategori,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isDeleted': isDeleted,
      'terjual': terjual,
    };
  }

  // Create copy with updated fields
  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? nama,
    String? deskripsi,
    double? harga,
    int? stok,
    double? berat,
    String? kategori,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isDeleted,
    int? terjual,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      berat: berat ?? this.berat,
      kategori: kategori ?? this.kategori,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      terjual: terjual ?? this.terjual,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, nama: $nama, harga: $harga, stok: $stok, kategori: $kategori)';
  }
}

