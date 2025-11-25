import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:jawara/core/models/BlobStorage/storage_response.dart';
import 'package:jawara/core/models/BlobStorage/user_images_response.dart';
import 'package:jawara/core/services/azure_blob_storage_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'azure_blob_storage_service_test.mocks.dart';
import '../fixtures/azure_blob_mock_responses.dart';

@GenerateMocks([http.Client])
void main() {
  group('AzureBlobStorageService', () {
    late AzureBlobStorageService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = AzureBlobStorageService(
        firebaseToken: '123',
        httpClient: mockClient,
      );
    });

    group('uploadImage', () {
      late File mockFile;

      setUp(() async {
        // Create a temporary test file
        mockFile = File('test_image.jpg');
        await mockFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      });

      tearDown(() async {
        // Clean up test files
        if (await mockFile.exists()) {
          await mockFile.delete();
        }
      });

      test('uploads public image successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload public image with 200 OK response');
        }
        // Arrange
        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                json.encode(AzureBlobMockResponses.uploadPublicSuccess),
              ),
            ),
            200,
          ),
        );

        // Act
        final result = await service.uploadImage(
          file: mockFile,
          isPrivate: false,
          prefixName: 'test-123',
        );

        // Assert
        expect(result, isA<StorageResponse>());
        expect(result!.success, true);
        expect(result.blobName, 'test-user-123profile_20231125_120000.jpg');
        expect(
          result.blobUrl,
          contains('pblsem5storage.blob.core.windows.net/public'),
        );
        expect(result.message, 'File uploaded successfully');

        verify(mockClient.send(any)).called(1);
        if (kDebugMode) {
          print('✅ Passed: Upload public image\n');
        }
      });

      test('uploads private image successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload private image with custom filename');
        }
        // Arrange
        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                json.encode(AzureBlobMockResponses.uploadPrivateSuccess),
              ),
            ),
            201,
          ),
        );

        // Act
        final result = await service.uploadImage(
          file: mockFile,
          isPrivate: true,
          prefixName: 'test-user-123',
          customFileName: 'document.jpg',
        );

        // Assert
        expect(result, isA<StorageResponse>());
        expect(result!.success, true);
        expect(result.blobName, contains('private/test-user-123'));
        expect(result.blobUrl, contains('jawara-private'));
        expect(result.message, 'File uploaded successfully to private storage');

        verify(mockClient.send(any)).called(1);
        if (kDebugMode) {
          print('✅ Passed: Upload private image\n');
        }
      });

      test('handles different image formats correctly', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload PNG format image');
        }
        // Test PNG
        final pngFile = File('test_image.png');
        await pngFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]); // PNG header

        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                json.encode(AzureBlobMockResponses.uploadPublicSuccess),
              ),
            ),
            200,
          ),
        );

        final result = await service.uploadImage(file: pngFile);

        expect(result, isA<StorageResponse>());
        verify(mockClient.send(any)).called(1);

        await pngFile.delete();
        if (kDebugMode) {
          print('✅ Passed: PNG format upload\n');
        }
      });

      test('throws exception on upload failure', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload failure with 400 Bad Request');
        }
        // Arrange
        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(json.encode(AzureBlobMockResponses.uploadError)),
            ),
            400,
          ),
        );

        // Act & Assert
        await expectLater(
          service.uploadImage(file: mockFile),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Upload failed'),
            ),
          ),
        );

        verify(mockClient.send(any)).called(1);
        if (kDebugMode) {
          print('✅ Passed: Upload failure exception\n');
        }
      });

      test('throws exception on unauthorized upload', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload with 401 Unauthorized response');
        }
        // Arrange
        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(
              utf8.encode(
                json.encode(AzureBlobMockResponses.unauthorizedResponse),
              ),
            ),
            401,
          ),
        );

        // Act & Assert
        await expectLater(
          service.uploadImage(file: mockFile),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Upload failed'),
            ),
          ),
        );
        if (kDebugMode) {
          print('✅ Passed: Unauthorized upload exception\n');
        }
      });

      test('throws exception on server error', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload with 500 Internal Server Error');
        }
        // Arrange
        when(mockClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode('Internal Server Error')),
            500,
          ),
        );

        // Act & Assert
        await expectLater(
          service.uploadImage(file: mockFile),
          throwsA(isA<Exception>()),
        );
        if (kDebugMode) {
          print('✅ Passed: Server error exception\n');
        }
      });
    });

    group('deleteFile', () {
      test('deletes public file successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete public file with 200 OK');
        }
        // Arrange
        when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.deleteSuccess),
            200,
          ),
        );

        // Act & Assert - Should not throw
        await expectLater(
          service.deleteFile(
            blobName: 'test-user-123profile_20231125_120000.jpg',
            isPrivate: false,
          ),
          completes,
        );

        verify(mockClient.delete(any, headers: anyNamed('headers'))).called(1);
        if (kDebugMode) {
          print('✅ Passed: Delete public file\n');
        }
      });

      test('deletes private file successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete private file successfully');
        }
        // Arrange
        when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.deleteSuccess),
            200,
          ),
        );

        // Act & Assert - Should not throw
        await expectLater(
          service.deleteFile(
            blobName: 'private/test-user-456/document_20231125_120000.jpg',
            isPrivate: true,
          ),
          completes,
        );

        verify(mockClient.delete(any, headers: anyNamed('headers'))).called(1);
        if (kDebugMode) {
          print('✅ Passed: Delete private file\n');
        }
      });

      test('throws exception on delete failure', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete non-existent file (404 Not Found)');
        }
        // Arrange
        when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.notFoundResponse),
            404,
          ),
        );

        // Act & Assert
        await expectLater(
          service.deleteFile(blobName: 'nonexistent/file.jpg'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Delete failed'),
            ),
          ),
        );
        if (kDebugMode) {
          print('✅ Passed: Delete failure exception\n');
        }
      });

      test('throws exception on unauthorized delete', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete with 401 Unauthorized');
        }
        // Arrange
        when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.unauthorizedResponse),
            401,
          ),
        );

        // Act & Assert
        await expectLater(
          service.deleteFile(blobName: 'test-user-123file.jpg'),
          throwsA(isA<Exception>()),
        );
        if (kDebugMode) {
          print('✅ Passed: Unauthorized delete exception\n');
        }
      });
    });

    group('getImages', () {
      test('retrieves public images successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Get public images list (3 images)');
        }
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.getPublicImagesSuccess),
            200,
          ),
        );

        // Act
        final result = await service.getImages(
          uid: 'test-user-123',
          isPrivate: false,
        );

        // Assert
        expect(result, isA<UserImagesResponse>());
        expect(result!.userId, 'test-user-123');
        expect(result.count, 3);
        expect(result.images.length, 3);
        expect(result.images[0].blobName, contains('profile_20231125_120000'));
        expect(result.images[0].blobUrl, contains('public'));

        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
        if (kDebugMode) {
          print('✅ Passed: Get public images\n');
        }
      });

      test('retrieves private images successfully', () async {
        if (kDebugMode) {
          print('📝 Testing: Get private images list (2 images)');
        }
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.getPrivateImagesSuccess),
            200,
          ),
        );

        // Act
        final result = await service.getImages(
          uid: 'test-user-456',
          isPrivate: true,
        );

        // Assert
        expect(result, isA<UserImagesResponse>());
        expect(result!.userId, 'test-user-456');
        expect(result.count, 2);
        expect(result.images.length, 2);
        expect(result.images[0].blobName, contains('private'));

        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
        if (kDebugMode) {
          print('✅ Passed: Get private images\n');
        }
      });

      test('retrieves images with filename prefix filter', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images with filename prefix filter');
        }
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.getPublicImagesSuccess),
            200,
          ),
        );

        // Act
        final result = await service.getImages(
          uid: 'test-user-123',
          filenamePrefix: 'profile',
          isPrivate: false,
        );

        // Assert
        expect(result, isA<UserImagesResponse>());
        expect(result!.images.length, greaterThan(0));

        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
        if (kDebugMode) {
          print('✅ Passed: Filename prefix filter\n');
        }
      });

      test('returns empty list when no images found', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images returns empty list');
        }
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.getPublicImagesEmpty),
            200,
          ),
        );

        // Act
        final result = await service.getImages(
          uid: 'test-user-123',
          isPrivate: false,
        );

        // Assert
        expect(result, isA<UserImagesResponse>());
        expect(result!.count, 0);
        expect(result.images, isEmpty);
        if (kDebugMode) {
          print('✅ Passed: Empty list returned\n');
        }
      });

      test('returns null on get images failure', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images with 404 Not Found returns null');
        }
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await service.getImages(uid: 'test-user-123');

        // Assert
        expect(result, isNull);
        if (kDebugMode) {
          print('✅ Passed: Get images failure returns null\n');
        }
      });

      test('returns null on unauthorized request', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images with 401 Unauthorized returns null');
        }
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            json.encode(AzureBlobMockResponses.unauthorizedResponse),
            401,
          ),
        );

        // Act
        final result = await service.getImages(uid: 'test-user-123');

        // Assert
        expect(result, isNull);
        if (kDebugMode) {
          print('✅ Passed: Unauthorized request returns null\n');
        }
      });
    });

    group('Error handling', () {
      late File mockFile;

      setUp(() async {
        mockFile = File('test_error.jpg');
        await mockFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      });

      tearDown(() async {
        if (await mockFile.exists()) {
          await mockFile.delete();
        }
      });

      test('handles network errors gracefully on upload', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload with network error (SocketException)');
        }
        // Arrange
        when(
          mockClient.send(any),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        await expectLater(
          service.uploadImage(file: mockFile),
          throwsA(isA<SocketException>()),
        );
        if (kDebugMode) {
          print('✅ Passed: Network error on upload\n');
        }
      });

      test('handles timeout errors on upload', () async {
        if (kDebugMode) {
          print('📝 Testing: Upload with timeout error');
        }
        // Arrange
        when(
          mockClient.send(any),
        ).thenThrow(TimeoutException('Request timeout'));

        // Act & Assert
        await expectLater(
          service.uploadImage(file: mockFile),
          throwsA(isA<TimeoutException>()),
        );
        if (kDebugMode) {
          print('✅ Passed: Timeout error on upload\n');
        }
      });

      test('handles network errors on delete', () async {
        if (kDebugMode) {
          print('📝 Testing: Delete with network error');
        }
        // Arrange
        when(
          mockClient.delete(any, headers: anyNamed('headers')),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        await expectLater(
          service.deleteFile(blobName: 'test.jpg'),
          throwsA(isA<SocketException>()),
        );
        if (kDebugMode) {
          print('✅ Passed: Network error on delete\n');
        }
      });

      test('handles network errors on getImages', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images with network error returns null');
        }
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act
        final result = await service.getImages(uid: 'test-user-123');

        // Assert
        expect(result, isNull);
        if (kDebugMode) {
          print('✅ Passed: Network error on getImages\n');
        }
      });

      test('handles JSON parsing errors', () async {
        if (kDebugMode) {
          print('📝 Testing: Get images with invalid JSON returns null');
        }
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Invalid JSON', 200));

        // Act
        final result = await service.getImages(uid: 'test-user-123');

        // Assert
        expect(result, isNull);
        if (kDebugMode) {
          print('✅ Passed: JSON parsing error handled\n');
        }
      });
    });
  });
}
