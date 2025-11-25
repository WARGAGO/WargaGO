class AzureBlobMockResponses {
  // Upload Success Response
  static const Map<String, dynamic> uploadPublicSuccess = {
    'success': true,
    'blob_name': 'test-user-123profile_20231125_120000.jpg',
    'blob_url':
        'https://pblsem5storage.blob.core.windows.net/public/jawara-container/test-user-123profile_20231125_120000.jpg',
    'message': 'File uploaded successfully',
  };

  // Upload Success Response (Private)
  static const Map<String, dynamic> uploadPrivateSuccess = {
    'success': true,
    'blob_name': 'private/test-user-123document_20231125_120000.jpg',
    'blob_url':
        'https://pblsem5storage.blob.core.windows.net/public/jawara-private/private/test-user-123document_20231125_120000.jpg',
    'message': 'File uploaded successfully to private storage',
  };

  // Get Images Success Response
  static const Map<String, dynamic> getPublicImagesSuccess = {
    'user_id': 'test-user-123',
    'count': 3,
    'images': [
      {
        'success': true,
        'blob_name': 'test-user-123profile_20231125_120000.jpg',
        'blob_url':
            'https://pblsem5storage.blob.core.windows.net/public/jawara-container/test-user-123profile_20231125_120000.jpg',
        'message': 'Image retrieved',
      },
      {
        'success': true,
        'blob_name': 'test-user-123profile_20231125_130000.jpg',
        'blob_url':
            'https://pblsem5storage.blob.core.windows.net/public/jawara-container/test-user-123profile_20231125_130000.jpg',
        'message': 'Image retrieved',
      },
      {
        'success': true,
        'blob_name': 'test-user-123cover_20231125_140000.jpg',
        'blob_url':
            'https://pblsem5storage.blob.core.windows.net/public/jawara-container/test-user-123cover_20231125_140000.jpg',
        'message': 'Image retrieved',
      },
    ],
  };

  // Get Images Empty Response
  static const Map<String, dynamic> getPublicImagesEmpty = {
    'user_id': 'test-user-123',
    'count': 0,
    'images': [],
  };

  // Get Private Images Success Response
  static const Map<String, dynamic> getPrivateImagesSuccess = {
    'user_id': 'test-user-456',
    'count': 2,
    'images': [
      {
        'success': true,
        'blob_name': 'private/test-user-456/document_20231125_120000.jpg',
        'blob_url':
            'https://pblsem5storage.blob.core.windows.net/public/jawara-private/private/test-user-456/document_20231125_120000.jpg',
        'message': 'Private image retrieved',
      },
      {
        'success': true,
        'blob_name': 'private/test-user-456/secure_20231125_130000.jpg',
        'blob_url':
            'https://pblsem5storage.blob.core.windows.net/public/jawara-private/private/test-user-456/secure_20231125_130000.jpg',
        'message': 'Private image retrieved',
      },
    ],
  };

  // Delete Success Response
  static const Map<String, dynamic> deleteSuccess = {
    'success': true,
    'message': 'File deleted successfully',
  };

  // Upload Error Response
  static const Map<String, dynamic> uploadError = {
    'success': false,
    'message': 'Upload failed: Invalid file format',
  };

  // Unauthorized Response
  static const Map<String, dynamic> unauthorizedResponse = {
    'error': 'Unauthorized',
    'message': 'Invalid or missing authentication token',
  };

  // Not Found Response
  static const Map<String, dynamic> notFoundResponse = {
    'error': 'Not Found',
    'message': 'The requested resource was not found',
  };
}
