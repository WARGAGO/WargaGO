// ============================================================================
// BACKEND CRUD TEST SCRIPT
// ============================================================================
// Script untuk testing manual backend CRUD operations
// Run: flutter run -t lib/test_backend_crud.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wargago/core/services/product_service.dart';
import 'package:wargago/core/services/cart_service.dart';
import 'package:wargago/core/models/product_model.dart';
import 'package:wargago/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BackendCrudTestApp());
}

class BackendCrudTestApp extends StatelessWidget {
  const BackendCrudTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backend CRUD Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BackendCrudTestScreen(),
    );
  }
}

class BackendCrudTestScreen extends StatefulWidget {
  const BackendCrudTestScreen({super.key});

  @override
  State<BackendCrudTestScreen> createState() => _BackendCrudTestScreenState();
}

class _BackendCrudTestScreenState extends State<BackendCrudTestScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend CRUD Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _runAllTests,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run All Tests'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _clearResults,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Results'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Panel
          Expanded(
            child: _isRunning
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Running tests...'),
                      ],
                    ),
                  )
                : _testResults.isEmpty
                    ? const Center(
                        child: Text('Press "Run All Tests" to start'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _testResults.length,
                        itemBuilder: (context, index) {
                          final result = _testResults[index];
                          final isSuccess = result.startsWith('✅');
                          final isError = result.startsWith('❌');
                          final isHeader = result.startsWith('===');

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isHeader
                                  ? Colors.blue.shade100
                                  : isSuccess
                                      ? Colors.green.shade50
                                      : isError
                                          ? Colors.red.shade50
                                          : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isHeader
                                    ? Colors.blue
                                    : isSuccess
                                        ? Colors.green
                                        : isError
                                            ? Colors.red
                                            : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              result,
                              style: TextStyle(
                                fontWeight:
                                    isHeader ? FontWeight.bold : FontWeight.normal,
                                color: isHeader
                                    ? Colors.blue.shade900
                                    : isSuccess
                                        ? Colors.green.shade900
                                        : isError
                                            ? Colors.red.shade900
                                            : Colors.black87,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _testResults.clear();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    try {
      _addResult('=== BACKEND CRUD TEST SUITE ===');
      _addResult('Started at: ${DateTime.now()}');
      _addResult('');

      // Test 1: Product CRUD
      await _testProductCRUD();

      // Test 2: Batch Operations
      await _testBatchOperations();

      // Test 3: Stock Management
      await _testStockManagement();

      // Test 4: Validation
      await _testValidation();

      // Test 5: Statistics
      await _testStatistics();

      // Test 6: Cart Cleanup
      await _testCartCleanup();

      _addResult('');
      _addResult('=== ALL TESTS COMPLETED ===');
      _addResult('Finished at: ${DateTime.now()}');
    } catch (e) {
      _addResult('❌ FATAL ERROR: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _testProductCRUD() async {
    _addResult('');
    _addResult('=== TEST 1: Product CRUD Operations ===');

    try {
      // CREATE
      _addResult('Testing CREATE...');
      final testProduct = ProductModel(
        id: '',
        nama: 'Test Product ${DateTime.now().millisecondsSinceEpoch}',
        deskripsi: 'Test description',
        harga: 10000,
        stok: 100,
        berat: 0.5,
        kategori: 'Sayuran Daun',
        imageUrls: ['https://via.placeholder.com/150'],
        sellerId: FirebaseAuth.instance.currentUser?.uid ?? 'test-seller',
        sellerName: 'Test Seller',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final productId = await _productService.createProduct(testProduct);
      if (productId != null) {
        _addResult('✅ CREATE success - Product ID: $productId');

        // READ
        _addResult('Testing READ...');
        final product = await _productService.getProductById(productId);
        if (product != null) {
          _addResult('✅ READ success - Product: ${product.nama}');

          // UPDATE
          _addResult('Testing UPDATE...');
          final updatedProduct = product.copyWith(harga: 15000);
          final updateSuccess = await _productService.updateProduct(updatedProduct);
          if (updateSuccess) {
            _addResult('✅ UPDATE success - New price: 15000');
          } else {
            _addResult('❌ UPDATE failed');
          }

          // DELETE
          _addResult('Testing DELETE...');
          final deleteSuccess = await _productService.hardDeleteProduct(productId);
          if (deleteSuccess) {
            _addResult('✅ DELETE success');
          } else {
            _addResult('❌ DELETE failed');
          }
        } else {
          _addResult('❌ READ failed - Product not found');
        }
      } else {
        _addResult('❌ CREATE failed - No product ID returned');
      }
    } catch (e) {
      _addResult('❌ Product CRUD test error: $e');
    }
  }

  Future<void> _testBatchOperations() async {
    _addResult('');
    _addResult('=== TEST 2: Batch Operations ===');

    try {
      _addResult('Testing batch update status...');
      // Note: This would need existing product IDs to test properly
      _addResult('⚠️ Skipped - Needs existing products');
    } catch (e) {
      _addResult('❌ Batch operations test error: $e');
    }
  }

  Future<void> _testStockManagement() async {
    _addResult('');
    _addResult('=== TEST 3: Stock Management ===');

    try {
      _addResult('Creating test product for stock test...');
      final testProduct = ProductModel(
        id: '',
        nama: 'Stock Test ${DateTime.now().millisecondsSinceEpoch}',
        deskripsi: 'Stock test',
        harga: 5000,
        stok: 50,
        berat: 0.3,
        kategori: 'Sayuran Daun',
        imageUrls: ['https://via.placeholder.com/150'],
        sellerId: FirebaseAuth.instance.currentUser?.uid ?? 'test-seller',
        sellerName: 'Test Seller',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final productId = await _productService.createProduct(testProduct);
      if (productId != null) {
        _addResult('✅ Test product created');

        // Decrease stock
        final decreaseSuccess = await _productService.decreaseStock(productId, 10);
        if (decreaseSuccess) {
          _addResult('✅ Decrease stock success (50 -> 40)');
        } else {
          _addResult('❌ Decrease stock failed');
        }

        // Increase stock
        final increaseSuccess = await _productService.increaseStock(productId, 5);
        if (increaseSuccess) {
          _addResult('✅ Increase stock success (40 -> 45)');
        } else {
          _addResult('❌ Increase stock failed');
        }

        // Cleanup
        await _productService.hardDeleteProduct(productId);
        _addResult('✅ Test product cleaned up');
      } else {
        _addResult('❌ Failed to create test product');
      }
    } catch (e) {
      _addResult('❌ Stock management test error: $e');
    }
  }

  Future<void> _testValidation() async {
    _addResult('');
    _addResult('=== TEST 4: Validation ===');

    try {
      _addResult('Testing product validation...');
      final validation = await _productService.validateProductForOrder(
        'non-existent-id',
        1,
      );

      if (validation['isValid'] == false) {
        _addResult('✅ Validation correctly identified invalid product');
        _addResult('   Message: ${validation['message']}');
      } else {
        _addResult('❌ Validation failed to identify invalid product');
      }
    } catch (e) {
      _addResult('❌ Validation test error: $e');
    }
  }

  Future<void> _testStatistics() async {
    _addResult('');
    _addResult('=== TEST 5: Seller Statistics ===');

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _addResult('Getting statistics for seller: ${currentUser.uid}');
        final stats = await _productService.getSellerStatistics(currentUser.uid);

        _addResult('✅ Statistics retrieved:');
        _addResult('   Total Products: ${stats['totalProducts']}');
        _addResult('   Active Products: ${stats['activeProducts']}');
        _addResult('   Inactive Products: ${stats['inactiveProducts']}');
        _addResult('   Total Stock: ${stats['totalStock']}');
        _addResult('   Out of Stock: ${stats['outOfStock']}');
      } else {
        _addResult('⚠️ No user logged in - skipping statistics test');
      }
    } catch (e) {
      _addResult('❌ Statistics test error: $e');
    }
  }

  Future<void> _testCartCleanup() async {
    _addResult('');
    _addResult('=== TEST 6: Cart Cleanup ===');

    try {
      _addResult('Testing cart cleanup for deleted products...');
      await _cartService.cleanupDeletedProducts();
      _addResult('✅ Cart cleanup executed successfully');
    } catch (e) {
      _addResult('❌ Cart cleanup test error: $e');
    }
  }

  void _addResult(String message) {
    setState(() {
      _testResults.add(message);
    });
    print(message); // Also print to console
  }
}

