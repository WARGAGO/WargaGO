// ============================================================================
// MARKETPLACE PAYMENT E2E TEST - WARGA ROLE
// ============================================================================
// E2E Testing untuk flow payment marketplace sebagai warga
// - Login sebagai warga
// - Lanjut dari checkout ke payment
// - Pilih metode pembayaran
// - Konfirmasi pembayaran
// - Lihat receipt/struk
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wargago/main.dart' as app;
import '../helpers/warga_auth_helper.dart';
import '../helpers/marketplace_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warga - Marketplace Payment E2E Tests', () {
    testWidgets(
      'Login → Cart → Checkout → Pilih Metode → Payment → Receipt',
      (WidgetTester tester) async {
        print('\n💳 Starting Marketplace Payment E2E Test...\n');

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

        // 3. TAMBAH PRODUK KE CART (QUICK PATH)
        WargaAuthHelper.printStep('Step 5: Adding product to cart (quick path)...');
        
        // Open product detail
        await MarketplaceHelper.openProductDetail(tester);
        
        // Add to cart
        await MarketplaceHelper.addToCart(tester);
        
        // Back to marketplace
        await WargaAuthHelper.goBack(tester);
        
        WargaAuthHelper.printSuccess('Product added\n');

        // 4. BUKA CART DAN CHECKOUT
        WargaAuthHelper.printStep('Step 6: Opening cart and proceeding to checkout...');
        
        await WargaAuthHelper.navigateToCart(tester);
        await MarketplaceHelper.selectAllCartItems(tester);
        await MarketplaceHelper.proceedToCheckout(tester);
        
        WargaAuthHelper.printSuccess('Checkout page opened\n');

        // 5. VERIFIKASI HALAMAN CHECKOUT
        WargaAuthHelper.printStep('Step 7: Verifying checkout page...');
        WargaAuthHelper.verifyCheckoutPage(tester);

        // Verifikasi alamat pengiriman
        expect(
          find.textContaining('Alamat'),
          findsWidgets,
          reason: 'Shipping address should be visible',
        );
        print('  ✓ Shipping address section verified');

        WargaAuthHelper.printSuccess('Checkout page verified\n');

        // 6. PILIH METODE PENGIRIMAN
        WargaAuthHelper.printStep('Step 8: Selecting shipping method...');
        await MarketplaceHelper.selectShippingMethod(tester, 'Express');
        WargaAuthHelper.printSuccess('Shipping method selected\n');

        // 7. TAMBAH CATATAN (OPTIONAL)
        WargaAuthHelper.printStep('Step 9: Adding notes (optional)...');
        await MarketplaceHelper.addNoteToSeller(
          tester,
          'Mohon dikemas dengan baik, terima kasih!',
        );
        WargaAuthHelper.printSuccess('Note added\n');

        // 8. PROCEED TO PAYMENT
        WargaAuthHelper.printStep('Step 10: Proceeding to payment...');
        await MarketplaceHelper.proceedToPayment(tester);
        WargaAuthHelper.printSuccess('Payment page opened\n');

        // 9. VERIFIKASI HALAMAN PAYMENT
        WargaAuthHelper.printStep('Step 11: Verifying payment page...');
        
        // Verifikasi QR Code atau payment details
        expect(
          find.byType(CustomScrollView),
          findsWidgets,
          reason: 'Payment page should have scrollable content',
        );
        print('  ✓ Payment page layout verified');

        // Verifikasi total pembayaran
        expect(
          find.textContaining('Total'),
          findsWidgets,
          reason: 'Total payment should be visible',
        );
        print('  ✓ Total payment displayed');

        WargaAuthHelper.printSuccess('Payment page verified\n');

        // 10. KONFIRMASI PEMBAYARAN
        WargaAuthHelper.printStep('Step 12: Confirming payment...');
        await MarketplaceHelper.confirmPayment(tester);
        WargaAuthHelper.printSuccess('Payment confirmed\n');

        // 11. VERIFIKASI RECEIPT/STRUK
        WargaAuthHelper.printStep('Step 13: Verifying receipt...');
        MarketplaceHelper.verifyReceipt(tester);
        
        // Verifikasi detail transaksi
        expect(
          find.textContaining('Total'),
          findsWidgets,
          reason: 'Transaction total should be visible',
        );
        print('  ✓ Transaction details verified');
        
        WargaAuthHelper.printSuccess('Receipt verified\n');

        // 12. TEST SCROLL RECEIPT
        WargaAuthHelper.printStep('Step 14: Testing receipt scroll...');
        
        // Scroll untuk melihat detail lengkap receipt
        await WargaAuthHelper.scrollVertical(
          tester,
          find.byType(SingleChildScrollView).first,
          -300,
        );
        print('  ✓ Scrolled through receipt');
        
        await WargaAuthHelper.scrollVertical(
          tester,
          find.byType(SingleChildScrollView).first,
          200,
        );
        print('  ✓ Scrolled back');
        
        WargaAuthHelper.printSuccess('Receipt scroll complete\n');

        // 13. SELESAI
        print('═' * 80);
        print('✅ MARKETPLACE PAYMENT E2E TEST COMPLETED SUCCESSFULLY!');
        print('═' * 80);
        print('\n📊 Test Summary:');
        print('  ✓ Login as warga');
        print('  ✓ Add product to cart (quick path)');
        print('  ✓ Open cart and select items');
        print('  ✓ Proceed to checkout');
        print('  ✓ Verify checkout page');
        print('  ✓ Select shipping method');
        print('  ✓ Add notes to seller');
        print('  ✓ Proceed to payment');
        print('  ✓ Verify payment page');
        print('  ✓ Confirm payment');
        print('  ✓ Verify receipt/success page');
        print('  ✓ Test receipt scroll');
        print('\n');
      },
    );
  });
}
