// ============================================================================
// AZURE API TEST SCRIPT
// ============================================================================
// Script untuk test Azure Blob Storage API tanpa run Flutter app
// Run: dart run test/azure_api_test.dart
// ============================================================================

import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Azure Blob Storage API...\n');
  print('⚠️  PENTING: Test script ini TIDAK bisa test Firebase Auth!');
  print('    Karena Firebase Auth hanya berfungsi di Flutter app context.\n');
  print('─' * 60);

  // Base URL dari API
  const baseUrl = 'https://pcvk-containerapp.lemonisland-43c085da.southeastasia.azurecontainerapps.io';

  // ⚠️ UNTUK TEST PRIVATE API:
  // Opsi 1: Run Flutter app langsung (RECOMMENDED)
  //         → flutter run
  //         → Login dengan Firebase Auth
  //         → Upload KYC document
  //         → Token otomatis terambil ✅
  //
  // Opsi 2: Pakai static token untuk test script ini
  //         → Login dulu di Flutter app
  //         → Copy Firebase ID token (dari log atau debug)
  //         → Paste di bawah ini
  const authToken = null; // Ganti dengan: 'Bearer eyJhbGci...' (Firebase ID token)

  print('ℹ️  Auth Token: ${authToken ?? "NOT SET"}');
  print('');

  // Test 1: Get Public Images (tidak perlu auth)
  await testGetPublicImages(baseUrl, authToken);

  // Test 2: Get Private Images (perlu Firebase Auth token)
  await testGetPrivateImages(baseUrl, authToken);

  print('\n' + '=' * 60);
  print('💡 RECOMMENDATION:');
  print('   Jangan test dengan script ini untuk Private API!');
  print('   Langsung test di Flutter app saja:');
  print('   1. flutter run');
  print('   2. Login dengan Firebase Auth');
  print('   3. Upload KYC document');
  print('   4. Token otomatis terambil dari Firebase ✅');
  print('=' * 60);
}

// Test Get Public Images
Future<void> testGetPublicImages(String baseUrl, String? authToken) async {
  print('📋 Test 1: GET Public Images');
  print('URL: $baseUrl/api/storage/public/get-images');

  try {
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = authToken;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/storage/public/get-images'),
      headers: headers.isEmpty ? null : headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ GET Public Images - SUCCESS\n');
    } else {
      print('❌ GET Public Images - FAILED\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

// Test Get Private Images
Future<void> testGetPrivateImages(String baseUrl, String? authToken) async {
  print('📋 Test 2: GET Private Images');
  print('URL: $baseUrl/api/storage/private/get-images');
  print('Auth: ${authToken != null ? "YES" : "NO (akan error 403!)"}');

  try {
    final headers = <String, String>{};
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = authToken;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/storage/private/get-images'),
      headers: headers.isEmpty ? null : headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ GET Private Images - SUCCESS\n');
    } else if (response.statusCode == 403) {
      print('❌ GET Private Images - FAILED (403 Not Authenticated)');
      print('   → Butuh authentication token!');
      print('   → Tanya teman: "Apa token/API key untuk private storage?"\n');
    } else {
      print('❌ GET Private Images - FAILED\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

// Test Upload Image (uncomment untuk test upload)
Future<void> testUploadImage(String baseUrl, String? authToken) async {
  print('📋 Test 3: POST Upload Image (Private)');
  print('URL: $baseUrl/api/storage/private/upload');
  print('Auth: ${authToken != null ? "YES" : "NO (akan error 403!)"}');

  try {
    // Buat dummy file untuk test
    final testFile = File('test_image.jpg');

    // Check file exists
    if (!await testFile.exists()) {
      print('⚠️ File test_image.jpg tidak ditemukan');
      print('Buat file test_image.jpg di folder project untuk test upload\n');
      return;
    }

    // Create multipart request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/storage/private/upload'),
    );

    // Add authentication header
    if (authToken != null && authToken.isNotEmpty) {
      request.headers['Authorization'] = authToken;
    }

    // Add file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Field name sesuai API
        testFile.path,
      ),
    );

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Upload Image - SUCCESS\n');
    } else if (response.statusCode == 403) {
      print('❌ Upload Image - FAILED (403 Not Authenticated)');
      print('   → Butuh authentication token!\n');
    } else {
      print('❌ Upload Image - FAILED\n');
    }
  } catch (e) {
    print('❌ Error: $e\n');
  }
}

