// ============================================================================
// AZURE API SERVICE
// ============================================================================
// Service untuk upload file ke Azure Blob Storage via API Backend
// Tidak perlu credentials, semua lewat backend API
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart'; // Import untuk MediaType

class AzureApiService {
  // ⚠️ Base URL API Backend (sudah diisi!)
  // PENTING: Jangan tambah slash (/) di akhir!
  static const String baseUrl = 'https://pcvk-containerapp.lemonisland-43c085da.southeastasia.azurecontainerapps.io';

  // ✅ Menggunakan Firebase Authentication Token
  // Token diambil otomatis dari user yang sedang login

  // Endpoints berdasarkan dokumentasi API
  // Public Storage Endpoints
  static const String uploadPublicEndpoint = '/api/storage/public/upload';
  static const String getPublicImagesEndpoint = '/api/storage/public/get-images';
  static String deletePublicImageEndpoint(String blobName) => '/api/storage/public/image/$blobName';

  // Private Storage Endpoints (untuk KYC documents)
  static const String uploadPrivateEndpoint = '/api/storage/private/upload';
  static const String getPrivateImagesEndpoint = '/api/storage/private/get-images';
  static String deletePrivateImageEndpoint(String blobName) => '/api/storage/private/image/$blobName';

  // Get Firebase Auth Token
  Future<String?> _getFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('⚠️ User not logged in to Firebase Auth');
        }
        return null;
      }

      final token = await user.getIdToken();
      if (kDebugMode) {
        print('✅ Firebase ID token obtained');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting Firebase token: $e');
      }
      return null;
    }
  }

  // Helper: Get headers with Firebase authentication
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Get Firebase Auth token
    final token = await _getFirebaseToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Helper: Get headers for multipart (tanpa content-type)
  Future<Map<String, String>> _getMultipartHeaders() async {
    final headers = <String, String>{};

    // Get Firebase Auth token
    final token = await _getFirebaseToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Upload file ke Azure via API (Private - untuk KYC)
  Future<String?> uploadFile({
    required File file,
    required String folder, // Contoh: 'kyc_documents'
    required String userId,
    String? customFileName, // Custom nama file/blob
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Uploading file via API (Private)...');
        print('Folder: $folder');
        print('User ID: $userId');
        if (customFileName != null) {
          print('Custom filename: $customFileName');
        }
      }

      // Create multipart request ke endpoint private
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$uploadPrivateEndpoint'),
      );

      // Add Firebase authentication headers (await karena async)
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);

      if (kDebugMode) {
        print('Request headers: $headers');
        print('Request URL: ${request.url}');
        print('Request method: ${request.method}');
      }

      // Detect content-type dari file extension
      final extension = file.path.toLowerCase().split('.').last;
      MediaType? contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        case 'pdf':
          contentType = MediaType('application', 'pdf');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // Default ke jpeg
      }

      if (kDebugMode) {
        print('File extension: $extension');
        print('Detected content-type: $contentType');
      }

      // Add file dengan field name 'file' dan explicit content-type
      // Gunakan custom filename jika disediakan
      final multipartFile = await http.MultipartFile.fromPath(
        'file', // Field name yang di-expect backend
        file.path,
        contentType: contentType, // Explicit content-type
        filename: customFileName, // Custom filename
      );

      request.files.add(multipartFile);

      if (kDebugMode) {
        print('Multipart file details:');
        print('  Field name: ${multipartFile.field}');
        print('  Filename: ${multipartFile.filename}');
        print('  Content-Type: ${multipartFile.contentType}');
        print('  Length: ${multipartFile.length}');
        print('Total files in request: ${request.files.length}');
      }

      // Add metadata jika diperlukan
      // request.fields['folder'] = folder;
      // request.fields['userId'] = userId;

      // Send request
      if (kDebugMode) {
        print('Sending request...');
      }

      var streamedResponse = await request.send();

      if (kDebugMode) {
        print('Request sent, waiting for response...');
        print('Response status code: ${streamedResponse.statusCode}');
      }

      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response received!');
        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body length: ${response.body.length}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);

          if (kDebugMode) {
            print('JSON decoded successfully!');
            print('Parsed response data: $data');
            print('Response type: ${data.runtimeType}');
            if (data is Map) {
              print('Available keys: ${data.keys.toList()}');
              // Print all values untuk debugging
              data.forEach((key, value) {
                print('  $key: $value');
              });
            }
          }

          String? url;

          // Handle different response formats
          if (data is Map) {
            // Try direct keys first
            url = data['url'] as String? ??
                  data['imageUrl'] as String? ??
                  data['blobUrl'] as String? ??
                  data['file_url'] as String? ??
                  data['blob_url'] as String? ??
                  data['download_url'] as String? ??
                  data['image_url'] as String? ??
                  data['path'] as String? ??
                  data['image'] as String? ??
                  data['file'] as String?;

            // Try nested data object
            if (url == null && data['data'] != null) {
              final nestedData = data['data'];
              if (kDebugMode) {
                print('Checking nested data object...');
                print('Nested data: $nestedData');
              }
              if (nestedData is Map) {
                url = nestedData['url'] as String? ??
                      nestedData['imageUrl'] as String? ??
                      nestedData['blobUrl'] as String? ??
                      nestedData['blob_url'] as String? ??
                      nestedData['file_url'] as String? ??
                      nestedData['path'] as String? ??
                      nestedData['image'] as String? ??
                      nestedData['file'] as String?;
              } else if (nestedData is String) {
                // data['data'] might be the URL itself
                url = nestedData;
              }
            }

            // If still no URL, try to construct from blob name/path
            if (url == null && data['blob_name'] != null) {
              final blobName = data['blob_name'] as String;
              url = '$baseUrl/files/$blobName';
              if (kDebugMode) {
                print('⚠️ Constructed URL from blob_name: $url');
              }
            }

            // Try message field (some APIs return URL in message)
            if (url == null && data['message'] != null && data['message'] is String) {
              final message = data['message'] as String;
              if (message.startsWith('http')) {
                url = message;
                if (kDebugMode) {
                  print('⚠️ Found URL in message field: $url');
                }
              }
            }
          } else if (data is String) {
            // Response might be just a string URL
            if (data.startsWith('http')) {
              url = data;
              if (kDebugMode) {
                print('⚠️ Response is a string URL: $url');
              }
            }
          }

          if (url == null || url.isEmpty) {
            if (kDebugMode) {
              print('❌ No URL found in response!');
              if (data is Map) {
                print('Response keys: ${data.keys.toList()}');
              }
              print('Full response: $data');
              print('');
              print('🔍 KIRIM LOG INI KE DEVELOPER:');
              print('Response body: ${response.body}');
            }
            throw Exception('No URL in response. Full response: ${response.body}');
          }

          if (kDebugMode) {
            print('✅ Upload successful!');
            print('URL: $url');
          }

          return url;
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing response: $e');
            print('Response body: ${response.body}');
          }
          rethrow;
        }
      } else {
        if (kDebugMode) {
          print('❌ Upload failed: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading file: $e');
      }
      rethrow;
    }
  }

  // Upload file public (untuk profile picture, dll)
  Future<String?> uploadPublicFile({
    required File file,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Uploading file via API (Public)...');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$uploadPublicEndpoint'),
      );

      // Add Firebase auth headers (await karena async)
      request.headers.addAll(await _getMultipartHeaders());

      // Detect content-type dari file extension
      final extension = file.path.toLowerCase().split('.').last;
      MediaType? contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'gif':
          contentType = MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: contentType,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Public upload - Response status: ${response.statusCode}');
        print('Public upload - Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        String? url;
        if (data is Map) {
          url = data['url'] as String? ??
                data['imageUrl'] as String? ??
                data['blobUrl'] as String? ??
                data['file_url'] as String? ??
                data['blob_url'] as String?;

          if (url == null && data['data'] != null && data['data'] is Map) {
            url = data['data']['url'] as String? ??
                  data['data']['imageUrl'] as String? ??
                  data['data']['blobUrl'] as String?;
          }
        }

        if (kDebugMode) {
          print('✅ Public upload successful!');
          print('URL: $url');
        }

        return url;
      } else {
        throw Exception('Public upload failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading public file: $e');
      }
      rethrow;
    }
  }

  // Delete file dari Azure via API (Private)
  Future<void> deleteFile(String blobName) async {
    try {
      if (kDebugMode) {
        print('🗑️ Deleting file via API...');
        print('Blob Name: $blobName');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl${deletePrivateImageEndpoint(blobName)}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Delete successful!');
        }
      } else {
        if (kDebugMode) {
          print('❌ Delete failed: ${response.statusCode}');
        }
        throw Exception('Delete failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting file: $e');
      }
      rethrow;
    }
  }

  // Get all images (Private)
  Future<List<String>> getPrivateImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$getPrivateImagesEndpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Response biasanya: { "images": ["url1", "url2", ...] }
        final images = (data['images'] ?? []) as List;
        return images.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting images: $e');
      }
      return [];
    }
  }

  // Get all images (Public)
  Future<List<String>> getPublicImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$getPublicImagesEndpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final images = (data['images'] ?? []) as List;
        return images.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting public images: $e');
      }
      return [];
    }
  }

  // Helper: Generate unique filename
  String generateFileName(String userId, String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return '${userId}_$timestamp.$extension';
  }

  // Get file URL from blob name (Generate fresh URL on-demand)
  // URL akan fresh dan tidak akan expired
  Future<String?> getFileUrl(String blobName, {bool isPublic = false}) async {
    try {
      if (kDebugMode) {
        print('🔗 Generating fresh URL for blob: $blobName');
        print('Is public: $isPublic');
      }

      // Untuk private storage, kita perlu endpoint khusus untuk generate URL
      // Jika backend belum support, kita bisa construct URL langsung
      // Format: https://baseUrl/api/storage/private/file/{blobName}

      final endpoint = isPublic
          ? '/api/storage/public/file/$blobName'
          : '/api/storage/private/file/$blobName';

      final url = '$baseUrl$endpoint';

      if (kDebugMode) {
        print('✅ Generated URL: $url');
      }

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating file URL: $e');
      }
      return null;
    }
  }

  // Alternative: Get SAS URL from backend (jika backend support)
  Future<String?> getSasUrl(String blobName, {bool isPublic = false}) async {
    try {
      if (kDebugMode) {
        print('🔗 Requesting SAS URL for blob: $blobName');
      }

      final endpoint = isPublic
          ? '/api/storage/public/sas-url/$blobName'
          : '/api/storage/private/sas-url/$blobName';

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sasUrl = data['url'] as String? ??
                      data['sasUrl'] as String? ??
                      data['sas_url'] as String?;

        if (kDebugMode) {
          print('✅ SAS URL obtained: $sasUrl');
        }

        return sasUrl;
      } else {
        if (kDebugMode) {
          print('⚠️ Failed to get SAS URL: ${response.statusCode}');
        }
        // Fallback to direct URL
        return getFileUrl(blobName, isPublic: isPublic);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting SAS URL: $e');
      }
      // Fallback to direct URL
      return getFileUrl(blobName, isPublic: isPublic);
    }
  }
}

