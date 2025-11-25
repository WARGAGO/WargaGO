import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jawara/core/models/user_model.dart';
import 'package:jawara/core/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
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
    await _googleSignIn.signOut();
    _userModel = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('\n=== GOOGLE SIGN IN ATTEMPT ===');
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        if (kDebugMode) {
          print('❌ User cancelled Google Sign In');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Google account selected: ${googleUser.email}');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      if (kDebugMode) {
        print('🔐 Signing in with Google credential...');
      }

      // Sign in to Firebase with Google credential
      final userCredential = await _auth.signInWithCredential(credential);

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
        print('🔍 Checking user in Firestore...');
      }

      // Check if user exists in Firestore
      var user = await _firestoreService.getUserById(userCredential.user!.uid);

      if (user == null) {
        // New user - create account as warga with unverified status
        if (kDebugMode) {
          print('📝 New user - creating warga account...');
        }

        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          nama: userCredential.user!.displayName ?? '',
          role: 'warga',
          status: 'unverified', // New status for unverified warga
          createdAt: DateTime.now(),
        );

        final userId = await _firestoreService.createUser(newUser);

        if (userId == null) {
          if (kDebugMode) {
            print('❌ Failed to create user in Firestore');
          }
          await _auth.signOut();
          await _googleSignIn.signOut();
          _errorMessage = 'Gagal menyimpan data pengguna';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        user = newUser;
        if (kDebugMode) {
          print('✅ New warga account created!');
        }
      }

      if (kDebugMode) {
        print('✅ User found/created!');
        print('User data:');
        print('  - Email: ${user.email}');
        print('  - Nama: ${user.nama}');
        print('  - Role: ${user.role}');
        print('  - Status: ${user.status}');
      }

      // Allow login for both unverified and approved warga
      // Admin should still be approved only
      if (user.role == 'admin' && user.status != 'approved') {
        if (kDebugMode) {
          print('❌ Admin status bukan approved: ${user.status}');
        }
        await _auth.signOut();
        await _googleSignIn.signOut();
        _errorMessage = user.status == 'pending'
            ? 'Akun admin Anda masih menunggu persetujuan'
            : 'Akun admin Anda tidak aktif';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.status == 'rejected') {
        if (kDebugMode) {
          print('❌ User rejected');
        }
        await _auth.signOut();
        await _googleSignIn.signOut();
        _errorMessage = 'Akun Anda ditolak oleh admin';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('🎉 GOOGLE SIGN IN BERHASIL!');
        print('===================\n');
      }

      _userModel = user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on PlatformException catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ GOOGLE SIGN IN PLATFORM ERROR ===');
        print('Error Code: ${e.code}');
        print('Error Message: ${e.message}');
        print('Error Details: ${e.details}');
        print('StackTrace: $stackTrace');
        print('==================\n');
      }

      // Handling different error codes
      if (e.code == 'sign_in_failed' || e.code == '10') {
        _errorMessage = 'Google Sign In tidak tersedia.\n\n'
            'Kemungkinan penyebab:\n'
            '• SHA-1 fingerprint belum terdaftar di Firebase Console\n'
            '• Google Play Services perlu update\n'
            '• Koneksi internet tidak stabil\n\n'
            'Solusi:\n'
            '1. Pastikan SHA-1 fingerprint HP sudah terdaftar di Firebase\n'
            '2. Update Google Play Services di HP\n'
            '3. Restart aplikasi dan coba lagi\n'
            '4. Periksa koneksi internet\n\n'
            'Catatan: Jika device lain bisa login, kemungkinan SHA-1 fingerprint device ini belum terdaftar.';
      } else if (e.code == 'network_error') {
        _errorMessage = 'Gagal terhubung ke Google.\nPeriksa koneksi internet Anda.';
      } else if (e.code == 'sign_in_canceled') {
        _errorMessage = null; // User cancelled, no error message needed
      } else {
        _errorMessage = 'Google Sign In gagal: ${e.message ?? e.code}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ FIREBASE AUTH ERROR ===');
        print('Error Code: ${e.code}');
        print('Error Message: ${e.message}');
        print('StackTrace: $stackTrace');
        print('==================\n');
      }

      if (e.code == 'invalid-credential') {
        _errorMessage = 'Kredensial Google tidak valid.\n\n'
            'Kemungkinan penyebab:\n'
            '• SHA-1 fingerprint tidak sesuai\n'
            '• Konfigurasi Firebase salah\n\n'
            'Solusi:\n'
            '1. Periksa SHA-1 di Firebase Console\n'
            '2. Download ulang google-services.json\n'
            '3. Rebuild aplikasi';
      } else {
        _errorMessage = 'Firebase Auth gagal: ${e.message}';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ GOOGLE SIGN IN ERROR ===');
        print('Error: $e');
        print('StackTrace: $stackTrace');
        print('==================\n');
      }
      _errorMessage = 'Terjadi kesalahan saat login dengan Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register warga with email/password
  Future<bool> registerWarga({
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
        print('=== START WARGA REGISTRATION ===');
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
        print('Creating warga document in Firestore...');
      }

      // Create user data in Firestore as warga with unverified status
      final newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        nama: nama,
        nik: nik,
        jenisKelamin: jenisKelamin,
        noTelepon: noTelepon,
        alamat: alamat,
        role: 'warga',
        status: 'unverified', // Start as unverified
        password: null,
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

      // Auto login after registration for warga
      _userModel = newUser;
      _isAuthenticated = true;

      if (kDebugMode) {
        print('=== WARGA REGISTRATION SUCCESS ===');
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
