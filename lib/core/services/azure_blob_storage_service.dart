import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wargago/core/configs/url_pcvk_api.dart';
import 'package:wargago/core/models/BlobStorage/storage_response.dart';
import 'package:wargago/core/models/BlobStorage/user_images_response.dart';

class AzureBlobStorageService {
  static const String _uploadPublicEndpoint = 'storage/public/upload';
  static const String _getPublicImagesEndpoint = 'storage/public/get-images';
  static const String _deletePublicEndpoint = 'storage/public/image';

  static const String _uploadPrivateEndpoint = 'storage/private/upload';
  static const String _getPrivateImagesEndpoint = 'storage/private/get-images';
  static const String _deletePrivateEndpoint = 'storage/private/image';

  late final http.Client _client;
  final String firebaseToken;

  AzureBlobStorageService({
    required this.firebaseToken,
    http.Client? httpClient,
  }) {
    if (firebaseToken.isEmpty) {
      throw Exception('firebaseToken cannot be empty');
    }
    _client = httpClient ?? http.Client();
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    headers['Authorization'] = 'Bearer $firebaseToken';
    return headers;
  }

  Future<StorageResponse?> uploadImage({
    required File file,
    bool isPrivate = true,
    String? prefixName,
    String? customFileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        UrlPCVKAPI.buildEndpoint(
          isPrivate ? _uploadPrivateEndpoint : _uploadPublicEndpoint,
          queryParameters: {
            'prefix_name': prefixName,
            'custom_name': customFileName,
          },
        ),
      );

      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // if (kDebugMode) {
      //   print('Request headers: $headers');
      //   print('Request URL: ${request.url}');
      //   print('Request method: ${request.method}');
      // }

      final extension = file.path.toLowerCase().split('.').last;
      http.MediaType? contentType;

      switch (extension) {
        case 'png':
          contentType = http.MediaType('image', 'png');
          break;
        case 'gif':
          contentType = http.MediaType('image', 'gif');
          break;
        case 'webp':
          contentType = http.MediaType('image', 'webp');
          break;
        default:
          contentType = http.MediaType('image', 'jpeg');
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: contentType,
        filename: customFileName,
      );

      request.files.add(multipartFile);

      // if (kDebugMode) {
      //   print('Multipart file details:');
      //   print('  Field name: ${multipartFile.field}');
      //   print('  Filename: ${multipartFile.filename}');
      //   print('  Content-Type: ${multipartFile.contentType}');
      //   print('  Length: ${multipartFile.length}');
      //   print('Total files in request: ${request.files.length}');
      //   print('Sending request...');
      // }

      final response = await _client.send(request);
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      // if (kDebugMode) {
      //   print('Response received!');
      //   print('Response status code: ${response.statusCode}');
      //   print('Response headers: ${response.headers}');
      //   print('Response body length: ${responseBody.length}');
      //   print('Response body: $responseJson');
      // }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final StorageResponse storageResponse = StorageResponse.fromJson(
            responseJson,
          );

          // if (kDebugMode) {
          //   print('✅ Upload successful!');
          //   print('URL: ${storageResponse.blobUrl}');
          // }

          return storageResponse;
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing response: $e');
          }
          rethrow;
        }
      } else {
        if (kDebugMode) {
          print('❌ Upload failed: ${response.statusCode}');
        }
        throw Exception('Upload failed: $responseJson');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteFile({
    required String blobName,
    bool isPrivate = true,
  }) async {
    try {
      // if (kDebugMode) {
      //   print('🗑️ Deleting file...');
      //   print('Blob Name: $blobName');
      // }

      final response = await _client.delete(
        UrlPCVKAPI.buildEndpoint(
          '${isPrivate ? _deletePrivateEndpoint : _deletePublicEndpoint}/$blobName',
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        // if (kDebugMode) {
        //   print('✅ Delete successful!');
        // }
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

  Future<UserImagesResponse?> getImages({
    String? uid,
    String? filenamePrefix,
    bool isPrivate = true,
  }) async {
    try {
      final response = await _client.get(
        UrlPCVKAPI.buildEndpoint(
          isPrivate ? _getPrivateImagesEndpoint : _getPublicImagesEndpoint,
          queryParameters: {'uid': uid, 'filename_prefix': filenamePrefix},
        ),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserImagesResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting images: $e');
      }
      return null;
    }
  }
}
