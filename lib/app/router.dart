import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wargago/core/widgets/admin_app_bottom_navigation.dart';
import 'package:wargago/core/widgets/warga_app_bottom_navigation.dart';
import 'package:wargago/features/admin/data_warga/data_warga_main_page.dart';
import 'package:wargago/features/admin/kelola_lapak/kelola_lapak_page.dart';
import 'package:wargago/features/admin/keuangan/keuangan_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/lupa_page.dart';
import 'package:wargago/features/common/splash/splash_page.dart';
import 'package:wargago/features/common/onboarding/onboarding_page.dart';
import 'package:wargago/features/common/pre_auth/pre_auth_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/unified_login_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/warga_register_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/kyc_upload_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/alamat_rumah_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/data_keluarga_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/status/pending_approval_page.dart';
import 'package:wargago/features/common/auth/presentation/pages/status/rejected_page.dart';
import 'package:wargago/features/admin/dashboard/dashboard_page.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/features/warga/home/pages/warga_home_page.dart';
import 'package:wargago/features/warga/marketplace/pages/cart_page.dart';
import 'package:wargago/features/warga/marketplace/pages/my_orders_page.dart';
import 'package:wargago/features/warga/marketplace/pages/product_detail_page.dart';
import 'package:wargago/features/warga/marketplace/pages/warga_marketplace_page.dart';
import 'package:wargago/features/warga/profile/akun_screen.dart';
import 'package:wargago/features/warga/profile/edit_profil_screen.dart';
import 'package:wargago/features/warga/profile/toko_saya_screen.dart';
import 'package:wargago/features/warga/iuran/pages/iuran_warga_page.dart';
import 'package:wargago/features/bendahara/dashboard/bendahara_dashboard_page.dart';
import 'package:wargago/features/sekertaris/sekretaris_main_page.dart';

import '../features/common/classification/classification_camera.dart';

class AppRouterConfig {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _adminShellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'adminShell');
  static final GlobalKey<NavigatorState> _wargaShellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'wargaShell');

  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    routes: [
      // ========== COMMON ROUTES (No Shell) ==========
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.preAuth,
        name: 'preAuth',
        builder: (context, state) => const PreAuthPage(),
      ),

      // ========== AUTH ROUTES ==========
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const UnifiedLoginPage(),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const LupaPage(),
      ),

      // ========== BENDAHARA ROUTES ==========
      GoRoute(
        path: AppRoutes.bendaharaDashboard,
        name: 'bendaharaDashboard',
        builder: (context, state) => const BendaharaDashboardPage(),
      ),

      // ========== SEKRETARIS ROUTES ==========
      GoRoute(
        path: AppRoutes.sekretarisDashboard,
        name: 'sekretarisDashboard',
        builder: (context, state) => const SekretarisMainPage(),
      ),

      // ========== WARGA ROUTES ==========
      GoRoute(
        path: AppRoutes.wargaRegister,
        name: 'wargaRegister',
        builder: (context, state) => const WargaRegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.wargaKYC,
        name: 'wargaKYC',
        builder: (context, state) => const KYCUploadPage(),
      ),
      // 🆕 NEW: Alamat Rumah & Data Keluarga Flow
      GoRoute(
        path: AppRoutes.wargaAlamatRumah,
        name: 'wargaAlamatRumah',
        builder: (context, state) {
          final kycData = state.extra as Map<String, dynamic>;
          return AlamatRumahPage(kycData: kycData);
        },
      ),
      GoRoute(
        path: AppRoutes.wargaDataKeluarga,
        name: 'wargaDataKeluarga',
        builder: (context, state) {
          final completeData = state.extra as Map<String, dynamic>;
          return DataKeluargaPage(completeData: completeData);
        },
      ),

      GoRoute(
        path: AppRoutes.wargaClassificationCamera,
        name: 'wargaClassificationCamera',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: WargaAppBottomNavigation(child: ClassificationCameraPage()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 1.0).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1),
        ),
      ),
      // ========== STATUS ROUTES ==========
      GoRoute(
        path: AppRoutes.pending,
        name: 'pending',
        builder: (context, state) => const PendingApprovalPage(),
      ),
      GoRoute(
        path: AppRoutes.rejected,
        name: 'rejected',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RejectedPage(reason: extra?['reason'] as String?);
        },
      ),

      // GoRoute(
      //   path: AppRoutes.wargaDashboard,
      //   name: 'wargaDashboard',
      //   builder: (context, state) => const WargaMainPage(),
      // ),

      // ========== ADMIN SHELL WITH BOTTOM NAVIGATION ==========
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminAppBottomNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            navigatorKey: _adminShellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.adminDashboard,
                name: 'adminDashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          // Branch 1: Data Warga
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/data-warga',
                name: 'adminDataWarga',
                builder: (context, state) => const DataWargaMainPage(),
              ),
            ],
          ),
          // Branch 2: Keuangan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/keuangan',
                name: 'adminKeuangan',
                builder: (context, state) => const KeuanganPage(),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                name: 'adminProfile',
                builder: (context, state) => const KelolaLapakPage(),
              ),
            ],
          ),
        ],
      ),

      // ========== WARGA SHELL WITH BOTTOM NAVIGATION ==========
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return WargaAppBottomNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _wargaShellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.wargaDashboard,
                name: 'wargaDashboard',
                builder: (context, state) => const WargaHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wargaMarketplace,
                name: 'wargaMarketplace',
                builder: (context, state) => const WargaMarketplacePage(),
              ),
              GoRoute(
                path: AppRoutes.wargaPesananSaya,
                name: 'wargaPesananSaya',
                builder: (context, state) => const MyOrdersPage(),
              ),
              GoRoute(
                path: AppRoutes.wargaKeranjangSaya,
                name: 'wargaKeranjangSaya',
                builder: (context, state) => const CartPage(),
              ),
              GoRoute(
                path: AppRoutes.wargaItemDetail,
                name: 'wargaItemDetail',
                builder: (context, state) {
                  final extras = Map<String, dynamic>.from(state.extra as Map);
                  return ProductDetailPage(
                    productId: extras['productId'] as String,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wargaIuran,
                name: 'wargaIuran',
                builder: (context, state) => const IuranWargaPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wargaAkun,
                name: 'wargaAkun',
                builder: (context, state) => AkunScreen(),
              ),
              GoRoute(
                path: AppRoutes.wargaEditProfile,
                name: 'wargaEditProfile',
                builder: (context, state) => EditProfilScreen(),
              ),
              GoRoute(
                path: AppRoutes.wargaTokoSaya,
                name: 'wargaTokoSaya',
                builder: (context, state) => TokoSayaScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route tidak ditemukan: ${state.uri.path}')),
    ),
  );
}
