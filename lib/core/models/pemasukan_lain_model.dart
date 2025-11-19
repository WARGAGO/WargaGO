import 'package:cloud_firestore/cloud_firestore.dart';
class PemasukanLainModel {
  final String id;
  final String name;
  final String category;
  final double nominal;
  final String? deskripsi;
  final DateTime tanggal;
  final String status;
  final String? bukti;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  PemasukanLainModel({required this.id, required this.name, required this.category, required this.nominal, this.deskripsi, required this.tanggal, this.status = 'Menunggu', this.bukti, this.createdBy = '', this.createdAt, this.updatedAt, this.isActive = true});
  factory PemasukanLainModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PemasukanLainModel(id: doc.id, name: data['name'] ?? '', category: data['category'] ?? '', nominal: (data['nominal'] as num?)?.toDouble() ?? 0, deskripsi: data['deskripsi'], tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(), status: data['status'] ?? 'Menunggu', bukti: data['bukti'], createdBy: data['createdBy'] ?? '', createdAt: (data['createdAt'] as Timestamp?)?.toDate(), updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(), isActive: data['isActive'] ?? true);
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'category': category, 'nominal': nominal, 'deskripsi': deskripsi, 'tanggal': Timestamp.fromDate(tanggal), 'status': status, 'bukti': bukti, 'createdBy': createdBy, 'isActive': isActive};
  }
  PemasukanLainModel copyWith({String? name, String? category, double? nominal, String? deskripsi, DateTime? tanggal, String? status, String? bukti, String? createdBy, bool? isActive}) {
    return PemasukanLainModel(id: id, name: name ?? this.name, category: category ?? this.category, nominal: nominal ?? this.nominal, deskripsi: deskripsi ?? this.deskripsi, tanggal: tanggal ?? this.tanggal, status: status ?? this.status, bukti: bukti ?? this.bukti, createdBy: createdBy ?? this.createdBy, createdAt: createdAt, updatedAt: updatedAt, isActive: isActive ?? this.isActive);
  }
}
