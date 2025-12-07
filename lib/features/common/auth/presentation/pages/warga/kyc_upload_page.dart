// ============================================================================
// KYC UPLOAD PAGE
// ============================================================================
// Halaman untuk upload dokumen verifikasi KYC
// Warga bisa upload KTP, KK, atau Akte Kelahiran (opsional)
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wargago/core/enums/kyc_enum.dart';
import 'package:provider/provider.dart';
import 'package:wargago/core/constants/app_routes.dart';
import 'package:wargago/core/providers/auth_provider.dart';
import 'package:wargago/core/services/kyc_service.dart';
import 'package:wargago/core/services/ocr_service.dart';
import 'package:wargago/core/models/KYC/ktp_model.dart';
import 'package:wargago/features/common/auth/presentation/pages/warga/kyc_data_confirmation_page.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_widgets.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_constants.dart';

class KYCUploadPage extends StatefulWidget {
  const KYCUploadPage({super.key});

  @override
  State<KYCUploadPage> createState() => _KYCUploadPageState();
}

class _KYCUploadPageState extends State<KYCUploadPage> {
  final KYCService _kycService = KYCService();
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();

  File? _ktpFile;
  File? _kkFile;
  File? _akteFile;
  KTPModel? _ktpData; // Store OCR result

  bool _isUploading = false;
  bool _isProcessingOCR = false;

  @override
  void initState() {
    super.initState();
  }

