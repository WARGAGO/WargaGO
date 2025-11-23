// ============================================================================
// SIMPLE OCR TEST - Run directly with: flutter run lib/test_ocr_simple.dart
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'core/services/ocr_service.dart';

void main() => runApp(const OCRTestApp());

class OCRTestApp extends StatelessWidget {
  const OCRTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const OCRTestScreen(),
    );
  }
}

class OCRTestScreen extends StatefulWidget {
  const OCRTestScreen({super.key});

  @override
  State<OCRTestScreen> createState() => _OCRTestScreenState();
}

class _OCRTestScreenState extends State<OCRTestScreen> {
  final OCRService _ocrService = OCRService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  String _results = '';
  String _debugInfo = '';
  bool _isProcessing = false;
  bool _showDebug = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcess() async {
    setState(() {
      _results = '';
      _isProcessing = true;
    });

    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile == null) {
        setState(() {
          _results = 'No image selected';
          _isProcessing = false;
        });
        return;
      }

      final file = File(pickedFile.path);
      setState(() => _image = file);

      // Process OCR
      print('🔍 Starting OCR...');
      final ocrResult = await _ocrService.processImage(file);

      // Build debug info from OCR result
      final debugBuffer = StringBuffer();
      debugBuffer.writeln('=== DEBUG INFO ===\n');

      if (ocrResult != null) {
        debugBuffer.writeln('NIK Found: ${ocrResult.nik ?? "Not found"}');
        debugBuffer.writeln('NIK Length: ${ocrResult.nik?.length ?? 0}');
        debugBuffer.writeln('\nNama Found: ${ocrResult.nama ?? "Not found"}');
        debugBuffer.writeln('Nama Length: ${ocrResult.nama?.length ?? 0}');
        debugBuffer.writeln('\nTempat Lahir: ${ocrResult.tempatLahir ?? "Not found"}');
        debugBuffer.writeln('Tanggal Lahir: ${ocrResult.tanggalLahir ?? "Not found"}');
        debugBuffer.writeln('Alamat: ${ocrResult.alamat ?? "Not found"}');

        if (ocrResult.additionalFields != null && ocrResult.additionalFields!.isNotEmpty) {
          debugBuffer.writeln('\nAdditional Fields:');
          ocrResult.additionalFields!.forEach((key, value) {
            debugBuffer.writeln('- $key: $value');
          });
        }
      } else {
        debugBuffer.writeln('OCR returned null - no data extracted');
      }

      // Build results
      final buffer = StringBuffer();
      buffer.writeln('=== OCR RESULTS ===\n');

      if (ocrResult != null) {
        buffer.writeln('✅ OCR Success!');

        // Display document type if detected
        final docType = ocrResult.additionalFields?['document_type'];
        if (docType != null) {
          buffer.writeln('📄 Document Type: $docType');
        }

        buffer.writeln('NIK: ${ocrResult.nik ?? "Not found"}');
        buffer.writeln('Nama: ${ocrResult.nama ?? "Not found"}');
        buffer.writeln('Tempat Lahir: ${ocrResult.tempatLahir ?? "Not found"}');
        buffer.writeln('Tanggal Lahir: ${ocrResult.tanggalLahir ?? "Not found"}');
        buffer.writeln('Alamat: ${ocrResult.alamat ?? "Not found"}');

        final confidence = _calculateConfidence(ocrResult);
        buffer.writeln('\nConfidence: ${(confidence * 100).toStringAsFixed(1)}%');

        if (ocrResult.additionalFields != null && ocrResult.additionalFields!.isNotEmpty) {
          buffer.writeln('\nAdditional Fields:');
          ocrResult.additionalFields!.forEach((key, value) {
            if (key != 'document_type') { // Skip document_type as already shown
              buffer.writeln('- $key: $value');
            }
          });
        }
      } else {
        buffer.writeln('❌ OCR Failed - No text extracted');
      }

      setState(() {
        _results = buffer.toString();
        _debugInfo = debugBuffer.toString();
        _isProcessing = false;
      });

      // Print to console as well
      print('\n$_results');

    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _results = '❌ ERROR:\n$e';
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
            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'How to Test',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Tap button below'),
                    const Text('2. Select KTP image from gallery'),
                    const Text('3. Wait for processing'),
                    const Text('4. View results'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pick Image Button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickAndProcess,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.image),
              label: Text(_isProcessing ? 'Processing...' : 'Pick Image & Test OCR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Image Preview
            if (_image != null)
              Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Selected Image',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Image.file(
                      _image!,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Results
            if (_results.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      Text(
                        _results,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Debug Info Toggle
            if (_debugInfo.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showDebug = !_showDebug;
                  });
                },
                icon: Icon(_showDebug ? Icons.visibility_off : Icons.visibility),
                label: Text(_showDebug ? 'Hide Debug Info' : 'Show Debug Info'),
              ),
            ],

            // Debug Info
            if (_debugInfo.isNotEmpty && _showDebug)
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bug_report, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Debug Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        _debugInfo,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Calculate confidence score based on completeness
  double _calculateConfidence(dynamic result) {
    int score = 0;
    int total = 0;

    // NIK (30 points)
    if (result.nik != null && result.nik!.length == 16) {
      score += 30;
    }
    total += 30;

    // Nama (25 points)
    if (result.nama != null && result.nama!.isNotEmpty) {
      score += 25;
    }
    total += 25;

    // Tempat Lahir (15 points)
    if (result.tempatLahir != null && result.tempatLahir!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    // Tanggal Lahir (15 points)
    if (result.tanggalLahir != null && result.tanggalLahir!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    // Alamat (15 points)
    if (result.alamat != null && result.alamat!.isNotEmpty) {
      score += 15;
    }
    total += 15;

    return total > 0 ? (score / total) : 0.0;
  }
}

