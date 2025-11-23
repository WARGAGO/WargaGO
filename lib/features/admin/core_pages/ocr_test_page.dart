// ============================================================================
// OCR & FACE DETECTION TEST PAGE
// ============================================================================
// Halaman untuk testing OCR dan Face Detection
// Upload gambar KTP untuk test
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawara/core/services/ocr_service.dart';
import 'package:jawara/core/models/kyc_document_model.dart' as model;

class OCRTestPage extends StatefulWidget {
  const OCRTestPage({super.key});

  @override
  State<OCRTestPage> createState() => _OCRTestPageState();
}

class _OCRTestPageState extends State<OCRTestPage> {
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  model.OCRResult? _ocrResult;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    // OCRService dispose is optional
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _ocrResult = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Process OCR
      final ocrResult = await _ocrService.processImage(_selectedImage!);

      setState(() {
        _ocrResult = ocrResult;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR & Face Detection Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_selectedImage == null)
                      const Icon(Icons.image, size: 100, color: Colors.grey)
                    else
                      Image.file(
                        _selectedImage!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select Image'),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _processImage,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isProcessing ? 'Processing...' : 'Process Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // OCR Results
            if (_ocrResult != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.text_fields, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'OCR Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildResultRow('NIK', _ocrResult!.nik),
                      _buildResultRow('Nama', _ocrResult!.nama),
                      _buildResultRow('Tempat Lahir', _ocrResult!.tempatLahir),
                      _buildResultRow('Tanggal Lahir', _ocrResult!.tanggalLahir),
                      _buildResultRow('Alamat', _ocrResult!.alamat),
                      if (_ocrResult!.additionalFields != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Additional Fields:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ..._ocrResult!.additionalFields!.entries.map(
                          (entry) => _buildResultRow(entry.key, entry.value?.toString()),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildConfidenceBar(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar() {
    // Calculate confidence based on how many fields are filled
    final confidence = _getConfidenceScore(_ocrResult!);
    final percentage = (confidence * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence Score: $percentage%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            confidence > 0.7
                ? Colors.green
                : confidence > 0.4
                    ? Colors.orange
                    : Colors.red,
          ),
          minHeight: 10,
        ),
      ],
    );
  }

  /// Calculate confidence score based on completeness of OCR result
  double _getConfidenceScore(model.OCRResult result) {
    int score = 0;
    int total = 0;

    // Check NIK (16 digits) - 30 points
    if (result.nik != null && result.nik!.length == 16) {
      score += 30;
    }
    total += 30;

    // Check Nama - 25 points
    if (result.nama != null && result.nama!.isNotEmpty) {
      score += 25;
    }
    total += 25;

    // Check Tempat Lahir - 15 points
    if (result.tempatLahir != null && result.tempatLahir!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    // Check Tanggal Lahir - 15 points
    if (result.tanggalLahir != null && result.tanggalLahir!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    // Check Alamat - 15 points
    if (result.alamat != null && result.alamat!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    return total > 0 ? (score / total) : 0.0;
  }
}

