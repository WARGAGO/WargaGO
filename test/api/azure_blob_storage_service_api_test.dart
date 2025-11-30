import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wargago/core/models/BlobStorage/storage_response.dart';
import 'package:wargago/core/models/BlobStorage/user_images_response.dart';
import 'package:wargago/core/services/azure_blob_storage_service.dart';

import '../fixtures/utils.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  late final String token;
  token = await Utils.getAuthToken();
  group('AzureBlobStorageService - API Tests', () {
    late AzureBlobStorageService service;

    setUp(() => service = AzureBlobStorageService(firebaseToken: token));

    group('uploadImage', () {
      test('uploads public image successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload public image to Azure Blob Storage');
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        // Act
        final result = await service.uploadImage(
          file: testFile,
          isPrivate: false,
          prefixName: 'api-test',
          customFileName: 'test_upload.jpg',
        );

        // Assert
        expect(result, isA<StorageResponse>());
        expect(result!.success, true);
        expect(result.blobName, isNotEmpty);
        expect(result.blobUrl, isNotEmpty);
        expect(result.blobUrl, contains('blob.core.windows.net'));
        expect(result.message, isNotEmpty);

        if (kDebugMode) {
          print('✅ Upload successful:');
          print('   Blob Name: ${result.blobName}');
          print('   Blob URL: ${result.blobUrl}');
          print('   Message: ${result.message}');
          print('');
        }
      }, skip: false);

      test('uploads private image successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload private image to Azure Blob Storage');
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        if (!await testFile.exists()) {
          return;
        }

        // Act
        final result = await service.uploadImage(
          file: testFile,
          isPrivate: true,
          prefixName: 'api-test-private',
          customFileName: 'test_private.jpg',
        );

        // Assert
        expect(result, isA<StorageResponse>());
        expect(result!.success, true);
        expect(result.blobName, isNotEmpty);
        expect(result.blobUrl, isNotEmpty);

        if (kDebugMode) {
          print('✅ Private upload successful:');
          print('   Blob Name: ${result.blobName}');
          print('   Blob URL: ${result.blobUrl}');
          print('');
        }
      }, skip: false);

      test('handles different image formats', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload different image formats (PNG, GIF, WebP)');
        }
        final formats = ['png', 'gif', 'webp'];

        for (final format in formats) {
          final testImagePath = 'test/fixtures/test_images/test.$format';
          final testFile = File(testImagePath);

          if (!await testFile.exists()) {
            continue;
          }

          final result = await service.uploadImage(
            file: testFile,
            prefixName: 'api-test-formats',
            customFileName: 'test_$format.$format',
          );

          expect(result, isA<StorageResponse>());
          expect(result!.success, true);

          if (kDebugMode) {
            print('✅ $format format upload successful');
          }
        }
        if (kDebugMode) {
          print('');
        }
      }, skip: false);
    });

    group('getImages', () {
      test('retrieves public images successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Retrieve public images from Azure Blob Storage');
        }
        // Act
        final result = await service.getImages(isPrivate: false);

        // Assert
        expect(result, isNotNull);
        expect(result, isA<UserImagesResponse>());
        expect(result!.userId, isNotEmpty);
        expect(result.count, greaterThanOrEqualTo(0));
        expect(result.images, isA<List<StorageResponse>>());

        if (kDebugMode) {
          print(
            '✅ Retrieved ${result.count} images for user: ${result.userId}',
          );
          for (var i = 0; i < result.images.length; i++) {
            print('   Image ${i + 1}: ${result.images[i].blobName}');
          }
          print('');
        }
      }, skip: false);

      test('retrieves private images successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Retrieve private images from Azure Blob Storage');
        }
        // Act
        final result = await service.getImages(isPrivate: true);

        expect(result, isNotNull);
        expect(result!, isA<UserImagesResponse>());
        expect(result.userId, isNotEmpty);
        expect(result.count, greaterThanOrEqualTo(0));

        if (kDebugMode) {
          print('✅ Retrieved ${result.count} private images');
          print('');
        }
      }, skip: false);

      test('retrieves images with filename prefix filter', () async {
        if (kDebugMode) {
          print('📝 Testing: Retrieve images with filename prefix filter');
        }
        // Act
        final result = await service.getImages(
          filenamePrefix: 'test',
          isPrivate: false,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!, isA<UserImagesResponse>());
        if (kDebugMode) {
          print('✅ Retrieved ${result.count} images with prefix "profile"');
          print('');
        }
      }, skip: false);
    });

    group('deleteFile', () {
      test('deletes public file successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete public file from Azure Blob Storage');
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        // Upload first
        final uploadResult = await service.uploadImage(
          file: testFile,
          isPrivate: false,
          prefixName: 'api-test-delete',
          customFileName: 'test_delete.jpg',
        );

        final blobName = uploadResult!.blobName;

        expect(uploadResult, isNotNull);
        if (kDebugMode) {
          print('✅ Uploaded file for deletion test: $blobName');
        }

        // Now delete
        await expectLater(
          service.deleteFile(blobName: blobName, isPrivate: false),
          completes,
        );

        if (kDebugMode) {
          print('✅ File deleted successfully: $blobName');
          print('');
        }
      }, skip: false);

      test('deletes private file successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete private file from Azure Blob Storage');
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        if (!await testFile.exists()) {
          return;
        }

        // Upload first
        final uploadResult = await service.uploadImage(
          file: testFile,
          isPrivate: true,
          prefixName: 'api-test-delete-private',
          customFileName: 'test_delete_private.jpg',
        );

        final blobName = uploadResult!.blobName;

        expect(uploadResult, isNotNull);
        if (kDebugMode) {
          print('✅ Uploaded private file for deletion: $blobName');
        }

        // Now delete
        await expectLater(
          service.deleteFile(blobName: blobName, isPrivate: true),
          completes,
        );

        if (kDebugMode) {
          print('✅ File deleted successfully: $blobName');
          print('');
        }
      }, skip: false);
    });

    group('Error handling', () {
      test('handles non-existent file deletion gracefully', () async {
        if (kDebugMode) {
          print('📝 Testing: Handle non-existent file deletion error');
        }
        // Act & Assert
        await expectLater(
          service.deleteFile(
            blobName: 'nonexistent/file.jpg',
            isPrivate: false,
          ),
          throwsA(isA<Exception>()),
        );

        if (kDebugMode) {
          print('✅ Correctly threw exception for non-existent file');
          print('');
        }
      }, skip: false);

      test('handles invalid file upload', () async {
        if (kDebugMode) {
          print('📝 Testing: Handle invalid file upload error');
        }
        // Create an invalid/empty file
        final invalidFile = File('test_invalid.txt');
        await invalidFile.writeAsString('This is not an image');

        try {
          await expectLater(
            service.uploadImage(file: invalidFile),
            throwsA(isA<Exception>()),
          );
          if (kDebugMode) {
            print('✅ Correctly handled invalid file upload');
            print('');
          }
        } finally {
          if (await invalidFile.exists()) {
            await invalidFile.delete();
          }
        }
      }, skip: false);
    });

    group('Integration workflow', () {
      test('complete upload, retrieve, and delete workflow', () async {
        if (kDebugMode) {
          print(
            '📝 Testing: Complete integration workflow (upload → retrieve → delete)',
          );
        }
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        if (!await testFile.exists()) {
          return;
        }

        final uniquePrefix = 'integration-test';

        // 1. Upload
        if (kDebugMode) {
          print('📤 Step 1: Uploading image...');
        }
        final uploadResult = await service.uploadImage(
          file: testFile,
          isPrivate: false,
          prefixName: uniquePrefix,
          customFileName: 'workflow_test.jpg',
        );

        expect(uploadResult, isNotNull);
        expect(uploadResult!.success, true);

        final blobName = uploadResult.blobName;
        final filenamePrefix = '${uniquePrefix}workflow_test';

        if (kDebugMode) {
          print('✅ Upload completed: $blobName');
        }

        // 2. Retrieve
        if (kDebugMode) {
          print('📥 Step 2: Retrieving images...');
        }
        final getResult = await service.getImages(
          filenamePrefix: filenamePrefix,
          isPrivate: false,
        );

        expect(getResult, isNotNull);
        expect(getResult!.count, greaterThan(0));
        if (kDebugMode) {
          print('✅ Retrieved ${getResult.count} images');
        }

        // 3. Delete
        if (kDebugMode) {
          print('🗑️ Step 3: Deleting image prefix: $filenamePrefix');
        }
        await expectLater(
          service.deleteFile(blobName: blobName, isPrivate: false),
          completes,
        );
        if (kDebugMode) {
          print('✅ Delete completed');
        }

        // 4. Verify deletion
        if (kDebugMode) {
          print('🔍 Step 4: Verifying deletion...');
        }
        final verifyResult = await service.getImages(
          filenamePrefix: filenamePrefix,
          isPrivate: false,
        );

        if (verifyResult != null) {
          expect(verifyResult.count, 0);
        }
        if (kDebugMode) {
          print('✅ Integration workflow completed successfully');
          print('');
        }
      }, skip: false);
    });
  });
}
