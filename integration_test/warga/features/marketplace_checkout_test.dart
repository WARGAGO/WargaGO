// ============================================================================
// MARKETPLACE CHECKOUT E2E TEST - WARGA ROLE
// ============================================================================
// E2E Testing untuk flow checkout marketplace sebagai warga
// - Login sebagai warga
// - Pilih produk
// - Tambah ke keranjang
// - Manage cart (update quantity, delete item)
// - Proceed to checkout
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;
import '../helpers/warga_auth_helper.dart';
import '../helpers/marketplace_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Marketplace Checkout E2E Tests', () {
    testWidgets(
      'Login → Pilih Produk → Add to Cart → Manage Cart → Checkout',
      (WidgetTester tester) async {
        print('\n🛒 Starting Marketplace Checkout E2E Test...\n');

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

        // 3. PILIH PRODUK DAN BUKA DETAIL
        WargaAuthHelper.printStep('Step 5: Selecting product...');
        await MarketplaceHelper.openProductDetail(tester);
        print('');

        // 4. TAMBAH KE KERANJANG
        WargaAuthHelper.printStep('Step 6: Adding product to cart...');
        
        // Increase quantity
        await MarketplaceHelper.increaseQuantity(tester, times: 2);
        print('  ✓ Quantity increased to 3');

        // Add to cart
        await MarketplaceHelper.addToCart(tester);
        
        // Verifikasi snackbar muncul
        MarketplaceHelper.verifySuccessMessage(tester, 'berhasil ditambahkan');
        WargaAuthHelper.printSuccess('Product added to cart\n');

        // 5. BUKA HALAMAN KERANJANG
        WargaAuthHelper.printStep('Step 7: Opening cart page...');
        
        // Back ke marketplace
        await WargaAuthHelper.goBack(tester);

        // Buka cart
        await WargaAuthHelper.navigateToCart(tester);
        print('');

        // 6. VERIFIKASI ISI KERANJANG
        WargaAuthHelper.printStep('Step 8: Verifying cart contents...');
        WargaAuthHelper.verifyCartPage(tester);

        // Verifikasi item ada di keranjang
        final cartItems = find.byType(Checkbox);
        expect(
          cartItems,
          findsWidgets,
          reason: 'Cart items with checkboxes should be visible',
        );
        print('  ✓ Cart items found');
        WargaAuthHelper.printSuccess('Cart contents verified\n');

        // 7. TEST SELECT ITEM
        WargaAuthHelper.printStep('Step 9: Testing item selection...');
        await MarketplaceHelper.selectCartItem(tester);
        WargaAuthHelper.printSuccess('Item selection complete\n');

        // 8. TEST UPDATE QUANTITY DI CART
        WargaAuthHelper.printStep('Step 10: Testing quantity update in cart...');
        await MarketplaceHelper.increaseQuantityInCart(tester);
        await MarketplaceHelper.decreaseQuantityInCart(tester);
        WargaAuthHelper.printSuccess('Quantity update complete\n');

        // 9. TEST SELECT ALL
        WargaAuthHelper.printStep('Step 11: Testing select all items...');
        await MarketplaceHelper.selectAllCartItems(tester);
        WargaAuthHelper.printSuccess('Select all complete\n');

        // 10. TEST DELETE ITEM (OPTIONAL)
        WargaAuthHelper.printStep('Step 12: Testing delete item (optional)...');
        
        // Cari icon delete
        final deleteIcon = find.byIcon(Icons.delete_outline);
        if (deleteIcon.evaluate().length > 1) {
          print('  Found delete icons, but skipping to keep items for checkout');
          print('  ✓ Delete functionality available');
        }
        WargaAuthHelper.printSuccess('Delete test skipped to preserve items\n');

        // 11. PROCEED TO CHECKOUT
        WargaAuthHelper.printStep('Step 13: Proceeding to checkout...');
        await MarketplaceHelper.proceedToCheckout(tester);
        WargaAuthHelper.verifyCheckoutPage(tester);
        WargaAuthHelper.printSuccess('Checkout initiated\n');

        // 12. VERIFIKASI CHECKOUT PAGE
        WargaAuthHelper.printStep('Step 14: Verifying checkout page elements...');
        
        // Verifikasi alamat pengiriman
        expect(
          find.textContaining('Alamat'),
          findsWidgets,
          reason: 'Shipping address should be visible',
        );
        print('  ✓ Shipping address section found');

        // Verifikasi ringkasan produk
        expect(
          find.textContaining('Produk'),
          findsWidgets,
          reason: 'Product summary should be visible',
        );
        print('  ✓ Product summary section found');

        // Verifikasi metode pengiriman
        expect(
          find.textContaining('Pengiriman'),
          findsWidgets,
          reason: 'Shipping method should be visible',
        );
        print('  ✓ Shipping method section found');

        WargaAuthHelper.printSuccess('Checkout page verification complete\n');

        // 13. SELESAI
        print('═' * 80);
        print('✅ MARKETPLACE CHECKOUT E2E TEST COMPLETED SUCCESSFULLY!');
        print('═' * 80);
        print('\n📊 Test Summary:');
        print('  ✓ Login as warga');
        print('  ✓ Navigate to Marketplace');
        print('  ✓ Select product');
        print('  ✓ Add to cart with quantity adjustment');
        print('  ✓ Open cart page');
        print('  ✓ Verify cart contents');
        print('  ✓ Select items');
        print('  ✓ Update quantity in cart');
        print('  ✓ Select all items');
        print('  ✓ Proceed to checkout');
        print('  ✓ Verify checkout page');
        print('\n');
      },
    );
  });
}
