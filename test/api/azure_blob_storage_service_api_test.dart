import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawara/core/models/BlobStorage/storage_response.dart';
import 'package:jawara/core/models/BlobStorage/user_images_response.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/services/azure_blob_storage_service.dart';
import 'package:jawara/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AzureBlobStorageService - API Tests', () {
    late AzureBlobStorageService service;
    late AuthProvider auth;

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    setUp(() async {
      auth = AuthProvider();
      await auth.signIn(email: '', password: '');
      final token = await auth.getToken();
      service = AzureBlobStorageService(firebaseToken: token ?? '');
    });

    group('uploadImage', () {
      test('uploads public image successfully', () async {
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
        }
      }, skip: false);

      test('uploads private image successfully', () async {
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
        }
      }, skip: false);

      test('handles different image formats', () async {
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
      }, skip: false);
    });

    group('getImages', () {
      test('retrieves public images successfully', () async {
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
        }
      }, skip: false);

      test('retrieves private images successfully', () async {
        // Act
        final result = await service.getImages(isPrivate: true);

        expect(result, isNotNull);
        expect(result!, isA<UserImagesResponse>());
        expect(result.userId, isNotEmpty);
        expect(result.count, greaterThanOrEqualTo(0));

        if (kDebugMode) {
          print('✅ Retrieved ${result.count} private images');
        }
      }, skip: false);

      test('retrieves images with filename prefix filter', () async {
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
        }
      }, skip: false);
    });

    group('deleteFile', () {
      test('deletes public file successfully', () async {
        final testImagePath = 'test/fixtures/test_images/1.jpg';
        final testFile = File(testImagePath);

        if (!await testFile.exists()) {
          return;
        }

        // Upload first
        final uploadResult = await service.uploadImage(
          file: testFile,
          isPrivate: false,
          prefixName: 'api-test-delete',
          customFileName: 'test_delete.jpg',
        );

        final blobName = '${await auth.getToken()}/${uploadResult!.blobName}';

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
        }
      }, skip: false);

      test('deletes private file successfully', () async {
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

        final blobName = '${await auth.getToken()}/${uploadResult!.blobName}';

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
        }
      }, skip: false);
    });

    group('Error handling', () {
      test('handles non-existent file deletion gracefully', () async {
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
        }
      }, skip: false);

      test('handles invalid file upload', () async {
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
        if (kDebugMode) {
          print('✅ Upload completed: ${uploadResult.blobName}');
        }

        // 2. Retrieve
        if (kDebugMode) {
          print('📥 Step 2: Retrieving images...');
        }
        final getResult = await service.getImages(
          uid: uniquePrefix,
          isPrivate: false,
        );

        expect(getResult, isNotNull);
        expect(getResult!.count, greaterThan(0));
        if (kDebugMode) {
          print('✅ Retrieved ${getResult.count} images');
        }

        // 3. Delete
        if (kDebugMode) {
          print('🗑️ Step 3: Deleting image...');
        }
        await expectLater(
          service.deleteFile(blobName: uploadResult.blobName, isPrivate: false),
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
          uid: uniquePrefix,
          isPrivate: false,
        );

        // Should return null or empty list after deletion
        if (verifyResult != null) {
          expect(verifyResult.count, 0);
        }
        if (kDebugMode) {
          print('✅ Integration workflow completed successfully');
        }
      }, skip: false);
    });
  });
}
