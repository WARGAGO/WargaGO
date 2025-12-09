import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:wargago/core/models/user_model.dart';
import 'package:wargago/core/services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<User?>? _authStateSubscription;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Constructor - setup auth state listener
  AuthProvider() {
    _initAuthStateListener();
  }

  Future<String?> getToken() async => await _auth.currentUser!.getIdToken();

  // Initialize auth state listener
  void _initAuthStateListener() {
    if (kDebugMode) {
      print('🔐 Initializing auth state listener...');
    }

    _authStateSubscription = _auth.authStateChanges().listen((User? user) async {
      if (kDebugMode) {
        print('🔐 Auth state changed');
        print('   User: ${user?.uid}');
        print('   Email: ${user?.email}');
      }

      if (user != null) {
        // User is signed in
        if (kDebugMode) {
          print('✅ User is signed in, loading user data...');
        }

        try {
          // Load user data from Firestore
          var userModel = await _firestoreService.getUserById(user.uid);

          if (userModel == null && user.email != null) {
            // Fallback: try to find by email
            userModel = await _firestoreService.getUserByEmail(user.email!);
          }

          if (userModel != null) {
            _userModel = userModel;
            _isAuthenticated = true;

            // Start listening to user data changes
            _startUserListener(userModel.id);

            notifyListeners();

            if (kDebugMode) {
              print('✅ User data loaded on app start');
              print('   Name: ${userModel.nama}');
              print('   Status: ${userModel.status}');
            }
          } else {
            if (kDebugMode) {
              print('⚠️ User exists in Firebase Auth but not in Firestore');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error loading user data: $e');
          }
        }
      } else {
        // User is signed out
        if (kDebugMode) {
          print('🔓 User is signed out');
        }
        _stopUserListener();
        _userModel = null;
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }

  // Start listening to user data changes
  void _startUserListener(String userId) {
    if (kDebugMode) {
      print('👂 Starting real-time listener for user: $userId');
    }

    _userSubscription?.cancel();
    _userSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen(
      (snapshot) {
        if (kDebugMode) {
          print('📡 Firestore snapshot received for user: $userId');
          print('   Exists: ${snapshot.exists}');
          print('   Has data: ${snapshot.data() != null}');
        }

        if (snapshot.exists && snapshot.data() != null) {
          final userData = snapshot.data() as Map<String, dynamic>;
          final updatedUser = UserModel.fromMap(userData, snapshot.id);

          if (kDebugMode) {
            print('🔄 User data updated from Firestore');
            print('   Old status: ${_userModel?.status}');
            print('   New status: ${updatedUser.status}');
            print('   Status changed: ${_userModel?.status != updatedUser.status}');
          }

          _userModel = updatedUser;
          notifyListeners();

          if (kDebugMode) {
            print('✅ notifyListeners() called - UI should update');
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('❌ Error in user listener: $error');
        }
      },
    );
  }

  // Stop listening to user data changes
  void _stopUserListener() {
    if (kDebugMode) {
      print('🔇 Stopping user listener');
    }
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  // Manually refresh user data from Firestore
  Future<void> refreshUserData() async {
    if (_userModel == null) return;

    try {
      if (kDebugMode) {
        print('🔄 Manually refreshing user data...');
      }

      final user = await _firestoreService.getUserById(_userModel!.id);

      if (user != null) {
        _userModel = user;
        notifyListeners();

        if (kDebugMode) {
          print('✅ User data refreshed successfully');
          print('   Status: ${user.status}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing user data: $e');
      }
    }
  }

  @override
  void dispose() {
    _stopUserListener();
    _authStateSubscription?.cancel();
    super.dispose();
  }

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
        print('Email: ${userCredential.user!.email}');
        print('🔍 Getting user data from Firestore...');
      }

      // Get user data from Firestore using UID
      var user = await _firestoreService.getUserById(
        userCredential.user!.uid,
      );

      // FALLBACK: If user not found by UID, try to find by email
      // This handles legacy admin accounts created without Firebase Auth UID
      if (user == null && userCredential.user!.email != null) {
        if (kDebugMode) {
          print('⚠️  User not found by UID, trying fallback query by email...');
          print('   Email: ${userCredential.user!.email}');
        }

        user = await _firestoreService.getUserByEmail(
          userCredential.user!.email!,
        );

        if (user != null) {
          if (kDebugMode) {
            print('✅ User found by email! (Legacy admin account detected)');
            print('   Document ID: ${user.id}');
            print('   Firebase UID: ${userCredential.user!.uid}');
            print('   ⚠️  Consider migrating this account to use Firebase UID as document ID');
          }
        }
      }

      if (user == null) {
        if (kDebugMode) {
          print('❌ User not found in Firestore (both by UID and email)');
          print('⚠️  User exists in Firebase Auth but not in Firestore!');
          print('   Firebase UID: ${userCredential.user!.uid}');
          print('   Email: ${userCredential.user!.email}');
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
        print('  - TOKEN: ${await getToken()}');
      }

      // Only block rejected users - others can login
      // Status 'approved', 'pending', 'unverified' can all login
      // but features will be limited based on status
      if (user.status == 'rejected') {
        if (kDebugMode) {
          print('❌ Status rejected, login denied');
        }
        await _auth.signOut();
        _errorMessage =
            'Akun Anda ditolak oleh admin. Silakan hubungi admin untuk informasi lebih lanjut.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (kDebugMode) {
        print('✅ Login allowed for status: ${user.status}');
        if (user.status == 'pending') {
          print('⚠️  Status: PENDING - Menunggu approval admin');
        } else if (user.status == 'unverified') {
          print(
            '⚠️  Status: UNVERIFIED - Belum upload KYC atau belum diverifikasi admin',
          );
        } else if (user.status == 'approved') {
          print('✅ Status: APPROVED - Full access');
        }
        print('🎉 LOGIN BERHASIL!');
        print('===================\n');
      }

      _userModel = user;
      _isAuthenticated = true;
      _isLoading = false;

      // Start listening to user data changes
      _startUserListener(user.id);

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
    _stopUserListener(); // Stop listening to user changes
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
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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

        // 🆕 AUTO-CREATE entry in data_penduduk for Google Sign-In users
        if (kDebugMode) {
          print('🆕 Creating data_penduduk entry for Google user...');
        }
        try {
          await _firestore.collection('data_penduduk').add({
            'userId': userCredential.user!.uid,
            'namaLengkap': userCredential.user!.displayName ?? '',
            'email': userCredential.user!.email ?? '',
            'nik': '',
            'jenisKelamin': '',
            'noTelepon': '',
            'alamat': '',
            'keluargaId': '', // Empty - will be set by admin
            'status': 'Pending', // Pending approval
            'tempatLahir': '',
            'tanggalLahir': null,
            'agama': '',
            'pendidikan': '',
            'pekerjaan': '',
            'statusPerkawinan': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          if (kDebugMode) {
            print('✅ data_penduduk entry created for Google user!');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Failed to create data_penduduk for Google user: $e');
          }
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

      // Start listening to user data changes
      _startUserListener(user.id);

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
        _errorMessage =
            'Google Sign In tidak tersedia.\n\n'
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
        _errorMessage =
            'Gagal terhubung ke Google.\nPeriksa koneksi internet Anda.';
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
        _errorMessage =
            'Kredensial Google tidak valid.\n\n'
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

      // 🆕 AUTO-CREATE entry in data_penduduk collection
      // This allows admin to easily set keluargaId without manual data entry
      if (kDebugMode) {
        print('🆕 Creating data_penduduk entry...');
      }
      try {
        await _firestore.collection('data_penduduk').add({
          'userId': userCredential.user!.uid,
          'namaLengkap': nama,
          'email': email,
          'nik': nik ?? '',
          'jenisKelamin': jenisKelamin ?? '',
          'noTelepon': noTelepon ?? '',
          'alamat': alamat ?? '',
          'keluargaId': '', // Empty - will be set by admin
          'status': 'Pending', // Pending approval
          'tempatLahir': '',
          'tanggalLahir': null,
          'agama': '',
          'pendidikan': '',
          'pekerjaan': '',
          'statusPerkawinan': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (kDebugMode) {
          print('✅ data_penduduk entry created!');
          print('   Admin can now approve and set keluargaId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Failed to create data_penduduk entry: $e');
          print('   User can still proceed, admin will need to add manually');
        }
        // Don't fail registration if data_penduduk creation fails
        // User can still proceed with registration
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

      // Only block if user doesn't exist or is rejected
      // Allow approved, pending, and unverified to stay logged in
      if (user == null) {
        await _auth.signOut();
        _isAuthenticated = false;
        _userModel = null;
        return false;
      }

      // Only sign out if rejected
      if (user.status == 'rejected') {
        await _auth.signOut();
        _isAuthenticated = false;
        _userModel = null;
        return false;
      }

      // User exists and not rejected - keep them logged in
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

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      if (kDebugMode) {
        print('\n=== UPDATE USER PROFILE ===');
        print('User ID: ${updatedUser.id}');
        print('Nama: ${updatedUser.nama}');
        print('NIK: ${updatedUser.nik}');
        print('No Telepon: ${updatedUser.noTelepon}');
        print('Alamat: ${updatedUser.alamat}');
        print('⭐ Keluarga ID: ${updatedUser.keluargaId}'); // ⭐ ADDED DEBUG
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Update to Firestore
      final updateData = {
        'nama': updatedUser.nama,
        'nik': updatedUser.nik,
        'jenisKelamin': updatedUser.jenisKelamin,
        'noTelepon': updatedUser.noTelepon,
        'alamat': updatedUser.alamat,
        'keluargaId': updatedUser.keluargaId, // ⭐ ADDED - FIX UTAMA!
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (kDebugMode) {
        print('📝 Update data:');
        updateData.forEach((key, value) {
          print('   $key: $value');
        });
      }

      final success = await _firestoreService.updateUser(updatedUser.id, updateData);

      if (success) {
        // Update local state
        _userModel = updatedUser.copyWith(updatedAt: DateTime.now());
        _isLoading = false;
        notifyListeners();

        if (kDebugMode) {
          print('✅ Profile updated successfully');
          print('✅ New keluargaId in memory: ${_userModel?.keluargaId}');
        }
        return true;
      } else {
        _errorMessage = 'Gagal memperbarui profil';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('=== UPDATE PROFILE ERROR ===');
        print('Error: $e');
        print('StackTrace: $stackTrace');
      }
      _errorMessage = 'Terjadi kesalahan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
