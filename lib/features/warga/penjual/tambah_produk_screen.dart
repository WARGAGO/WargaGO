// ============================================================================
// TAMBAH PRODUK SCREEN - Modern & Professional
// ============================================================================
// Modern product form dengan image picker, validation, dan blue theme
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:wargago/core/models/product_model.dart';
import 'package:wargago/core/services/product_service.dart';
import 'package:wargago/core/services/azure_blob_storage_service.dart';
import 'package:wargago/core/providers/auth_provider.dart';

class TambahProdukScreen extends StatefulWidget {
  const TambahProdukScreen({super.key});

  @override
  State<TambahProdukScreen> createState() => _TambahProdukScreenState();
}

class _TambahProdukScreenState extends State<TambahProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _beratController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<File> _productImages = [];
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Sayuran Daun',        // Bayam, Kangkung, Sawi, Selada, Kol
    'Sayuran Akar',        // Wortel, Lobak, Bit
    'Sayuran Buah',        // Tomat, Terong, Cabai, Mentimun
    'Sayuran Polong',      // Kacang Panjang, Buncis, Kapri
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    _beratController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (image != null) {
        setState(() {
          _productImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Pilih Sumber Gambar',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF2F80ED),
                ),
              ),
              title: Text(
                'Kamera',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF2F80ED),
                ),
              ),
              title: Text(
                'Galeri',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_productImages.isEmpty) {
      _showErrorSnackbar('Minimal tambahkan 1 foto produk');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackbar('Pilih kategori produk');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user info
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      final firebaseToken = await currentUser.getIdToken();
      if (firebaseToken == null) {
        throw Exception('Token tidak valid. Silakan login kembali.');
      }

      // Initialize services
      final azureService = AzureBlobStorageService(firebaseToken: firebaseToken);
      final productService = ProductService();

      // Upload images to Azure Storage (max 3 images)
      final uploadedImageUrls = <String>[];
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < _productImages.length && i < 3; i++) {
        try {
          final fileName = 'product_${currentUser.uid}_${timestamp}_$i.jpg';
          final response = await azureService.uploadImage(
            file: _productImages[i],
            isPrivate: false, // Public untuk produk
            prefixName: 'products/', // Add trailing slash
            customFileName: fileName,
          );

          if (response != null) {
            // TEMPORARY: Keep SAS token until container is set to public
            // TODO: After setting container public, use removeSasToken()
            uploadedImageUrls.add(response.blobUrl);
            print('✅ Image ${i + 1} uploaded: ${response.blobUrl}');
          }
        } catch (e) {
          print('❌ Error uploading image ${i + 1}: $e');
          // Continue dengan gambar yang sudah berhasil diupload
        }
      }

      if (uploadedImageUrls.isEmpty) {
        throw Exception('Gagal mengupload gambar. Silakan coba lagi.');
      }

      // Parse berat (default 0 jika tidak diisi)
      double berat = 0.0;
      if (_beratController.text.isNotEmpty) {
        berat = double.tryParse(_beratController.text) ?? 0.0;
        // Convert gram to kg
        berat = berat / 1000;
      }

      // Create product model
      final product = ProductModel(
        id: '', // Will be set by Firestore
        sellerId: currentUser.uid,
        sellerName: authProvider.userModel?.nama ?? 'Penjual',
        nama: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        harga: double.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
        berat: berat,
        kategori: _selectedCategory!,
        imageUrls: uploadedImageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        terjual: 0,
      );

      // Save to Firestore
      final productId = await productService.createProduct(product);

      if (productId == null) {
        throw Exception('Gagal menyimpan produk ke database.');
      }

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessSnackbar('Produk berhasil ditambahkan!');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        _showErrorSnackbar('Gagal menambahkan produk: ${e.toString()}');
      }

      print('❌ Error in _submitForm: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Image Upload Section
                  _buildImageSection(),

                  const SizedBox(height: 24),

                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Informasi Produk'),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _namaController,
                          label: 'Nama Produk',
                          hint: 'Contoh: Wortel Fresh',
                          icon: Icons.shopping_bag,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama produk harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCategorySelector(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _deskripsiController,
                          label: 'Deskripsi Produk',
                          hint: 'Jelaskan produk Anda...',
                          icon: Icons.description,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi harus diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Harga & Stok'),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _hargaController,
                                label: 'Harga',
                                hint: '0',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                prefix: Text(
                                  'Rp ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harga harus diisi';
                                  }
                                  if (int.parse(value) <= 0) {
                                    return 'Harga harus lebih dari 0';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _stokController,
                                label: 'Stok',
                                hint: '0',
                                icon: Icons.inventory_2,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                suffix: Text(
                                  'pcs',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Stok harus diisi';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _beratController,
                          label: 'Berat (opsional)',
                          hint: '0',
                          icon: Icons.scale,
                          keyboardType: TextInputType.number,
                          suffix: Text(
                            'gram',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // App Bar dengan gradient biru
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2F80ED),
                Color(0xFF1E6FD9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
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
                              'Tambah Produk',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Isi informasi produk dengan lengkap',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Image Upload Section
  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Foto Produk'),
          const SizedBox(height: 4),
          Text(
            'Tambahkan minimal 1 foto produk (Maks. 3 foto untuk upload optimal)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),

          // Add Image Button - Full Width Horizontal
          GestureDetector(
            onTap: _productImages.length < 3 ? _showImageSourceDialog : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2F80ED).withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: _productImages.length < 3
                        ? const Color(0xFF2F80ED)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _productImages.length < 3
                          ? 'Tap untuk menambah foto produk (${_productImages.length}/3)'
                          : 'Maksimal 3 foto sudah tercapai',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _productImages.length < 3
                            ? const Color(0xFF2F80ED)
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Uploaded Images Preview - Grid
          if (_productImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _productImages.length,
              itemBuilder: (context, index) {
                final image = _productImages[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Utama',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  // Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2F80ED)),
        prefix: prefix,
        suffix: suffix,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF6B7280),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF2F80ED),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFEF4444),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  // Category Selector
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.category,
            color: Color(0xFF2F80ED),
          ),
          labelText: 'Kategori',
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF1F2937),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF2F80ED),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Pilih kategori produk';
          }
          return null;
        },
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF1E6FD9)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitForm,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Simpan Produk',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
