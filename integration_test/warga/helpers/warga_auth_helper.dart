// ============================================================================
// WARGA AUTH HELPER
// ============================================================================
// Helper untuk authentication dan navigasi sebagai warga
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class untuk authentication warga
class WargaAuthHelper {
  // ============================================================================
  // LOGIN HELPERS
  // ============================================================================

  /// Login sebagai warga dengan credentials default
  static Future<void> loginAsWarga(WidgetTester tester) async {
    print('🔵 [WargaAuthHelper] Logging in as warga...');
    
    await tester.enterText(
      find.byType(TextField).at(0),
      'jaehyun@gmail.com',
    );
    await tester.enterText(
      find.byType(TextField).at(1),
      'jaehyun',
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle(const Duration(seconds: 8));
    
    print('  ✅ Logged in successfully as warga');
  }

  /// Login dengan custom credentials
  static Future<void> loginWithCredentials(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    print('🔵 [WargaAuthHelper] Logging in with custom credentials...');
    print('  Email: $email');
    
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), password);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle(const Duration(seconds: 8));
    
    print('  ✅ Login completed');
  }

  /// Skip onboarding screen
  static Future<void> skipOnboarding(WidgetTester tester) async {
    print('🔵 [WargaAuthHelper] Checking for onboarding...');
    
    final closeBtn = find.byIcon(Icons.close);
    if (closeBtn.evaluate().isNotEmpty) {
      print('  Found onboarding, closing...');
      await tester.tap(closeBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Onboarding closed');
    } else {
      print('  ℹ️  No onboarding found');
    }
  }

  // ============================================================================
  // NAVIGATION HELPERS
  // ============================================================================

  /// Navigate ke Marketplace dari dashboard
  static Future<void> navigateToMarketplace(WidgetTester tester) async {
    print('🔵 [WargaAuthHelper] Navigating to Marketplace...');
    
    // Coba cari icon store di bottom navigation
    final marketplaceIcon = find.byIcon(Icons.store);
    if (marketplaceIcon.evaluate().isNotEmpty) {
      await tester.tap(marketplaceIcon);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Navigated via store icon');
      return;
    }

    // Alternatif: cari text 'Marketplace'
    final marketplaceText = find.text('Marketplace');
    if (marketplaceText.evaluate().isNotEmpty) {
      await tester.tap(marketplaceText);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Navigated via marketplace text');
      return;
    }

    print('  ⚠️  Marketplace navigation not found, might already be on page');
  }

  /// Navigate ke Cart/Keranjang
  static Future<void> navigateToCart(WidgetTester tester) async {
    print('🔵 [WargaAuthHelper] Navigating to Cart...');
    
    final cartIcon = find.byIcon(Icons.shopping_cart_outlined);
    if (cartIcon.evaluate().isNotEmpty) {
      await tester.tap(cartIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Cart opened');
    } else {
      print('  ⚠️  Cart icon not found');
    }
  }

  /// Go back to previous page
  static Future<void> goBack(WidgetTester tester) async {
    print('🔵 [WargaAuthHelper] Going back...');
    
    final backBtn = find.byIcon(Icons.arrow_back);
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Navigated back');
    } else {
      print('  ⚠️  Back button not found');
    }
  }

  // ============================================================================
  // VERIFICATION HELPERS
  // ============================================================================

  /// Verify marketplace page is displayed
  static void verifyMarketplacePage(WidgetTester tester) {
    print('🔵 [WargaAuthHelper] Verifying Marketplace page...');
    
    expect(
      find.textContaining('Marketplace'),
      findsWidgets,
      reason: 'Marketplace title should be visible',
    );
    
    print('  ✅ Marketplace page verified');
  }

  /// Verify cart page is displayed
  static void verifyCartPage(WidgetTester tester) {
    print('🔵 [WargaAuthHelper] Verifying Cart page...');
    
    expect(
      find.textContaining('Keranjang'),
      findsWidgets,
      reason: 'Cart title should be visible',
    );
    
    print('  ✅ Cart page verified');
  }

  /// Verify checkout page is displayed
  static void verifyCheckoutPage(WidgetTester tester) {
    print('🔵 [WargaAuthHelper] Verifying Checkout page...');
    
    expect(
      find.textContaining('Checkout'),
      findsWidgets,
      reason: 'Checkout title should be visible',
    );
    
    print('  ✅ Checkout page verified');
  }

  // ============================================================================
  // UTILITY HELPERS
  // ============================================================================

  /// Scroll widget vertically
  static Future<void> scrollVertical(
    WidgetTester tester,
    Finder finder,
    double offset,
  ) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.drag(finder, Offset(0, offset));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Scroll widget horizontally
  static Future<void> scrollHorizontal(
    WidgetTester tester,
    Finder finder,
    double offset,
  ) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.drag(finder, Offset(offset, 0));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Wait and settle
  static Future<void> waitAndSettle(
    WidgetTester tester, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    await tester.pumpAndSettle(duration);
  }

  /// Print test step
  static void printStep(String step, [String? detail]) {
    print('🔵 $step');
    if (detail != null) {
      print('  $detail');
    }
  }

  /// Print success message
  static void printSuccess(String message) {
    print('✅ $message');
  }

  /// Print warning message
  static void printWarning(String message) {
    print('⚠️  $message');
  }
}
