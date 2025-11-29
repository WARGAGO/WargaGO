import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jawara/core/models/user_model.dart';

/// Repository untuk mengelola data users (akun login)
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all users from Firestore
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get users by status
  Stream<List<UserModel>> getUsersByStatus(String status) {
    return _firestore
        .collection('users')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get pending users (unverified or pending)
  Stream<List<UserModel>> getPendingUsers() {
    return _firestore
        .collection('users')
        .where('status', whereIn: ['unverified', 'pending'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  /// Update user status
  Future<bool> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ User status updated to: $status');
      return true;
    } catch (e) {
      print('❌ Error updating user status: $e');
      return false;
    }
  }

  /// Update user role
  Future<bool> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ User role updated to: $role');
      return true;
    } catch (e) {
      print('❌ Error updating user role: $e');
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  /// Update user data
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('users').doc(userId).update(data);
      print('✅ User updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    }
  }

  /// Create new user (for adding admin)
  Future<bool> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').add(user.toMap());
      print('✅ User created successfully');
      return true;
    } catch (e) {
      print('❌ Error creating user: $e');
      return false;
    }
  }

  /// Create user with specific ID
  Future<bool> createUserWithId(String userId, UserModel user) async {
    try {
      await _firestore.collection('users').doc(userId).set(user.toMap());
      print('✅ User created with ID: $userId');
      return true;
    } catch (e) {
      print('❌ Error creating user with ID: $e');
      return false;
    }
  }

  /// Get user count by role
  Future<int> getUserCountByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting user count: $e');
      return 0;
    }
  }

  /// Get user count by status
  Future<int> getUserCountByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: status)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting user count: $e');
      return 0;
    }
  }

  /// Search users by name or email
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection('users')
        .orderBy('nama')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) {
        final nameLower = user.nama.toLowerCase();
        final emailLower = user.email.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower) ||
            emailLower.contains(queryLower);
      }).toList();
    });
  }
}

