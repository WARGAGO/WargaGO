import 'package:flutter/material.dart';
import 'package:jawara/core/models/kyc_document_model.dart';
import 'package:jawara/core/services/kyc_service.dart';

/// Widget untuk menampilkan preview KYC document
/// Menggunakan URL yang di-generate on-demand untuk menghindari expired URL
class KYCDocumentPreview extends StatefulWidget {
  final KYCDocumentModel document;
  final VoidCallback? onTap;
  final double height;

  const KYCDocumentPreview({
    super.key,
    required this.document,
    this.onTap,
    this.height = 200,
  });

  @override
  State<KYCDocumentPreview> createState() => _KYCDocumentPreviewState();
}

class _KYCDocumentPreviewState extends State<KYCDocumentPreview> {
  final KYCService _kycService = KYCService();
  String? _documentUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocumentUrl();
  }

  Future<void> _loadDocumentUrl() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Generate fresh URL dari blob name
      final url = await _kycService.getDocumentUrlFromModel(widget.document);

      if (mounted) {
        setState(() {
          _documentUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool get _isPdf {
    final blobName = widget.document.blobName.toLowerCase();
    return blobName.endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onTap != null && _documentUrl != null) {
          widget.onTap!();
        }
      },
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading document...'),
          ],
        ),
      );
    }

    if (_error != null || _documentUrl == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Failed to load document'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadDocumentUrl,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 48),
            SizedBox(height: 8),
            Text('PDF Document'),
            Text('Tap to view'),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _documentUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: $error'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadDocumentUrl,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Get current document URL (untuk open di browser/viewer)
  String? get documentUrl => _documentUrl;
}

