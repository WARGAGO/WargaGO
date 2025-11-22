import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jawara/core/models/user_model.dart';
import 'package:jawara/core/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Sign in with email and password using Firebase Auth
  Future<bool> signIn({required String email, required String password}) async {
    try {
      if (kDebugMode) {
        print('\n=== LOGIN ATTEMPT ===');
        print('Email: $email');
        print('Password length: ${password.length}');
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validate input
      if (email.isEmpty || password.isEmpty) {
        if (kDebugMode) {
          print('❌ Validation failed: Empty fields');
        }
        _errorMessage = 'Email dan password harus diisi';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign in with Firebase Auth
      if (kDebugMode) {
        print('🔐 Signing in with Firebase Auth...');
      }
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        if (kDebugMode) {
          print('❌ Firebase Auth user is null');
        }
        _errorMessage = 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Firebase Auth successful!');
        print('Firebase UID: ${userCredential.user!.uid}');
        print('🔍 Getting user data from Firestore...');
      }

      // Get user data from Firestore using UID
      final user = await _firestoreService.getUserById(
        userCredential.user!.uid,
      );

      if (user == null) {
        if (kDebugMode) {
          print('❌ User not found in Firestore');
          print('⚠️  User exists in Firebase Auth but not in Firestore!');
        }
        await _auth.signOut();
        _errorMessage = 'Data pengguna tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ User found!');
        print('User data:');
        print('  - Email: ${user.email}');
        print('  - Nama: ${user.nama}');
        print('  - Role: ${user.role}');
        print('  - Status: ${user.status}');
        print('  - TOKEN: ${await _auth.currentUser!.getIdToken()}');
      }

      // Check if user status is approved
      if (user.status != 'approved') {
        if (kDebugMode) {
          print('❌ Status bukan approved: ${user.status}');
        }
        await _auth.signOut();
        if (user.status == 'pending') {
          _errorMessage = 'Akun Anda masih menunggu persetujuan admin';
        } else if (user.status == 'rejected') {
          _errorMessage = 'Akun Anda ditolak oleh admin';
        } else {
          _errorMessage = 'Akun Anda tidak aktif (status: ${user.status})';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Status approved!');
        print('🎉 LOGIN BERHASIL!');
        print('===================\n');
      }

      _userModel = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('\n❌ Firebase Auth Error ===');
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      }

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          _errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          _errorMessage = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          _errorMessage =
              'Terlalu banyak percobaan login. Silakan coba lagi nanti';
          break;
        case 'invalid-credential':
          _errorMessage = 'Email atau password salah';
          break;
        default:
          _errorMessage = 'Login gagal: ${e.message}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ LOGIN ERROR ===');
        print('Error: $e');
        print('StackTrace: $stackTrace');
        print('==================\n');
      }
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up / Register using Firebase Auth
  Future<bool> signUp({
    required String email,
    required String password,
    required String nama,
    String? nik,
    String? jenisKelamin,
    String? noTelepon,
    String? alamat,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) {
        print('=== START REGISTRATION ===');
        print('Email: $email');
        print('Nama: $nama');
      }

      // Validate input
      if (email.isEmpty || password.isEmpty || nama.isEmpty) {
        _errorMessage = 'Email, password, dan nama harus diisi';
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) {
          print('Validation failed: Empty fields');
        }
        return false;
      }

      // Create user with Firebase Auth
      if (kDebugMode) {
        print('🔐 Creating Firebase Auth user...');
      }
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        if (kDebugMode) {
          print('❌ Failed to create Firebase Auth user');
        }
        _errorMessage = 'Gagal membuat akun';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Firebase Auth user created!');
        print('Firebase UID: ${userCredential.user!.uid}');
        print('Creating user document in Firestore...');
      }

      // Create user data in Firestore (using Firebase UID as document ID)
      final newUser = UserModel(
        id: userCredential.user!.uid, // Use Firebase UID
        email: email,
        nama: nama,
        nik: nik,
        jenisKelamin: jenisKelamin,
        noTelepon: noTelepon,
        alamat: alamat,
        role: 'admin',
        status: 'approved',
        password: null, // No longer store password in Firestore
        createdAt: DateTime.now(),
      );

      if (kDebugMode) {
        print('Saving to Firestore...');
      }
      final userId = await _firestoreService.createUser(newUser);
      if (kDebugMode) {
        print('User ID: $userId');
      }

      if (userId == null) {
        // Rollback: Delete Firebase Auth user if Firestore save fails
        if (kDebugMode) {
          print('⚠️ Firestore save failed, deleting Firebase Auth user...');
        }
        await userCredential.user!.delete();
        _errorMessage = 'Gagal menyimpan data ke database';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Sign out after registration (user needs to login)
      await _auth.signOut();

      if (kDebugMode) {
        print('=== REGISTRATION SUCCESS ===');
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('=== Firebase Auth Error ===');
        print('Error code: ${e.code}');
        print('Error message: ${e.message}');
      }

      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          _errorMessage = 'Format email tidak valid';
          break;
        case 'weak-password':
          _errorMessage = 'Password terlalu lemah (minimal 6 karakter)';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Registrasi tidak diizinkan';
          break;
        default:
          _errorMessage = 'Registrasi gagal: ${e.message}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== REGISTRATION ERROR ===');
        print('Error: $e');
        print('StackTrace: $stackTrace');
      }
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out from Firebase Auth
  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Check authentication status from Firebase Auth
  Future<bool> checkAuthStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _isAuthenticated = false;
        _userModel = null;
        return false;
      }

      // Get user data from Firestore
      final user = await _firestoreService.getUserById(currentUser.uid);
      if (user == null || user.status != 'approved') {
        await _auth.signOut();
        _isAuthenticated = false;
        _userModel = null;
        return false;
      }

      _userModel = user;
      _isAuthenticated = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking auth status: $e');
      }
      _isAuthenticated = false;
      _userModel = null;
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
