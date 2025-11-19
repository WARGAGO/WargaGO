import 'package:cloud_firestore/cloud_firestore.dart';

class KeuanganModel {
  final String id;
  final String type;
  final double amount;
  final String kategori;
  final String? deskripsi;
  final DateTime tanggal;
  final String? bukti;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  KeuanganModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.kategori,
    this.deskripsi,
    required this.tanggal,
    this.bukti,
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory KeuanganModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KeuanganModel(
      id: doc.id,
      type: data['type'] ?? 'pemasukan',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      kategori: data['kategori'] ?? data['category'] ?? '',
      deskripsi: data['deskripsi'] ?? data['description'],
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bukti: data['bukti'] ?? data['proof'],
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'kategori': kategori,
      'category': kategori,
      'deskripsi': deskripsi,
      'description': deskripsi,
      'tanggal': Timestamp.fromDate(tanggal),
      'bukti': bukti,
      'proof': bukti,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  KeuanganModel copyWith({
    String? type,
    double? amount,
    String? kategori,
    String? deskripsi,
    DateTime? tanggal,
    String? bukti,
    String? createdBy,
    bool? isActive,
  }) {
    return KeuanganModel(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      kategori: kategori ?? this.kategori,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      bukti: bukti ?? this.bukti,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

