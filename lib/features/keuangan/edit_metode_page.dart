// ============================================================================
// EDIT METODE PAGE (CLEAN CODE VERSION)
// ============================================================================
// Halaman edit metode pembayaran
//
// Clean Code Principles Applied:
// ✅ Fokus ke tampilan & interaksi user (logic minimal)
// ✅ StatefulWidget (perlu state untuk form & image)
// ✅ Pecah jadi widget kecil & reusable
// ✅ Pakai widget reusable dari edit_metode_widgets.dart
// ✅ Nama variabel & method yang jelas
// ✅ Responsif dengan SingleChildScrollView
// ✅ Tidak panggil API langsung (siap integrate Service)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'widgets/edit_metode_widgets.dart';
import 'widgets/keuangan_constants.dart';

/// Edit Metode Page - Halaman edit metode pembayaran
///
/// Fitur:
/// - Edit nama channel, tipe, pemilik, catatan
/// - Upload thumbnail
/// - Upload QR Code
/// - Form validation
/// - Success dialog
class EditMetodePage extends StatefulWidget {
  const EditMetodePage({super.key});

  @override
  State<EditMetodePage> createState() => _EditMetodePageState();
}

class _EditMetodePageState extends State<EditMetodePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaChannelController = TextEditingController(text: 'QRIS Resmi RT 08');
  final _tipeChannelController = TextEditingController(text: 'QRIS');
  final _namaPemilikController = TextEditingController(text: 'RW 08 Karangploso');
  final _catatanController = TextEditingController(
    text: 'Scan QR di bawah untuk membayar. Kirim bukti setelah pembayaran',
  );

  File? _thumbnailImage;
  File? _qrCodeImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaChannelController.dispose();
    _tipeChannelController.dispose();
    _namaPemilikController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  /// Handle pick thumbnail image
  Future<void> _handlePickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _thumbnailImage = File(image.path));
    }
  }

  /// Handle pick QR code image
  Future<void> _handlePickQRCode(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _qrCodeImage = File(image.path));
    }
  }

  /// Show QR picker options bottom sheet
  void _handleShowQRPicker() {
    showQRPickerBottomSheet(
      context: context,
      onCameraTap: () => _handlePickQRCode(ImageSource.camera),
      onGalleryTap: () => _handlePickQRCode(ImageSource.gallery),
    );
  }

  /// Handle save changes
  void _handleSaveChanges() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Call service to save changes
    // await MetodePembayaranService.update(
    //   namaChannel: _namaChannelController.text,
    //   tipeChannel: _tipeChannelController.text,
    //   namaPemilik: _namaPemilikController.text,
    //   catatan: _catatanController.text,
    //   thumbnail: _thumbnailImage,
    //   qrCode: _qrCodeImage,
    // );

    _showSuccessDialog();
  }

  /// Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KeuanganRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KeuanganSpacing.sm),
              decoration: BoxDecoration(
                color: KeuanganColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KeuanganRadius.sm),
              ),
              child: const Icon(
                Icons.check_circle,
                color: KeuanganColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: KeuanganSpacing.md),
            const Text('Berhasil'),
          ],
        ),
        content: const Text('Metode pembayaran berhasil diperbarui!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KeuanganColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildThumbnailSection(),
            _buildFormSection(),
          ],
        ),
      ),
    );
  }

  /// Build app bar dengan gradient
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A2F80ED),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(KeuanganSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Metode Pembayaran',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  /// Build thumbnail section
  Widget _buildThumbnailSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: MetodeThumbnailPicker(
        image: _thumbnailImage,
        onTap: _handlePickThumbnail,
      ),
    );
  }

  /// Build form section
  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8EAF2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F80ED).withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 24),
              MetodeQRCodePicker(
                image: _qrCodeImage,
                onTap: _handleShowQRPicker,
              ),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build form header
  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_document,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Informasi Metode',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F1F1F),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  /// Build form fields
  Widget _buildFormFields() {
    return Column(
      children: [
        MetodeTextField(
          controller: _namaChannelController,
          label: 'Nama Channel',
          hint: 'Masukkan nama channel',
          icon: Icons.payment_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama channel tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        MetodeTextField(
          controller: _tipeChannelController,
          label: 'Tipe Channel',
          hint: 'Masukkan tipe channel',
          icon: Icons.category_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tipe channel tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        MetodeTextField(
          controller: _namaPemilikController,
          label: 'Nama Pemilik (A/N)',
          hint: 'Masukkan nama pemilik',
          icon: Icons.person_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama pemilik tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        MetodeTextField(
          controller: _catatanController,
          label: 'Catatan',
          hint: 'Masukkan catatan',
          icon: Icons.note_alt_rounded,
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Catatan tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSaveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 22),
            const SizedBox(width: 10),
            Text(
              'Perbarui Metode',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

