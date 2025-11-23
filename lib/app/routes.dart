import 'package:flutter/material.dart';
import 'package:jawara/core/constants/app_routes.dart';
import 'package:jawara/features/common/splash/splash_page.dart';
import 'package:jawara/features/common/onboarding/onboarding_page.dart';
import 'package:jawara/features/common/pre_auth/pre_auth_page.dart';

// Auth - Admin
import 'package:jawara/features/common/auth/presentation/pages/admin/admin_login_page.dart';

// Auth - Warga
import 'package:jawara/features/common/auth/presentation/pages/warga/warga_register_page.dart';
import 'package:jawara/features/common/auth/presentation/pages/warga/warga_login_page.dart';
import 'package:jawara/features/common/auth/presentation/pages/warga/kyc_upload_page.dart';

// Dashboards
import 'package:jawara/features/admin/dashboard/dashboard_page.dart'; // Admin Dashboard
import 'package:jawara/features/warga/dashboard/warga_dashboard_page.dart'; // Warga Dashboard

// Status pages
import 'package:jawara/features/common/auth/presentation/pages/status/pending_approval_page.dart';
import 'package:jawara/features/common/auth/presentation/pages/status/rejected_page.dart';

/// Konfigurasi routing untuk seluruh aplikasi
/// Menggunakan named routes untuk navigasi yang lebih clean
class AppRouter {
  /// Generate routes berdasarkan route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ========== COMMON ROUTES ==========
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );

      case AppRoutes.preAuth:
        return MaterialPageRoute(
          builder: (_) => const PreAuthPage(),
          settings: settings,
        );

      // ========== ADMIN ROUTES ==========
      case AppRoutes.adminLogin:
      case AppRoutes.login: // Redirect ke admin login untuk backwards compatibility
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminLoginPage(
            initialProgress: args?['initialProgress'] as double? ?? 0.0,
            isForward: args?['isForward'] as bool? ?? true,
          ),
          settings: settings,
        );

      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(), // Admin Dashboard
          settings: settings,
        );

      // ========== WARGA ROUTES ==========
      case AppRoutes.wargaRegister:
        return MaterialPageRoute(
          builder: (_) => const WargaRegisterPage(),
          settings: settings,
        );

      case AppRoutes.wargaLogin:
        return MaterialPageRoute(
          builder: (_) => const WargaLoginPage(),
          settings: settings,
        );

      case AppRoutes.wargaKYC:
        return MaterialPageRoute(
          builder: (_) => const KYCUploadPage(),
          settings: settings,
        );

      case AppRoutes.wargaDashboard:
        return MaterialPageRoute(
          builder: (_) => const WargaDashboardPage(),
          settings: settings,
        );

      // ========== STATUS ROUTES ==========
      case AppRoutes.pending:
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalPage(),
          settings: settings,
        );

      case AppRoutes.rejected:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RejectedPage(
            reason: args?['reason'] as String?,
          ),
          settings: settings,
        );

      // ========== DEFAULT (404) ==========
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Helper untuk navigasi dengan named route
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Helper untuk navigasi dengan replace (tidak bisa back)
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Helper untuk navigasi dan clear semua stack
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}

