// ============================================================================
// CART PAGE (KERANJANG SAYA)
// ============================================================================
// Halaman keranjang belanja untuk pembeli
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/cart_seller_group.dart';
import '../widgets/cart_bottom_bar.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy data - grouped by seller
  final Map<String, List<Map<String, dynamic>>> cartItems = {
    'Toko Sayur Rafcol': [
      {
        'name': 'Sayur Wortel',
        'price': 'Rp. 10.000',
        'quantity': 1,
        'image': null,
        'isSelected': false,
      },
      {
        'name': 'Sayur Wortel',
        'price': 'Rp. 10.000',
        'quantity': 1,
        'image': null,
        'isSelected': false,
      },
    ],
  };

  bool isAllSelected = false;

  void toggleSelectAll(bool? value) {
    setState(() {
      isAllSelected = value ?? false;
      // Update all items
      cartItems.forEach((seller, items) {
        for (var item in items) {
          item['isSelected'] = isAllSelected;
        }
      });
    });
  }

  void toggleSellerGroup(String seller, bool? value) {
    setState(() {
      for (var item in cartItems[seller]!) {
        item['isSelected'] = value ?? false;
      }
      // Check if all items are selected
      isAllSelected = cartItems.values.every((items) => 
        items.every((item) => item['isSelected'] == true)
      );
    });
  }

  void toggleItem(String seller, int index, bool? value) {
    setState(() {
      cartItems[seller]![index]['isSelected'] = value ?? false;
      
      // Check if all items in seller group are selected
      bool allInGroupSelected = cartItems[seller]!.every((item) => item['isSelected'] == true);
      
      // Check if all items in cart are selected
      isAllSelected = cartItems.values.every((items) => 
        items.every((item) => item['isSelected'] == true)
      );
    });
  }

  void updateQuantity(String seller, int index, int newQuantity) {
    setState(() {
      if (newQuantity > 0) {
        cartItems[seller]![index]['quantity'] = newQuantity;
      }
    });
  }

  int getTotalPrice() {
    int total = 0;
    cartItems.forEach((seller, items) {
      for (var item in items) {
        if (item['isSelected'] == true) {
          // Extract number from price string (e.g., "Rp. 10.000" -> 10000)
          String priceStr = item['price'].replaceAll(RegExp(r'[^\d]'), '');
          int price = int.parse(priceStr);
          total += price * (item['quantity'] as int);
        }
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool hasItems = cartItems.isNotEmpty && 
        cartItems.values.any((items) => items.isNotEmpty);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Keranjang Saya',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
      ),
      body: !hasItems ? _buildEmptyCart() : Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  const Color(0xFF10B981).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Color(0xFF2F80ED),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belanja Hemat & Segar',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Dapatkan sayuran segar langsung dari petani',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Select All Checkbox
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  onChanged: toggleSelectAll,
                  activeColor: const Color(0xFF2F80ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Text(
                  'Pilih Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_getTotalItems()} item',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Cart Items grouped by seller
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                String seller = cartItems.keys.elementAt(index);
                List<Map<String, dynamic>> items = cartItems[seller]!;
                
                return CartSellerGroup(
                  sellerName: seller,
                  items: items,
                  onSellerToggle: (value) => toggleSellerGroup(seller, value),
                  onItemToggle: (itemIndex, value) => toggleItem(seller, itemIndex, value),
                  onQuantityChanged: (itemIndex, newQuantity) => 
                    updateQuantity(seller, itemIndex, newQuantity),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CartBottomBar(
        totalPrice: getTotalPrice(),
        onCheckout: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckoutPage()),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Keranjang Kosong',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk, mulai belanja sayuran segar\ndan produk pilihan lainnya!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined, size: 20),
              label: Text(
                'Mulai Belanja',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalItems() {
    int total = 0;
    cartItems.forEach((seller, items) {
      total += items.length;
    });
    return total;
  }
}
