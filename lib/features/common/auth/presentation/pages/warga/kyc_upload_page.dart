// ============================================================================
// KYC UPLOAD PAGE
// ============================================================================
// Halaman untuk upload dokumen verifikasi KYC
// Warga bisa upload KTP, KK, atau Akte Kelahiran (opsional)
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jawara/core/models/kyc_document_model.dart';
import 'package:jawara/core/providers/auth_provider.dart';
import 'package:jawara/core/services/kyc_service.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_constants.dart';
import 'package:jawara/features/common/auth/presentation/widgets/auth_widgets.dart';
import 'package:jawara/features/warga/dashboard/warga_dashboard_page.dart';

class KYCUploadPage extends StatefulWidget {
  const KYCUploadPage({super.key});

  @override
  State<KYCUploadPage> createState() => _KYCUploadPageState();
}

class _KYCUploadPageState extends State<KYCUploadPage> {
  final KYCService _kycService = KYCService();
  final ImagePicker _picker = ImagePicker();

  File? _ktpFile;
  File? _kkFile;
  File? _akteFile;

  bool _isUploading = false;

  /// Pick image from gallery or camera
  Future<File?> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (mounted) {
        AuthDialogs.showError(
          context,
          'Error',
          'Gagal memilih gambar: $e',
        );
      }
      return null;
    }
  }

  /// Upload KTP
  Future<void> _uploadKTP() async {
    final file = await _pickImage();
    if (file != null) {
      setState(() => _ktpFile = file);
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id;

    if (userId == null) {
      AuthDialogs.showError(context, 'Error', 'User tidak ditemukan');
      return;
    }

    // Check if at least one document is selected
    if (_ktpFile == null && _kkFile == null && _akteFile == null) {
      AuthDialogs.showError(
        context,
        'Dokumen Belum Dipilih',
        'Silakan upload minimal satu dokumen untuk verifikasi',
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload KTP if selected
      if (_ktpFile != null) {
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
        buttonText: 'Lanjutkan',
        onPressed: () {
          Navigator.pop(context); // Close dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WargaDashboardPage()),
          );
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WargaDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onRemove: () => setState(() => _ktpFile = null),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Dokumen',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AuthColors.primary,
          ),
        ),
        const SizedBox(height: AuthSpacing.sm),
        Text(
          'Upload dokumen identitas Anda untuk mendapatkan akses penuh ke aplikasi',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AuthColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Build info card
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AuthSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AuthSpacing.md),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: AuthSpacing.md),
          Expanded(
            child: Text(
              'Upload minimal 1 dokumen. Proses verifikasi memakan waktu 1-3 hari kerja.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build document upload card
  Widget _buildDocumentCard({
    required String title,
    required String description,
    required File? file,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(AuthSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AuthSpacing.md),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AuthSpacing.xs),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AuthColors.textTertiary,
            ),
          ),
          const SizedBox(height: AuthSpacing.md),
          if (file == null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Pilih File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AuthColors.primary),
                  foregroundColor: AuthColors.primary,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AuthSpacing.sm),
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AuthSpacing.md),
                Column(
                  children: [
                    IconButton(
                      onPressed: onUpload,
                      icon: const Icon(Icons.edit),
                      color: AuthColors.primary,
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
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

