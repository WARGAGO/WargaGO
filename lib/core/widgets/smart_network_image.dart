import 'package:flutter/material.dart';

/// Smart Image URL Handler untuk Azure Blob Storage
/// Handles expired SAS tokens dan fallback ke direct URL access
class AzureImageUrlHandler {
  /// Check if URL has expired SAS token
  static bool hasExpiredSasToken(String url) {
    try {
      final uri = Uri.parse(url);

      // Check if has SAS token parameters
      if (!uri.queryParameters.containsKey('se')) {
        return false; // No SAS token
      }

      // Parse expiry time (se parameter)
      final expiryStr = uri.queryParameters['se'];
      if (expiryStr == null) return false;

      final expiry = DateTime.parse(Uri.decodeComponent(expiryStr));
      final now = DateTime.now();

      // Check if expired
      return now.isAfter(expiry);
    } catch (e) {
      return false; // Can't parse, assume not expired
    }
  }

  /// Get clean URL without SAS token
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
      );

      return cleanUri.toString();
    } catch (e) {
      return url; // If parsing fails, return original
    }
  }

  /// Smart URL resolver: Try original, then fallback to clean URL
  static List<String> getUrlsToTry(String originalUrl) {
    final urls = <String>[];

    // Try original URL first
    urls.add(originalUrl);

    // If has expired token, also try without token
    if (hasExpiredSasToken(originalUrl)) {
      urls.add(removeSasToken(originalUrl));
    }

    return urls;
  }
}

/// Smart Network Image Widget dengan automatic fallback
class SmartNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<SmartNetworkImage> createState() => _SmartNetworkImageState();
}

class _SmartNetworkImageState extends State<SmartNetworkImage> {
  late List<String> _urlsToTry;
  int _currentUrlIndex = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _urlsToTry = AzureImageUrlHandler.getUrlsToTry(widget.imageUrl);
  }

  @override
  void didUpdateWidget(SmartNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _urlsToTry = AzureImageUrlHandler.getUrlsToTry(widget.imageUrl);
        _currentUrlIndex = 0;
        _hasError = false;
      });
    }
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _urlsToTry.length - 1) {
      setState(() {
        _currentUrlIndex++;
        _hasError = false;
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    return Image.network(
      _urlsToTry[_currentUrlIndex],
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ?? _buildDefaultLoading(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        // Try next URL on error
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryNextUrl();
        });
        return widget.placeholder ?? _buildDefaultLoading(null);
      },
    );
  }

  Widget _buildDefaultLoading(ImageChunkEvent? progress) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFFF8F9FD),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF2F80ED),
            ),
            value: progress?.expectedTotalBytes != null
                ? progress!.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: const Color(0xFF2F80ED).withValues(alpha: 0.5),
            size: (widget.height ?? 100) * 0.3,
          ),
          if (widget.height != null && widget.height! > 80) ...[
            const SizedBox(height: 8),
            const Text(
              'Gambar tidak tersedia',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