  Future<File?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (mounted) {
        AuthDialogs.showError(context, 'Error', 'Gagal memilih gambar: $e');
      }
      return null;
    }
  }

  /// Upload KTP - with OCR processing and confirmation
  Future<void> _uploadKTP() async {
    final file = await _pickImage();
    if (file == null) return;

    setState(() {
      _isProcessingOCR = true;
    });

    try {
      // Perform OCR on KTP
      final ocrResponse = await _ocrService.recognizeText(file);
      final ocrResults = ocrResponse.results;

      if (ocrResults.length < 3) {
        if (mounted) {
          AuthDialogs.showError(
            context,
            'OCR Gagal',
            'Tidak dapat membaca KTP. Pastikan foto jelas dan tidak blur.',
          );
        }
        setState(() => _isProcessingOCR = false);
        return;
      }

      // Extract KTP data from OCR
      final ktpData = KTPModel.fromOCR(ocrResults);

      // Show confirmation page
      if (mounted) {
        final result = await Navigator.of(context).push<KTPModel>(
          MaterialPageRoute(
            builder: (context) => KYCDataConfirmationPage(
              ktpData: ktpData,
              onConfirm: (updatedData) {
                Navigator.of(context).pop(updatedData);
              },
              onRetake: () {
                Navigator.of(context).pop();
                _uploadKTP(); // Retry
              },
            ),
          ),
        );

        // If user confirmed (returned KTPModel data)
        if (result != null) {
          setState(() {
            _ktpFile = file;
            _ktpData = result; // Use the updated data from confirmation page
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AuthDialogs.showError(
          context,
          'Error',
          'Gagal memproses KTP: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingOCR = false);
      }
    }
  }

  /// Upload KK
  Future<void> _uploadKK() async {
    final file = await _pickImage();
    if (file != null) {
      setState(() => _kkFile = file);
    }
  }

  /// Upload Akte
  Future<void> _uploadAkte() async {
    final file = await _pickImage();
    if (file != null) {
      setState(() => _akteFile = file);
    }
  }

  /// Submit all documents
  Future<void> _submitDocuments() async {
    // Validate at least KTP is uploaded
    if (_ktpFile == null) {
      AuthDialogs.showError(
        context,
        'Dokumen Belum Lengkap',
        'Mohon upload KTP terlebih dahulu.',
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userModel?.id;

      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      // Upload KTP if selected (dengan data yang sudah dikonfirmasi)
      if (_ktpFile != null && _ktpData != null) {
        // Upload KTP with confirmed data
        await _kycService.uploadDocumentWithData(
          userId: userId,
          documentType: KYCDocumentType.ktp,
          file: _ktpFile!,
          ktpData: _ktpData,
        );
      } else if (_ktpFile != null) {
        // Fallback: upload without confirmed data (shouldn't happen with new flow)
        await _kycService.uploadDocument(
          userId: userId,
          documentType: KYCDocumentType.ktp,
          file: _ktpFile!,
        );
      }

      // Upload KK if selected
      if (_kkFile != null) {
        await _kycService.uploadDocument(
          userId: userId,
          documentType: KYCDocumentType.kk,
          file: _kkFile!,
        );
      }

      // Upload Akte if selected
      if (_akteFile != null) {
        await _kycService.uploadDocument(
          userId: userId,
          documentType: KYCDocumentType.akteKelahiran,
          file: _akteFile!,
        );
      }

      if (!mounted) return;

      // Show success and navigate to dashboard
      AuthDialogs.showSuccess(
        context,
        'Upload Berhasil',
        'Dokumen Anda berhasil diupload. Admin akan memverifikasi dokumen Anda dalam 1-3 hari kerja.',
        buttonText: 'Ke Dashboard',
        onPressed: () {
          context.pop(); // Close dialog
          context.go(AppRoutes.wargaDashboard);
        },
      );
    } catch (e) {
      if (mounted) {
        AuthDialogs.showError(
          context,
          'Upload Gagal',
          'Terjadi kesalahan saat mengupload dokumen: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  /// Skip KYC for now
  void _skipKYC() {
    context.go(AppRoutes.wargaDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _kycService.initializationDone,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Stack(
              children: [
                Scaffold(
                  backgroundColor: AuthColors.background,
                  appBar: _buildAppBar(),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AuthSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: AuthSpacing.xxl),
                          _buildInfoCard(),
                          const SizedBox(height: AuthSpacing.xl),
                          _buildDocumentCard(
                            title: 'KTP (Kartu Tanda Penduduk)',
                            description: 'Upload foto KTP Anda',
                            file: _ktpFile,
                            onUpload: _uploadKTP,
                            onRemove: () => setState(() {
                              _ktpFile = null;
                              _ktpData = null;
                            }),
                            hasOCRData: _ktpData != null,
                          ),
                          const SizedBox(height: AuthSpacing.lg),
                          _buildDocumentCard(
                            title: 'Kartu Keluarga (Opsional)',
                            description: 'Upload foto Kartu Keluarga',
                            file: _kkFile,
                            onUpload: _uploadKK,
                            onRemove: () => setState(() => _kkFile = null),
                          ),
                          const SizedBox(height: AuthSpacing.lg),
                          _buildDocumentCard(
                            title: 'Akte Kelahiran (Opsional)',
                            description: 'Upload foto Akte Kelahiran',
                            file: _akteFile,
                            onUpload: _uploadAkte,
                            onRemove: () => setState(() => _akteFile = null),
                          ),
                          const SizedBox(height: AuthSpacing.xxl),
                          _buildSubmitButton(),
                          const SizedBox(height: AuthSpacing.md),
                          _buildSkipButton(),
                        ],
                      ),
                    ),
                  ),
                ),
                // OCR Processing Overlay
                if (_isProcessingOCR)
                  Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AuthColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Memproses KTP...',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Mohon tunggu, kami sedang membaca\ndata KTP Anda menggunakan teknologi OCR',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Proses ini memakan waktu 5-10 detik',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AuthColors.background,
      elevation: 0,
      title: Text(
        'Verifikasi KYC',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AuthColors.primary,
            AuthColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AuthColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifikasi KYC',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload dokumen untuk verifikasi identitas',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info card
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade600.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pastikan foto dokumen jelas dan tidak blur untuk proses verifikasi yang lebih cepat.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build document card
  Widget _buildDocumentCard({
    required String title,
    required String description,
    File? file,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
    bool hasOCRData = false,
  }) {
    final bool isKTP = title.contains('KTP');
    final bool isRequired = !title.contains('Opsional');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: file != null
              ? Colors.green.shade300
              : isRequired
                  ? AuthColors.primary.withValues(alpha: 0.3)
                  : AuthColors.border,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: file != null
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: file != null
                  ? Colors.green.shade50
                  : isRequired
                      ? AuthColors.primary.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: file != null
                        ? Colors.green.shade100
                        : isRequired
                            ? AuthColors.primary.withValues(alpha: 0.1)
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isKTP
                        ? Icons.badge
                        : title.contains('Keluarga')
                            ? Icons.family_restroom
                            : Icons.description,
                    color: file != null
                        ? Colors.green.shade700
                        : isRequired
                            ? AuthColors.primary
                            : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                          if (isRequired)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Wajib',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasOCRData) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Data KTP berhasil dibaca dan tersimpan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (file == null)
                  InkWell(
                    onTap: onUpload,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AuthColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AuthColors.primary,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            color: AuthColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Pilih File',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AuthColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Image Preview
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onUpload,
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(
                                'Ganti',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: AuthColors.primary, width: 2),
                                foregroundColor: AuthColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onRemove,
                              icon: const Icon(Icons.delete, size: 18),
                              label: Text(
                                'Hapus',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Colors.red, width: 2),
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return AuthPrimaryButton(
      text: 'Submit Dokumen',
      onPressed: _isUploading ? null : _submitDocuments,
      isLoading: _isUploading,
    );
  }

  /// Build skip button
  Widget _buildSkipButton() {
    return Center(
      child: TextButton(
        onPressed: _skipKYC,
        child: Text(
          'Lewati untuk sekarang',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AuthColors.textTertiary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

