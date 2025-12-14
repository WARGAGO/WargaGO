import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, SystemChrome;
import 'package:go_router/go_router.dart';
import 'package:wargago/core/utils/page_transitions.dart';
import 'package:wargago/core/widgets/admin_app_bottom_navigation.dart';
import 'package:wargago/core/widgets/warga_app_bottom_navigation.dart';
import 'package:wargago/features/admin/dashboard/dashboard_detail_page.dart';
import 'package:wargago/features/admin/data_warga/data_warga_main_page.dart';
import 'package:wargago/features/admin/kelola_lapak/kelola_lapak_page.dart';
import 'package:wargago/features/admin/keuangan/keuangan_page.dart';
import 'package:wargago/features/admin/polling/pages/admin_poll_list_page.dart';
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
import 'package:wargago/features/sekertaris/sekretaris_main_page.dart';
import 'package:wargago/features/bendahara/bendahara_main_page.dart';

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
        pageBuilder: (context, state) => PageTransitions.fadeTransition(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) {
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
          );
          return PageTransitions.fadeTransition(
            key: state.pageKey,
            child: const OnboardingPage(),
            duration: const Duration(milliseconds: 500),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.preAuth,
        name: 'preAuth',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          key: state.pageKey,
          child: const PreAuthPage(),
          duration: const Duration(milliseconds: 400),
        ),
      ),

      // ========== AUTH ROUTES ==========
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => PageTransitions.slideAndFade(
          key: state.pageKey,
          child: const UnifiedLoginPage(),
          duration: const Duration(milliseconds: 400),
        ),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => PageTransitions.slideFromBottom(
          key: state.pageKey,
          child: const LupaPage(),
        ),
      ),

      // ========== BENDAHARA ROUTES ==========
      GoRoute(
        path: AppRoutes.bendaharaDashboard,
        name: 'bendaharaDashboard',
        pageBuilder: (context, state) => PageTransitions.sharedAxis(
          key: state.pageKey,
          child: const BendaharaMainPage(),
        ),
      ),

      // ========== SEKRETARIS ROUTES ==========
      GoRoute(
        path: AppRoutes.sekretarisDashboard,
        name: 'sekretarisDashboard',
        pageBuilder: (context, state) => PageTransitions.sharedAxis(
          key: state.pageKey,
          child: const SekretarisMainPage(),
        ),
      ),

      // ========== WARGA ROUTES ==========
      GoRoute(
        path: AppRoutes.wargaRegister,
        name: 'wargaRegister',
        pageBuilder: (context, state) => PageTransitions.slideAndFade(
          key: state.pageKey,
          child: const WargaRegisterPage(),
          duration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppRoutes.wargaKYC,
        name: 'wargaKYC',
        pageBuilder: (context, state) => PageTransitions.slideAndFade(
          key: state.pageKey,
          child: const KYCUploadPage(),
          duration: const Duration(milliseconds: 400),
        ),
      ),
      // 🆕 NEW: Alamat Rumah & Data Keluarga Flow
      GoRoute(
        path: AppRoutes.wargaAlamatRumah,
        name: 'wargaAlamatRumah',
        pageBuilder: (context, state) {
          final kycData = state.extra as Map<String, dynamic>;
          return PageTransitions.slideAndFade(
            key: state.pageKey,
            child: AlamatRumahPage(kycData: kycData),
            duration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wargaDataKeluarga,
        name: 'wargaDataKeluarga',
        pageBuilder: (context, state) {
          final completeData = state.extra as Map<String, dynamic>;
          return PageTransitions.slideAndFade(
            key: state.pageKey,
            child: DataKeluargaPage(completeData: completeData),
            duration: const Duration(milliseconds: 400),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.wargaClassificationCamera,
        name: 'wargaClassificationCamera',
        pageBuilder: (context, state) => PageTransitions.noTransition(
          key: state.pageKey,
          child: ClassificationCameraPage(),
        ),
      ),
      // ========== STATUS ROUTES ==========
      GoRoute(
        path: AppRoutes.pending,
        name: 'pending',
        pageBuilder: (context, state) => PageTransitions.scaleTransition(
          key: state.pageKey,
          child: const PendingApprovalPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.rejected,
        name: 'rejected',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PageTransitions.scaleTransition(
            key: state.pageKey,
            child: RejectedPage(reason: extra?['reason'] as String?),
          );
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
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const DashboardPage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              GoRoute(
                path: AppRoutes.adminDashboardSelengkapnya,
                name: 'adminDashboardSelengkapnya',
                pageBuilder: (context, state) => PageTransitions.slideFromRight(
                  key: state.pageKey,
                  child: const DashboardDetailPage(),
                  duration: const Duration(milliseconds: 350),
                ),
              ),
              GoRoute(
                path: AppRoutes.adminKelolaPolling,
                name: 'adminKelolaPolling',
                pageBuilder: (context, state) => PageTransitions.slideFromRight(
                  key: state.pageKey,
                  child: const AdminPollListPage(),
                  duration: const Duration(milliseconds: 350),
                ),
              ),
            ],
          ),
          // Branch 1: Data Warga
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/data-warga',
                name: 'adminDataWarga',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const DataWargaMainPage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
          // Branch 2: Keuangan
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/keuangan',
                name: 'adminKeuangan',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const KeuanganPage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/profile',
                name: 'adminProfile',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const KelolaLapakPage(),
                  duration: const Duration(milliseconds: 250),
                ),
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
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const WargaHomePage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wargaMarketplace,
                name: 'wargaMarketplace',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const WargaMarketplacePage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              GoRoute(
                path: AppRoutes.wargaPesananSaya,
                name: 'wargaPesananSaya',
                pageBuilder: (context, state) => PageTransitions.slideAndFade(
                  key: state.pageKey,
                  child: const MyOrdersPage(),
                  duration: const Duration(milliseconds: 350),
                ),
              ),
              GoRoute(
                path: AppRoutes.wargaKeranjangSaya,
                name: 'wargaKeranjangSaya',
                pageBuilder: (context, state) =>
                    PageTransitions.slideFromBottom(
                      key: state.pageKey,
                      child: const CartPage(),
                      duration: const Duration(milliseconds: 400),
                    ),
              ),
              GoRoute(
                path: AppRoutes.wargaItemDetail,
                name: 'wargaItemDetail',
                pageBuilder: (context, state) {
                  final extras = Map<String, dynamic>.from(state.extra as Map);
                  return PageTransitions.slideAndFade(
                    key: state.pageKey,
                    child: ProductDetailPage(
                      productId: extras['productId'] as String,
                    ),
                    duration: const Duration(milliseconds: 350),
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
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: const IuranWargaPage(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wargaAkun,
                name: 'wargaAkun',
                pageBuilder: (context, state) => PageTransitions.fadeTransition(
                  key: state.pageKey,
                  child: AkunScreen(),
                  duration: const Duration(milliseconds: 250),
                ),
              ),
              GoRoute(
                path: AppRoutes.wargaEditProfile,
                name: 'wargaEditProfile',
                pageBuilder: (context, state) => PageTransitions.slideAndFade(
                  key: state.pageKey,
                  child: EditProfilScreen(),
                  duration: const Duration(milliseconds: 350),
                ),
              ),
              GoRoute(
                path: AppRoutes.wargaTokoSaya,
                name: 'wargaTokoSaya',
                pageBuilder: (context, state) => PageTransitions.slideAndFade(
                  key: state.pageKey,
                  child: TokoSayaScreen(),
                  duration: const Duration(milliseconds: 350),
                ),
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
