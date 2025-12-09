import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String nama;
  final String? nik;
  final String? jenisKelamin;
  final String? noTelepon;
  final String? alamat;
  final String role;
  final String status;
  final String? password;
  final String? keluargaId; // ⭐ ADDED: Link to keluarga collection
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.nama,
    this.nik,
    this.jenisKelamin,
    this.noTelepon,
    this.alamat,
    required this.role,
    required this.status,
    this.password,
    required this.createdAt,
    this.updatedAt,
    this.keluargaId, // ⭐ ADDED
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Warning: Failed to parse DateTime from string: $value');
        return null;
      }
    } else if (value is DateTime) {
      return value;
    }

    print('Warning: Unknown DateTime format: ${value.runtimeType}');
    return null;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      print('UserModel.fromMap called');
      print('Document ID: $id');
      print('Map data: $map');
      
      final user = UserModel(
        id: id,
        email: map['email'] ?? '',
        nama: map['nama'] ?? '',
        nik: map['nik']?.toString(),
        jenisKelamin: map['jenisKelamin'],
        noTelepon: map['noTelepon'],
        alamat: map['alamat'],
        role: map['role'] ?? 'user',
        status: map['status'] ?? 'pending',
        password: map['password'],
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(map['updatedAt']),
        keluargaId: map['keluargaId'], // ⭐ ADDED
      );
      
      print('✅ UserModel created successfully');
      return user;
    } catch (e, stackTrace) {
      print('❌ ERROR in UserModel.fromMap:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    print('UserModel.toMap() called');
    print('  - email: $email');
    print('  - nama: $nama');
    print('  - nik: $nik');
    print('  - role: $role');
    print('  - status: $status');

    final map = {
      'email': email,
      'nama': nama,
      'nik': nik,
      'jenisKelamin': jenisKelamin,
      'noTelepon': noTelepon,
      'alamat': alamat,
      'role': role,
      'status': status,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'keluargaId': keluargaId, // ⭐ ADDED
    };

    print('UserModel.toMap() completed successfully');
    return map;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? nik,
    String? jenisKelamin,
    String? noTelepon,
    String? alamat,
    String? role,
    String? status,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? keluargaId, // ⭐ ADDED
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      nik: nik ?? this.nik,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      noTelepon: noTelepon ?? this.noTelepon,
      alamat: alamat ?? this.alamat,
      role: role ?? this.role,
      status: status ?? this.status,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      keluargaId: keluargaId ?? this.keluargaId, // ⭐ ADDED
    );
  }
}

