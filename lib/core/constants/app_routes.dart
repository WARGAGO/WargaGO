/// Konstanta untuk semua route dalam aplikasi
/// Terpusat di satu tempat untuk memudahkan maintenance
class AppRoutes {
  AppRoutes._(); // Private constructor untuk prevent instantiation

  // ========== COMMON ROUTES ==========
  /// Route awal aplikasi (Splash Screen)
  static const String splash = '/';

  /// Route onboarding (pengenalan app)
  static const String onboarding = '/onboarding';

  /// Route pre-auth (DEPRECATED - tidak digunakan lagi)
  @Deprecated('Use login instead')
  static const String preAuth = '/pre-auth';

  // ========== AUTH ROUTES (UNIFIED) ==========
  /// Route login unified untuk Admin & Warga
  static const String login = '/login';

  // ========== ADMIN ROUTES ==========
  /// Route login admin (DEPRECATED - gunakan /login)
  @Deprecated('Use login instead')
  static const String adminLogin = '/admin/login';

  /// Route dashboard admin
  static const String adminDashboard = '/admin/dashboard';

  /// Route verifikasi warga oleh admin
  static const String adminVerifyWarga = '/admin/verify-warga';

  // ========== WARGA ROUTES ==========
  /// Route registrasi warga baru
  static const String wargaRegister = '/warga/register';

  /// Route login warga (DEPRECATED - gunakan /login)
  @Deprecated('Use login instead')
  static const String wargaLogin = '/warga/login';

  /// Route upload KYC (KTP & Selfie)
  static const String wargaKYC = '/warga/kyc';

  /// Route dashboard warga
  static const String wargaDashboard = '/warga/dashboard';

  // ========== STATUS ROUTES ==========
  /// Route halaman menunggu persetujuan
  static const String pending = '/pending';

  /// Route halaman akun ditolak
  static const String rejected = '/rejected';
}

