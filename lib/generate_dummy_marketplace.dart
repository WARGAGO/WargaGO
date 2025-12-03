// ============================================================================
// GENERATE DUMMY MARKETPLACE PRODUCTS
// ============================================================================
// Script untuk generate produk dummy untuk testing marketplace
// ============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  print('\n🛒 ========== GENERATE DUMMY MARKETPLACE PRODUCTS ==========\n');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;

  final dummyProducts = [
    {
      'sellerId': 'dummy_seller_001',
      'sellerName': 'Pak Budi',
      'productName': 'Wortel Segar',
      'description': 'Wortel segar pilihan langsung dari petani. Cocok untuk sayur sup atau jus wortel.',
      'price': 15000.0,
      'stock': 50,
      'category': 'Sayuran',
      'imageUrls': [
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 12,
      'rating': 4.5,
      'reviewCount': 8,
    },
    {
      'sellerId': 'dummy_seller_001',
      'sellerName': 'Pak Budi',
      'productName': 'Bayam Hijau',
      'description': 'Bayam hijau organik, bebas pestisida. Kaya akan zat besi dan vitamin.',
      'price': 8000.0,
      'stock': 30,
      'category': 'Sayuran',
      'imageUrls': [
        'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500',
      ],
      'unit': 'ikat',
      'isActive': true,
      'soldCount': 25,
      'rating': 4.8,
      'reviewCount': 15,
    },
    {
      'sellerId': 'dummy_seller_002',
      'sellerName': 'Ibu Siti',
      'productName': 'Tomat Merah',
      'description': 'Tomat merah segar dan matang sempurna. Cocok untuk masakan atau salad.',
      'price': 12000.0,
      'stock': 40,
      'category': 'Sayuran',
      'imageUrls': [
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 18,
      'rating': 4.6,
      'reviewCount': 12,
    },
    {
      'sellerId': 'dummy_seller_002',
      'sellerName': 'Ibu Siti',
      'productName': 'Kangkung Segar',
      'description': 'Kangkung hijau segar dipetik pagi hari. Dijamin masih fresh.',
      'price': 5000.0,
      'stock': 60,
      'category': 'Sayuran',
      'imageUrls': [
        'https://images.unsplash.com/photo-1612450965726-c5fadd65f69d?w=500',
      ],
      'unit': 'ikat',
      'isActive': true,
      'soldCount': 35,
      'rating': 4.7,
      'reviewCount': 20,
    },
    {
      'sellerId': 'dummy_seller_003',
      'sellerName': 'Pak Andi',
      'productName': 'Cabai Merah Keriting',
      'description': 'Cabai merah keriting super pedas. Cocok untuk sambal dan bumbu masakan.',
      'price': 45000.0,
      'stock': 25,
      'category': 'Bumbu',
      'imageUrls': [
        'https://images.unsplash.com/photo-1583663789112-4f8c977c60e7?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 8,
      'rating': 4.3,
      'reviewCount': 5,
    },
    {
      'sellerId': 'dummy_seller_003',
      'sellerName': 'Pak Andi',
      'productName': 'Bawang Merah',
      'description': 'Bawang merah berkualitas premium. Aroma harum dan tidak mudah busuk.',
      'price': 35000.0,
      'stock': 30,
      'category': 'Bumbu',
      'imageUrls': [
        'https://images.unsplash.com/photo-1618512496269-5f5e3e0c4165?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 15,
      'rating': 4.9,
      'reviewCount': 18,
    },
    {
      'sellerId': 'dummy_seller_004',
      'sellerName': 'Bu Ani',
      'productName': 'Pisang Cavendish',
      'description': 'Pisang cavendish manis dan segar. Cocok untuk buah meja atau diet sehat.',
      'price': 18000.0,
      'stock': 45,
      'category': 'Buah',
      'imageUrls': [
        'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 22,
      'rating': 4.4,
      'reviewCount': 14,
    },
    {
      'sellerId': 'dummy_seller_004',
      'sellerName': 'Bu Ani',
      'productName': 'Jeruk Manis',
      'description': 'Jeruk manis kaya vitamin C. Segar dan tidak asam.',
      'price': 20000.0,
      'stock': 35,
      'category': 'Buah',
      'imageUrls': [
        'https://images.unsplash.com/photo-1547514701-42782101795e?w=500',
      ],
      'unit': 'kg',
      'isActive': true,
      'soldCount': 19,
      'rating': 4.7,
      'reviewCount': 11,
    },
    {
      'sellerId': 'dummy_seller_005',
      'sellerName': 'Pak Joko',
      'productName': 'Beras Premium 5kg',
      'description': 'Beras premium pulen dan wangi. Hasil panen pilihan terbaik.',
      'price': 75000.0,
      'stock': 20,
      'category': 'Sembako',
      'imageUrls': [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
      ],
      'unit': 'pack',
      'isActive': true,
      'soldCount': 45,
      'rating': 4.8,
      'reviewCount': 32,
    },
    {
      'sellerId': 'dummy_seller_005',
      'sellerName': 'Pak Joko',
      'productName': 'Minyak Goreng 2L',
      'description': 'Minyak goreng berkualitas tanpa kolesterol. Jernih dan tidak mudah berbusa.',
      'price': 32000.0,
      'stock': 50,
      'category': 'Sembako',
      'imageUrls': [
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500',
      ],
      'unit': 'botol',
      'isActive': true,
      'soldCount': 38,
      'rating': 4.6,
      'reviewCount': 25,
    },
  ];

  try {
    print('🔵 Deleting existing dummy products...');
    final existingProducts = await firestore
        .collection('marketplace_products')
        .where('sellerId', whereIn: [
          'dummy_seller_001',
          'dummy_seller_002',
          'dummy_seller_003',
          'dummy_seller_004',
          'dummy_seller_005',
        ])
        .get();

    for (final doc in existingProducts.docs) {
      await doc.reference.delete();
    }
    print('✅ Deleted ${existingProducts.docs.length} existing products\n');

    print('🔵 Creating ${dummyProducts.length} dummy products...\n');

    int count = 0;
    for (final productData in dummyProducts) {
      final docRef = firestore.collection('marketplace_products').doc();

      await docRef.set({
        'id': docRef.id,
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      count++;
      print('✅ [$count/${dummyProducts.length}] ${productData['productName']} - ${productData['sellerName']}');
    }

    print('\n✅ Successfully created $count dummy products!');
    print('🎉 Marketplace ready for testing!\n');
    print('📊 Summary:');
    print('   - Pak Budi: 2 products (Sayuran)');
    print('   - Ibu Siti: 2 products (Sayuran)');
    print('   - Pak Andi: 2 products (Bumbu)');
    print('   - Bu Ani: 2 products (Buah)');
    print('   - Pak Joko: 2 products (Sembako)');
    print('\n🛒 ========== DONE! ==========\n');

  } catch (e, stackTrace) {
    print('❌ Error generating dummy products: $e');
    print('StackTrace: $stackTrace');
  }
}

