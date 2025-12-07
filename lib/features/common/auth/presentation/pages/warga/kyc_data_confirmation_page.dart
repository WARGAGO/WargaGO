// ============================================================================
// KYC DATA CONFIRMATION PAGE
// ============================================================================
// Halaman untuk konfirmasi dan edit data hasil OCR KTP
// User dapat memverifikasi dan memperbaiki data sebelum submit
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:wargago/core/models/KYC/ktp_model.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_constants.dart';
import 'package:wargago/features/common/auth/presentation/widgets/auth_widgets.dart';

class KYCDataConfirmationPage extends StatefulWidget {
  final KTPModel ktpData;
  final Function(KTPModel updatedData) onConfirm;
  final VoidCallback onRetake;

  const KYCDataConfirmationPage({
    super.key,
    required this.ktpData,
    required this.onConfirm,
    required this.onRetake,
  });

  @override
  State<KYCDataConfirmationPage> createState() =>
      _KYCDataConfirmationPageState();
}

class _KYCDataConfirmationPageState extends State<KYCDataConfirmationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nikController;
  late TextEditingController _namaController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _alamatController;
  late TextEditingController _jenisKelaminController;
  late TextEditingController _agamaController;
  late TextEditingController _pekerjaanController;
  late TextEditingController _statusPerkawinanController;
  late TextEditingController _kewarganegaraanController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController(text: widget.ktpData.nik ?? '');
    _namaController = TextEditingController(text: widget.ktpData.nama ?? '');
    _tempatLahirController =
        TextEditingController(text: widget.ktpData.tempatLahir ?? '');
    _tanggalLahirController =
        TextEditingController(text: widget.ktpData.tanggalLahir ?? '');
    _alamatController = TextEditingController(text: widget.ktpData.alamat ?? '');
    _jenisKelaminController =
        TextEditingController(text: widget.ktpData.jenisKelamin ?? '');
    _agamaController = TextEditingController(text: widget.ktpData.agama ?? '');
    _pekerjaanController =
        TextEditingController(text: widget.ktpData.pekerjaan ?? '');
    _statusPerkawinanController =
        TextEditingController(text: widget.ktpData.statusPerkawinan ?? '');
    _kewarganegaraanController =
        TextEditingController(text: widget.ktpData.kewarganegaraan ?? '');
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _alamatController.dispose();
    _jenisKelaminController.dispose();
    _agamaController.dispose();
    _pekerjaanController.dispose();
    _statusPerkawinanController.dispose();
    _kewarganegaraanController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      widget.onConfirm(updatedKTPData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuthSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AuthSpacing.xl),
                _buildInfoCard(),
                const SizedBox(height: AuthSpacing.xl),
                _buildDataFields(),
                const SizedBox(height: AuthSpacing.xxl),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AuthColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Konfirmasi Data KTP',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: AuthSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KTP Berhasil Di-scan!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AuthColors.primary,
                    ),
                  ),
                  Text(
                    'Periksa dan perbaiki data jika diperlukan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AuthColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AuthSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(AuthSpacing.md),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: AuthSpacing.md),
          Expanded(
            child: Text(
              'Data ini hasil scan otomatis dari KTP Anda. Mohon periksa kembali dan perbaiki jika ada yang tidak sesuai.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nikController,
          label: 'NIK',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _namaController,
          label: 'Nama Lengkap',
          icon: Icons.person,
        ),
        const SizedBox(height: AuthSpacing.lg),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _tempatLahirController,
                label: 'Tempat Lahir',
                icon: Icons.location_on,
              ),
            ),
            const SizedBox(width: AuthSpacing.md),
            Expanded(
              flex: 1,
              child: _buildTextField(
                controller: _tanggalLahirController,
                label: 'Tanggal Lahir',
                icon: Icons.calendar_today,
                hint: 'DD-MM-YYYY',
              ),
            ),
          ],
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _alamatController,
          label: 'Alamat',
          icon: Icons.home,
          maxLines: 3,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _jenisKelaminController,
          label: 'Jenis Kelamin',
          icon: Icons.wc,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _agamaController,
          label: 'Agama',
          icon: Icons.church,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _pekerjaanController,
          label: 'Pekerjaan',
          icon: Icons.work,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _statusPerkawinanController,
          label: 'Status Perkawinan',
          icon: Icons.favorite,
        ),
        const SizedBox(height: AuthSpacing.lg),
        _buildTextField(
          controller: _kewarganegaraanController,
          label: 'Kewarganegaraan',
          icon: Icons.flag,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuthColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AuthColors.textSecondary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        if (label == 'NIK' && value.length != 16) {
          return 'NIK harus 16 digit';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Confirm Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AuthColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Konfirmasi & Lanjutkan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AuthSpacing.md),
        // Retake Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: _isLoading ? null : widget.onRetake,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AuthColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 20, color: AuthColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Foto Ulang KTP',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AuthColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  KTPModel get updatedKTPData => KTPModel(
        nik: _nikController.text,
        nama: _namaController.text,
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _tanggalLahirController.text,
        alamat: _alamatController.text,
        jenisKelamin: _jenisKelaminController.text,
        agama: _agamaController.text,
        pekerjaan: _pekerjaanController.text,
        statusPerkawinan: _statusPerkawinanController.text,
        kewarganegaraan: _kewarganegaraanController.text,
      );
}

