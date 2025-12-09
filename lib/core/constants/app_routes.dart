/// Konstanta untuk semua route dalam aplikasi
/// Terpusat di satu tempat untuk memudahkan maintenance
class AppRoutes {
  AppRoutes._();

  // ========== COMMON ROUTES ==========
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String preAuth = '/pre-auth';
  static const String classificationCamera = '/classification-camera';

  // ========== AUTH ROUTES (UNIFIED) ==========
  static const String login = '/login';
  static const String forgotPassword = '/login/forgot';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminVerifyWarga = '/admin/verify-warga';

  // ========== WARGA ROUTES ==========
  static const String wargaRegister = '/warga/register';
  static const String wargaKYC = '/warga/kyc';
  static const String wargaAlamatRumah = '/warga/alamat-rumah'; // 🆕 After KYC
  static const String wargaDataKeluarga = '/warga/data-keluarga'; // 🆕 After Alamat
  static const String wargaDashboard = '/warga/dashboard';

  static const String wargaMarketplace = '/warga/marketplace';
  static const String wargaPesananSaya = '/warga/marketplace/pesanan';
  static const String wargaKeranjangSaya = '/warga/marketplace/keranjang';
  static const String wargaItemDetail = '/warga/marketplace/detail';
  static const String wargaClassificationCamera =
      '/warga/classification-camera';

  static const String wargaIuran = '/warga/iuran';

  static const String wargaAkun = '/warga/akun';
  static const String wargaEditProfile = '/warga/edit-profil';
  static const String wargaTokoSaya = '/warga/toko-saya';

  // ========== STATUS ROUTES ==========
  static const String pending = '/pending';
  static const String rejected = '/rejected';
}
