// ============================================================================
// MARKETPLACE HELPER
// ============================================================================
// Helper untuk interaksi dengan fitur marketplace
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class untuk marketplace operations
class MarketplaceHelper {
  // ============================================================================
  // PRODUCT HELPERS
  // ============================================================================

  /// Search product by keyword
  static Future<void> searchProduct(
    WidgetTester tester,
    String keyword,
  ) async {
    print('🔵 [MarketplaceHelper] Searching for: $keyword');
    
    final searchFields = find.byType(TextField);
    if (searchFields.evaluate().isNotEmpty) {
      await tester.enterText(searchFields.first, keyword);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Search completed');
    } else {
      print('  ⚠️  Search field not found');
    }
  }

  /// Clear search
  static Future<void> clearSearch(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Clearing search...');
    
    final searchFields = find.byType(TextField);
    if (searchFields.evaluate().isNotEmpty) {
      await tester.enterText(searchFields.first, '');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Search cleared');
    }
  }

  /// Filter by category
  static Future<void> filterByCategory(
    WidgetTester tester,
    String category,
  ) async {
    print('🔵 [MarketplaceHelper] Filtering by category: $category');
    
    final categoryWidget = find.textContaining(category);
    if (categoryWidget.evaluate().isNotEmpty) {
      await tester.tap(categoryWidget.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Category filter applied');
    } else {
      print('  ⚠️  Category not found: $category');
    }
  }

  /// Open product detail
  static Future<void> openProductDetail(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Opening product detail...');
    
    // Scroll untuk mencari produk
    await _scrollToFindProducts(tester);
    
    final productCards = find.byType(GestureDetector);
    if (productCards.evaluate().isNotEmpty) {
      await tester.tap(productCards.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Product detail opened');
    } else {
      print('  ⚠️  No product cards found');
    }
  }

  /// Scroll to find products
  static Future<void> _scrollToFindProducts(WidgetTester tester) async {
    final scrollView = find.byType(CustomScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.first, const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // ============================================================================
  // CART HELPERS
  // ============================================================================

  /// Add product to cart
  static Future<void> addToCart(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Adding product to cart...');
    
    // Scroll untuk melihat tombol add to cart
    await _scrollInDetailPage(tester);
    
    final addToCartBtn = find.text('Tambah ke Keranjang');
    if (addToCartBtn.evaluate().isNotEmpty) {
      await tester.tap(addToCartBtn);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Product added to cart');
    } else {
      print('  ⚠️  Add to cart button not found');
    }
  }

  /// Increase product quantity
  static Future<void> increaseQuantity(
    WidgetTester tester, {
    int times = 1,
  }) async {
    print('🔵 [MarketplaceHelper] Increasing quantity $times times...');
    
    final plusButton = find.byIcon(Icons.add);
    if (plusButton.evaluate().isNotEmpty) {
      for (int i = 0; i < times; i++) {
        await tester.tap(plusButton.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      print('  ✅ Quantity increased');
    } else {
      print('  ⚠️  Plus button not found');
    }
  }

  /// Decrease product quantity
  static Future<void> decreaseQuantity(
    WidgetTester tester, {
    int times = 1,
  }) async {
    print('🔵 [MarketplaceHelper] Decreasing quantity $times times...');
    
    final minusButton = find.byIcon(Icons.remove);
    if (minusButton.evaluate().isNotEmpty) {
      for (int i = 0; i < times; i++) {
        await tester.tap(minusButton.last);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      print('  ✅ Quantity decreased');
    }
  }

  /// Scroll in detail page
  static Future<void> _scrollInDetailPage(WidgetTester tester) async {
    final scrollView = find.byType(CustomScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.first, const Offset(0, -400));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // ============================================================================
  // CART MANAGEMENT HELPERS
  // ============================================================================

  /// Select cart item by checking checkbox
  static Future<void> selectCartItem(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Selecting cart item...');
    
    final checkbox = find.byType(Checkbox);
    if (checkbox.evaluate().isNotEmpty) {
      await tester.tap(checkbox.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Item selected');
    } else {
      print('  ⚠️  Checkbox not found');
    }
  }

  /// Select all cart items
  static Future<void> selectAllCartItems(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Selecting all items...');
    
    final selectAll = find.textContaining('Pilih Semua');
    if (selectAll.evaluate().isNotEmpty) {
      await tester.tap(selectAll);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ All items selected');
    } else {
      print('  ⚠️  Select all not found');
    }
  }

  /// Update quantity in cart (increase)
  static Future<void> increaseQuantityInCart(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Increasing quantity in cart...');
    
    final increaseBtn = find.byIcon(Icons.add_circle_outline);
    if (increaseBtn.evaluate().isNotEmpty) {
      await tester.tap(increaseBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Quantity increased in cart');
    } else {
      print('  ⚠️  Increase button not found in cart');
    }
  }

  /// Update quantity in cart (decrease)
  static Future<void> decreaseQuantityInCart(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Decreasing quantity in cart...');
    
    final decreaseBtn = find.byIcon(Icons.remove_circle_outline);
    if (decreaseBtn.evaluate().isNotEmpty) {
      await tester.tap(decreaseBtn.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Quantity decreased in cart');
    } else {
      print('  ⚠️  Decrease button not found in cart');
    }
  }

  /// Proceed to checkout from cart
  static Future<void> proceedToCheckout(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Proceeding to checkout...');
    
    // Scroll untuk melihat checkout button
    final scrollView = find.byType(SingleChildScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.last, const Offset(0, -200));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    
    final checkoutBtn = find.text('Checkout');
    if (checkoutBtn.evaluate().isNotEmpty) {
      await tester.tap(checkoutBtn.last);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('  ✅ Proceeded to checkout');
    } else {
      print('  ⚠️  Checkout button not found');
    }
  }

  // ============================================================================
  // CHECKOUT HELPERS
  // ============================================================================

  /// Select shipping method
  static Future<void> selectShippingMethod(
    WidgetTester tester,
    String method,
  ) async {
    print('🔵 [MarketplaceHelper] Selecting shipping: $method');
    
    // Scroll untuk melihat opsi pengiriman
    await _scrollInCheckoutPage(tester);
    
    final shippingOption = find.textContaining(method);
    if (shippingOption.evaluate().isNotEmpty) {
      await tester.tap(shippingOption.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('  ✅ Shipping method selected');
    } else {
      print('  ⚠️  Shipping method not found');
    }
  }

  /// Add note to seller
  static Future<void> addNoteToSeller(
    WidgetTester tester,
    String note,
  ) async {
    print('🔵 [MarketplaceHelper] Adding note: $note');
    
    final noteFields = find.byType(TextField);
    if (noteFields.evaluate().length > 1) {
      await tester.enterText(noteFields.last, note);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      print('  ✅ Note added');
    } else {
      print('  ⚠️  Note field not found');
    }
  }

  /// Proceed to payment
  static Future<void> proceedToPayment(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Proceeding to payment...');
    
    // Scroll untuk melihat tombol payment
    await _scrollInCheckoutPage(tester, offset: -400);
    
    final paymentBtn = find.textContaining('Bayar');
    if (paymentBtn.evaluate().isNotEmpty) {
      await tester.tap(paymentBtn.last);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('  ✅ Payment page opened');
    } else {
      print('  ⚠️  Payment button not found');
    }
  }

  /// Scroll in checkout page
  static Future<void> _scrollInCheckoutPage(
    WidgetTester tester, {
    double offset = -300,
  }) async {
    final scrollView = find.byType(SingleChildScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.first, Offset(0, offset));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // ============================================================================
  // PAYMENT HELPERS
  // ============================================================================

  /// Confirm payment
  static Future<void> confirmPayment(WidgetTester tester) async {
    print('🔵 [MarketplaceHelper] Confirming payment...');
    
    // Scroll untuk melihat tombol konfirmasi
    await _scrollInPaymentPage(tester);
    
    // Cari tombol konfirmasi
    final confirmBtn = find.textContaining('Konfirmasi');
    if (confirmBtn.evaluate().isNotEmpty) {
      await tester.tap(confirmBtn.last);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('  ✅ Payment confirmed');
      return;
    }
    
    // Alternatif: tombol "Selesai"
    final doneBtn = find.textContaining('Selesai');
    if (doneBtn.evaluate().isNotEmpty) {
      await tester.tap(doneBtn.last);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('  ✅ Payment process completed');
    } else {
      print('  ⚠️  Confirm button not found');
    }
  }

  /// Scroll in payment page
  static Future<void> _scrollInPaymentPage(WidgetTester tester) async {
    final scrollView = find.byType(CustomScrollView);
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView.first, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  // ============================================================================
  // VERIFICATION HELPERS
  // ============================================================================

  /// Verify success message appears
  static void verifySuccessMessage(WidgetTester tester, String message) {
    print('🔵 [MarketplaceHelper] Verifying success message...');
    
    expect(
      find.textContaining(message),
      findsWidgets,
      reason: 'Success message should appear',
    );
    
    print('  ✅ Success message verified');
  }

  /// Verify receipt is displayed
  static void verifyReceipt(WidgetTester tester) {
    print('🔵 [MarketplaceHelper] Verifying receipt...');
    
    final receiptIndicators = [
      find.textContaining('Berhasil'),
      find.textContaining('Receipt'),
      find.textContaining('Struk'),
      find.byIcon(Icons.check_circle),
      find.byIcon(Icons.receipt),
    ];

    bool receiptFound = false;
    for (var indicator in receiptIndicators) {
      if (indicator.evaluate().isNotEmpty) {
        receiptFound = true;
        break;
      }
    }

    expect(receiptFound, true, reason: 'Receipt should be displayed');
    print('  ✅ Receipt verified');
  }

  // ============================================================================
  // UTILITY HELPERS
  // ============================================================================

  /// Scroll to bottom
  static Future<void> scrollToBottom(WidgetTester tester) async {
    final scrollView = find.byType(CustomScrollView).first;
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }

  /// Scroll to top
  static Future<void> scrollToTop(WidgetTester tester) async {
    final scrollView = find.byType(CustomScrollView).first;
    if (scrollView.evaluate().isNotEmpty) {
      await tester.drag(scrollView, const Offset(0, 500));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
  }
}
