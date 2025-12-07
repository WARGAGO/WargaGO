// ============================================================================
// SELLER REGISTRATION FORM PAGE
// ============================================================================
// Form lengkap untuk pendaftaran seller oleh warga
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/pending_seller_model.dart';
import '../../../../core/services/seller_service.dart';

class SellerRegistrationFormPage extends StatefulWidget {
  const SellerRegistrationFormPage({super.key});

  @override
  State<SellerRegistrationFormPage> createState() =>
      _SellerRegistrationFormPageState();
}

class _SellerRegistrationFormPageState
    extends State<SellerRegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SellerService _sellerService = SellerService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _alamatTokoController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _deskripsiUsahaController =
      TextEditingController();

  // Selected categories
  List<String> _selectedCategories = [];

  // Image files
  File? _fotoKTP;
  File? _fotoSelfieKTP;
  File? _fotoToko;

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nikController.dispose();
    _namaTokoController.dispose();
    _nomorTeleponController.dispose();
    _alamatTokoController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _deskripsiUsahaController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check apakah sudah terdaftar
      final existingSeller = await _sellerService.checkUserSellerStatus();
      if (existingSeller != null) {
        if (mounted) {
          // Handle berdasarkan status
          if (existingSeller.status == SellerVerificationStatus.rejected) {
            // Jika ditolak, izinkan daftar ulang dengan menampilkan alasan penolakan
            _showRejectedCanRetryDialog(existingSeller);
            // Tetap load data untuk form
            await _loadWargaData(user.uid);
          } else if (existingSeller.status == SellerVerificationStatus.approved) {
            // Jika sudah disetujui, redirect ke halaman seller
            _redirectToSellerPage();
            return;
          } else {
            // Pending atau suspended, tampilkan dialog status
            _showAlreadyRegisteredDialog(existingSeller);
            return;
          }
        }
      } else {
        // Belum terdaftar, load data warga
        await _loadWargaData(user.uid);
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _loadWargaData(String userId) async {
    final wargaDoc =
        await FirebaseFirestore.instance.collection('warga').doc(userId).get();

    if (wargaDoc.exists) {
      final data = wargaDoc.data();
      setState(() {
        _namaLengkapController.text = data?['name'] ?? '';
        _nikController.text = data?['nik'] ?? '';
        _nomorTeleponController.text = data?['phone'] ?? '';
        _alamatTokoController.text = data?['alamat'] ?? '';
        _rtController.text = data?['rt'] ?? '';
        _rwController.text = data?['rw'] ?? '';
      });
    }
  }

  void _showAlreadyRegisteredDialog(PendingSellerModel seller) {
    String statusMessage = '';
    Color statusColor = Colors.orange;

    switch (seller.status) {
      case SellerVerificationStatus.pending:
        statusMessage =
            'Pendaftaran Anda sedang diproses oleh admin. Harap tunggu konfirmasi.';
        statusColor = Colors.orange;
        break;
      case SellerVerificationStatus.approved:
        statusMessage =
            'Selamat! Anda sudah terdaftar sebagai seller dan dapat mulai berjualan.';
        statusColor = Colors.green;
        break;
      case SellerVerificationStatus.rejected:
        statusMessage =
            'Pendaftaran Anda ditolak. Alasan: ${seller.alasanPenolakan ?? "Tidak disebutkan"}';
        statusColor = Colors.red;
        break;
      case SellerVerificationStatus.suspended:
        statusMessage =
            'Akun seller Anda telah disuspend. Hubungi admin untuk informasi lebih lanjut.';
        statusColor = Colors.grey;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Status Pendaftaran',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          statusMessage,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog terlebih dahulu
              Navigator.of(context).pop();
              // Gunakan go_router untuk kembali dengan aman
              if (context.canPop()) {
                context.pop();
              } else {
                // Jika tidak bisa pop, redirect ke profile
                context.go('/warga/profile');
              }
            },
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectedCanRetryDialog(PendingSellerModel seller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            Text(
              'Pendaftaran Ditolak',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendaftaran seller Anda sebelumnya ditolak.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alasan Penolakan:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seller.alasanPenolakan ?? 'Tidak disebutkan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF7F1D1D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Anda dapat mendaftar ulang dengan memperbaiki data sesuai alasan penolakan di atas.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/warga/profile');
              }
            },
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Tetap di halaman form untuk daftar ulang
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F80ED),
            ),
            child: Text(
              'Daftar Ulang',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _redirectToSellerPage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.store, color: Color(0xFF10B981), size: 28),
            const SizedBox(width: 12),
            Text(
              'Sudah Terdaftar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'Anda sudah terdaftar sebagai seller dan dapat mulai berjualan.\n\nAnda akan diarahkan ke halaman seller.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Redirect ke halaman marketplace/seller dashboard
              context.go('/warga/marketplace');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: Text(
              'Ke Halaman Seller',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'ktp':
              _fotoKTP = File(image.path);
              break;
            case 'selfie':
              _fotoSelfieKTP = File(image.path);
              break;
            case 'toko':
              _fotoToko = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      _showErrorSnackBar('Pilih minimal 1 kategori produk');
      return;
    }

    if (_fotoKTP == null) {
      _showErrorSnackBar('Foto KTP harus diupload');
      return;
    }

    if (_fotoSelfieKTP == null) {
      _showErrorSnackBar('Foto Selfie dengan KTP harus diupload');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User tidak terautentikasi');

      print('🚀 Starting seller registration...');

      // Submit registration using SellerService
      final docId = await _sellerService.submitSellerRegistration(
        namaLengkap: _namaLengkapController.text.trim(),
        nik: _nikController.text.trim(),
        namaToko: _namaTokoController.text.trim(),
        nomorTelepon: _nomorTeleponController.text.trim(),
        alamatToko: _alamatTokoController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
        deskripsiUsaha: _deskripsiUsahaController.text.trim(),
        kategoriProduk: _selectedCategories,
        fotoKTP: _fotoKTP!,
        fotoSelfieKTP: _fotoSelfieKTP!,
        fotoToko: _fotoToko,
      );

      if (docId != null) {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        throw Exception('Gagal menyimpan pendaftaran');
      }
    } catch (e) {
      print('❌ Error submitting registration: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan: ';

        if (e.toString().contains('PCVK API')) {
          errorMessage = 'Gagal menghubungi server. Pastikan:\n'
              '1. PCVK API sudah berjalan\n'
              '2. Koneksi internet aktif\n'
              '3. IP/URL PCVK benar di .env';
        } else if (e.toString().contains('upload')) {
          errorMessage = 'Gagal upload foto. Coba lagi atau periksa koneksi internet.';
        } else if (e.toString().contains('database') || e.toString().contains('Firestore')) {
          errorMessage = 'Gagal menyimpan data. Coba lagi nanti.';
        } else {
          errorMessage = e.toString();
        }

        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF10B981), size: 32),
            const SizedBox(width: 12),
            Text(
              'Berhasil!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'Pendaftaran Anda telah dikirim dan sedang menunggu verifikasi dari admin. Kami akan menghubungi Anda melalui nomor telepon yang terdaftar.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Close dialog terlebih dahulu
              Navigator.of(context).pop();
              // Gunakan go_router untuk kembali dengan aman
              if (context.canPop()) {
                context.pop();
              } else {
                // Jika tidak bisa pop, redirect ke profile
                context.go('/warga/profile');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2F80ED)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Daftar Sebagai Penjual',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 20),
                  _buildStoreInfoSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                  const SizedBox(height: 20),
                  _buildDocumentSection(),
                  const SizedBox(height: 20),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Mengirim pendaftaran...',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9), Color(0xFF1557B0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Lengkapi form berikut untuk mendaftar sebagai penjual di marketplace warga',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Data Diri',
      Icons.person_rounded,
      [
        TextFormField(
          controller: _namaLengkapController,
          decoration: _inputDecoration('Nama Lengkap', Icons.person_rounded),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Nama lengkap harus diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nikController,
          decoration: _inputDecoration('NIK', Icons.badge_rounded),
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'NIK harus diisi';
            if (value!.length != 16) return 'NIK harus 16 digit';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nomorTeleponController,
          decoration: _inputDecoration('Nomor Telepon', Icons.phone_rounded),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Nomor telepon harus diisi' : null,
        ),
      ],
    );
  }

  Widget _buildStoreInfoSection() {
    return _buildSection(
      'Informasi Toko',
      Icons.store_rounded,
      [
        TextFormField(
          controller: _namaTokoController,
          decoration: _inputDecoration('Nama Toko/Lapak', Icons.store_rounded),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Nama toko harus diisi' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _alamatTokoController,
          decoration:
              _inputDecoration('Alamat Toko', Icons.location_on_rounded),
          maxLines: 2,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Alamat toko harus diisi' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _rtController,
                decoration: _inputDecoration('RT', Icons.home_rounded),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'RT harus diisi' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _rwController,
                decoration: _inputDecoration('RW', Icons.home_rounded),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'RW harus diisi' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _deskripsiUsahaController,
          decoration: _inputDecoration(
            'Deskripsi Usaha',
            Icons.description_rounded,
          ),
          maxLines: 4,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Deskripsi usaha harus diisi' : null,
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final categories = ProductCategoryHelper.getCategoriesWithLabels();

    return _buildSection(
      'Kategori Produk',
      Icons.category_rounded,
      [
        Text(
          'Pilih kategori produk yang akan Anda jual:',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected =
                _selectedCategories.contains(cat['value'] ?? '');
            return FilterChip(
              label: Text(cat['label'] ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(cat['value'] ?? '');
                  } else {
                    _selectedCategories.remove(cat['value']);
                  }
                });
              },
              selectedColor: const Color(0xFF2F80ED).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF2F80ED),
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: isSelected
                    ? const Color(0xFF2F80ED)
                    : const Color(0xFF6B7280),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentSection() {
    return _buildSection(
      'Dokumen Verifikasi',
      Icons.document_scanner_rounded,
      [
        _buildImagePicker(
          'Foto KTP *',
          'Upload foto KTP yang jelas dan dapat dibaca',
          _fotoKTP,
          'ktp',
          true,
        ),
        const SizedBox(height: 16),
        _buildImagePicker(
          'Foto Selfie dengan KTP *',
          'Upload foto selfie Anda memegang KTP',
          _fotoSelfieKTP,
          'selfie',
          true,
        ),
        const SizedBox(height: 16),
        _buildImagePicker(
          'Foto Toko (Opsional)',
          'Upload foto toko/tempat usaha Anda',
          _fotoToko,
          'toko',
          false,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImagePicker(String title, String subtitle, File? imageFile,
      String type, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 12),
        if (imageFile != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      switch (type) {
                        case 'ktp':
                          _fotoKTP = null;
                          break;
                        case 'selfie':
                          _fotoSelfieKTP = null;
                          break;
                        case 'toko':
                          _fotoToko = null;
                          break;
                      }
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera, type),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Kamera'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery, type),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Galeri'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9), Color(0xFF1557B0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRegistration,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_rounded, size: 22),
            const SizedBox(width: 12),
            Text(
              'Kirim Pendaftaran',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2F80ED)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
      ),
    );
  }
}

