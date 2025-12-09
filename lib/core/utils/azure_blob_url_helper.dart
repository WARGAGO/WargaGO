/// ============================================================================
/// AZURE BLOB URL HELPER
/// ============================================================================
/// Utility untuk handle Azure Blob Storage URLs
/// - Remove SAS token parameters (untuk public container)
/// - Clean expired tokens
/// ============================================================================

class AzureBlobUrlHelper {
  /// Remove SAS token parameters from Azure Blob URL
  ///
  /// Example:
  /// Input:  https://storage.blob.core.windows.net/public/image.webp?st=2025-12-06&se=2025-12-07&sig=xxx
  /// Output: https://storage.blob.core.windows.net/public/image.webp
  ///
  /// ⭐ Use this when container is PUBLIC (no SAS token needed)
  static String removeSasToken(String url) {
    try {
      final uri = Uri.parse(url);

      // Check if it's Azure Blob Storage URL
      if (!uri.host.contains('blob.core.windows.net')) {
        return url; // Not Azure Blob, return as-is
      }

      // Remove all query parameters (SAS token params)
      final cleanUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path,
        // No query parameters = no SAS token
      );

      return cleanUri.toString();
    } catch (e) {
      // If parsing fails, return original URL
      return url;
    }
  }

  /// Clean list of URLs (remove SAS tokens)
  static List<String> cleanUrlList(List<String> urls) {
    return urls.map((url) => removeSasToken(url)).toList();
  }

  /// Check if URL has SAS token parameters
  static bool hasSasToken(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters.isNotEmpty &&
          (uri.queryParameters.containsKey('st') ||
           uri.queryParameters.containsKey('se') ||
           uri.queryParameters.containsKey('sig'));
    } catch (e) {
      return false;
    }
  }

  /// Extract base URL (without SAS token)
  static String getBaseUrl(String url) {
    return removeSasToken(url);
  }
}

