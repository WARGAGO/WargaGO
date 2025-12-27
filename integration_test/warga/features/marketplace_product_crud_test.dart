// ============================================================================
// MARKETPLACE PRODUCT CRUD E2E TEST - WARGA ROLE
// ============================================================================
// E2E Testing untuk CRUD produk marketplace sebagai warga
// - Login sebagai warga
// - Lihat list produk
// - Lihat detail produk
// - Search produk
// - Filter produk berdasarkan kategori
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;
import '../helpers/warga_auth_helper.dart';
import '../helpers/marketplace_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Marketplace Product CRUD E2E Tests', () {
    testWidgets(
      'Login → Lihat List Produk → Search → Filter → Detail Produk',
      (WidgetTester tester) async {
        print('\n🛒 Starting Marketplace Product CRUD E2E Test...\n');

        // 1. START APP & LOGIN SEBAGAI WARGA
        WargaAuthHelper.printStep('Step 1: Starting application...');
        app.main();
        await WargaAuthHelper.waitAndSettle(tester, duration: const Duration(seconds: 5));
        WargaAuthHelper.printSuccess('App started\n');

        // Skip onboarding jika ada
        await WargaAuthHelper.skipOnboarding(tester);

        // Login sebagai warga
        WargaAuthHelper.printStep('Step 3: Logging in as warga...');
        await WargaAuthHelper.loginAsWarga(tester);
        print('');

        // 2. NAVIGASI KE MARKETPLACE
        WargaAuthHelper.printStep('Step 4: Navigating to Marketplace...');
        await WargaAuthHelper.navigateToMarketplace(tester);
        print('');

        // 3. VERIFIKASI UI MARKETPLACE
        WargaAuthHelper.printStep('Step 5: Verifying Marketplace UI elements...');
        WargaAuthHelper.verifyMarketplacePage(tester);
        
        // Verifikasi search bar
        final searchField = find.byType(TextField);
        expect(
          searchField,
          findsWidgets,
          reason: 'Search field should be visible',
        );
        print('  ✓ Search field found');

        // Scroll untuk melihat produk
        await WargaAuthHelper.scrollVertical(
          tester,
          find.byType(SingleChildScrollView).first,
          -200,
        );
        WargaAuthHelper.printSuccess('UI verification complete\n');

        // 4. TEST SEARCH PRODUK
        WargaAuthHelper.printStep('Step 6: Testing product search...');
        await MarketplaceHelper.searchProduct(tester, 'Sayur');
        await MarketplaceHelper.clearSearch(tester);
        WargaAuthHelper.printSuccess('Search test complete\n');

        // 5. TEST FILTER KATEGORI
        WargaAuthHelper.printStep('Step 7: Testing category filter...');
        await MarketplaceHelper.filterByCategory(tester, 'Sayuran');
        WargaAuthHelper.printSuccess('Category filter test complete\n');

        // 6. TEST LIHAT DETAIL PRODUK
        WargaAuthHelper.printStep('Step 8: Testing product detail view...');
        await MarketplaceHelper.openProductDetail(tester);
        
        // Verifikasi halaman detail produk
        expect(
          find.byIcon(Icons.arrow_back),
          findsOneWidget,
          reason: 'Back button should be visible on detail page',
        );
        print('  ✓ Product detail page opened');
        
        // Verifikasi elemen detail produk
        expect(
          find.byType(ElevatedButton),
          findsWidgets,
          reason: 'Action buttons should be visible',
        );
        print('  ✓ Product detail elements verified');
        
        // Scroll di detail page
        await WargaAuthHelper.scrollVertical(
          tester,
          find.byType(CustomScrollView).first,
          -200,
        );
        print('  ✓ Scrolled through product details');
        
        // Kembali ke list
        await WargaAuthHelper.goBack(tester);
        WargaAuthHelper.printSuccess('Product detail test complete\n');

        // 7. TEST SCROLL LIST PRODUK
        WargaAuthHelper.printStep('Step 9: Testing product list scroll...');
        
        // Scroll down untuk load more products
        for (int i = 0; i < 3; i++) {
          await MarketplaceHelper.scrollToBottom(tester);
          print('  ✓ Scroll iteration ${i + 1}');
        }
        
        // Scroll back to top
        await MarketplaceHelper.scrollToTop(tester);
        WargaAuthHelper.printSuccess('Scroll test complete\n');

        // 8. SELESAI
        print('═' * 80);
        print('✅ MARKETPLACE PRODUCT CRUD E2E TEST COMPLETED SUCCESSFULLY!');
        print('═' * 80);
        print('\n📊 Test Summary:');
        print('  ✓ Login as warga');
        print('  ✓ Navigate to Marketplace');
        print('  ✓ Verify UI elements');
        print('  ✓ Search products');
        print('  ✓ Filter by category');
        print('  ✓ View product details');
        print('  ✓ Scroll product list');
        print('\n');
      },
    );
  });
}
